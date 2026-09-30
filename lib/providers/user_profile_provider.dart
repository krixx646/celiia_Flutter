import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../utils/user_facing_error.dart';

/// Holds the server-side onboarding profile.
///
/// Saves are partial and idempotent, so the onboarding flow pushes the whole
/// draft after each step. A step that fails to reach the server does not trap
/// the user: the draft stays in memory and the next save carries the earlier
/// answers along with it. Only finishing onboarding requires a save to land.
class UserProfileProvider extends ChangeNotifier {
  @visibleForTesting
  static UserProfileService Function() defaultService = () =>
      UserProfileService();

  UserProfileProvider({UserProfileService? service})
    : _service = service ?? defaultService();

  final UserProfileService _service;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  /// Whether a load has completed, successfully or not. The onboarding gate
  /// waits on this so it never flashes the flow at someone who has a profile.
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  /// False for a user who has never onboarded, and for one whose stored
  /// profile predates the current [kOnboardingVersion].
  bool get isOnboardingComplete => _profile?.isOnboardingComplete ?? false;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.fetch();
      _hasLoaded = true;
    } catch (e) {
      _error = toUserFriendlyMessage(e, fallbackOf: (l10n) => l10n.errorGeneric);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Writes the answers in [draft] and adopts the stored result.
  Future<bool> save(UserProfile draft) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.save(draft);
      _hasLoaded = true;
      return true;
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.onboardingSaveFailed,
      );
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Marks onboarding finished at the version the app is currently on.
  Future<bool> completeOnboarding(UserProfile draft) {
    return save(
      draft.copyWith(
        onboardingVersion: kOnboardingVersion,
        onboardingCompletedAt: DateTime.now(),
      ),
    );
  }

  void clear() {
    _profile = null;
    _error = null;
    _isLoading = false;
    _isSaving = false;
    _hasLoaded = false;
    notifyListeners();
  }
}
