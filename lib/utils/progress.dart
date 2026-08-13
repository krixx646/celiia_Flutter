import '../l10n/app_localizations.dart';
import '../models/meal_log.dart';
import '../models/routine.dart';

/// Snapshot of the user's cross-feature activity streak.
class ActiveStreakStats {
  const ActiveStreakStats({
    required this.streak,
    required this.activeToday,
    required this.loggedMealToday,
    required this.completedWorkoutToday,
    required this.wasActiveYesterday,
  });

  final int streak;
  final bool activeToday;
  final bool loggedMealToday;
  final bool completedWorkoutToday;
  final bool wasActiveYesterday;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Collect calendar days with a completed workout and/or logged meal.
Set<DateTime> collectActiveDays(
  List<UserRoutine> routines,
  List<MealLog> meals,
) {
  final days = <DateTime>{};
  for (final routine in routines) {
    final playedAt = routine.lastPlayedAt;
    if (playedAt == null) continue;
    days.add(_dateOnly(playedAt));
  }
  for (final meal in meals) {
    days.add(_dateOnly(meal.loggedAt));
  }
  return days;
}

/// Count consecutive active days ending today (local date).
int computeStreakFromActiveDays(Set<DateTime> activeDays, {DateTime? now}) {
  if (activeDays.isEmpty) return 0;

  final n = now ?? DateTime.now();
  var cursor = _dateOnly(n);
  var streak = 0;
  while (activeDays.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Compute consecutive-day streak from workouts and logged meals.
///
/// Rules:
/// - An active day counts if the user completed a workout and/or logged a meal.
/// - Streak only counts when the user is active today (local date).
/// - Multiple activities on the same day count once.
ActiveStreakStats computeActiveStreakStats({
  required List<UserRoutine> routines,
  required List<MealLog> meals,
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  final today = _dateOnly(n);
  final yesterday = today.subtract(const Duration(days: 1));
  final activeDays = collectActiveDays(routines, meals);

  final loggedMealToday = meals.any((meal) => _isSameDay(meal.loggedAt, n));
  final completedWorkoutToday = routines.any(
    (routine) =>
        routine.lastPlayedAt != null &&
        _isSameDay(routine.lastPlayedAt!, n),
  );

  return ActiveStreakStats(
    streak: computeStreakFromActiveDays(activeDays, now: n),
    activeToday: loggedMealToday || completedWorkoutToday,
    loggedMealToday: loggedMealToday,
    completedWorkoutToday: completedWorkoutToday,
    wasActiveYesterday: activeDays.contains(yesterday),
  );
}

/// Compute consecutive-day streak based on `UserRoutine.lastPlayedAt`.
///
/// Rules:
/// - Counts a streak only if the user played a routine today (local date).
/// - Duplicates within the same day count once.
int computeDayStreak(List<UserRoutine> routines, {DateTime? now}) {
  final days = <DateTime>{};
  for (final r in routines) {
    final d = r.lastPlayedAt;
    if (d == null) continue;
    days.add(_dateOnly(d));
  }
  return computeStreakFromActiveDays(days, now: now);
}

/// Total completed workouts across all saved routines.
int computeTotalWorkoutCompletions(List<UserRoutine> routines) {
  return routines.fold<int>(0, (sum, r) => sum + r.timesCompleted);
}

/// Compute user level from total completions across all saved routines.
///
/// Default: level 1 for 0-4 completions, level 2 for 5-9, etc.
int computeLevel(List<UserRoutine> routines, {int completionsPerLevel = 5}) {
  final per = completionsPerLevel <= 0 ? 5 : completionsPerLevel;
  final totalCompletions = computeTotalWorkoutCompletions(routines);
  return 1 + (totalCompletions ~/ per);
}

/// Short coaching copy for Home and Profile surfaces.
String buildStreakNudge(AppLocalizations l10n, ActiveStreakStats stats) {
  if (stats.streak == 0) {
    if (stats.activeToday) return l10n.streakDayOneStarted;
    if (stats.wasActiveYesterday) return l10n.streakRebuild;
    return l10n.streakStart;
  }

  if (stats.streak >= 7) return l10n.streakLongRun(stats.streak);

  if (stats.loggedMealToday && stats.completedWorkoutToday) {
    return l10n.streakBothLogged(stats.streak);
  }
  if (stats.loggedMealToday) return l10n.streakNeedWorkout(stats.streak);
  if (stats.completedWorkoutToday) return l10n.streakNeedMeal(stats.streak);
  return l10n.streakStayActive(stats.streak);
}

/// Hidden context appended to chat messages so Celia can coach on consistency.
String buildStreakChatContext(ActiveStreakStats stats) {
  return '[Activity context for Celia: User has a ${stats.streak}-day active streak '
      '(days with a logged meal and/or completed workout). '
      'Active today: ${stats.activeToday}. '
      'Meal logged today: ${stats.loggedMealToday}. '
      'Workout completed today: ${stats.completedWorkoutToday}. '
      'Encourage consistency when relevant.]';
}

/// Combine nutrition and activity context for chat coaching.
String buildCoachContext({
  required String nutritionContext,
  required ActiveStreakStats streakStats,
}) {
  final parts = <String>[];
  if (nutritionContext.isNotEmpty) {
    parts.add(nutritionContext);
  }
  parts.add(buildStreakChatContext(streakStats));
  return parts.join('\n');
}
