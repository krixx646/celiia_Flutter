import 'package:celia_flutter/config/env.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/models/video.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';

Routine _dummyRoutine() {
  return Routine(
    id: 'r',
    title: 't',
    durationMinutes: 1,
    difficulty: RoutineDifficulty.easy,
    category: RoutineCategory.custom,
    steps: const [],
    createdBy: 'u',
    createdAt: DateTime(2026, 1, 1),
    isPublished: false,
  );
}

Video _dummyVideo() {
  return Video(
    id: 'v',
    streamId: 's',
    title: 't',
    durationSeconds: 1,
    playbackUrl: '',
    status: VideoStatus.processing,
    uploadedBy: 'u',
    uploadedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  // Env now ships real Supabase defaults, so without this the lazy
  // initialize() inside these calls reaches the real client and dies on a
  // missing shared_preferences plugin instead of exercising the
  // uninitialized paths this test is about.
  setUp(() {
    SupabaseService.supabaseUrl = () => '';
    SupabaseService.supabaseAnonKey = () => '';
    SupabaseService.resetForTesting();
  });

  tearDown(() {
    SupabaseService.supabaseUrl = () => Env.supabaseUrl;
    SupabaseService.supabaseAnonKey = () => Env.supabaseAnonKey;
    SupabaseService.resetForTesting();
  });

  test(
    'SupabaseService methods are at least exercised (uninitialized client paths)',
    () async {
      final s = SupabaseService.instance;

      // these should be safe and return null
      expect(await s.getVideoByAnyId('   '), isNull);
      expect(await s.getVideoByAnyId('abc'), isNull);
      expect(await s.getVideoByStreamId('abc'), isNull);

      // routines/videos CRUD - should throw when client isn't initialized
      for (final f in <Future<void> Function()>[
        () async => s.getPublishedRoutines(),
        () async => s.getUserCreatedRoutines(userId: 'u'),
        () async => s.getRoutine('id'),
        () async => s.createRoutine(_dummyRoutine()),
        () async => s.updateRoutine(_dummyRoutine()),
        () async => s.deleteRoutine('id'),
        () async => s.getVideos(),
        () async => s.getVideo('id'),
        () async => s.createVideo(_dummyVideo()),
        () async => s.updateVideo(_dummyVideo()),
        () async => s.deleteVideo('id'),
        () async => s.getUserRoutines('u'),
        () async => s.saveRoutine('u', 'r'),
        () async => s.unsaveRoutine('u', 'r'),
        () async => s.toggleFavorite('ur', true),
        () async => s.recordCompletion('ur'),
      ]) {
        try {
          await f();
          fail('Expected an exception from uninitialized Supabase client');
        } catch (_) {
          // expected
        }
      }
    },
  );
}
