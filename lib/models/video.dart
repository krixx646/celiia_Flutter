import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

/// Status of a video in Cloudflare Stream
enum VideoStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('ready')
  ready,
  @JsonValue('error')
  error,
}

/// A video stored in Cloudflare Stream
@JsonSerializable()
class Video {
  final String id; // Supabase ID
  final String streamId; // Cloudflare Stream video ID
  final String title;
  final String? description;
  final int durationSeconds;
  final String? thumbnailUrl;
  final String playbackUrl; // HLS/DASH URL from Cloudflare
  final VideoStatus status;
  final String uploadedBy; // User ID or 'admin'
  final DateTime uploadedAt;
  final List<String> tags;
  final String? category;
  final int? fileSize; // In bytes

  const Video({
    required this.id,
    required this.streamId,
    required this.title,
    this.description,
    required this.durationSeconds,
    this.thumbnailUrl,
    required this.playbackUrl,
    required this.status,
    required this.uploadedBy,
    required this.uploadedAt,
    this.tags = const [],
    this.category,
    this.fileSize,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);

  /// Get formatted duration string
  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes < 60) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if video is ready for playback
  bool get isReady => status == VideoStatus.ready;

  /// Get Cloudflare Stream thumbnail URL
  String get streamThumbnailUrl =>
      'https://customer-${streamId.split('-').first}.cloudflarestream.com/$streamId/thumbnails/thumbnail.jpg';
}

/// Request to generate a signed upload URL for Cloudflare Stream
@JsonSerializable()
class VideoUploadRequest {
  final String filename;
  final int maxDurationSeconds;
  final Map<String, String>? metadata;

  const VideoUploadRequest({
    required this.filename,
    this.maxDurationSeconds = 3600, // 1 hour max
    this.metadata,
  });

  factory VideoUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$VideoUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VideoUploadRequestToJson(this);
}

/// Response from Cloudflare Stream after requesting upload URL
@JsonSerializable()
class VideoUploadResponse {
  final String uploadUrl;
  final String streamId;
  final DateTime expiresAt;

  const VideoUploadResponse({
    required this.uploadUrl,
    required this.streamId,
    required this.expiresAt,
  });

  factory VideoUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VideoUploadResponseToJson(this);
}

