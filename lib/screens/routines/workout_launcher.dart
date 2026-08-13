import 'package:flutter/material.dart';

import '../../config/env.dart';
import '../../models/routine.dart';
import 'guided_workout_screen.dart';
import 'routine_player_screen.dart';

/// Picks the player a routine should run in.
///
/// Everything goes through the guided, coached player now. The old
/// playlist-style player is kept behind the flag so a bad release can be
/// reverted without shipping code.
Widget buildWorkoutPlayer(Routine routine) {
  if (Env.enableGuidedWorkouts) {
    return GuidedWorkoutScreen(routine: routine);
  }
  return RoutinePlayerScreen(routine: routine);
}

/// Opens [routine] in the right player.
Future<void> openWorkout(BuildContext context, Routine routine, {bool useRootNavigator = false}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    MaterialPageRoute(builder: (_) => buildWorkoutPlayer(routine)),
  );
}
