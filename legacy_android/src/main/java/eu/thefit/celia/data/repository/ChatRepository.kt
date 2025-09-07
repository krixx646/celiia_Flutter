package eu.thefit.celia.data.repository

import eu.thefit.celia.data.api.BotpressApi
import eu.thefit.celia.data.model.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ChatRepository @Inject constructor(
    private val api: BotpressApi
) {
    suspend fun checkConnection(): Result<String> = withContext(Dispatchers.IO) {
        try {
            val response = api.checkConnection()
            if (response.success && response.data != null) {
                Result.success(response.data)
            } else {
                Result.failure(Exception(response.error ?: "Connection failed or null response"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createUser(name: String? = null, email: String? = null): Result<User> = withContext(Dispatchers.IO) {
        try {
            val requestObj = CreateUserRequest(
                name = name ?: "Android User",
                email = email ?: "user@example.com"
            )
            val response = api.createUser(requestObj)
            
            // Check for error response
            if (response.message != null && response.code != null) {
                return@withContext Result.failure(Exception("API Error (${response.code}): ${response.message}"))
            }
            
            // The user and key are returned directly in the response
            if (response.user != null && response.key != null) {
                // Create a user with the key as ID for simplicity
                val user = User(
                    id = response.key,
                    name = name ?: "Android User", 
                    email = email
                )
                return@withContext Result.success(user)
            } else {
                return@withContext Result.failure(Exception("Failed to parse user response: ${response}"))
            }
        } catch (e: Exception) {
            return@withContext Result.failure(e)
        }
    }

    suspend fun createConversation(userKey: String): Result<Conversation> = withContext(Dispatchers.IO) {
        try {
            val request = CreateConversationRequest()
            val response = api.createConversation(userKey, request)
            
            // Convert the BotpressConversation to our Conversation model
            val conversation = Conversation(
                id = response.conversation.id,
                userId = "user", // Default value since API doesn't return userId
                created = response.conversation.createdAt,
                updated = response.conversation.updatedAt
            )
            
            return@withContext Result.success(conversation)
        } catch (e: Exception) {
            return@withContext Result.failure(e)
        }
    }

    suspend fun sendMessage(userKey: String, conversationId: String, text: String): Result<Message> = withContext(Dispatchers.IO) {
        try {
            val messagePayload = MessagePayload(type = "text", text = text)
            val request = MessageWithConversation(payload = messagePayload, conversationId = conversationId)
            val response = api.sendMessageDirect(userKey, request)
            
            // Convert BotpressMessage to our Message model
            val message = Message(
                id = response.message.id,
                conversationId = response.message.conversationId,
                userId = response.message.userId ?: "user", // Default if null
                text = response.message.payload.text,
                type = response.message.payload.type,
                created = response.message.createdAt,
                imageUrl = response.message.payload.imageUrl,
                options = response.message.payload.options
            )
            
            return@withContext Result.success(message)
        } catch (e: kotlinx.serialization.SerializationException) {
            // Handle serialization exceptions (like missing fields)
            return@withContext Result.failure(Exception("API response format error: ${e.localizedMessage}", e))
        } catch (e: retrofit2.HttpException) {
            // Handle HTTP errors
            val errorBody = e.response()?.errorBody()?.string()
            return@withContext Result.failure(Exception("HTTP Error ${e.code()}: $errorBody", e))
        } catch (e: java.io.IOException) {
            // Handle network errors
            return@withContext Result.failure(Exception("Network error: ${e.localizedMessage}", e))
        } catch (e: Exception) {
            // Handle all other exceptions
            return@withContext Result.failure(Exception("Error sending message: ${e.localizedMessage}", e))
        }
    }

    suspend fun getMessages(userKey: String, conversationId: String): Result<List<Message>> = withContext(Dispatchers.IO) {
        try {
            val response = api.getMessages(userKey, conversationId)
            
            android.util.Log.d("ChatRepository", "Raw response: ${response.messages.size} messages")
            
            // Convert BotpressMessage list to our Message model list
            val messages = response.messages.map { botpressMessage ->
                // Determine the correct message type based on payload
                val messageType = when {
                    // First check if there's a specific type in the payload
                    botpressMessage.payload.type.equals("choice", ignoreCase = true) -> "choice"
                    botpressMessage.payload.type.equals("dropdown", ignoreCase = true) -> "dropdown"
                    botpressMessage.payload.type.equals("image", ignoreCase = true) -> "image"
                    botpressMessage.payload.type.equals("button", ignoreCase = true) -> "button"
                    
                    // If options exist but no specific type, treat as button
                    !botpressMessage.payload.options.isNullOrEmpty() && 
                    botpressMessage.payload.options.size > 0 -> "button"
                    
                    // Default to text
                    else -> "text"
                }
                
                // CRITICAL FIX: Explicitly identify who sent the message
                // 1. If userId contains userKey, it's a user message
                // 2. If userId is null or doesn't contain userKey, it's a bot message
                val isUserMessage = botpressMessage.userId?.contains(userKey) == true
                val userId = if (isUserMessage) {
                    "user_${botpressMessage.userId}"
                } else {
                    "bot_${botpressMessage.userId ?: "botpress"}"
                }
                
                android.util.Log.d("ChatRepository", "Message ${botpressMessage.id} processed - userId: $userId, type: $messageType")
                
                Message(
                    id = botpressMessage.id,
                    conversationId = botpressMessage.conversationId,
                    userId = userId,
                    text = botpressMessage.payload.text,
                    type = messageType,
                    created = botpressMessage.createdAt,
                    imageUrl = botpressMessage.payload.imageUrl,
                    options = botpressMessage.payload.options
                )
            }
            
            android.util.Log.d("ChatRepository", "Converted messages: ${messages.size}")
            
            return@withContext Result.success(messages)
        } catch (e: kotlinx.serialization.SerializationException) {
            // Handle serialization exceptions (like missing fields)
            android.util.Log.e("ChatRepository", "Serialization error: ${e.message}", e)
            return@withContext Result.failure(Exception("API response format error: ${e.localizedMessage}", e))
        } catch (e: retrofit2.HttpException) {
            // Handle HTTP errors
            val errorBody = e.response()?.errorBody()?.string()
            android.util.Log.e("ChatRepository", "HTTP error: ${e.code()} - $errorBody", e)
            return@withContext Result.failure(Exception("HTTP Error ${e.code()}: $errorBody", e))
        } catch (e: java.io.IOException) {
            // Handle network errors
            android.util.Log.e("ChatRepository", "Network error: ${e.message}", e)
            return@withContext Result.failure(Exception("Network error: ${e.localizedMessage}", e))
        } catch (e: Exception) {
            // Handle all other exceptions
            android.util.Log.e("ChatRepository", "General error getting messages: ${e.message}", e)
            return@withContext Result.failure(Exception("Error getting messages: ${e.localizedMessage}", e))
        }
    }
} 