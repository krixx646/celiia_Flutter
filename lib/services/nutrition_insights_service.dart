import '../models/meal_log.dart';
import '../models/nutrition_profile.dart';

class NutritionInsight {
  const NutritionInsight({
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final NutritionInsightTone tone;
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
        title: 'Start fueling today',
        message:
            'You have your full calorie budget left. Scan or log your first meal to stay on track.',
        tone: NutritionInsightTone.neutral,
      );
    }

    if (remainingCalories < -150) {
      return NutritionInsight(
        title: 'Above target today',
        message:
            'You are ${(-remainingCalories).round()} kcal above your daily target. Keep dinner lighter or add a short workout.',
        tone: NutritionInsightTone.warning,
      );
    }

    if (proteinGap > 25) {
      return NutritionInsight(
        title: 'Protein is still low',
        message:
            'You still need about ${proteinGap.round()}g protein today to hit your target.',
        tone: NutritionInsightTone.neutral,
      );
    }

    if (remainingCalories <= 350 && remainingCalories >= 0) {
      return NutritionInsight(
        title: 'Almost at your goal',
        message:
            'You have ${remainingCalories.round()} kcal left today. A balanced snack should fit nicely.',
        tone: NutritionInsightTone.positive,
      );
    }

    return NutritionInsight(
      title: 'On track today',
      message:
          '${remainingCalories.round()} kcal and ${proteinGap.round()}g protein left to reach your daily targets.',
      tone: NutritionInsightTone.positive,
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
        title: 'Build your weekly rhythm',
        message:
            'Log meals across the week so Celia can spot patterns and coach you better.',
        tone: NutritionInsightTone.neutral,
      );
    }

    final average =
        dailyTotals.fold<double>(0, (sum, value) => sum + value) / loggedDays;
    final delta = average - profile.dailyCalories;
    final direction = delta.abs() < 80
        ? 'right around your daily target'
        : delta > 0
        ? '${delta.round()} kcal above your target on average'
        : '${(-delta).round()} kcal below your target on average';

    return NutritionInsight(
      title: 'Weekly trend',
      message:
          'You logged meals on $loggedDays of the last 7 days, averaging ${average.round()} kcal — $direction.',
      tone: delta.abs() < 120
          ? NutritionInsightTone.positive
          : NutritionInsightTone.neutral,
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
