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
        fallback: 'Could not load your nutrition profile.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({
    required double weightKg,
    required double heightCm,
    required int age,
    required NutritionGender gender,
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
      );
      _profile = await _repository.saveProfile(profile);
      return true;
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallback: 'Could not save your nutrition profile.',
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
