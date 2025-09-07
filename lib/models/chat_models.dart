import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String? name;
  final String? email;
  final Map<String, String>? metadata;

  User({
    required this.id,
    this.name,
    this.email,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Conversation {
  final String id;
  final String userId;
  final String created;
  final String? updated;
  final Map<String, String>? metadata;

  Conversation({
    required this.id,
    required this.userId,
    required this.created,
    this.updated,
    this.metadata,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String userId;
  final String? text;
  final String type;
  final String created;
  final String? imageUrl;
  final List<MessageOption>? options;
  final Map<String, String>? metadata;
  bool interacted;

  Message({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.text,
    this.type = "text",
    required this.created,
    this.imageUrl,
    this.options,
    this.metadata,
    this.interacted = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class MessageOption {
  final String label;
  final String value;

  MessageOption({
    required this.label,
    required this.value,
  });

  factory MessageOption.fromJson(Map<String, dynamic> json) => _$MessageOptionFromJson(json);
  Map<String, dynamic> toJson() => _$MessageOptionToJson(this);
}

@JsonSerializable()
class SimpleMessageRequest {
  final String type;
  final String text;

  SimpleMessageRequest({
    this.type = "text",
    required this.text,
  });

  factory SimpleMessageRequest.fromJson(Map<String, dynamic> json) => _$SimpleMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleMessageRequestToJson(this);
}

@JsonSerializable()
class BotpressUser {
  final String id;
  final String createdAt;
  final String updatedAt;

  BotpressUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BotpressUser.fromJson(Map<String, dynamic> json) => _$BotpressUserFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressUserToJson(this);
}

@JsonSerializable()
class BotpressUserResponse {
  final BotpressUser? user;
  final String? key;
  final String? id;
  final int? code;
  final String? type;
  final String? message;

  BotpressUserResponse({
    this.user,
    this.key,
    this.id,
    this.code,
    this.type,
    this.message,
  });

  factory BotpressUserResponse.fromJson(Map<String, dynamic> json) => _$BotpressUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressUserResponseToJson(this);
}

@JsonSerializable()
class BotpressMessage {
  final String id;
  final String conversationId;
  final String? userId;
  final List<String>? tags;
  final MessagePayload payload;
  final String createdAt;
  final String? updatedAt;

  BotpressMessage({
    required this.id,
    required this.conversationId,
    this.userId,
    this.tags,
    required this.payload,
    required this.createdAt,
    this.updatedAt,
  });

  factory BotpressMessage.fromJson(Map<String, dynamic> json) => _$BotpressMessageFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressMessageToJson(this);
}

@JsonSerializable()
class MessagePayload {
  final String type;
  final String? text;
  final String? imageUrl;
  final List<MessageOption>? options;

  MessagePayload({
    this.type = "text",
    this.text,
    this.imageUrl,
    this.options,
  });

  factory MessagePayload.fromJson(Map<String, dynamic> json) => _$MessagePayloadFromJson(json);
  Map<String, dynamic> toJson() => _$MessagePayloadToJson(this);
}

@JsonSerializable()
class MessageWithConversation {
  final String conversationId;
  final MessagePayload payload;

  MessageWithConversation({
    required this.conversationId,
    required this.payload,
  });

  factory MessageWithConversation.fromJson(Map<String, dynamic> json) => _$MessageWithConversationFromJson(json);
  Map<String, dynamic> toJson() => _$MessageWithConversationToJson(this);
}

@JsonSerializable()
class BotpressMessageResponse {
  final BotpressMessage message;
  final String? error;
  final int? code;

  BotpressMessageResponse({
    required this.message,
    this.error,
    this.code,
  });

  factory BotpressMessageResponse.fromJson(Map<String, dynamic> json) => _$BotpressMessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressMessageResponseToJson(this);
}

@JsonSerializable()
class BotpressMessagesResponse {
  final List<BotpressMessage> messages;
  final Map<String, String> meta;

  BotpressMessagesResponse({
    required this.messages,
    this.meta = const {},
  });

  factory BotpressMessagesResponse.fromJson(Map<String, dynamic> json) => _$BotpressMessagesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressMessagesResponseToJson(this);
}

@JsonSerializable()
class CreateUserRequest {
  final String name;
  final String email;
  final Map<String, String> metadata;

  CreateUserRequest({
    this.name = "Flutter User",
    this.email = "user@example.com",
    this.metadata = const {"platform": "flutter", "deviceType": "mobile"},
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable()
class CreateConversationRequest {
  final String? userId;
  final Map<String, String> metadata;

  CreateConversationRequest({
    this.userId,
    this.metadata = const {"source": "flutter"},
  });

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) => _$CreateConversationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

@JsonSerializable()
class BotpressConversation {
  final String id;
  final String createdAt;
  final String updatedAt;

  BotpressConversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BotpressConversation.fromJson(Map<String, dynamic> json) => _$BotpressConversationFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressConversationToJson(this);
}

@JsonSerializable()
class BotpressConversationResponse {
  final BotpressConversation conversation;

  BotpressConversationResponse({required this.conversation});

  factory BotpressConversationResponse.fromJson(Map<String, dynamic> json) => _$BotpressConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BotpressConversationResponseToJson(this);
}


