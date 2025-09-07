package eu.thefit.celia.ui.history

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import eu.thefit.celia.data.repository.ChatHistoryRepository
import eu.thefit.celia.ui.chat.SavedConversation
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class HistoryViewModel @Inject constructor(
    private val chatHistoryRepository: ChatHistoryRepository
) : ViewModel() {
    
    // UI state for the history screen
    private val _uiState = MutableStateFlow(HistoryUiState())
    val uiState: StateFlow<HistoryUiState> = _uiState.asStateFlow()
    
    /**
     * Load chat history from the repository
     */
    fun loadHistory() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            
            chatHistoryRepository.getConversations()
                .fold(
                    onSuccess = { conversations ->
                        _uiState.update { 
                            it.copy(
                                isLoading = false,
                                conversations = conversations
                            )
                        }
                    },
                    onFailure = { error ->
                        _uiState.update { 
                            it.copy(
                                isLoading = false,
                                error = error.message ?: "Failed to load conversations"
                            )
                        }
                    }
                )
        }
    }
    
    /**
     * Delete a conversation by ID
     */
    fun deleteConversation(conversationId: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isDeleting = true) }
            
            chatHistoryRepository.deleteConversation(conversationId)
                .fold(
                    onSuccess = {
                        // Remove the deleted conversation from the UI state
                        _uiState.update { state ->
                            state.copy(
                                isDeleting = false,
                                conversations = state.conversations.filter { it.id != conversationId }
                            )
                        }
                    },
                    onFailure = { error ->
                        _uiState.update { 
                            it.copy(
                                isDeleting = false,
                                error = "Failed to delete conversation: ${error.message}"
                            )
                        }
                    }
                )
        }
    }
    
    /**
     * Delete all conversations older than 30 days
     */
    fun cleanupOldConversations() {
        viewModelScope.launch {
            chatHistoryRepository.deleteOldConversations()
                .fold(
                    onSuccess = { count ->
                        if (count > 0) {
                            // If conversations were deleted, reload the list
                            loadHistory()
                        }
                    },
                    onFailure = { /* Silently ignore cleanup errors */ }
                )
        }
    }
}

/**
 * UI state for the History screen
 */
data class HistoryUiState(
    val isLoading: Boolean = false,
    val isDeleting: Boolean = false,
    val conversations: List<SavedConversation> = emptyList(),
    val error: String? = null
) 