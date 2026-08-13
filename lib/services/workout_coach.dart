import 'package:flutter/services.dart';

import '../models/workout_session.dart';

/// The voice and feel of a guided workout.
///
/// The player reports what is happening through this interface and never
/// calls a speech engine directly, so giving Celia a real coaching voice is a
/// matter of adding an implementation rather than reworking the player.
abstract class WorkoutCoach {
  /// A new phase has begun.
  void onPhaseStart(WorkoutPhase phase);

  /// The user should be on rep [rep] of [total] right now.
  void onRep(int rep, int total);

  /// The final seconds of a rest or hold, counted down.
  void onFinalSeconds(int secondsRemaining);

  /// The workout is finished.
  void onComplete();

  /// Stop anything in flight, for a pause or when leaving the screen.
  void stop();
}

/// The default coach: no speech, but the phase changes and rep boundaries are
/// still felt through the handset.
///
/// This is deliberately useful on its own. A user can run an entire workout
/// with the phone face down and know from their wrist when a rep lands and
/// when rest is over.
class HapticCoach implements WorkoutCoach {
  @override
  void onPhaseStart(WorkoutPhase phase) {
    switch (phase.kind) {
      case WorkoutPhaseKind.getReady:
        HapticFeedback.selectionClick();
      case WorkoutPhaseKind.work:
        HapticFeedback.heavyImpact();
      case WorkoutPhaseKind.rest:
        HapticFeedback.mediumImpact();
    }
  }

  @override
  void onRep(int rep, int total) => HapticFeedback.lightImpact();

  @override
  void onFinalSeconds(int secondsRemaining) => HapticFeedback.selectionClick();

  @override
  void onComplete() => HapticFeedback.heavyImpact();

  @override
  void stop() {}
}
