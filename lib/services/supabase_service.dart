import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env.dart';
import '../models/routine.dart';
import '../models/video.dart';

/// Service for interacting with Supabase (Database, Auth, Storage)
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase - call this in main.dart before runApp
  static Future<void> initialize() async {
    if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) {
      throw SupabaseException(
        'Supabase credentials not configured',
        'Please add SUPABASE_URL and SUPABASE_ANON_KEY to env.dart',
      );
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw SupabaseException(
        'Supabase not initialized',
        'Call SupabaseService.initialize() before using the client',
      );
    }
    return _client!;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROUTINES
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch all published routines
  Future<List<Routine>> getPublishedRoutines({
    int limit = 50,
    int offset = 0,
    RoutineCategory? category,
    RoutineDifficulty? difficulty,
    bool? isCurated,
  }) async {
    // Build filter query first (before order/range)
    var filterQuery = client
        .from('routines')
        .select()
        .eq('is_published', true);

    if (category != null) {
      filterQuery = filterQuery.eq('category', category.name);
    }
    if (difficulty != null) {
      filterQuery = filterQuery.eq('difficulty', difficulty.name);
    }
    if (isCurated != null) {
      filterQuery = filterQuery.eq('is_curated', isCurated);
    }

    // Apply order and range after filters
    final response = await filterQuery
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List<dynamic>)
        .map((json) => Routine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single routine by ID
  Future<Routine?> getRoutine(String id) async {
    final response =
        await client.from('routines').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return Routine.fromJson(response);
  }

  /// Create a new routine
  Future<Routine> createRoutine(Routine routine) async {
    final response = await client
        .from('routines')
        .insert(routine.toJson())
        .select()
        .single();

    return Routine.fromJson(response);
  }

  /// Generate a personalized routine on the server (Next.js / Vercel) using the clip library.
  /// This keeps OpenAI keys off the device.
  Future<Routine> generateRoutineOnServer({
    required String request,
    required int durationMinutes,
    required RoutineDifficulty difficulty,
    required List<String> equipment,
  }) async {
    final base = Env.celiaBackendBaseUrl.trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define (e.g. https://your-vercel-app.vercel.app)',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw SupabaseException('Not signed in', 'Please sign in before generating a routine');
    }

    final idToken = await user.getIdToken();
    final uri = Uri.parse('$base/api/mobile/generate-routine');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'request': request,
        'durationMinutes': durationMinutes,
        'difficulty': difficulty.name,
        'equipment': equipment,
      }),
    );

    final raw = await res.bodyBytes;
    final text = utf8.decode(raw);
    final json = text.isNotEmpty ? jsonDecode(text) : {};

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = (json is Map && json['error'] != null) ? json['error'].toString() : 'Failed to generate routine';
      throw SupabaseException(msg, text);
    }

    final routineJson = (json is Map) ? json['routine'] : null;
    if (routineJson is! Map<String, dynamic>) {
      throw SupabaseException('Invalid server response', text);
    }

    return Routine.fromJson(routineJson);
  }

  /// Update an existing routine
  Future<Routine> updateRoutine(Routine routine) async {
    final response = await client
        .from('routines')
        .update(routine.toJson())
        .eq('id', routine.id)
        .select()
        .single();

    return Routine.fromJson(response);
  }

  /// Delete a routine
  Future<void> deleteRoutine(String id) async {
    await client.from('routines').delete().eq('id', id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VIDEOS
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch all videos
  Future<List<Video>> getVideos({
    int limit = 50,
    int offset = 0,
    String? category,
    VideoStatus? status,
  }) async {
    // Build filter query first (before order/range)
    var filterQuery = client.from('videos').select();

    if (category != null) {
      filterQuery = filterQuery.eq('category', category);
    }
    if (status != null) {
      filterQuery = filterQuery.eq('status', status.name);
    }

    // Apply order and range after filters
    final response = await filterQuery
        .order('uploaded_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List<dynamic>)
        .map((json) => _videoFromSupabaseRow(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single video by ID
  Future<Video?> getVideo(String id) async {
    final response =
        await client.from('videos').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return _videoFromSupabaseRow(response);
  }

  /// Fetch a single video by Cloudflare Stream ID (stream_id column)
  Future<Video?> getVideoByStreamId(String streamId) async {
    // Prefer the newer column name (cloudflare_video_id), fall back to legacy (stream_id).
    try {
      final response = await client
          .from('videos')
          .select()
          .eq('cloudflare_video_id', streamId)
          .maybeSingle();
      if (response != null) return _videoFromSupabaseRow(response);
    } catch (_) {
      // Ignore and try legacy column below
    }

    try {
      final response = await client
          .from('videos')
          .select()
          .eq('stream_id', streamId)
          .maybeSingle();
      if (response != null) return _videoFromSupabaseRow(response);
    } catch (_) {
      // ignore
    }

    return null;
  }

  /// Fetch a single video by either:
  /// - videos.id (UUID), or
  /// - videos.cloudflare_video_id / videos.stream_id (Cloudflare Stream UID)
  ///
  /// This is used because some routines store `steps[].video_id` as the video row UUID,
  /// while others store the Cloudflare Stream UID directly.
  Future<Video?> getVideoByAnyId(String idOrCloudflareId) async {
    final value = idOrCloudflareId.trim();
    if (value.isEmpty) return null;

    // Try primary key lookup first (fast path)
    try {
      final byId = await getVideo(value);
      if (byId != null) return byId;
    } catch (_) {
      // ignore
    }

    // Try Cloudflare UID columns (new + legacy)
    final byStream = await getVideoByStreamId(value);
    if (byStream != null) return byStream;

    return null;
  }

  /// Convert Supabase row (snake_case) to Video model (camelCase)
  Video _videoFromSupabaseRow(Map<String, dynamic> row) {
    final uploadedAtRaw = row['uploaded_at'] ?? row['created_at'];
    final uploadedAtIso = uploadedAtRaw is DateTime
        ? uploadedAtRaw.toIso8601String()
        : (uploadedAtRaw?.toString() ?? DateTime.now().toIso8601String());

    // Map snake_case from Supabase to camelCase for Video model
    final mapped = <String, dynamic>{
      'id': row['id']?.toString() ?? '',
      'streamId': (row['cloudflare_video_id'] ??
              row['stream_id'] ??
              row['streamId'] ??
              '')
          .toString(),
      'title': row['title']?.toString() ?? '',
      'description': row['description']?.toString(),
      'durationSeconds': row['duration_seconds'] ?? row['durationSeconds'] ?? 0,
      'thumbnailUrl': row['thumbnail_url'] ?? row['thumbnailUrl'],
      'playbackUrl': (row['playback_url'] ?? row['playbackUrl'] ?? '').toString(),
      'status': (row['status'] ?? 'processing').toString(),
      'uploadedBy': (row['uploaded_by'] ?? row['uploadedBy'] ?? 'admin').toString(),
      'uploadedAt': uploadedAtIso,
      'tags': row['tags'] ?? [],
      'category': row['category']?.toString(),
      'fileSize': row['file_size'] ?? row['fileSize'],
    };

    return Video.fromJson(mapped);
  }

  /// Create a new video record
  Future<Video> createVideo(Video video) async {
    final response =
        await client.from('videos').insert(video.toJson()).select().single();

    return _videoFromSupabaseRow(response);
  }

  /// Update a video record
  Future<Video> updateVideo(Video video) async {
    final response = await client
        .from('videos')
        .update(video.toJson())
        .eq('id', video.id)
        .select()
        .single();

    return _videoFromSupabaseRow(response);
  }

  /// Delete a video record
  Future<void> deleteVideo(String id) async {
    await client.from('videos').delete().eq('id', id);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER ROUTINES (Saved/Favorites)
  // ─────────────────────────────────────────────────────────────────────────

  /// Get user's saved routines
  Future<List<UserRoutine>> getUserRoutines(String oderId) async {
    final response = await client
        .from('user_routines')
        .select()
        .eq('user_id', oderId)
        .order('saved_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => UserRoutine.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Save a routine for a user
  Future<UserRoutine> saveRoutine(String oderId, String routineId) async {
    final response = await client
        .from('user_routines')
        .insert({
          'user_id': oderId,
          'routine_id': routineId,
          'saved_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return UserRoutine.fromJson(response);
  }

  /// Remove a saved routine
  Future<void> unsaveRoutine(String oderId, String routineId) async {
    await client
        .from('user_routines')
        .delete()
        .eq('user_id', oderId)
        .eq('routine_id', routineId);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String userRoutineId, bool isFavorite) async {
    await client
        .from('user_routines')
        .update({'is_favorite': isFavorite})
        .eq('id', userRoutineId);
  }

  /// Record routine completion
  Future<void> recordCompletion(String userRoutineId) async {
    await client.rpc('increment_routine_completion', params: {
      'routine_id': userRoutineId,
    });
  }
}

/// Exception for Supabase errors
class SupabaseException implements Exception {
  final String message;
  final String? details;

  SupabaseException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

