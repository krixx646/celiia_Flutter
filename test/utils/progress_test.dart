import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/utils/progress.dart';
import 'package:flutter_test/flutter_test.dart';

UserRoutine ur({
  required String id,
  required String userId,
  required String routineId,
  DateTime? savedAt,
  DateTime? lastPlayedAt,
  int timesCompleted = 0,
  bool isFavorite = false,
}) {
  return UserRoutine(
    id: id,
    userId: userId,
    routineId: routineId,
    savedAt: savedAt ?? DateTime(2026, 1, 1),
    lastPlayedAt: lastPlayedAt,
    timesCompleted: timesCompleted,
    isFavorite: isFavorite,
  );
}

void main() {
  group('computeDayStreak', () {
    test('returns 0 when there are no played days', () {
      final streak = computeDayStreak([
        ur(id: '1', userId: 'u', routineId: 'r', lastPlayedAt: null),
      ], now: DateTime(2026, 1, 10, 12));
      expect(streak, 0);
    });

    test('requires today to count a streak', () {
      final streak = computeDayStreak([
        ur(id: '1', userId: 'u', routineId: 'r', lastPlayedAt: DateTime(2026, 1, 9, 23, 59)),
      ], now: DateTime(2026, 1, 10, 12));
      expect(streak, 0);
    });

    test('counts consecutive days starting from today', () {
      final streak = computeDayStreak([
        ur(id: '1', userId: 'u', routineId: 'r', lastPlayedAt: DateTime(2026, 1, 10, 8)),
        ur(id: '2', userId: 'u', routineId: 'r2', lastPlayedAt: DateTime(2026, 1, 9, 20)),
        ur(id: '3', userId: 'u', routineId: 'r3', lastPlayedAt: DateTime(2026, 1, 8, 7)),
      ], now: DateTime(2026, 1, 10, 12));
      expect(streak, 3);
    });

    test('deduplicates multiple plays in the same day', () {
      final streak = computeDayStreak([
        ur(id: '1', userId: 'u', routineId: 'r', lastPlayedAt: DateTime(2026, 1, 10, 8)),
        ur(id: '2', userId: 'u', routineId: 'r2', lastPlayedAt: DateTime(2026, 1, 10, 22)),
        ur(id: '3', userId: 'u', routineId: 'r3', lastPlayedAt: DateTime(2026, 1, 9, 7)),
      ], now: DateTime(2026, 1, 10, 12));
      expect(streak, 2);
    });
  });

  group('computeLevel', () {
    test('level 1 at 0 completions', () {
      expect(computeLevel([]), 1);
    });

    test('level increases every 5 completions by default', () {
      final lvl1 = computeLevel([
        ur(id: '1', userId: 'u', routineId: 'r', timesCompleted: 4),
      ]);
      final lvl2 = computeLevel([
        ur(id: '1', userId: 'u', routineId: 'r', timesCompleted: 5),
      ]);
      final lvl3 = computeLevel([
        ur(id: '1', userId: 'u', routineId: 'r', timesCompleted: 10),
      ]);

      expect(lvl1, 1);
      expect(lvl2, 2);
      expect(lvl3, 3);
    });
  });
}

