import 'exercise_clip.dart';
import 'routine.dart';

/// What the player is doing at a given moment.
enum WorkoutPhaseKind {
  /// A short lead-in before an exercise starts, so the user can get into
  /// position instead of being dropped straight into the first rep.
  getReady,

  /// A working set: reps counted along with the looping clip, or a hold.
  work,

  /// Recovery. The client was explicit that the app rests with the user
  /// rather than just pausing, so rest is a real phase with its own clock.
  rest,
}

/// When there is no clip to take a tempo from, count at a pace that suits an
/// unhurried, controlled rep.
const double kFallbackSecondsPerRep = 3.0;

const Duration kGetReadyDuration = Duration(seconds: 10);

/// Used when a routine asks for rest but does not say how much.
const int kDefaultRestSeconds = 30;

/// Used when a held exercise arrives with no duration at all.
const int kDefaultHoldSeconds = 30;

/// One stretch of the workout with a single clock and a single instruction.
class WorkoutPhase {
  const WorkoutPhase({
    required this.kind,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.setNumber,
    required this.totalSets,
    required this.duration,
    this.clip,
    this.reps,
    this.secondsPerRep,
    this.nextLabel,
  });

  final WorkoutPhaseKind kind;
  final RoutineStep step;
  final int stepIndex;
  final int totalSteps;
  final int setNumber;
  final int totalSets;
  final Duration duration;
  final ExerciseClip? clip;

  /// Reps to perform in this phase. Null for holds and for non-work phases.
  final int? reps;

  /// How often a rep lands, matching the clip's filmed tempo where there is
  /// one. Counting off this keeps the spoken numbers with the demonstration.
  final double? secondsPerRep;

  /// What comes after this phase, so rest can tell the user what to prepare
  /// for rather than leaving them guessing.
  final String? nextLabel;

  bool get isCounted => kind == WorkoutPhaseKind.work && (reps ?? 0) > 0;

  /// Which rep the user should be on after [elapsed] of this phase, from 1 to
  /// [reps]. Null when nothing is being counted.
  int? repAt(Duration elapsed) {
    final total = reps;
    final perRep = secondsPerRep;
    if (!isCounted || total == null || perRep == null || perRep <= 0) {
      return null;
    }
    final index = (elapsed.inMilliseconds / (perRep * 1000)).floor() + 1;
    return index.clamp(1, total);
  }
}

/// An exercise paired with the clip that demonstrates it.
class PreparedExercise {
  const PreparedExercise({required this.step, this.clip});

  final RoutineStep step;
  final ExerciseClip? clip;

  /// Whether this exercise is counted in reps rather than held for time.
  ///
  /// The routine's own prescription wins, because a coach may ask for a timed
  /// set of an exercise that is normally counted. The clip only decides when
  /// the routine says nothing.
  bool get isCounted {
    if (step.isCounted) return true;
    if (step.durationSeconds > 0) return false;
    return clip?.isCounted ?? false;
  }

  int get reps => step.reps ?? clip?.defaultReps ?? 10;

  int get holdSeconds {
    if (step.durationSeconds > 0) return step.durationSeconds;
    return clip?.defaultHoldSeconds ?? kDefaultHoldSeconds;
  }

  double get secondsPerRep => clip?.secondsPerRep ?? kFallbackSecondsPerRep;

  String get title => step.title;
}

/// The full workout laid out as a list of phases to run in order.
///
/// Building the whole plan up front rather than deciding what comes next on
/// the fly means the player can show total time remaining, let the user jump
/// around, and keep a spoken count honest across pauses.
class WorkoutPlan {
  const WorkoutPlan(this.phases);

  final List<WorkoutPhase> phases;

  bool get isEmpty => phases.isEmpty;

  Duration get totalDuration =>
      phases.fold(Duration.zero, (sum, phase) => sum + phase.duration);

  factory WorkoutPlan.from(List<PreparedExercise> exercises) {
    final phases = <WorkoutPhase>[];

    for (var stepIndex = 0; stepIndex < exercises.length; stepIndex++) {
      final exercise = exercises[stepIndex];
      final totalSets = exercise.step.sets < 1 ? 1 : exercise.step.sets;
      final isLastExercise = stepIndex == exercises.length - 1;

      WorkoutPhase phase(
        WorkoutPhaseKind kind, {
        required int setNumber,
        required Duration duration,
        int? reps,
        double? secondsPerRep,
        String? nextLabel,
      }) {
        return WorkoutPhase(
          kind: kind,
          step: exercise.step,
          stepIndex: stepIndex,
          totalSteps: exercises.length,
          setNumber: setNumber,
          totalSets: totalSets,
          duration: duration,
          clip: exercise.clip,
          reps: reps,
          secondsPerRep: secondsPerRep,
          nextLabel: nextLabel,
        );
      }

      phases.add(
        phase(
          WorkoutPhaseKind.getReady,
          setNumber: 1,
          duration: kGetReadyDuration,
          nextLabel: exercise.title,
        ),
      );

      for (var set = 1; set <= totalSets; set++) {
        if (exercise.isCounted) {
          final reps = exercise.reps;
          final perRep = exercise.secondsPerRep;
          phases.add(
            phase(
              WorkoutPhaseKind.work,
              setNumber: set,
              duration: Duration(
                milliseconds: (reps * perRep * 1000).round(),
              ),
              reps: reps,
              secondsPerRep: perRep,
            ),
          );
        } else {
          phases.add(
            phase(
              WorkoutPhaseKind.work,
              setNumber: set,
              duration: Duration(seconds: exercise.holdSeconds),
            ),
          );
        }

        // No rest after the very last set of the workout: the user is done,
        // and sitting them in front of a countdown would be strange.
        final isLastSet = set == totalSets;
        if (isLastSet && isLastExercise) continue;

        final restSeconds = exercise.step.restSeconds > 0
            ? exercise.step.restSeconds
            : kDefaultRestSeconds;
        final nextLabel = isLastSet
            ? exercises[stepIndex + 1].title
            : exercise.title;

        phases.add(
          phase(
            WorkoutPhaseKind.rest,
            setNumber: set,
            duration: Duration(seconds: restSeconds),
            nextLabel: nextLabel,
          ),
        );
      }
    }

    return WorkoutPlan(phases);
  }
}
