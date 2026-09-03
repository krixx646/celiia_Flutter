import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sticky app-level mode: Manual (tab shell) vs Avatar (full-screen voice shell).
///
/// Persisted so the choice survives restarts — matching "either manual or
/// avatar mode" rather than a one-shot screen you enter and leave.
class AvatarModeProvider extends ChangeNotifier {
  static const _prefsKey = 'avatar_mode_enabled';

  bool _enabled = false;
  bool _loaded = false;

  bool get isEnabled => _enabled;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      // A mode preference is not worth failing a launch over.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (_enabled == enabled) return;
    _enabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, enabled);
    } catch (_) {
      // The change still applies for this session even if it cannot be saved.
    }
  }
}
