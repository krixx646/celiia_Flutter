import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static String _key(String userId) => 'onboarding_complete_$userId';

  static Future<bool> isComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  static Future<void> markComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}
