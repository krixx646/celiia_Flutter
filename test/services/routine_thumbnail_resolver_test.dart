import 'package:celia_flutter/models/exercise_media.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/models/video.dart';
import 'package:celia_flutter/services/cloudflare_stream_service.dart';
import 'package:celia_flutter/services/exercise_media_resolver.dart';
import 'package:celia_flutter/services/routine_thumbnail_resolver.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

Routine _routine({
  String id = 'r',
  String? thumbnailUrl,
  List<RoutineStep> steps = const [],
}) {
  return Routine(
    id: id,
    title: 'Routine',
    durationMinutes: 10,
    difficulty: RoutineDifficulty.medium,
    category: RoutineCategory.custom,
    thumbnailUrl: thumbnailUrl,
    steps: steps,
    createdBy: 'u',
    createdAt: DateTime(2026, 1, 1),
    isPublished: false,
  );
}

RoutineStep _step({
  String title = 'Step',
  String? videoId,
  String? thumbnailUrl,
}) {
  return RoutineStep(
    id: 's',
    title: title,
    durationSeconds: 30,
    videoId: videoId,
    thumbnailUrl: thumbnailUrl,
    orderIndex: 0,
  );
}

Video _video({String streamId = 'stream', String? thumbnailUrl}) {
  return Video(
    id: 'v',
    streamId: streamId,
    title: 'Video',
    durationSeconds: 30,
    thumbnailUrl: thumbnailUrl,
    playbackUrl: '',
    status: VideoStatus.ready,
    uploadedBy: 'u',
    uploadedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('uses routine-level thumbnail before remote lookup '
      'when real videos are not suspended', () async {
    final supabase = MockSupabaseService();
    final resolver = RoutineThumbnailResolver(
      supabase: supabase,
      suspendRealVideos: false,
    );

    final thumb = await resolver.resolve(
      _routine(thumbnailUrl: 'https://img.test/r.jpg'),
    );

    expect(thumb, 'https://img.test/r.jpg');
    verifyNever(() => supabase.getVideoByAnyId(any()));
  });

  test('uses step thumbnail before remote lookup '
      'when real videos are not suspended', () async {
    final supabase = MockSupabaseService();
    final resolver = RoutineThumbnailResolver(
      supabase: supabase,
      suspendRealVideos: false,
    );

    final thumb = await resolver.resolve(
      _routine(steps: [_step(thumbnailUrl: 'https://img.test/s.jpg')]),
    );

    expect(thumb, 'https://img.test/s.jpg');
    verifyNever(() => supabase.getVideoByAnyId(any()));
  });

  test(
    'ignores a leftover routine/step thumbnail_url (populated straight from '
    'Cloudflare alongside the video) and prefers a stock GIF while real '
    'videos are suspended, instead of surfacing a dead video thumbnail',
    () async {
      final supabase = MockSupabaseService();
      when(() => supabase.getExerciseMediaLibrary()).thenAnswer(
        (_) async => [
          const ExerciseMedia(
            slug: 'jumping-jacks',
            displayName: 'Jumping Jacks',
            category: 'functional_hiit',
            gifUrl: 'https://gifs.test/jumping-jacks.gif',
          ),
        ],
      );
      final resolver = RoutineThumbnailResolver(
        supabase: supabase,
        exerciseMedia: ExerciseMediaResolver(supabase: supabase),
        suspendRealVideos: true,
      );

      final thumb = await resolver.resolve(
        _routine(
          thumbnailUrl: 'https://customer-x.cloudflarestream.com/dead.jpg',
          steps: [
            _step(
              title: 'Jumping Jacks',
              thumbnailUrl: 'https://customer-x.cloudflarestream.com/dead.jpg',
            ),
          ],
        ),
      );

      expect(thumb, 'https://gifs.test/jumping-jacks.gif');
      verifyNever(() => supabase.getVideoByAnyId(any()));
    },
  );

  // Real videos are suspended app-wide by default (Env.suspendRealVideos)
  // while the client's filming pipeline isn't ready, so these two tests
  // explicitly opt back in to cover that this dormant path still works
  // correctly and is ready to flip on again later.
  test('resolves video thumbnails through Supabase then caches result '
      'when real videos are not suspended', () async {
    final supabase = MockSupabaseService();
    when(() => supabase.getVideoByAnyId('video-row')).thenAnswer(
      (_) async => _video(thumbnailUrl: 'https://img.test/video.jpg'),
    );
    final resolver = RoutineThumbnailResolver(
      supabase: supabase,
      suspendRealVideos: false,
    );
    final routine = _routine(steps: [_step(videoId: 'video-row')]);

    expect(await resolver.resolve(routine), 'https://img.test/video.jpg');
    expect(await resolver.resolve(routine), 'https://img.test/video.jpg');
    verify(() => supabase.getVideoByAnyId('video-row')).called(1);
  });

  test('falls back to Cloudflare thumbnail when video lookup fails '
      'and real videos are not suspended', () async {
    final supabase = MockSupabaseService();
    when(
      () => supabase.getVideoByAnyId('stream'),
    ).thenThrow(Exception('offline'));
    final resolver = RoutineThumbnailResolver(
      supabase: supabase,
      cloudflare: CloudflareStreamService(accountId: 'acct', apiToken: 'token'),
      suspendRealVideos: false,
    );

    final thumb = await resolver.resolve(
      _routine(steps: [_step(videoId: 'stream')]),
    );

    expect(
      thumb,
      'https://customer-acct.cloudflarestream.com/stream/thumbnails/thumbnail.jpg',
    );
  });

  test('skips real video lookup entirely and prefers a stock GIF when real '
      'videos are suspended (the current app-wide default)', () async {
    final supabase = MockSupabaseService();
    when(() => supabase.getExerciseMediaLibrary()).thenAnswer(
      (_) async => [
        const ExerciseMedia(
          slug: 'jumping-jacks',
          displayName: 'Jumping Jacks',
          category: 'functional_hiit',
          gifUrl: 'https://gifs.test/jumping-jacks.gif',
        ),
      ],
    );
    final resolver = RoutineThumbnailResolver(
      supabase: supabase,
      exerciseMedia: ExerciseMediaResolver(supabase: supabase),
      suspendRealVideos: true,
    );

    final thumb = await resolver.resolve(
      _routine(
        steps: [_step(title: 'Jumping Jacks', videoId: 'video-row')],
      ),
    );

    expect(thumb, 'https://gifs.test/jumping-jacks.gif');
    verifyNever(() => supabase.getVideoByAnyId(any()));
  });

  test(
    'falls back to a stock GIF when the routine has no thumbnail or video at all',
    () async {
      final supabase = MockSupabaseService();
      when(() => supabase.getExerciseMediaLibrary()).thenAnswer(
        (_) async => [
          const ExerciseMedia(
            slug: 'jumping-jacks',
            displayName: 'Jumping Jacks',
            category: 'functional_hiit',
            gifUrl: 'https://gifs.test/jumping-jacks.gif',
          ),
        ],
      );
      final resolver = RoutineThumbnailResolver(
        supabase: supabase,
        exerciseMedia: ExerciseMediaResolver(supabase: supabase),
      );

      final thumb = await resolver.resolve(
        _routine(steps: [_step(title: 'Jumping Jacks')]),
      );

      expect(thumb, 'https://gifs.test/jumping-jacks.gif');
    },
  );

  test(
    'returns null when there is no thumbnail, video, or GIF match anywhere',
    () async {
      final supabase = MockSupabaseService();
      when(
        () => supabase.getExerciseMediaLibrary(),
      ).thenAnswer((_) async => []);
      final resolver = RoutineThumbnailResolver(
        supabase: supabase,
        exerciseMedia: ExerciseMediaResolver(supabase: supabase),
      );

      final thumb = await resolver.resolve(
        _routine(steps: [_step(title: 'Yoga Nidra')]),
      );

      expect(thumb, isNull);
    },
  );
}
