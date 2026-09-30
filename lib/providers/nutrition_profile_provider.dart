import 'package:flutter/foundation.dart';

import '../models/nutrition_profile.dart';
import '../repositories/nutrition_profile_repository.dart';
import '../utils/user_facing_error.dart';

class NutritionProfileProvider extends ChangeNotifier {
  @visibleForTesting
  static NutritionProfileRepository Function() defaultRepository = () =>
      NutritionProfileRepository();

  final NutritionProfileRepository _repository;

  NutritionProfile? _profile;
  bool _isLoading = false;
  String? _error;

  NutritionProfileProvider({NutritionProfileRepository? repository})
    : _repository = repository ?? defaultRepository();

  NutritionProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile?.isComplete ?? false;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.errorLoadNutritionProfile,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [activityMultiplier] and [calorieMultiplier] come from the onboarding
  /// profile: how hard the user trains, and whether their goal calls for a
  /// deficit or a surplus. Omitting them keeps the old maintenance-level
  /// estimate, which is what the in-app editor still wants.
  Future<bool> saveProfile({
    required double weightKg,
    required double heightCm,
    required int age,
    required NutritionGender gender,
    double activityMultiplier = 1.55,
    double calorieMultiplier = 1.0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = NutritionProfile.calculate(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        activityMultiplier: activityMultiplier,
        calorieMultiplier: calorieMultiplier,
      );
      _profile = await _repository.saveProfile(profile);
      return true;
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.onboardingSaveFailed,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
