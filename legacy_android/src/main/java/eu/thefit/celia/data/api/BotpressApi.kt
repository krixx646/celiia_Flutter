package eu.thefit.celia.data.api

import eu.thefit.celia.data.model.*
import retrofit2.http.*

interface BotpressApi {
    @GET("hello")
    suspend fun checkConnection(): ApiResponse<String>

    @POST("users")
    suspend fun createUser(
        @Body request: CreateUserRequest
    ): BotpressUserResponse

    @POST("conversations")
    suspend fun createConversation(
        @Header("X-User-Key") userKey: String,
        @Body request: CreateConversationRequest
    ): BotpressConversationResponse

    @POST("conversations/{conversationId}/message")
    @Headers("Content-Type: application/json")
    suspend fun sendMessage(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String,
        @Body request: SimpleMessageRequest
    ): BotpressMessageResponse

    @GET("conversations/{conversationId}/messages")
    suspend fun getMessages(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String
    ): BotpressMessagesResponse

    @GET("conversations/{conversationId}")
    suspend fun getConversation(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String
    ): ApiResponse<Conversation>

    @DELETE("conversations/{conversationId}")
    suspend fun deleteConversation(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String
    ): ApiResponse<Unit>

    @GET("conversations")
    suspend fun listConversations(
        @Header("X-User-Key") userKey: String
    ): ApiResponse<List<Conversation>>

    @POST("conversations/{conversationId}/participants")
    suspend fun addParticipant(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String,
        @Body request: AddParticipantRequest
    ): ApiResponse<Unit>

    @GET("conversations/{conversationId}/participants")
    suspend fun listParticipants(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String
    ): ApiResponse<List<Participant>>

    @DELETE("conversations/{conversationId}/participants/{participantId}")
    suspend fun removeParticipant(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String,
        @Path("participantId") participantId: String
    ): ApiResponse<Unit>

    @GET("conversations/{conversationId}/participants/{participantId}")
    suspend fun getParticipant(
        @Header("X-User-Key") userKey: String,
        @Path("conversationId") conversationId: String,
        @Path("participantId") participantId: String
    ): ApiResponse<Participant>

    @GET("messages/{messageId}")
    suspend fun getMessage(
        @Header("X-User-Key") userKey: String,
        @Path("messageId") messageId: String
    ): ApiResponse<Message>

    @DELETE("messages/{messageId}")
    suspend fun deleteMessage(
        @Header("X-User-Key") userKey: String,
        @Path("messageId") messageId: String
    ): ApiResponse<Unit>

    @GET("users/{userId}")
    suspend fun getUser(
        @Header("X-User-Key") userKey: String,
        @Path("userId") userId: String
    ): ApiResponse<User>

    @PUT("users/{userId}")
    suspend fun updateUser(
        @Header("X-User-Key") userKey: String,
        @Path("userId") userId: String,
        @Body request: UpdateUserRequest
    ): ApiResponse<User>

    @DELETE("users/{userId}")
    suspend fun deleteUser(
        @Header("X-User-Key") userKey: String,
        @Path("userId") userId: String
    ): ApiResponse<Unit>

    @GET("events/{eventId}")
    suspend fun getEvent(
        @Header("X-User-Key") userKey: String,
        @Path("eventId") eventId: String
    ): ApiResponse<Event>

    @POST("events")
    suspend fun createEvent(
        @Header("X-User-Key") userKey: String,
        @Body request: CreateEventRequest
    ): ApiResponse<Event>

    @POST("messages")
    @Headers("Content-Type: application/json")
    suspend fun sendMessageDirect(
        @Header("X-User-Key") userKey: String,
        @Body request: MessageWithConversation
    ): BotpressMessageResponse
} 