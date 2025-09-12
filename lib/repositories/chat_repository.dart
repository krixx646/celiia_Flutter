import '../services/botpress_api.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final BotpressApi _api = BotpressApi();

  Future<User> createUser({String? name, String? email}) async {
    try {
      final request = CreateUserRequest(
        name: name ?? "Flutter User",
        email: email ?? "user@example.com",
      );
      
      final response = await _api.createUser(request);
      
      if (response.message != null && response.code != null) {
        throw Exception("API Error (${response.code}): ${response.message}");
      }
      
      if (response.user != null && response.key != null) {
        return User(
          id: response.key!,
          name: name ?? "Flutter User",
          email: email,
        );
      } else {
        throw Exception("Failed to parse user response: $response");
      }
    } catch (e) {
      throw Exception("Error creating user: ${e.toString()}");
    }
  }

  Future<Conversation> createConversation(String userKey) async {
    try {
      final request = CreateConversationRequest();
      final response = await _api.createConversation(userKey, request);
      
      return Conversation(
        id: response.conversation.id,
        userId: "user",
        created: response.conversation.createdAt,
        updated: response.conversation.updatedAt,
      );
    } catch (e) {
      throw Exception("Error creating conversation: ${e.toString()}");
    }
  }

  Future<Message> sendMessage(String userKey, String conversationId, String text) async {
    try {
      final isImageUrl = text.startsWith('http') && (text.endsWith('.png') || text.endsWith('.jpg') || text.endsWith('.jpeg') || text.endsWith('.gif') || text.contains('imgbb.com') || text.contains('i.imgur.com'));
      final response = isImageUrl
          ? await _api.sendMessagePayload(userKey, conversationId, MessagePayload(type: 'image', imageUrl: text))
          : await _api.sendMessage(userKey, conversationId, SimpleMessageRequest(type: 'text', text: text));
      
      return Message(
        id: response.message.id,
        conversationId: response.message.conversationId,
        userId: "user_${response.message.userId ?? userKey}",
        text: response.message.payload.text,
        type: response.message.payload.type,
        created: response.message.createdAt,
        imageUrl: response.message.payload.imageUrl,
        options: response.message.payload.options,
      );
    } catch (e) {
      throw Exception("Error sending message: ${e.toString()}");
    }
  }

  Future<List<Message>> getMessages(String userKey, String conversationId) async {
    try {
      final response = await _api.getMessages(userKey, conversationId);
      
      final messages = response.messages.map((botpressMessage) {
        String messageType;
        if (botpressMessage.payload.type == "choice") {
          messageType = "choice";
        } else if (botpressMessage.payload.type == "dropdown") {
          messageType = "dropdown";
        } else if (botpressMessage.payload.type == "image") {
          messageType = "image";
        } else if (botpressMessage.payload.type == "button") {
          messageType = "button";
        } else if (botpressMessage.payload.options?.isNotEmpty == true) {
          messageType = "button";
        } else {
          messageType = "text";
        }
        
        final isUserMessage = botpressMessage.userId == null || botpressMessage.userId?.contains(userKey) == true;
        final userId = isUserMessage 
            ? "user_${botpressMessage.userId ?? userKey}"
            : "bot_${botpressMessage.userId ?? "botpress"}";
        
        // Deduplicate options if the bot returns repeated entries
        final rawOptions = botpressMessage.payload.options ?? const <MessageOption>[];
        final seen = <String>{};
        final uniqueOptions = <MessageOption>[];
        for (final opt in rawOptions) {
          final key = '${opt.label}|${opt.value}';
          if (!seen.contains(key)) {
            seen.add(key);
            uniqueOptions.add(opt);
          }
        }

        return Message(
          id: botpressMessage.id,
          conversationId: botpressMessage.conversationId,
          userId: userId,
          text: botpressMessage.payload.text,
          type: messageType,
          created: botpressMessage.createdAt,
          imageUrl: botpressMessage.payload.imageUrl,
          options: uniqueOptions,
        );
      }).toList();
      
      return messages;
    } catch (e) {
      throw Exception("Error getting messages: ${e.toString()}");
    }
  }

  void dispose() {
    _api.dispose();
  }
}


