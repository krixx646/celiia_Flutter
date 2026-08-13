import 'package:celia_flutter/l10n/app_localizations.dart';
import 'package:celia_flutter/models/nutrition_profile.dart';
import 'package:celia_flutter/providers/nutrition_tracker_provider.dart';
import 'package:celia_flutter/providers/theme_provider.dart';
import 'package:celia_flutter/utils/progress.dart';
import 'package:celia_flutter/widgets/daily_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTracker extends Mock implements NutritionTrackerProvider {}

NutritionProfile _profile() => const NutritionProfile(
  weightKg: 80,
  heightCm: 180,
  age: 30,
  gender: NutritionGender.male,
  dailyCalories: 2000,
  dailyProteinGrams: 150,
  dailyCarbsGrams: 200,
  dailyFatGrams: 60,
);

const _stats = ActiveStreakStats(
  streak: 3,
  activeToday: true,
  loggedMealToday: true,
  completedWorkoutToday: false,
  wasActiveYesterday: true,
);

NutritionTrackerProvider _tracker({
  NutritionProfile? profile,
  double calories = 0,
}) {
  final tracker = MockTracker();
  when(() => tracker.profile).thenReturn(profile);
  when(() => tracker.todayCalories).thenReturn(calories);
  when(() => tracker.todayProtein).thenReturn(60);
  when(() => tracker.todayCarbs).thenReturn(80);
  when(() => tracker.todayFat).thenReturn(20);
  when(() => tracker.todayInsight).thenReturn(null);
  return tracker;
}

Future<void> _pump(
  WidgetTester tester,
  NutritionTrackerProvider tracker,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: DailyProgressCard(tracker: tracker, streakStats: _stats),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows what is eaten against the budget, and what is left', (
    tester,
  ) async {
    await _pump(tester, _tracker(profile: _profile(), calories: 1200));

    expect(find.text('1200'), findsOneWidget);
    expect(find.text('of 2000 kcal'), findsOneWidget);
    expect(find.text('800 kcal left'), findsOneWidget);
    expect(find.text('60 / 150g'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('says how far over the budget is, not a negative remainder', (
    tester,
  ) async {
    await _pump(tester, _tracker(profile: _profile(), calories: 2500));

    expect(find.text('500 kcal over'), findsOneWidget);
    expect(find.text('-500 kcal left'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('asks for goals instead of dividing by an absent target', (
    tester,
  ) async {
    await _pump(tester, _tracker(profile: null));

    expect(find.textContaining('Set your nutrition goals'), findsOneWidget);
    expect(find.text('of 2000 kcal'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives a profile with no calorie target', (tester) async {
    const zeroTarget = NutritionProfile(
      weightKg: 80,
      heightCm: 180,
      age: 30,
      gender: NutritionGender.male,
      dailyCalories: 0,
      dailyProteinGrams: 0,
      dailyCarbsGrams: 0,
      dailyFatGrams: 0,
    );

    await _pump(tester, _tracker(profile: zeroTarget, calories: 300));

    // The ring would be NaN-wide if the division were unguarded.
    expect(tester.takeException(), isNull);
    expect(find.text('300'), findsOneWidget);
  });
}
