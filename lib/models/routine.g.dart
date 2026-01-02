// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutineStep _$RoutineStepFromJson(Map<String, dynamic> json) => RoutineStep(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      videoId: json['video_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      orderIndex: (json['order_index'] as num).toInt(),
    );

Map<String, dynamic> _$RoutineStepToJson(RoutineStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'duration_seconds': instance.durationSeconds,
      'video_id': instance.videoId,
      'thumbnail_url': instance.thumbnailUrl,
      'order_index': instance.orderIndex,
    };

Routine _$RoutineFromJson(Map<String, dynamic> json) => Routine(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      difficulty: $enumDecode(_$RoutineDifficultyEnumMap, json['difficulty']),
      category: $enumDecode(_$RoutineCategoryEnumMap, json['category']),
      thumbnailUrl: json['thumbnail_url'] as String?,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isPublished: json['is_published'] as bool? ?? true,
      isCurated: json['is_curated'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      caloriesBurned: (json['calories_burned'] as num?)?.toInt(),
      equipment: json['equipment'] as String?,
    );

Map<String, dynamic> _$RoutineToJson(Routine instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'duration_minutes': instance.durationMinutes,
      'difficulty': _$RoutineDifficultyEnumMap[instance.difficulty]!,
      'category': _$RoutineCategoryEnumMap[instance.category]!,
      'thumbnail_url': instance.thumbnailUrl,
      'steps': instance.steps,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_published': instance.isPublished,
      'is_curated': instance.isCurated,
      'tags': instance.tags,
      'calories_burned': instance.caloriesBurned,
      'equipment': instance.equipment,
    };

const _$RoutineDifficultyEnumMap = {
  RoutineDifficulty.easy: 'easy',
  RoutineDifficulty.medium: 'medium',
  RoutineDifficulty.hard: 'hard',
};

const _$RoutineCategoryEnumMap = {
  RoutineCategory.strength: 'strength',
  RoutineCategory.cardio: 'cardio',
  RoutineCategory.flexibility: 'flexibility',
  RoutineCategory.mindfulness: 'mindfulness',
  RoutineCategory.dance: 'dance',
  RoutineCategory.hiit: 'hiit',
  RoutineCategory.yoga: 'yoga',
  RoutineCategory.custom: 'custom',
};

UserRoutine _$UserRoutineFromJson(Map<String, dynamic> json) => UserRoutine(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      routineId: json['routine_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      lastPlayedAt: json['last_played_at'] == null
          ? null
          : DateTime.parse(json['last_played_at'] as String),
      timesCompleted: (json['times_completed'] as num?)?.toInt() ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );

Map<String, dynamic> _$UserRoutineToJson(UserRoutine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'routine_id': instance.routineId,
      'saved_at': instance.savedAt.toIso8601String(),
      'last_played_at': instance.lastPlayedAt?.toIso8601String(),
      'times_completed': instance.timesCompleted,
      'is_favorite': instance.isFavorite,
    };
