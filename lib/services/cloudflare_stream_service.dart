import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/video.dart';

/// Service for interacting with Cloudflare Stream API
class CloudflareStreamService {
  static const String _baseUrl =
      'https://api.cloudflare.com/client/v4/accounts';

  final String _accountId;
  final String _apiToken;
  final http.Client _client;

  CloudflareStreamService({
    String? accountId,
    String? apiToken,
    http.Client? client,
  }) : _accountId = accountId ?? Env.cloudflareAccountId,
       _apiToken = apiToken ?? Env.cloudflareApiToken,
       _client = client ?? http.Client();

  String get _streamUrl => '$_baseUrl/$_accountId/stream';

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiToken',
    'Content-Type': 'application/json',
  };

  /// Get a direct upload URL for uploading a video
  /// This allows clients to upload directly to Cloudflare without going through our server
  Future<VideoUploadResponse> getDirectUploadUrl({
    required String filename,
    int maxDurationSeconds = 3600,
    Map<String, String>? metadata,
  }) async {
    final response = await _client.post(
      Uri.parse('$_streamUrl/direct_upload'),
      headers: _headers,
      body: jsonEncode({
        'maxDurationSeconds': maxDurationSeconds,
        'meta': {'name': filename, ...?metadata},
        'requireSignedURLs': false, // Set to true for private videos
      }),
    );

    if (response.statusCode != 200) {
      throw CloudflareException(
        'Failed to get upload URL: ${response.statusCode}',
        response.body,
      );
    }

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw CloudflareException(
        'Cloudflare API error',
        data['errors']?.toString() ?? 'Unknown error',
      );
    }

    final result = data['result'];
    return VideoUploadResponse(
      uploadUrl: result['uploadURL'] as String,
      streamId: result['uid'] as String,
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  /// Get video details from Cloudflare Stream
  Future<Map<String, dynamic>> getVideoDetails(String streamId) async {
    final response = await _client.get(
      Uri.parse('$_streamUrl/$streamId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw CloudflareException(
        'Failed to get video details: ${response.statusCode}',
        response.body,
      );
    }

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw CloudflareException(
        'Cloudflare API error',
        data['errors']?.toString() ?? 'Unknown error',
      );
    }

    return data['result'] as Map<String, dynamic>;
  }

  /// Get the playback URL for a video
  String getPlaybackUrl(String streamId) {
    return 'https://customer-$_accountId.cloudflarestream.com/$streamId/manifest/video.m3u8';
  }

  /// Get the iframe embed URL for a video
  String getEmbedUrl(String streamId) {
    return 'https://customer-$_accountId.cloudflarestream.com/$streamId/iframe';
  }

  /// Get thumbnail URL for a video
  String getThumbnailUrl(
    String streamId, {
    int? time,
    int? width,
    int? height,
  }) {
    final params = <String, String>{};
    if (time != null) params['time'] = '${time}s';
    if (width != null) params['width'] = width.toString();
    if (height != null) params['height'] = height.toString();

    final queryString = params.isNotEmpty
        ? '?${Uri(queryParameters: params).query}'
        : '';
    return 'https://customer-$_accountId.cloudflarestream.com/$streamId/thumbnails/thumbnail.jpg$queryString';
  }

  /// List all videos in the account
  Future<List<Map<String, dynamic>>> listVideos({
    int limit = 50,
    String? after,
  }) async {
    final queryParams = <String, String>{'limit': limit.toString()};
    if (after != null) queryParams['after'] = after;

    final response = await _client.get(
      Uri.parse(_streamUrl).replace(queryParameters: queryParams),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw CloudflareException(
        'Failed to list videos: ${response.statusCode}',
        response.body,
      );
    }

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw CloudflareException(
        'Cloudflare API error',
        data['errors']?.toString() ?? 'Unknown error',
      );
    }

    return (data['result'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Delete a video from Cloudflare Stream
  Future<void> deleteVideo(String streamId) async {
    final response = await _client.delete(
      Uri.parse('$_streamUrl/$streamId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw CloudflareException(
        'Failed to delete video: ${response.statusCode}',
        response.body,
      );
    }
  }

  /// Check if a video is ready for playback
  Future<VideoStatus> getVideoStatus(String streamId) async {
    try {
      final details = await getVideoDetails(streamId);
      final status = details['status'] as Map<String, dynamic>?;

      if (status == null) return VideoStatus.pending;

      final state = status['state'] as String?;
      switch (state) {
        case 'ready':
          return VideoStatus.ready;
        case 'inprogress':
        case 'queued':
          return VideoStatus.processing;
        case 'error':
          return VideoStatus.error;
        default:
          return VideoStatus.pending;
      }
    } catch (e) {
      return VideoStatus.error;
    }
  }
}

/// Exception for Cloudflare API errors
class CloudflareException implements Exception {
  final String message;
  final String? details;

  CloudflareException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}
