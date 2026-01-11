import '../models/routine.dart';

/// Compute consecutive-day streak based on `UserRoutine.lastPlayedAt`.
///
/// Rules:
/// - Counts a streak only if the user played a routine today (local date).
/// - Duplicates within the same day count once.
int computeDayStreak(
  List<UserRoutine> routines, {
  DateTime? now,
}) {
  final days = <DateTime>{};
  for (final r in routines) {
    final d = r.lastPlayedAt;
    if (d == null) continue;
    days.add(DateTime(d.year, d.month, d.day));
  }
  if (days.isEmpty) return 0;

  final n = now ?? DateTime.now();
  var cursor = DateTime(n.year, n.month, n.day);
  var streak = 0;
  while (days.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Compute user level from total completions across all saved routines.
///
/// Default: level 1 for 0-4 completions, level 2 for 5-9, etc.
int computeLevel(
  List<UserRoutine> routines, {
  int completionsPerLevel = 5,
}) {
  final per = completionsPerLevel <= 0 ? 5 : completionsPerLevel;
  final totalCompletions = routines.fold<int>(0, (sum, r) => sum + r.timesCompleted);
  return 1 + (totalCompletions ~/ per);
}

