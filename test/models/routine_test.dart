import 'package:celia_flutter/models/routine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Routine labels + JSON', () {
    final r = Routine(
      id: 'r1',
      title: 'T',
      description: 'D',
      durationMinutes: 75,
      difficulty: RoutineDifficulty.hard,
      category: RoutineCategory.hiit,
      thumbnailUrl: null,
      steps: const [
        RoutineStep(
          id: 's1',
          title: 'Step',
          description: null,
          durationSeconds: 30,
          videoId: 'v1',
          thumbnailUrl: null,
          orderIndex: 0,
        ),
      ],
      createdBy: 'u',
      createdAt: DateTime(2026, 1, 10),
      updatedAt: null,
      isPublished: false,
      isCurated: false,
      tags: const ['a'],
      caloriesBurned: 10,
      equipment: 'None',
    );

    expect(r.difficultyLabel, 'Hard');
    expect(r.categoryLabel, 'HIIT');
    expect(r.durationLabel, '1h 15m');

    final rt = Routine.fromJson(r.toJson());
    expect(rt.id, 'r1');
    expect(rt.steps.single.orderIndex, 0);
    expect(rt.isPublished, isFalse);
  });

  test('Routine duration label under 60 minutes', () {
    final r = Routine(
      id: 'r2',
      title: 'T',
      durationMinutes: 20,
      difficulty: RoutineDifficulty.easy,
      category: RoutineCategory.yoga,
      steps: const [],
      createdBy: 'u',
      createdAt: DateTime(2026, 1, 10),
    );
    expect(r.durationLabel, '20 min');
  });
}
