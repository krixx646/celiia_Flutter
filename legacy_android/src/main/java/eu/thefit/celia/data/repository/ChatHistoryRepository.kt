package eu.thefit.celia.data.repository

import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import eu.thefit.celia.data.model.Message
import eu.thefit.celia.ui.chat.SavedConversation
import kotlinx.coroutines.tasks.await
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository for managing chat history in Firestore
 */
interface ChatHistoryRepository {
    /**
     * Save a conversation to history
     */
    suspend fun saveConversation(conversation: SavedConversation): Result<String>
    
    /**
     * Get all saved conversations for the current user
     */
    suspend fun getConversations(): Result<List<SavedConversation>>
    
    /**
     * Delete a specific conversation
     */
    suspend fun deleteConversation(conversationId: String): Result<Unit>
    
    /**
     * Delete all conversations older than 30 days
     */
    suspend fun deleteOldConversations(): Result<Int>
}

@Singleton
class FirestoreChatHistoryRepository @Inject constructor(
    private val auth: FirebaseAuth,
    private val firestore: FirebaseFirestore
) : ChatHistoryRepository {
    
    companion object {
        private const val TAG = "ChatHistoryRepository"
        private const val COLLECTION_USERS = "users"
        private const val COLLECTION_CONVERSATIONS = "conversations"
        private const val RETENTION_DAYS = 30
    }
    
    /**
     * Save a conversation to Firestore
     */
    override suspend fun saveConversation(conversation: SavedConversation): Result<String> {
        return try {
            val userId = auth.currentUser?.uid ?: return Result.failure(Exception("User not logged in"))
            
            // Convert timestamp to a proper date object
            val timestamp = convertStringToTimestamp(conversation.timestamp)
            
            // Convert messages to a format suitable for Firestore
            val messagesList = conversation.messages.map { message ->
                mapOf(
                    "id" to message.id,
                    "conversationId" to message.conversationId,
                    "userId" to message.userId,
                    "text" to message.text,
                    "type" to message.type,
                    "created" to message.created,
                    "imageUrl" to message.imageUrl,
                    "interacted" to message.interacted
                )
            }
            
            // Create a conversation document
            val conversationData = hashMapOf(
                "id" to conversation.id,
                "title" to conversation.title,
                "timestamp" to timestamp,
                "messages" to messagesList,
                "userKey" to conversation.userKey,
                "conversationId" to conversation.conversationId,
                "createdAt" to Date() // Use this for TTL
            )
            
            // Save to Firestore under the user's collection
            firestore.collection(COLLECTION_USERS)
                .document(userId)
                .collection(COLLECTION_CONVERSATIONS)
                .document(conversation.id)
                .set(conversationData)
                .await()
            
            Result.success(conversation.id)
        } catch (e: Exception) {
            Log.e(TAG, "Error saving conversation: ${e.message}", e)
            Result.failure(e)
        }
    }
    
    /**
     * Get all saved conversations for the current user
     */
    override suspend fun getConversations(): Result<List<SavedConversation>> {
        return try {
            val userId = auth.currentUser?.uid ?: return Result.success(emptyList())
            
            // Get conversations and order by timestamp (newest first)
            val querySnapshot = firestore.collection(COLLECTION_USERS)
                .document(userId)
                .collection(COLLECTION_CONVERSATIONS)
                .orderBy("timestamp", Query.Direction.DESCENDING)
                .get()
                .await()
                
            val conversations = querySnapshot.documents.mapNotNull { doc ->
                convertDocToConversation(doc)
            }
            
            // Run cleanup of old conversations in the background
            deleteOldConversations()
            
            Result.success(conversations)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting conversations: ${e.message}", e)
            Result.failure(e)
        }
    }
    
    /**
     * Delete a specific conversation
     */
    override suspend fun deleteConversation(conversationId: String): Result<Unit> {
        return try {
            val userId = auth.currentUser?.uid ?: return Result.failure(Exception("User not logged in"))
            
            firestore.collection(COLLECTION_USERS)
                .document(userId)
                .collection(COLLECTION_CONVERSATIONS)
                .document(conversationId)
                .delete()
                .await()
                
            Result.success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "Error deleting conversation: ${e.message}", e)
            Result.failure(e)
        }
    }
    
    /**
     * Delete all conversations older than 30 days
     */
    override suspend fun deleteOldConversations(): Result<Int> {
        return try {
            val userId = auth.currentUser?.uid ?: return Result.success(0)
            
            // Calculate the cutoff date (30 days ago)
            val thirtyDaysAgo = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, -RETENTION_DAYS)
            }.time
            
            // Query for old conversations
            val oldConversations = firestore.collection(COLLECTION_USERS)
                .document(userId)
                .collection(COLLECTION_CONVERSATIONS)
                .whereLessThan("createdAt", thirtyDaysAgo)
                .get()
                .await()
            
            val count = oldConversations.size()
            
            // Delete each old conversation
            oldConversations.documents.forEach { doc ->
                firestore.collection(COLLECTION_USERS)
                    .document(userId)
                    .collection(COLLECTION_CONVERSATIONS)
                    .document(doc.id)
                    .delete()
                    .await()
            }
            
            Result.success(count)
        } catch (e: Exception) {
            Log.e(TAG, "Error deleting old conversations: ${e.message}", e)
            Result.failure(e)
        }
    }
    
    // Helper methods
    
    private fun convertDocToConversation(doc: DocumentSnapshot): SavedConversation? {
        return try {
            val id = doc.getString("id") ?: return null
            val title = doc.getString("title") ?: ""
            val timestamp = doc.getTimestamp("timestamp")?.toDate()?.toString() ?: ""
            val userKey = doc.getString("userKey") ?: ""
            val conversationId = doc.getString("conversationId") ?: ""
            
            // Convert the messages list from Firestore
            val messagesData = doc.get("messages") as? List<Map<String, Any>> ?: emptyList()
            
            val messages = messagesData.mapNotNull { data ->
                try {
                    Message(
                        id = data["id"] as? String ?: "",
                        conversationId = data["conversationId"] as? String ?: "",
                        userId = data["userId"] as? String ?: "",
                        text = data["text"] as? String,
                        type = data["type"] as? String ?: "text",
                        created = data["created"] as? String ?: "",
                        imageUrl = data["imageUrl"] as? String,
                        interacted = data["interacted"] as? Boolean ?: false
                    )
                } catch (e: Exception) {
                    Log.e(TAG, "Error converting message data: ${e.message}")
                    null
                }
            }
            
            SavedConversation(
                id = id,
                title = title,
                timestamp = timestamp,
                messages = messages,
                userKey = userKey,
                conversationId = conversationId
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error converting document to conversation: ${e.message}")
            null
        }
    }
    
    private fun convertStringToTimestamp(timestamp: String): Date {
        return try {
            // Try to parse the timestamp string to a Date
            val formatter = DateTimeFormatter.ofPattern("MMM d, yyyy HH:mm")
            val localDateTime = LocalDateTime.parse(timestamp, formatter)
            Date.from(localDateTime.toInstant(ZoneOffset.UTC))
        } catch (e: Exception) {
            // If parsing fails, use current date
            Log.e(TAG, "Error parsing timestamp: ${e.message}")
            Date()
        }
    }
} 