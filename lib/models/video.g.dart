// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String,
  streamId: json['streamId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
  playbackUrl: json['playbackUrl'] as String,
  status: $enumDecode(_$VideoStatusEnumMap, json['status']),
  uploadedBy: json['uploadedBy'] as String,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category: json['category'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'id': instance.id,
  'streamId': instance.streamId,
  'title': instance.title,
  'description': instance.description,
  'durationSeconds': instance.durationSeconds,
  'thumbnailUrl': instance.thumbnailUrl,
  'playbackUrl': instance.playbackUrl,
  'status': _$VideoStatusEnumMap[instance.status]!,
  'uploadedBy': instance.uploadedBy,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
  'tags': instance.tags,
  'category': instance.category,
  'fileSize': instance.fileSize,
};

const _$VideoStatusEnumMap = {
  VideoStatus.pending: 'pending',
  VideoStatus.processing: 'processing',
  VideoStatus.ready: 'ready',
  VideoStatus.error: 'error',
};

VideoUploadRequest _$VideoUploadRequestFromJson(Map<String, dynamic> json) =>
    VideoUploadRequest(
      filename: json['filename'] as String,
      maxDurationSeconds: (json['maxDurationSeconds'] as num?)?.toInt() ?? 3600,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$VideoUploadRequestToJson(VideoUploadRequest instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'maxDurationSeconds': instance.maxDurationSeconds,
      'metadata': instance.metadata,
    };

VideoUploadResponse _$VideoUploadResponseFromJson(Map<String, dynamic> json) =>
    VideoUploadResponse(
      uploadUrl: json['uploadUrl'] as String,
      streamId: json['streamId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$VideoUploadResponseToJson(
  VideoUploadResponse instance,
) => <String, dynamic>{
  'uploadUrl': instance.uploadUrl,
  'streamId': instance.streamId,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
