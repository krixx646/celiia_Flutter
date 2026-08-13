import 'package:flutter/foundation.dart';

import '../models/meal_log.dart';
import '../models/nutrition_profile.dart';
import '../services/calorie_scanner_service.dart';
import '../services/nutrition_insights_service.dart';
import '../utils/user_facing_error.dart';

class NutritionTrackerProvider extends ChangeNotifier {
  NutritionTrackerProvider({CalorieScannerService? mealService})
    : _mealService = mealService ?? CalorieScannerService();

  final CalorieScannerService _mealService;

  List<MealLog> _meals = const [];
  NutritionProfile? _profile;
  bool _isLoading = false;
  String? _error;

  List<MealLog> get meals => _meals;
  NutritionProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile?.isComplete ?? false;

  List<MealLog> get todayMeals {
    final now = DateTime.now();
    return NutritionInsightsService.mealsForDay(_meals, now);
  }

  double get todayCalories => NutritionInsightsService.sumCalories(todayMeals);
  double get todayProtein => NutritionInsightsService.sumProtein(todayMeals);
  double get todayCarbs => NutritionInsightsService.sumCarbs(todayMeals);
  double get todayFat => NutritionInsightsService.sumFat(todayMeals);

  double? get remainingCalories =>
      _profile == null ? null : _profile!.dailyCalories - todayCalories;

  double? get remainingProtein =>
      _profile == null ? null : _profile!.dailyProteinGrams - todayProtein;

  NutritionInsight? get todayInsight {
    final profile = _profile;
    if (profile == null) return null;
    return NutritionInsightsService.buildTodayInsight(
      profile: profile,
      todayCalories: todayCalories,
      todayProtein: todayProtein,
      todayCarbs: todayCarbs,
      todayFat: todayFat,
    );
  }

  NutritionInsight? get weeklyInsight {
    final profile = _profile;
    if (profile == null) return null;
    return NutritionInsightsService.buildWeeklyInsight(
      meals: _meals,
      profile: profile,
    );
  }

  String get chatContext {
    final profile = _profile;
    if (profile == null) return '';
    return NutritionInsightsService.buildChatContext(
      profile: profile,
      todayCalories: todayCalories,
      todayProtein: todayProtein,
      todayCarbs: todayCarbs,
      todayFat: todayFat,
      todayMealCount: todayMeals.length,
    );
  }

  List<double> get lastSevenDayCalories {
    final now = DateTime.now();
    return List<double>.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      return NutritionInsightsService.sumCalories(
        NutritionInsightsService.mealsForDay(_meals, day),
      );
    });
  }

  Future<void> refresh({NutritionProfile? profile}) async {
    _isLoading = true;
    _error = null;
    if (profile != null) {
      _profile = profile;
    }
    notifyListeners();

    try {
      _meals = await _mealService.getMealLogs();
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallbackOf: (l10n) => l10n.errorRefreshNutrition,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void syncProfile(NutritionProfile? profile) {
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _meals = const [];
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
