/// A demo clip from the client's filmed exercise library.
///
/// The guided player loops one of these under each exercise and counts along
/// with it, so alongside the media URLs a clip carries the facts that make
/// counting possible: whether the exercise is counted or held, and how many
/// reps a single play of the clip is worth.
class ExerciseClip {
  const ExerciseClip({
    required this.slug,
    required this.nameEn,
    required this.nameEs,
    required this.pattern,
    required this.videoUrl,
    this.posterUrl,
    required this.isCounted,
    this.repsPerLoop,
    required this.clipSeconds,
    this.equipment = const [],
    this.defaultReps,
    this.defaultHoldSeconds,
    this.orientation = 'square',
  });

  final String slug;
  final String nameEn;
  final String nameEs;

  /// squat, hinge, lunge, push, pull, carry, core or recovery.
  final String pattern;

  final String videoUrl;
  final String? posterUrl;

  /// Counted exercises get a rep count spoken over them; the rest get a
  /// countdown.
  final bool isCounted;

  /// Complete reps shown by one play of the clip. Null for holds.
  final int? repsPerLoop;

  final double clipSeconds;

  /// Empty means the exercise needs nothing at all.
  final List<String> equipment;

  final int? defaultReps;
  final int? defaultHoldSeconds;
  final String orientation;

  bool get needsNoEquipment => equipment.isEmpty;

  /// How long one rep takes at the pace the clip was filmed at. This is what
  /// keeps the spoken count in step with the demonstration: the clip loops at
  /// its natural speed and a rep lands every [secondsPerRep].
  double? get secondsPerRep {
    final reps = repsPerLoop;
    if (!isCounted || reps == null || reps <= 0) return null;
    return clipSeconds / reps;
  }

  factory ExerciseClip.fromJson(Map<String, dynamic> json) {
    return ExerciseClip(
      slug: json['slug'] as String,
      nameEn: json['name_en'] as String,
      nameEs: json['name_es'] as String,
      pattern: json['pattern'] as String? ?? 'other',
      videoUrl: json['video_url'] as String,
      posterUrl: json['poster_url'] as String?,
      isCounted: (json['step_type'] as String? ?? 'reps') == 'reps',
      repsPerLoop: (json['reps_per_loop'] as num?)?.toInt(),
      clipSeconds: (json['clip_seconds'] as num?)?.toDouble() ?? 0,
      equipment:
          (json['equipment'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      defaultReps: (json['default_reps'] as num?)?.toInt(),
      defaultHoldSeconds: (json['default_hold_seconds'] as num?)?.toInt(),
      orientation: json['orientation'] as String? ?? 'square',
    );
  }
}
