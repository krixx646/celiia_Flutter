import 'package:celia_flutter/l10n/app_localizations.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/models/workout_session.dart';
import 'package:celia_flutter/services/workout_coach.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures what a coach was asked to say without touching audio hardware.
class _RecordingCoach implements WorkoutCoach {
  final phases = <WorkoutPhaseKind>[];
  final reps = <int>[];
  final countdowns = <int>[];
  var completed = 0;
  var stopped = 0;

  @override
  void onPhaseStart(WorkoutPhase phase) => phases.add(phase.kind);

  @override
  void onRep(int rep, int total) => reps.add(rep);

  @override
  void onFinalSeconds(int secondsRemaining) => countdowns.add(secondsRemaining);

  @override
  void onComplete() => completed++;

  @override
  void stop() => stopped++;
}

void main() {
  test('coach cue strings exist in English and Spanish', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final es = await AppLocalizations.delegate.load(const Locale('es'));

    expect(en.coachGetReady('Squat'), contains('Squat'));
    expect(es.coachGetReady('Sentadilla'), contains('Sentadilla'));
    expect(en.coachStartReps(10), contains('10'));
    expect(es.coachStartReps(10), contains('10'));
    expect(en.coachComplete, isNot(equals(es.coachComplete)));
  });

  test('recording coach receives phase and rep events', () {
    final coach = _RecordingCoach();
    const step = RoutineStep(
      id: '1',
      title: 'Squat',
      durationSeconds: 30,
      orderIndex: 0,
      sets: 1,
      reps: 8,
    );
    final phase = WorkoutPhase(
      kind: WorkoutPhaseKind.work,
      step: step,
      stepIndex: 0,
      totalSteps: 1,
      setNumber: 1,
      totalSets: 1,
      duration: const Duration(seconds: 24),
      reps: 8,
      secondsPerRep: 3,
    );

    coach.onPhaseStart(phase);
    coach.onRep(1, 8);
    coach.onComplete();
    coach.stop();

    expect(coach.phases, [WorkoutPhaseKind.work]);
    expect(coach.reps, [1]);
    expect(coach.completed, 1);
    expect(coach.stopped, 1);
  });
}
