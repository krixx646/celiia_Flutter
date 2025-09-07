// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'metadata': instance.metadata,
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      created: json['created'] as String,
      updated: json['updated'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'created': instance.created,
      'updated': instance.updated,
      'metadata': instance.metadata,
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String?,
      type: json['type'] as String? ?? "text",
      created: json['created'] as String,
      imageUrl: json['imageUrl'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => MessageOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      interacted: json['interacted'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'text': instance.text,
      'type': instance.type,
      'created': instance.created,
      'imageUrl': instance.imageUrl,
      'options': instance.options,
      'metadata': instance.metadata,
      'interacted': instance.interacted,
    };

MessageOption _$MessageOptionFromJson(Map<String, dynamic> json) =>
    MessageOption(
      label: json['label'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$MessageOptionToJson(MessageOption instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
    };

SimpleMessageRequest _$SimpleMessageRequestFromJson(
        Map<String, dynamic> json) =>
    SimpleMessageRequest(
      type: json['type'] as String? ?? "text",
      text: json['text'] as String,
    );

Map<String, dynamic> _$SimpleMessageRequestToJson(
        SimpleMessageRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
    };

BotpressUser _$BotpressUserFromJson(Map<String, dynamic> json) => BotpressUser(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$BotpressUserToJson(BotpressUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

BotpressUserResponse _$BotpressUserResponseFromJson(
        Map<String, dynamic> json) =>
    BotpressUserResponse(
      user: json['user'] == null
          ? null
          : BotpressUser.fromJson(json['user'] as Map<String, dynamic>),
      key: json['key'] as String?,
      id: json['id'] as String?,
      code: (json['code'] as num?)?.toInt(),
      type: json['type'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$BotpressUserResponseToJson(
        BotpressUserResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'key': instance.key,
      'id': instance.id,
      'code': instance.code,
      'type': instance.type,
      'message': instance.message,
    };

BotpressMessage _$BotpressMessageFromJson(Map<String, dynamic> json) =>
    BotpressMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      userId: json['userId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      payload: MessagePayload.fromJson(json['payload'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$BotpressMessageToJson(BotpressMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'tags': instance.tags,
      'payload': instance.payload,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

MessagePayload _$MessagePayloadFromJson(Map<String, dynamic> json) =>
    MessagePayload(
      type: json['type'] as String? ?? "text",
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => MessageOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessagePayloadToJson(MessagePayload instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'options': instance.options,
    };

MessageWithConversation _$MessageWithConversationFromJson(
        Map<String, dynamic> json) =>
    MessageWithConversation(
      conversationId: json['conversationId'] as String,
      payload: MessagePayload.fromJson(json['payload'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageWithConversationToJson(
        MessageWithConversation instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'payload': instance.payload,
    };

BotpressMessageResponse _$BotpressMessageResponseFromJson(
        Map<String, dynamic> json) =>
    BotpressMessageResponse(
      message:
          BotpressMessage.fromJson(json['message'] as Map<String, dynamic>),
      error: json['error'] as String?,
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BotpressMessageResponseToJson(
        BotpressMessageResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'error': instance.error,
      'code': instance.code,
    };

BotpressMessagesResponse _$BotpressMessagesResponseFromJson(
        Map<String, dynamic> json) =>
    BotpressMessagesResponse(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => BotpressMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: (json['meta'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$BotpressMessagesResponseToJson(
        BotpressMessagesResponse instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'meta': instance.meta,
    };

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    CreateUserRequest(
      name: json['name'] as String? ?? "Flutter User",
      email: json['email'] as String? ?? "user@example.com",
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {"platform": "flutter", "deviceType": "mobile"},
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'metadata': instance.metadata,
    };

CreateConversationRequest _$CreateConversationRequestFromJson(
        Map<String, dynamic> json) =>
    CreateConversationRequest(
      userId: json['userId'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {"source": "flutter"},
    );

Map<String, dynamic> _$CreateConversationRequestToJson(
        CreateConversationRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'metadata': instance.metadata,
    };

BotpressConversation _$BotpressConversationFromJson(
        Map<String, dynamic> json) =>
    BotpressConversation(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$BotpressConversationToJson(
        BotpressConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

BotpressConversationResponse _$BotpressConversationResponseFromJson(
        Map<String, dynamic> json) =>
    BotpressConversationResponse(
      conversation: BotpressConversation.fromJson(
          json['conversation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BotpressConversationResponseToJson(
        BotpressConversationResponse instance) =>
    <String, dynamic>{
      'conversation': instance.conversation,
    };
