import '../models/exercise_media.dart';
import '../models/routine.dart';
import '../utils/slug.dart';
import 'supabase_service.dart';

/// Looks up a temporary stock GIF for a routine step that has no real
/// filmed video yet, matching on [RoutineStep.exerciseSlug] when set, or a
/// slug derived from [RoutineStep.title] otherwise.
///
/// The whole `exercise_media` table is small and public, so it's fetched
/// once per app session and cached in memory.
class ExerciseMediaResolver {
  /// Maps a slug derived from a routine step's title to the closest matching
  /// slug in the stock GIF library, for common generic exercise names that
  /// don't have an exact 1:1 entry (the pack is equipment/variant-specific,
  /// e.g. it has "knee-push-ups-1" but no plain "push-up"). Checked only
  /// after an exact slug match fails.
  static const Map<String, String> _closeMatchAliases = {
    'arm-circles': 'circles-with-arms',
    'bodyweight-squats': 'squat-free-feet-together-1',
    'cool-down': 'stretch-butterfly',
    'cool-down-stretch': 'stretch-butterfly',
    'full-body': 'burpees',
    'glute-bridges': 'bridge-of-glutes',
    'high-knees': 'running-with-knee-raise',
    'jump': 'jumping-jacks',
    'lunges': 'lunge',
    'mountain-climbers': 'mountain-climber-1',
    'plank-hold': 'plank-1',
    'press-up': 'knee-push-ups-1',
    'press-ups': 'knee-push-ups-1',
    'push-ups': 'knee-push-ups-1',
    'shoulder-focus': 'circles-with-arms',
    // The AI-generated "Morning"/"Daily"/"blown" routines carry a title typo
    // ("Soulder  Focus") that slugifies to this exact key.
    'soulder-focus': 'circles-with-arms',
    'squats': 'squat-free-feet-together-1',
    'tricep-dips': 'dip-of-triceps',
    'warm-up-jog-in-place': 'jump-rope',
  };

  final SupabaseService _supabase;
  Map<String, ExerciseMedia>? _bySlug;
  Future<Map<String, ExerciseMedia>>? _loading;

  ExerciseMediaResolver({SupabaseService? supabase})
    : _supabase = supabase ?? SupabaseService.instance;

  Future<Map<String, ExerciseMedia>> _ensureLoaded() {
    if (_bySlug != null) return Future.value(_bySlug);
    return _loading ??= _load();
  }

  Future<Map<String, ExerciseMedia>> _load() async {
    try {
      final library = await _supabase.getExerciseMediaLibrary();
      final map = <String, ExerciseMedia>{
        for (final entry in library) entry.slug: entry,
      };
      _bySlug = map;
      return map;
    } catch (_) {
      // Fallback library is best-effort; never block routine playback on it.
      _bySlug = const {};
      return const {};
    } finally {
      _loading = null;
    }
  }

  /// Returns a stock GIF match for [step], or null if none is found.
  Future<ExerciseMedia?> resolveForStep(RoutineStep step) async {
    final library = await _ensureLoaded();
    if (library.isEmpty) return null;

    final explicitSlug = step.exerciseSlug?.trim();
    if (explicitSlug != null && explicitSlug.isNotEmpty) {
      final match =
          library[explicitSlug] ?? _resolveAlias(library, explicitSlug);
      if (match != null) return match;
    }

    final titleSlug = slugify(step.title);
    return library[titleSlug] ?? _resolveAlias(library, titleSlug);
  }

  ExerciseMedia? _resolveAlias(
    Map<String, ExerciseMedia> library,
    String slug,
  ) {
    final aliasSlug = _closeMatchAliases[slug];
    if (aliasSlug == null) return null;
    return library[aliasSlug];
  }
}
