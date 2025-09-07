package eu.thefit.celia.data.model

import kotlinx.serialization.Contextual
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class User(
    val id: String,
    val name: String? = null,
    val email: String? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class Conversation(
    val id: String,
    val userId: String,
    val created: String,
    val updated: String? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class Message(
    val id: String,
    val conversationId: String,
    val userId: String,
    val text: String? = null,
    val type: String = "text",
    val created: String,
    val imageUrl: String? = null,
    val options: List<MessageOption>? = null,
    val metadata: Map<String, String>? = null,
    var interacted: Boolean = false
)

@Serializable
data class Participant(
    val id: String,
    val conversationId: String,
    val userId: String,
    val role: String,
    val created: String,
    val metadata: Map<String, String>? = null
)

@Serializable
data class Event(
    val id: String,
    val type: String,
    val payload: JsonElement,
    val created: String,
    val metadata: Map<String, String>? = null
)

@Serializable
data class CreateUserRequest(
    val name: String = "Android User",
    val email: String = "user@example.com",
    val metadata: Map<String, String> = mapOf("platform" to "android", "deviceType" to "mobile")
)

// Renamed to SimpleMessageRequest to avoid duplicates
@Serializable
data class SimpleMessageRequest(
    val type: String = "text",
    val text: String
)

@Serializable
data class AddParticipantRequest(
    val userId: String,
    val role: String,
    val metadata: Map<String, String>? = null
)

@Serializable
data class UpdateUserRequest(
    val name: String? = null,
    val email: String? = null,
    val metadata: Map<String, String>? = null
)

@Serializable
data class CreateEventRequest(
    val type: String,
    val payload: JsonElement,
    val metadata: Map<String, String>? = null
)

@Serializable
data class ApiResponse<T>(
    val data: T? = null,
    val success: Boolean = true,
    val error: String? = null
)

@Serializable
data class BotpressUserResponse(
    val user: BotpressUser? = null,
    val key: String? = null,
    val id: String? = null,
    val code: Int? = null,
    val type: String? = null,
    val message: String? = null
)

@Serializable
data class BotpressUser(
    val id: String,
    val createdAt: String,
    val updatedAt: String
)

@Serializable
data class CreateConversationRequest(
    val userId: String? = null,
    val metadata: Map<String, String> = mapOf("source" to "android")
)

@Serializable
data class BotpressConversation(
    val id: String,
    val createdAt: String,
    val updatedAt: String
)

@Serializable
data class BotpressConversationResponse(
    val conversation: BotpressConversation
)

@Serializable
data class BotpressMessage(
    val id: String,
    val conversationId: String,
    val userId: String? = null,
    val tags: List<String>? = null,
    val payload: MessagePayload,
    val createdAt: String,
    val updatedAt: String? = null
)

@Serializable
data class MessagePayload(
    val type: String = "text",
    val text: String? = null,
    val imageUrl: String? = null,
    val options: List<MessageOption>? = null
)

@Serializable
data class MessageOption(
    val label: String,
    val value: String
)

@Serializable
data class BotpressMessageResponse(
    val message: BotpressMessage,
    val error: String? = null,
    val code: Int? = null
)

@Serializable
data class BotpressMessagesResponse(
    val messages: List<BotpressMessage>,
    val meta: Map<String, String> = emptyMap()
)

@Serializable
data class MessageContent(
    val text: String
)

@Serializable
data class MessageWithConversation(
    val payload: MessagePayload,
    val conversationId: String
) 