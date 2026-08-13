import 'package:json_annotation/json_annotation.dart';

part 'routine.g.dart';

/// Difficulty level for routines
enum RoutineDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('medium')
  medium,
  @JsonValue('hard')
  hard,
}

/// Category/type of routine
enum RoutineCategory {
  @JsonValue('strength')
  strength,
  @JsonValue('cardio')
  cardio,
  @JsonValue('flexibility')
  flexibility,
  @JsonValue('mindfulness')
  mindfulness,
  @JsonValue('dance')
  dance,
  @JsonValue('hiit')
  hiit,
  @JsonValue('yoga')
  yoga,
  @JsonValue('custom')
  custom,
}

/// A single exercise/step within a routine
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RoutineStep {
  final String id;
  final String title;
  final String? description;
  final int durationSeconds;
  final String? videoId; // Cloudflare Stream video ID
  final String? thumbnailUrl;
  final int orderIndex;

  /// Stable slug identifying the exercise (e.g. "squat", "pull-up"), used to
  /// look up a temporary stock GIF in `exercise_media` when no real video is
  /// ready yet. Optional — if absent, it's derived from [title] at runtime.
  final String? exerciseSlug;

  /// How many rounds of this exercise to do before moving on.
  final int sets;

  /// Reps per set for a counted exercise. Null means the exercise is held or
  /// worked for time instead, in which case [durationSeconds] is the target.
  final int? reps;

  /// Recovery between sets, and after the last set before the next exercise.
  final int restSeconds;

  const RoutineStep({
    required this.id,
    required this.title,
    this.description,
    required this.durationSeconds,
    this.videoId,
    this.thumbnailUrl,
    required this.orderIndex,
    this.exerciseSlug,
    this.sets = 1,
    this.reps,
    this.restSeconds = 0,
  });

  /// Whether the guided player counts reps out loud for this step or runs a
  /// countdown. Routines written before sets and reps existed have no rep
  /// prescription, so they keep working as timed steps.
  bool get isCounted => (reps ?? 0) > 0;

  factory RoutineStep.fromJson(Map<String, dynamic> json) =>
      _$RoutineStepFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineStepToJson(this);
}

/// A complete fitness routine
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Routine {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final RoutineDifficulty difficulty;
  final RoutineCategory category;
  final String? thumbnailUrl;
  final List<RoutineStep> steps;
  final String createdBy; // 'admin', 'ai', or user ID
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublished;
  final bool isCurated; // Admin-created vs AI-generated
  final List<String> tags;
  final int? caloriesBurned;
  final String? equipment; // e.g., "None", "Dumbbells", "Mat"

  const Routine({
    required this.id,
    required this.title,
    this.description,
    required this.durationMinutes,
    required this.difficulty,
    required this.category,
    this.thumbnailUrl,
    required this.steps,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isPublished = true,
    this.isCurated = false,
    this.tags = const [],
    this.caloriesBurned,
    this.equipment,
  });

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  /// Get difficulty display string
  String get difficultyLabel {
    switch (difficulty) {
      case RoutineDifficulty.easy:
        return 'Easy';
      case RoutineDifficulty.medium:
        return 'Medium';
      case RoutineDifficulty.hard:
        return 'Hard';
    }
  }

  /// Get category display string
  String get categoryLabel {
    switch (category) {
      case RoutineCategory.strength:
        return 'Strength';
      case RoutineCategory.cardio:
        return 'Cardio';
      case RoutineCategory.flexibility:
        return 'Flexibility';
      case RoutineCategory.mindfulness:
        return 'Mindfulness';
      case RoutineCategory.dance:
        return 'Dance';
      case RoutineCategory.hiit:
        return 'HIIT';
      case RoutineCategory.yoga:
        return 'Yoga';
      case RoutineCategory.custom:
        return 'Custom';
    }
  }

  /// Get formatted duration string
  String get durationLabel {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

/// User's saved/favorited routines
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserRoutine {
  final String id;
  final String userId;
  final String routineId;
  final DateTime savedAt;
  final DateTime? lastPlayedAt;
  final int timesCompleted;
  final bool isFavorite;

  const UserRoutine({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.savedAt,
    this.lastPlayedAt,
    this.timesCompleted = 0,
    this.isFavorite = false,
  });

  factory UserRoutine.fromJson(Map<String, dynamic> json) =>
      _$UserRoutineFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoutineToJson(this);
}

/// What came back from asking the backend for a routine: either a new one, or
/// the original it pointed us at because that exact sequence already existed.
class GeneratedRoutine {
  const GeneratedRoutine({required this.routine, required this.alreadyExisted});

  final Routine routine;
  final bool alreadyExisted;
}
