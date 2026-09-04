import 'package:celia_flutter/models/exercise_clip.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/models/workout_session.dart';
import 'package:flutter_test/flutter_test.dart';

ExerciseClip _clip({
  String slug = 'bodyweight-squat',
  bool isCounted = true,
  int? repsPerLoop = 2,
  double clipSeconds = 5.0,
  int? defaultReps = 12,
  int? defaultHoldSeconds,
}) {
  return ExerciseClip(
    slug: slug,
    nameEn: slug,
    nameEs: slug,
    pattern: 'squat',
    videoUrl: 'https://example.test/$slug.mp4',
    isCounted: isCounted,
    repsPerLoop: repsPerLoop,
    clipSeconds: clipSeconds,
    defaultReps: defaultReps,
    defaultHoldSeconds: defaultHoldSeconds,
  );
}

RoutineStep _step({
  String title = 'Bodyweight Squat',
  int sets = 1,
  int? reps,
  int restSeconds = 0,
  int durationSeconds = 0,
  int orderIndex = 0,
}) {
  return RoutineStep(
    id: 'step-$orderIndex',
    title: title,
    durationSeconds: durationSeconds,
    orderIndex: orderIndex,
    sets: sets,
    reps: reps,
    restSeconds: restSeconds,
  );
}

void main() {
  group('WorkoutPlan', () {
    test('lays a counted exercise out as get ready, work and rest per set', () {
      final plan = WorkoutPlan.from([
        PreparedExercise(
          step: _step(sets: 3, reps: 12, restSeconds: 40),
          clip: _clip(),
        ),
      ]);

      final kinds = plan.phases.map((phase) => phase.kind).toList();
      expect(kinds, [
        WorkoutPhaseKind.getReady,
        WorkoutPhaseKind.work,
        WorkoutPhaseKind.rest,
        WorkoutPhaseKind.work,
        WorkoutPhaseKind.rest,
        WorkoutPhaseKind.work,
      ]);
    });

    test('never leaves the user resting after the last set of the workout', () {
      final plan = WorkoutPlan.from([
        PreparedExercise(
          step: _step(sets: 2, reps: 10, restSeconds: 30),
          clip: _clip(),
        ),
      ]);

      expect(plan.phases.last.kind, WorkoutPhaseKind.work);
    });

    test('times a counted set from the clip tempo, not a guess', () {
      // Two reps across eight seconds of footage is 4 seconds a rep, so ten
      // reps should run for 40 seconds.
      final plan = WorkoutPlan.from([
        PreparedExercise(
          step: _step(sets: 1, reps: 10),
          clip: _clip(repsPerLoop: 2, clipSeconds: 8.0),
        ),
      ]);

      final work = plan.phases.firstWhere(
        (phase) => phase.kind == WorkoutPhaseKind.work,
      );
      expect(work.secondsPerRep, 4.0);
      expect(work.duration, const Duration(seconds: 40));
    });

    test('slows a too-fast clip to a followable spoken tempo', () {
      // Natural tempo is 2.0s/rep; the plan stretches that to the fallback so
      // the guided player can drop playback speed and keep count locked on.
      final exercise = PreparedExercise(
        step: _step(sets: 1, reps: 10),
        clip: _clip(repsPerLoop: 1, clipSeconds: 2.0),
      );
      expect(exercise.demoPlaybackSpeed, closeTo(2.0 / 3.0, 0.001));
      expect(exercise.secondsPerRep, kFallbackSecondsPerRep);

      final plan = WorkoutPlan.from([exercise]);
      final work = plan.phases.firstWhere(
        (phase) => phase.kind == WorkoutPhaseKind.work,
      );
      expect(work.secondsPerRep, kFallbackSecondsPerRep);
      expect(work.duration, const Duration(seconds: 30));
    });

    test('falls back to a controlled tempo when there is no clip', () {
      final plan = WorkoutPlan.from([
        PreparedExercise(step: _step(sets: 1, reps: 4)),
      ]);

      final work = plan.phases.firstWhere(
        (phase) => phase.kind == WorkoutPhaseKind.work,
      );
      expect(work.secondsPerRep, kFallbackSecondsPerRep);
      expect(work.duration, const Duration(seconds: 12));
    });

    test('runs a held exercise on its prescribed duration', () {
      final plan = WorkoutPlan.from([
        PreparedExercise(
          step: _step(sets: 2, durationSeconds: 30, restSeconds: 20),
          clip: _clip(
            slug: 'side-plank',
            isCounted: false,
            repsPerLoop: null,
            defaultReps: null,
            defaultHoldSeconds: 25,
          ),
        ),
      ]);

      final work = plan.phases.where(
        (phase) => phase.kind == WorkoutPhaseKind.work,
      );
      expect(work.length, 2);
      expect(work.first.duration, const Duration(seconds: 30));
      expect(work.first.isCounted, isFalse);
    });

    test('a timed prescription beats the clip being a counted exercise', () {
      // A coach asking for 45 seconds of squats should get 45 seconds of
      // squats, even though squats are normally counted.
      final exercise = PreparedExercise(
        step: _step(sets: 1, durationSeconds: 45),
        clip: _clip(),
      );

      expect(exercise.isCounted, isFalse);
      expect(exercise.holdSeconds, 45);
    });

    test('a hold clip beats a mistaken rep prescription', () {
      // Stretches occasionally land in the library with reps set. The filmed
      // hold is authoritative — counting them makes the demo pause/loop.
      final exercise = PreparedExercise(
        step: _step(
          title: 'Supine Spinal Twist',
          sets: 1,
          reps: 10,
          durationSeconds: 40,
        ),
        clip: _clip(
          slug: 'spinal-twist',
          isCounted: false,
          repsPerLoop: null,
          defaultReps: null,
          defaultHoldSeconds: 40,
        ),
      );

      expect(exercise.isCounted, isFalse);
      expect(exercise.holdSeconds, 40);
    });

    test('rest points at the next exercise once the sets are done', () {
      final plan = WorkoutPlan.from([
        PreparedExercise(
          step: _step(title: 'Squat', sets: 2, reps: 10, restSeconds: 30),
          clip: _clip(),
        ),
        PreparedExercise(
          step: _step(title: 'Push-Up', sets: 1, reps: 10, orderIndex: 1),
          clip: _clip(slug: 'floor-push-up'),
        ),
      ]);

      final rests = plan.phases
          .where((phase) => phase.kind == WorkoutPhaseKind.rest)
          .toList();
      expect(rests.first.nextLabel, 'Squat');
      expect(rests.last.nextLabel, 'Push-Up');
    });

    test('counts one rep per tempo window and never overruns the set', () {
      final plan = WorkoutPlan.from([
        PreparedExercise(
          step: _step(sets: 1, reps: 3),
          clip: _clip(repsPerLoop: 1, clipSeconds: 3.0),
        ),
      ]);

      final work = plan.phases.firstWhere(
        (phase) => phase.kind == WorkoutPhaseKind.work,
      );
      expect(work.repAt(Duration.zero), 1);
      expect(work.repAt(const Duration(milliseconds: 2999)), 1);
      expect(work.repAt(const Duration(seconds: 3)), 2);
      expect(work.repAt(const Duration(seconds: 7)), 3);
      expect(work.repAt(const Duration(seconds: 30)), 3);
    });

    test('an empty routine produces nothing to run', () {
      expect(WorkoutPlan.from(const []).isEmpty, isTrue);
    });
  });
}
