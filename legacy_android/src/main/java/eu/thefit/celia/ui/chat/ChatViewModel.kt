package eu.thefit.celia.ui.chat

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import eu.thefit.celia.data.model.Message
import eu.thefit.celia.data.repository.ChatRepository
import eu.thefit.celia.data.repository.ChatHistoryRepository
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject
import java.util.UUID
import java.time.OffsetDateTime
import java.time.format.DateTimeFormatter

// Represent a saved conversation that can be loaded from history
data class SavedConversation(
    val id: String, // Unique ID for the conversation
    val title: String, // Title given by the user or auto-generated
    val timestamp: String, // When it was saved
    val messages: List<Message>, // The conversation messages
    val userKey: String, // User key for this conversation
    val conversationId: String // Conversation ID from the server
)

data class ChatUiState(
    val messages: List<Message> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val userKey: String? = null,
    val conversationId: String? = null,
    val status: String = "",
    val inputText: String = "",
    val savedConversations: List<SavedConversation> = emptyList(),
    val showHistoryDialog: Boolean = false,
    val saveDialogOpen: Boolean = false,
    val saveConversationTitle: String = ""
)

@HiltViewModel
class ChatViewModel @Inject constructor(
    private val repository: ChatRepository,
    private val chatHistoryRepository: ChatHistoryRepository
) : ViewModel() {

    private var _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()

    private var userKey: String? = null
    private var conversationId: String? = null
    private var job: Job? = null

    init {
        createUserAndConversation()
        // Load saved conversations from Firestore
        loadSavedConversations()
    }

    // Show the save conversation dialog
    fun showSaveConversationDialog() {
        val defaultTitle = generateDefaultConversationTitle()
        _uiState.value = _uiState.value.copy(
            saveDialogOpen = true,
            saveConversationTitle = defaultTitle
        )
    }

    // Generate a default title based on the first message or date
    private fun generateDefaultConversationTitle(): String {
        val messages = _uiState.value.messages
        if (messages.isEmpty()) {
            return "Conversation ${getFormattedDate()}"
        }
        
        // Try to extract a title from the first user message
        val firstUserMessage = messages.firstOrNull { it.userId.contains("user_") }
        val text = firstUserMessage?.text ?: ""
        return if (text.isNotBlank()) {
            // Use first 20 chars of message as title, or less if shorter
            val titleText = if (text.length > 20) text.substring(0, 20) + "..." else text
            titleText
        } else {
            "Conversation ${getFormattedDate()}"
        }
    }
    
    private fun getFormattedDate(): String {
        val formatter = DateTimeFormatter.ofPattern("MMM d, yyyy HH:mm")
        return OffsetDateTime.now().format(formatter)
    }

    // Close the save dialog
    fun dismissSaveDialog() {
        _uiState.value = _uiState.value.copy(saveDialogOpen = false)
    }

    // Update the title in the save dialog
    fun updateSaveTitle(title: String) {
        _uiState.value = _uiState.value.copy(saveConversationTitle = title)
    }

    // Save the current conversation
    fun saveCurrentConversation() {
        val currentMessages = _uiState.value.messages
        val currentUserKey = userKey
        val currentConversationId = conversationId
        val title = _uiState.value.saveConversationTitle.ifBlank { generateDefaultConversationTitle() }
        
        if (currentMessages.isEmpty() || currentUserKey == null || currentConversationId == null) {
            _uiState.value = _uiState.value.copy(
                saveDialogOpen = false,
                status = "Cannot save an empty conversation"
            )
            return
        }
        
        val savedConversation = SavedConversation(
            id = UUID.randomUUID().toString(),
            title = title,
            timestamp = getFormattedDate(),
            messages = ArrayList(currentMessages), // Create a copy of the messages
            userKey = currentUserKey,
            conversationId = currentConversationId
        )
        
        // Save to both local state and Firestore
        viewModelScope.launch {
            // First update the UI to show immediate feedback
            val updatedHistory = _uiState.value.savedConversations + savedConversation
            _uiState.value = _uiState.value.copy(
                savedConversations = updatedHistory,
                saveDialogOpen = false,
                status = "Saving conversation..."
            )
            
            // Then save to Firestore
            chatHistoryRepository.saveConversation(savedConversation)
                .fold(
                    onSuccess = { _ ->
                        _uiState.value = _uiState.value.copy(
                            status = "Conversation saved to cloud"
                        )
                    },
                    onFailure = { error ->
                        _uiState.value = _uiState.value.copy(
                            status = "Error saving conversation: ${error.message}"
                        )
                    }
                )
        }
    }

    // Show the history dialog
    fun showHistoryDialog() {
        // Load conversations from Firestore when showing dialog
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                showHistoryDialog = true,
                status = "Loading conversations..."
            )
            
            chatHistoryRepository.getConversations()
                .fold(
                    onSuccess = { conversations ->
                        _uiState.value = _uiState.value.copy(
                            savedConversations = conversations,
                            status = "${conversations.size} conversations loaded"
                        )
                    },
                    onFailure = { error ->
                        _uiState.value = _uiState.value.copy(
                            status = "Error loading conversations: ${error.message}"
                        )
                    }
                )
        }
    }

    // Hide the history dialog
    fun dismissHistoryDialog() {
        _uiState.value = _uiState.value.copy(showHistoryDialog = false)
    }

    // Load a conversation from history
    fun loadConversation(savedConversation: SavedConversation) {
        // Stop current polling
        job?.cancel()
        
        // Update UI state with saved conversation data
        userKey = savedConversation.userKey
        conversationId = savedConversation.conversationId
        
        _uiState.value = _uiState.value.copy(
            messages = savedConversation.messages,
            userKey = savedConversation.userKey,
            conversationId = savedConversation.conversationId,
            showHistoryDialog = false,
            status = "Loaded conversation: ${savedConversation.title}"
        )
        
        // Start polling with the loaded conversation IDs
        startMessagePolling()
    }

    // Delete a conversation from history
    fun deleteConversation(conversationId: String) {
        viewModelScope.launch {
            // First update the UI
            val updatedHistory = _uiState.value.savedConversations.filter { it.id != conversationId }
            _uiState.value = _uiState.value.copy(
                savedConversations = updatedHistory,
                status = "Deleting conversation..."
            )
            
            // Then delete from Firestore
            chatHistoryRepository.deleteConversation(conversationId)
                .fold(
                    onSuccess = {
                        _uiState.value = _uiState.value.copy(
                            status = "Conversation deleted"
                        )
                    },
                    onFailure = { error ->
                        _uiState.value = _uiState.value.copy(
                            status = "Error deleting conversation: ${error.message}"
                        )
                    }
                )
        }
    }

    // Regular create user and conversation
    private fun createUserAndConversation() {
        viewModelScope.launch {
            try {
                val userResult = repository.createUser()
                if (userResult.isSuccess) {
                    val user = userResult.getOrThrow()
                    userKey = user.id
                    _uiState.value = _uiState.value.copy(status = "User created: ${user.id}")

                    val conversationResult = repository.createConversation(user.id)
                    if (conversationResult.isSuccess) {
                        val conversation = conversationResult.getOrThrow()
                        conversationId = conversation.id
                        _uiState.value = _uiState.value.copy(status = "Conversation created: ${conversation.id}")
                        startMessagePolling()
                    } else {
                        _uiState.value = _uiState.value.copy(status = "Error creating conversation: ${conversationResult.exceptionOrNull()?.message}")
                    }
                } else {
                    _uiState.value = _uiState.value.copy(status = "Error creating user: ${userResult.exceptionOrNull()?.message}")
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(status = "Error: ${e.message}")
            }
        }
    }

    fun sendMessage(text: String) {
        val currentUserKey = userKey
        val currentConversationId = conversationId
        
        if (text.isBlank() || currentUserKey == null || currentConversationId == null) {
            return
        }

        // Add user message to UI immediately with a temporary ID
        val userMessage = Message(
            id = "temp_${System.currentTimeMillis()}", // Use temp ID to identify temporary messages
            conversationId = currentConversationId,
            userId = "user_${currentUserKey}", // Ensure user messages have "user_" prefix
            text = text,
            type = "text",
            created = OffsetDateTime.now().toString()
        )
        
        _uiState.value = _uiState.value.copy(
            messages = _uiState.value.messages + userMessage,
            inputText = ""
        )
        
        // Send message to API
        viewModelScope.launch {
            try {
                _uiState.value = _uiState.value.copy(status = "Sending message...")
                
                // Mark any previous messages with options as interacted
                markPreviousMessagesAsInteracted()
                
                val result = repository.sendMessage(currentUserKey, currentConversationId, text)
                if (result.isSuccess) {
                    _uiState.value = _uiState.value.copy(status = "Message sent")
                    
                    // Once the message is sent successfully, the next polling cycle
                    // will pick up the official message from the server
                } else {
                    val errorMessage = result.exceptionOrNull()?.message ?: "Unknown error"
                    _uiState.value = _uiState.value.copy(status = "Error sending message: $errorMessage")
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(status = "Error: ${e.message}")
            }
        }
    }

    /**
     * Marks all previous bot messages that have options as interacted
     * This will disable the buttons/dropdowns in those messages
     */
    private fun markPreviousMessagesAsInteracted() {
        // Get current messages and update interacted flag directly
        val currentMessages = _uiState.value.messages
        
        // Find all bot messages with options
        currentMessages.forEach { message ->
            // Only mark bot messages with options as interacted
            if (!message.userId.contains("user_") && message.options?.isNotEmpty() == true) {
                message.interacted = true
            }
        }
        
        // Force a UI update by creating a new list instance
        _uiState.value = _uiState.value.copy(messages = ArrayList(currentMessages))
    }

    private fun startMessagePolling() {
        job?.cancel()
        job = viewModelScope.launch {
            val currentUserKey = userKey ?: return@launch
            val currentConversationId = conversationId ?: return@launch

            Log.d(TAG, "Starting message polling with userKey=$currentUserKey, conversationId=$currentConversationId")

            while (isActive) {
                try {
                    repository.getMessages(currentUserKey, currentConversationId).onSuccess { messages ->
                        Log.d(TAG, "Retrieved ${messages.size} messages from API")
                        
                        // More verbose debugging for message identification
                        Log.d(TAG, "=== MESSAGE DEBUGGING START ===")
                        messages.forEach { message ->
                            val isUserMessage = message.userId.contains("user_")
                            Log.d(TAG, "MESSAGE: id=${message.id}, userId='${message.userId}', isUserMessage=$isUserMessage, text=${message.text?.take(30) ?: "null"}")
                        }
                        Log.d(TAG, "=== MESSAGE DEBUGGING END ===")
                        
                        // Sort messages by creation timestamp to ensure chronological order
                        val sortedMessages = messages.sortedBy { it.created }
                        
                        // Replace local messages that have the same text with server messages
                        // This fixes the duplication problem when user sends a message
                        val currentMessages = _uiState.value.messages
                        val localUserMessages = currentMessages.filter { it.userId.contains("user_") }
                        
                        val nonDuplicatedMessages = sortedMessages.filter { serverMsg ->
                            !localUserMessages.any { localMsg -> 
                                // If this is a user message with the same text and roughly the same timestamp
                                // (within 10 seconds), consider it a duplicate of our locally added message
                                localMsg.userId.contains("user_") && 
                                localMsg.text == serverMsg.text &&
                                // If message is from the same user, check if it's close enough in time
                                serverMsg.userId.contains("user_") &&
                                localMsg.id.startsWith("temp_")
                            }
                        }
                        
                        // Create a map of existing messages by ID to preserve their interacted state
                        val existingMessagesMap = currentMessages.associateBy { it.id }
                        
                        // Process new messages to preserve interacted state from existing messages
                        val processedNewMessages = nonDuplicatedMessages.map { newMsg ->
                            existingMessagesMap[newMsg.id]?.let { existingMsg ->
                                // If message already exists, preserve its interacted state
                                newMsg.copy(interacted = existingMsg.interacted)
                            } ?: newMsg
                        }
                        
                        // Replace temporary messages with server messages
                        val updatedMessages = currentMessages
                            .filter { !it.id.startsWith("temp_") } // Remove temp messages
                            .plus(processedNewMessages)  // Add non-duplicated server messages
                            .distinctBy { it.id } // Remove any remaining duplicates
                            .sortedBy { it.created } // Sort by creation time
                        
                        if (updatedMessages != currentMessages) {
                            Log.d(TAG, "Updating message list with ${updatedMessages.size} messages")
                            // Log messages to help troubleshooting
                            updatedMessages.forEachIndexed { index, msg ->
                                Log.d(TAG, "[$index] ${msg.created} - ${msg.type}: ${msg.text}")
                            }
                            
                            _uiState.value = _uiState.value.copy(
                                messages = updatedMessages,
                                status = "Updated messages"
                            )
                        }
                    }.onFailure { error ->
                        Log.e(TAG, "Error getting messages: ${error.message}", error)
                        _uiState.value = _uiState.value.copy(status = "Error getting messages: ${error.message}")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Exception in message polling: ${e.message}", e)
                    _uiState.value = _uiState.value.copy(status = "Error: ${e.message}")
                }
                delay(2000) // Poll every 2 seconds
            }
        }
    }

    fun onInputChange(text: String) {
        _uiState.value = _uiState.value.copy(inputText = text)
    }

    override fun onCleared() {
        super.onCleared()
        job?.cancel()
    }

    private fun handleError(context: String, throwable: Throwable) {
        val errorMessage = when (throwable) {
            is HttpException -> {
                try {
                    val errorBody = throwable.response()?.errorBody()?.string()
                    Log.e(TAG, "HTTP Error: ${throwable.code()} - $errorBody")
                    "HTTP ${throwable.code()}: $errorBody"
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to parse error body", e)
                    "HTTP ${throwable.code()}: ${throwable.message()}"
                }
            }
            is IOException -> {
                Log.e(TAG, "Network error", throwable)
                "Network error: Check your internet connection"
            }
            else -> {
                Log.e(TAG, "Other error", throwable)
                throwable.message ?: "Unknown error"
            }
        }
        _uiState.value = _uiState.value.copy(
            error = "$context - $errorMessage",
            isLoading = false
        )
    }

    fun retry() {
        createUserAndConversation()
    }

    // Reset conversation to start a new one
    fun resetConversation() {
        viewModelScope.launch {
            try {
                _uiState.value = _uiState.value.copy(
                    status = "Resetting conversation...",
                    messages = emptyList()
                )
                
                // Create a new user
                val userResult = repository.createUser()
                if (userResult.isSuccess) {
                    val user = userResult.getOrThrow()
                    userKey = user.id
                    _uiState.value = _uiState.value.copy(status = "User created: ${user.id}")
                    
                    // Create a new conversation
                    val conversationResult = repository.createConversation(user.id)
                    if (conversationResult.isSuccess) {
                        val conversation = conversationResult.getOrThrow()
                        conversationId = conversation.id
                        _uiState.value = _uiState.value.copy(
                            status = "Conversation created: ${conversation.id}",
                            messages = emptyList(),
                            inputText = "",
                            userKey = user.id,
                            conversationId = conversation.id
                        )
                        
                        // Start polling for messages
                        startMessagePolling()
                    } else {
                        _uiState.value = _uiState.value.copy(
                            status = "Error creating conversation: ${conversationResult.exceptionOrNull()?.message}"
                        )
                    }
                } else {
                    _uiState.value = _uiState.value.copy(
                        status = "Error creating user: ${userResult.exceptionOrNull()?.message}"
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    status = "Error resetting conversation: ${e.message}"
                )
            }
        }
    }

    // Load all saved conversations from Firestore
    private fun loadSavedConversations() {
        viewModelScope.launch {
            chatHistoryRepository.getConversations()
                .fold(
                    onSuccess = { conversations ->
                        _uiState.value = _uiState.value.copy(
                            savedConversations = conversations
                        )
                        Log.d(TAG, "Loaded ${conversations.size} conversations from Firestore")
                    },
                    onFailure = { error ->
                        Log.e(TAG, "Error loading conversations: ${error.message}", error)
                    }
                )
        }
    }

    companion object {
        private const val TAG = "ChatViewModel"
    }
} 