import '../models/exercise_clip.dart';
import '../models/routine.dart';
import '../utils/slug.dart';
import 'supabase_service.dart';

/// Looks up the filmed demo clip for a routine step.
///
/// The library is public reference data (pack v1 + pack v2 studio takes), so
/// it is fetched once per app session and held in memory.
///
/// Matching is deliberately forgiving. A routine step may name an exercise
/// the way a coach would say it ("Push-Ups") while the library files it the
/// way it was filmed ("floor-push-up"), and a routine that fails to find its
/// clip falls back to a silent GIF, which is exactly the experience this
/// feature exists to replace.
class ExerciseClipLibrary {
  /// Names the routine generator and the chat agent tend to produce, mapped
  /// to what the clip is actually called. Only consulted after an exact slug
  /// match fails.
  static const Map<String, String> _aliases = {
    'air-squat': 'bodyweight-squat',
    'air-squats': 'bodyweight-squat',
    'bodyweight-squats': 'bodyweight-squat',
    'squat': 'bodyweight-squat',
    'squats': 'bodyweight-squat',
    'chair-squat': 'squat-to-chair',
    'chair-squats': 'squat-to-chair',
    'wall-sits': 'wall-sit',
    'lunge': 'forward-lunge',
    'lunges': 'forward-lunge',
    'forward-lunges': 'forward-lunge',
    'reverse-lunges': 'reverse-lunge',
    'lateral-lunge': 'lateral-lunge-short-range',
    'side-lunge': 'lateral-lunge-short-range',
    'step-ups': 'step-up',
    'glute-bridges': 'glute-bridge',
    'hip-thrusts': 'hip-thrust',
    'romanian-deadlift': 'romanian-deadlift-db',
    'rdl': 'romanian-deadlift-db',
    'deadlift': 'romanian-deadlift-db',
    'single-leg-deadlift': 'single-leg-rdl-supported',
    'push-up': 'floor-push-up',
    'push-ups': 'floor-push-up',
    'pushup': 'floor-push-up',
    'pushups': 'floor-push-up',
    'press-up': 'floor-push-up',
    'press-ups': 'floor-push-up',
    'knee-push-up': 'kneeling-push-up',
    'knee-push-ups': 'kneeling-push-up',
    'wall-push-ups': 'wall-push-up',
    'incline-push-ups': 'incline-push-up',
    'overhead-press': 'db-overhead-press',
    'shoulder-press': 'seated-db-shoulder-press',
    'chest-press': 'chest-press-with-band',
    'floor-press': 'db-floor-press',
    'row': 'bent-over-db-row',
    'rows': 'bent-over-db-row',
    'bent-over-row': 'bent-over-db-row',
    'dumbbell-row': 'bent-over-db-row',
    'single-arm-row': 'supported-single-arm-row',
    'lat-pulldown': 'band-pulldown',
    'pulldown': 'band-pulldown',
    'face-pull': 'face-pull-style-row',
    'reverse-flyes': 'reverse-fly',
    'farmer-carry': 'farmer-carry-db',
    'farmers-walk': 'farmer-carry-db',
    'suitcase-carry': 'suitcase-carry-one-side',
    'march': 'march-with-dumbbells',
    'plank': 'plank-variations',
    'plank-hold': 'plank-variations',
    'forearm-plank': 'plank-variations',
    'side-planks': 'side-plank',
    'mountain-climber': 'mountain-climber-slow',
    'mountain-climbers': 'mountain-climber-slow',
    'russian-twists': 'russian-twist',
    'dead-bugs': 'dead-bug',
    'bird-dogs': 'bird-dog',
    'heel-tap': 'heel-taps',
    'hollow-body-hold': 'hollow-hold',
    'cat-cow-stretch': 'cat-cow',
    'childs-pose-stretch': 'childs-pose',
    'breathing': 'simple-breathing-drills',
    'deep-breathing': 'diaphragmatic-breathing',
    'hamstring-stretch-standing': 'hamstring-stretch',
    'hip-flexor-stretch': 'kneeling-hip-flexor-stretch',
    'pigeon-stretch': 'pigeon-pose',
    'glute-stretch': 'figure-4-glute-stretch',
    'spinal-twist-stretch': 'spinal-twist',
    'chest-stretch': 'wall-pec-stretch',
    // Pack v2 studio additions
    'jumping-jack': 'jumping-jacks',
    'crunches': 'crunch',
    'sit-ups': 'sit-up',
    'situps': 'sit-up',
    'reverse-crunches': 'reverse-crunch',
    'leg-raise': 'lying-leg-raise',
    'leg-raises': 'lying-leg-raise',
    'scissor-kick': 'scissor-kicks',
    'scissors': 'scissor-kicks',
    'v-up': 'v-up-with-ball',
    'v-ups': 'v-up-with-ball',
    'jackknife': 'v-up-with-ball',
    'donkey-kicks': 'donkey-kick',
    'fire-hydrant': 'fire-hydrant-forearm',
    'fire-hydrants': 'fire-hydrant-forearm',
    'superman': 'prone-superman',
    'supermans': 'prone-superman',
    'pigeon': 'pigeon-pose',
    'forward-fold': 'standing-forward-fold',
    'toe-touch': 'standing-toe-touch',
    'toe-touches': 'standing-toe-touch',
  };

  ExerciseClipLibrary({SupabaseService? supabase})
    : _supabase = supabase ?? SupabaseService.instance;

  final SupabaseService _supabase;
  Map<String, ExerciseClip>? _bySlug;
  Future<Map<String, ExerciseClip>>? _loading;

  Future<Map<String, ExerciseClip>> _ensureLoaded() {
    final loaded = _bySlug;
    if (loaded != null) return Future.value(loaded);
    return _loading ??= _load();
  }

  Future<Map<String, ExerciseClip>> _load() async {
    try {
      final clips = await _supabase.getExerciseClips();
      final map = {for (final clip in clips) clip.slug: clip};
      _bySlug = map;
      return map;
    } catch (_) {
      // Never block a workout on the library failing to load; the player
      // falls back to whatever other media the step has.
      _bySlug = const {};
      return const {};
    } finally {
      _loading = null;
    }
  }

  /// Every clip in the library, for browsing and for routine building.
  Future<List<ExerciseClip>> all() async => (await _ensureLoaded()).values.toList();

  /// The filmed clip for [step], or null when the library has no match.
  Future<ExerciseClip?> resolveForStep(RoutineStep step) async {
    final library = await _ensureLoaded();
    if (library.isEmpty) return null;

    final explicit = step.exerciseSlug?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      final match = _lookup(library, explicit);
      if (match != null) return match;
    }

    return _lookup(library, slugify(step.title));
  }

  ExerciseClip? _lookup(Map<String, ExerciseClip> library, String slug) {
    final exact = library[slug];
    if (exact != null) return exact;

    final aliased = _aliases[slug];
    if (aliased != null) {
      final match = library[aliased];
      if (match != null) return match;
    }

    // Last resort before giving up: a singular/plural slip is the single most
    // common near miss, and it is unambiguous enough to resolve silently.
    if (slug.endsWith('s')) {
      final singular = slug.substring(0, slug.length - 1);
      final match = library[singular] ?? library[_aliases[singular] ?? ''];
      if (match != null) return match;
    }

    return null;
  }
}
