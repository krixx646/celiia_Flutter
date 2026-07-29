import 'dart:async';

import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/providers/routine_provider.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

Routine routine({
  required String id,
  required DateTime createdAt,
  bool isCurated = false,
  bool isPublished = true,
}) {
  return Routine(
    id: id,
    title: 'Routine $id',
    description: null,
    durationMinutes: 10,
    difficulty: RoutineDifficulty.medium,
    category: RoutineCategory.custom,
    thumbnailUrl: null,
    steps: const [
      RoutineStep(
        id: 's1',
        title: 'Step',
        description: null,
        durationSeconds: 30,
        videoId: 'v1',
        thumbnailUrl: null,
        orderIndex: 0,
      ),
    ],
    createdBy: isCurated ? 'admin' : 'u',
    createdAt: createdAt,
    updatedAt: null,
    isPublished: isPublished,
    isCurated: isCurated,
    tags: const [],
    caloriesBurned: null,
    equipment: null,
  );
}

UserRoutine userRoutine({
  required String id,
  required String userId,
  required String routineId,
  DateTime? savedAt,
  DateTime? lastPlayedAt,
  int timesCompleted = 0,
  bool isFavorite = false,
}) {
  return UserRoutine(
    id: id,
    userId: userId,
    routineId: routineId,
    savedAt: savedAt ?? DateTime(2026, 1, 1),
    lastPlayedAt: lastPlayedAt,
    timesCompleted: timesCompleted,
    isFavorite: isFavorite,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(RoutineCategory.custom);
    registerFallbackValue(RoutineDifficulty.medium);
  });

  test('uses defaultSupabase/defaultCurrentUserId when not provided', () async {
    final originalSupabase = RoutineProvider.defaultSupabase;
    final originalUid = RoutineProvider.defaultCurrentUserId;
    addTearDown(() {
      RoutineProvider.defaultSupabase = originalSupabase;
      RoutineProvider.defaultCurrentUserId = originalUid;
    });

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);

    RoutineProvider.defaultSupabase = () => supa;
    RoutineProvider.defaultCurrentUserId = () => '';

    final rp = RoutineProvider();
    await rp.loadRoutines(refresh: true);
    expect(rp.routines, isEmpty);
  });

  test('basic getters + selection + clearSelection + clearError', () {
    final supa = MockSupabaseService();
    final rp = RoutineProvider(supabase: supa, currentUserId: () => null);

    expect(rp.routines, isA<List<Routine>>());
    expect(rp.curatedRoutines, isA<List<Routine>>());
    expect(rp.aiRoutines, isA<List<Routine>>());
    expect(rp.userRoutines, isA<List<UserRoutine>>());
    expect(rp.selectedRoutine, isNull);
    expect(rp.isLoading, isFalse);
    expect(rp.isLoadingUserRoutines, isFalse);
    expect(rp.isGenerating, isFalse);
    expect(rp.error, isNull);

    final r = routine(id: 'r1', createdAt: DateTime(2026, 1, 1));
    rp.selectRoutine(r);
    expect(rp.selectedRoutine?.id, 'r1');
    rp.clearSelection();
    expect(rp.selectedRoutine, isNull);

    // cover clearError even if already null
    rp.clearError();
    expect(rp.error, isNull);
  });

  group('loadRoutinesByCategory', () {
    test('success filters curated/ai', () async {
      final supa = MockSupabaseService();
      when(
        () => supa.getPublishedRoutines(category: RoutineCategory.strength),
      ).thenAnswer((_) async {
        return [
          routine(id: 'a', createdAt: DateTime(2026, 1, 1), isCurated: true),
          routine(id: 'b', createdAt: DateTime(2026, 1, 2), isCurated: false),
        ];
      });

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadRoutinesByCategory(RoutineCategory.strength);
      expect(rp.curatedRoutines.map((r) => r.id).toList(), ['a']);
      expect(rp.aiRoutines.map((r) => r.id).toList(), ['b']);
      expect(rp.error, isNull);
    });

    test('error sets error message', () async {
      final supa = MockSupabaseService();
      when(
        () => supa.getPublishedRoutines(category: any(named: 'category')),
      ).thenThrow(Exception('boom'));
      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadRoutinesByCategory(RoutineCategory.cardio);
      expect(rp.error, contains('Could not load routines right now'));
    });
  });

  group('loadRoutines', () {
    test('error sets _error (catch branch)', () async {
      final supa = MockSupabaseService();
      when(() => supa.getPublishedRoutines()).thenThrow(Exception('boom'));

      final rp = RoutineProvider(supabase: supa, currentUserId: () => null);
      await rp.loadRoutines(refresh: true);
      expect(rp.error, contains('Could not load routines right now'));
    });
  });

  group('loadUserRoutines', () {
    test('success sets user routines', () async {
      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenAnswer(
        (_) async => [userRoutine(id: 'ur1', userId: 'u', routineId: 'r1')],
      );
      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');
      expect(rp.userRoutines.single.routineId, 'r1');
    });

    test('second call while in-flight returns early', () async {
      final supa = MockSupabaseService();
      final completer = Completer<List<UserRoutine>>();
      when(() => supa.getUserRoutines('u')).thenAnswer((_) => completer.future);

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      final f1 = rp.loadUserRoutines('u');
      final f2 = rp.loadUserRoutines('u');
      expect(f2, completes); // returns immediately

      completer.complete(<UserRoutine>[]);
      await f1;

      verify(() => supa.getUserRoutines('u')).called(1);
    });

    test('error sets error message', () async {
      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenThrow(Exception('boom'));
      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');
      expect(rp.error, contains('Could not load saved routines right now'));
    });
  });

  group('save/unsave', () {
    test(
      'saveRoutine success inserts and returns true; failure returns false',
      () async {
        final supa = MockSupabaseService();
        when(() => supa.saveRoutine('u', 'r1')).thenAnswer(
          (_) async => userRoutine(id: 'ur1', userId: 'u', routineId: 'r1'),
        );

        final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
        final ok = await rp.saveRoutine('u', 'r1');
        expect(ok, isTrue);
        expect(rp.userRoutines.first.routineId, 'r1');

        when(() => supa.saveRoutine(any(), any())).thenThrow(Exception('boom'));
        final ok2 = await rp.saveRoutine('u', 'r2');
        expect(ok2, isFalse);
      },
    );

    test(
      'unsaveRoutine success removes and returns true; failure returns false',
      () async {
        final supa = MockSupabaseService();
        when(() => supa.unsaveRoutine('u', 'r1')).thenAnswer((_) async {});
        final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
        rp
          ..clearError()
          ..selectRoutine(routine(id: 'x', createdAt: DateTime(2026, 1, 1)));

        // seed userRoutines
        await rp.saveRoutine(
          'u',
          'r1',
        ); // will fail unless stubbed; so seed manually
        rp
          ..clearSelection()
          ..clearError();
        // manual seed
        rp
          ..clearSelection()
          ..clearError();
        // easiest: call loadUserRoutines stub
        when(() => supa.getUserRoutines('u')).thenAnswer(
          (_) async => [userRoutine(id: 'ur1', userId: 'u', routineId: 'r1')],
        );
        await rp.loadUserRoutines('u');

        final ok = await rp.unsaveRoutine('u', 'r1');
        expect(ok, isTrue);
        expect(rp.userRoutines, isEmpty);

        when(
          () => supa.unsaveRoutine(any(), any()),
        ).thenThrow(Exception('boom'));
        final ok2 = await rp.unsaveRoutine('u', 'r2');
        expect(ok2, isFalse);
      },
    );
  });

  group('toggleFavorite', () {
    test('returns early when userRoutineId not found', () async {
      final supa = MockSupabaseService();
      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.toggleFavorite('missing');
      verifyNever(() => supa.toggleFavorite(any(), any()));
    });

    test('error is swallowed but still covers branch', () async {
      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenAnswer(
        (_) async => [
          userRoutine(
            id: 'ur1',
            userId: 'u',
            routineId: 'r1',
            isFavorite: false,
          ),
        ],
      );
      when(() => supa.toggleFavorite('ur1', true)).thenThrow(Exception('boom'));

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');
      await rp.toggleFavorite('ur1');
      // unchanged because service threw
      expect(rp.userRoutines.single.isFavorite, isFalse);
    });

    test(
      'toggleFavoriteByRoutineId returns early when routineId not found',
      () async {
        final supa = MockSupabaseService();
        final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
        await rp.toggleFavoriteByRoutineId('missing');
        verifyNever(() => supa.toggleFavorite(any(), any()));
      },
    );
  });

  group('recordCompletion', () {
    test('updates local record when present; swallows errors', () async {
      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenAnswer(
        (_) async => [
          userRoutine(
            id: 'ur1',
            userId: 'u',
            routineId: 'r1',
            timesCompleted: 0,
          ),
        ],
      );
      when(() => supa.recordCompletion('ur1')).thenAnswer((_) async {});

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');
      await rp.recordCompletion('ur1');
      expect(rp.userRoutines.single.timesCompleted, 1);
      expect(rp.userRoutines.single.lastPlayedAt, isNotNull);

      when(() => supa.recordCompletion('ur1')).thenThrow(Exception('boom'));
      await rp.recordCompletion('ur1'); // should not throw
    });
  });

  group('recordCompletionForRoutine', () {
    test(
      'when saveRoutine fails, reloads then records completion if row appears',
      () async {
        final supa = MockSupabaseService();
        when(
          () => supa.getUserRoutines('u'),
        ).thenAnswer((_) async => <UserRoutine>[]);
        when(() => supa.saveRoutine('u', 'r1')).thenThrow(Exception('unique'));
        when(() => supa.recordCompletion('ur1')).thenAnswer((_) async {});

        final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
        await rp.loadUserRoutines('u');

        // after reload, row exists
        when(() => supa.getUserRoutines('u')).thenAnswer(
          (_) async => [
            userRoutine(
              id: 'ur1',
              userId: 'u',
              routineId: 'r1',
              timesCompleted: 0,
            ),
          ],
        );

        await rp.recordCompletionForRoutine(userId: 'u', routineId: 'r1');
        verify(() => supa.recordCompletion('ur1')).called(1);
      },
    );

    test(
      'if row still missing after reload, returns without calling recordCompletion',
      () async {
        final supa = MockSupabaseService();
        when(
          () => supa.getUserRoutines('u'),
        ).thenAnswer((_) async => <UserRoutine>[]);
        when(() => supa.saveRoutine('u', 'r1')).thenThrow(Exception('unique'));
        when(
          () => supa.getUserRoutines('u'),
        ).thenAnswer((_) async => <UserRoutine>[]);

        final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
        await rp.loadUserRoutines('u');
        await rp.recordCompletionForRoutine(userId: 'u', routineId: 'r1');
        verifyNever(() => supa.recordCompletion(any()));
      },
    );
  });

  test(
    'isRoutineSaved + getUserRoutine hit success and catch branches',
    () async {
      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenAnswer(
        (_) async => [userRoutine(id: 'ur1', userId: 'u', routineId: 'r1')],
      );
      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');

      expect(rp.isRoutineSaved('r1'), isTrue);
      expect(rp.isRoutineSaved('missing'), isFalse);
      expect(rp.getUserRoutine('r1')?.id, 'ur1');
      expect(rp.getUserRoutine('missing'), isNull);
    },
  );
}
