import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/celia_chat_message.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/routines/routine_detail_screen.dart';
import '../screens/routines/workout_launcher.dart';
import '../screens/tools/calorie_scanner_screen.dart';
import '../screens/tools/nutrition_screen.dart';

/// Runs client-executed app-control tools emitted by the Avatar Mode agent.
///
/// The server acknowledges these tools immediately; the real work happens here
/// via [Navigator] pushes on the Avatar Mode shell's nested navigator.
class AvatarActionDispatcher {
  AvatarActionDispatcher(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  BuildContext? get _context => navigatorKey.currentContext;

  Future<void> dispatchAll(Iterable<ChatToolCall> calls) async {
    for (final call in calls) {
      await dispatch(call);
    }
  }

  Future<void> dispatch(ChatToolCall call) async {
    final context = _context;
    if (context == null || !context.mounted) return;

    switch (call.toolName) {
      case 'open_screen':
        await _openScreen(context, call.input?['screen']?.toString());
      case 'open_routine':
        await _openRoutine(context, call.input?['routineId']?.toString());
      case 'start_workout':
        await _startWorkout(context, call.input?['routineId']?.toString());
      case 'open_meal_scanner':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CalorieScannerScreen()),
        );
      case 'go_back':
        final nav = Navigator.of(context);
        if (nav.canPop()) nav.pop();
      default:
        break;
    }
  }

  Future<void> _openScreen(BuildContext context, String? screen) async {
    final Widget page;
    switch (screen) {
      case 'home':
        page = const HomeScreen();
      case 'library':
        page = const LibraryScreen();
      case 'profile':
        page = const ProfileScreen();
      case 'nutrition':
        page = const NutritionScreen();
      case 'scanner':
        page = const CalorieScannerScreen();
      default:
        return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openRoutine(BuildContext context, String? routineId) async {
    final routine = await _resolveRoutine(context, routineId);
    if (routine == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoutineDetailScreen(routine: routine)),
    );
  }

  Future<void> _startWorkout(BuildContext context, String? routineId) async {
    final routine = await _resolveRoutine(context, routineId);
    if (routine == null || !context.mounted) return;
    await openWorkout(context, routine);
  }

  Future<Routine?> _resolveRoutine(
    BuildContext context,
    String? routineId,
  ) async {
    if (routineId == null || routineId.isEmpty) return null;
    final routines = context.read<RoutineProvider>();

    Routine? find() {
      for (final r in routines.routines) {
        if (r.id == routineId) return r;
      }
      for (final r in [...routines.curatedRoutines, ...routines.aiRoutines]) {
        if (r.id == routineId) return r;
      }
      return null;
    }

    final hit = find();
    if (hit != null) return hit;

    await routines.loadRoutines(refresh: true);
    if (!context.mounted) return null;
    return find();
  }
}
