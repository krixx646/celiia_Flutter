import '../config/env.dart';
import '../models/routine.dart';
import 'cloudflare_stream_service.dart';
import 'exercise_clip_library.dart';
import 'exercise_media_resolver.dart';
import 'supabase_service.dart';

class RoutineThumbnailResolver {
  final SupabaseService _supabase;
  final CloudflareStreamService _cloudflare;
  final ExerciseClipLibrary _clips;
  final ExerciseMediaResolver _exerciseMedia;
  final bool _suspendRealVideos;
  final bool _enableGifFallback;
  final Map<String, String?> _resolved = {};
  final Map<String, Future<String?>> _inFlight = {};

  RoutineThumbnailResolver({
    SupabaseService? supabase,
    CloudflareStreamService? cloudflare,
    ExerciseClipLibrary? clips,
    ExerciseMediaResolver? exerciseMedia,
    bool? suspendRealVideos,
    bool? enableGifFallback,
  }) : _supabase = supabase ?? SupabaseService.instance,
       _cloudflare = cloudflare ?? CloudflareStreamService(),
       _clips = clips ?? ExerciseClipLibrary(),
       _exerciseMedia = exerciseMedia ?? ExerciseMediaResolver(),
       _suspendRealVideos = suspendRealVideos ?? Env.suspendRealVideos,
       _enableGifFallback = enableGifFallback ?? Env.enableGifFallback;

  Future<String?> resolve(Routine routine) {
    if (_resolved.containsKey(routine.id)) {
      return Future.value(_resolved[routine.id]);
    }

    final existing = _inFlight[routine.id];
    if (existing != null) return existing;

    final future = _resolve(routine);
    _inFlight[routine.id] = future;
    return future;
  }

  Future<String?> _resolve(Routine routine) async {
    try {
      // The filmed library leads: its poster frames are the artwork for every
      // routine built from the client's own footage, which is now all of them.
      for (final step in routine.steps) {
        final poster = (await _clips.resolveForStep(step))?.posterUrl?.trim();
        if (poster != null && poster.isNotEmpty) {
          return _cache(routine.id, poster);
        }
      }

      // `thumbnail_url` on both the routine and its steps is populated
      // straight from Cloudflare Stream alongside the video upload, so it's
      // effectively part of the (currently suspended) real-video pipeline,
      // not independent artwork. Skip it too while suspended, or a dead
      // leftover video thumbnail wins over a perfectly good GIF fallback.
      if (!_suspendRealVideos) {
        final routineThumb = routine.thumbnailUrl?.trim();
        if (routineThumb != null && routineThumb.isNotEmpty) {
          return _cache(routine.id, routineThumb);
        }

        for (final step in routine.steps) {
          final stepThumb = step.thumbnailUrl?.trim();
          if (stepThumb != null && stepThumb.isNotEmpty) {
            return _cache(routine.id, stepThumb);
          }
        }
      }

      final stepVideoId = _suspendRealVideos
          ? ''
          : routine.steps
                .map((step) => step.videoId?.trim() ?? '')
                .firstWhere((videoId) => videoId.isNotEmpty, orElse: () => '');
      if (stepVideoId.isNotEmpty) {
        try {
          final video = await _supabase.getVideoByAnyId(stepVideoId);
          final streamId = (video != null && video.streamId.isNotEmpty)
              ? video.streamId
              : stepVideoId;
          final resolved = (video?.thumbnailUrl?.isNotEmpty ?? false)
              ? video!.thumbnailUrl
              : _cloudflare.getThumbnailUrl(streamId);
          return _cache(routine.id, resolved);
        } catch (_) {
          return _cache(routine.id, _cloudflare.getThumbnailUrl(stepVideoId));
        }
      }

      // Nothing filmed anywhere in this routine; fall back to the stock GIF
      // pack for its first matched step, if that pack is still enabled.
      if (_enableGifFallback) {
        for (final step in routine.steps) {
          final media = await _exerciseMedia.resolveForStep(step);
          final gifUrl = media?.gifUrl?.trim();
          if (gifUrl != null && gifUrl.isNotEmpty) {
            return _cache(routine.id, gifUrl);
          }
        }
      }

      return _cache(routine.id, null);
    } finally {
      _inFlight.remove(routine.id);
    }
  }

  String? _cache(String routineId, String? thumbnailUrl) {
    _resolved[routineId] = thumbnailUrl;
    return thumbnailUrl;
  }
}
