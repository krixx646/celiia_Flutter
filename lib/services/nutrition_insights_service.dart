import '../models/meal_log.dart';
import '../models/nutrition_profile.dart';

/// Which observation an insight is making.
///
/// The service decides what is worth saying; the wording lives in the widget
/// layer (see `insightText`) so the same insight reads in whatever language
/// the app is currently set to, including after the user changes it.
enum NutritionInsightKind {
  startFueling,
  aboveTarget,
  lowProtein,
  almostThere,
  onTrack,
  weeklyRhythm,
  weeklyTrend,
}

class NutritionInsight {
  const NutritionInsight({
    required this.kind,
    required this.tone,
    this.calories = 0,
    this.grams = 0,
    this.loggedDays = 0,
    this.averageCalories = 0,
    this.deltaCalories = 0,
  });

  final NutritionInsightKind kind;
  final NutritionInsightTone tone;

  /// Numbers the wording needs. Which ones are meaningful depends on [kind].
  final int calories;
  final int grams;
  final int loggedDays;
  final int averageCalories;
  final int deltaCalories;
}

enum NutritionInsightTone { positive, neutral, warning }

class NutritionInsightsService {
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<MealLog> mealsForDay(List<MealLog> meals, DateTime day) {
    return meals.where((meal) => _isSameDay(meal.loggedAt, day)).toList();
  }

  static double sumCalories(Iterable<MealLog> meals) =>
      meals.fold<double>(0, (sum, meal) => sum + meal.calories);

  static double sumProtein(Iterable<MealLog> meals) =>
      meals.fold<double>(0, (sum, meal) => sum + meal.proteinGrams);

  static double sumCarbs(Iterable<MealLog> meals) =>
      meals.fold<double>(0, (sum, meal) => sum + meal.carbsGrams);

  static double sumFat(Iterable<MealLog> meals) =>
      meals.fold<double>(0, (sum, meal) => sum + meal.fatGrams);

  static NutritionInsight? buildTodayInsight({
    required NutritionProfile profile,
    required double todayCalories,
    required double todayProtein,
    required double todayCarbs,
    required double todayFat,
  }) {
    final remainingCalories = profile.dailyCalories - todayCalories;
    final proteinGap = profile.dailyProteinGrams - todayProtein;

    if (todayCalories <= 0) {
      return const NutritionInsight(
        kind: NutritionInsightKind.startFueling,
        tone: NutritionInsightTone.neutral,
      );
    }

    if (remainingCalories < -150) {
      return NutritionInsight(
        kind: NutritionInsightKind.aboveTarget,
        tone: NutritionInsightTone.warning,
        calories: (-remainingCalories).round(),
      );
    }

    if (proteinGap > 25) {
      return NutritionInsight(
        kind: NutritionInsightKind.lowProtein,
        tone: NutritionInsightTone.neutral,
        grams: proteinGap.round(),
      );
    }

    if (remainingCalories <= 350 && remainingCalories >= 0) {
      return NutritionInsight(
        kind: NutritionInsightKind.almostThere,
        tone: NutritionInsightTone.positive,
        calories: remainingCalories.round(),
      );
    }

    return NutritionInsight(
      kind: NutritionInsightKind.onTrack,
      tone: NutritionInsightTone.positive,
      calories: remainingCalories.round(),
      grams: proteinGap.round(),
    );
  }

  static NutritionInsight? buildWeeklyInsight({
    required List<MealLog> meals,
    required NutritionProfile profile,
  }) {
    final now = DateTime.now();
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index)),
    );

    final dailyTotals = days.map((day) {
      final dayMeals = mealsForDay(meals, day);
      return sumCalories(dayMeals);
    }).toList();

    final loggedDays = dailyTotals.where((value) => value > 0).length;
    if (loggedDays == 0) {
      return const NutritionInsight(
        kind: NutritionInsightKind.weeklyRhythm,
        tone: NutritionInsightTone.neutral,
      );
    }

    final average =
        dailyTotals.fold<double>(0, (sum, value) => sum + value) / loggedDays;
    final delta = average - profile.dailyCalories;

    return NutritionInsight(
      kind: NutritionInsightKind.weeklyTrend,
      tone: delta.abs() < 120
          ? NutritionInsightTone.positive
          : NutritionInsightTone.neutral,
      loggedDays: loggedDays,
      averageCalories: average.round(),
      deltaCalories: delta.round(),
    );
  }

  static String buildChatContext({
    required NutritionProfile profile,
    required double todayCalories,
    required double todayProtein,
    required double todayCarbs,
    required double todayFat,
    required int todayMealCount,
  }) {
    final remainingCalories = profile.dailyCalories - todayCalories;
    final remainingProtein = profile.dailyProteinGrams - todayProtein;
    return '[Nutrition context for Celia: Today the user has logged '
        '${todayCalories.round()} kcal across $todayMealCount meals '
        '(${todayProtein.round()}g protein, ${todayCarbs.round()}g carbs, ${todayFat.round()}g fat). '
        'Daily targets: ${profile.dailyCalories.round()} kcal, '
        '${profile.dailyProteinGrams.round()}g protein, '
        '${profile.dailyCarbsGrams.round()}g carbs, '
        '${profile.dailyFatGrams.round()}g fat. '
        'Remaining today: ${remainingCalories.round()} kcal and '
        '${remainingProtein.round()}g protein. '
        'Use this when giving nutrition advice.]';
  }
}
