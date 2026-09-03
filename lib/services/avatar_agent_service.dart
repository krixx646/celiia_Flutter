import 'celia_chat_service.dart';

/// Avatar Mode agent client — same SSE protocol as chat, different endpoint
/// and its own conversation threads (`mode=avatar` on the server).
class AvatarAgentService extends CeliaChatService {
  AvatarAgentService({super.firebaseAuth, super.httpClient})
    : super(chatPath: '/api/mobile/avatar');

  static const appControlTools = {
    'open_screen',
    'open_routine',
    'start_workout',
    'open_meal_scanner',
    'go_back',
  };

  static bool isAppControlTool(String toolName) =>
      appControlTools.contains(toolName);
}
