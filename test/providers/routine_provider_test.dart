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
    isPublished: !isCurated,
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
    registerFallbackValue(RoutineDifficulty.medium);
  });

  group('RoutineProvider.generateRoutine', () {
    test('adds generated routine to local lists on success', () async {
      final supa = MockSupabaseService();
      final created = routine(id: 'r_new', createdAt: DateTime(2026, 1, 10));

      when(() => supa.generateRoutineOnServer(
            request: any(named: 'request'),
            durationMinutes: any(named: 'durationMinutes'),
            difficulty: any(named: 'difficulty'),
            equipment: any(named: 'equipment'),
          )).thenAnswer((_) async => created);

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      final res = await rp.generateRoutine(
        request: 'make me a quick workout',
        durationMinutes: 15,
        difficulty: RoutineDifficulty.medium,
        equipment: const ['None'],
      );

      expect(res, isNotNull);
      expect(rp.routines.first.id, 'r_new');
      expect(rp.aiRoutines.first.id, 'r_new');
      expect(rp.error, isNull);
      verify(() => supa.generateRoutineOnServer(
            request: any(named: 'request'),
            durationMinutes: 15,
            difficulty: RoutineDifficulty.medium,
            equipment: const ['None'],
          )).called(1);
    });

    test('sets error and returns null on failure', () async {
      final supa = MockSupabaseService();
      when(() => supa.generateRoutineOnServer(
            request: any(named: 'request'),
            durationMinutes: any(named: 'durationMinutes'),
            difficulty: any(named: 'difficulty'),
            equipment: any(named: 'equipment'),
          )).thenThrow(Exception('boom'));

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      final res = await rp.generateRoutine(
        request: 'x',
        durationMinutes: 15,
        difficulty: RoutineDifficulty.medium,
        equipment: const ['None'],
      );

      expect(res, isNull);
      expect(rp.error, contains('Failed to generate routine'));
    });
  });

  group('RoutineProvider.loadRoutines', () {
    test('merges published + user private routines (dedupe by id, sort desc)', () async {
      final supa = MockSupabaseService();

      final published = [
        routine(id: 'a', createdAt: DateTime(2026, 1, 1), isCurated: true),
        routine(id: 'b', createdAt: DateTime(2026, 1, 2), isCurated: false),
      ];
      final mine = [
        routine(id: 'c', createdAt: DateTime(2026, 1, 5), isCurated: false),
        routine(id: 'b', createdAt: DateTime(2026, 1, 9), isCurated: false), // duplicate id, should win
      ];

      when(() => supa.getPublishedRoutines()).thenAnswer((_) async => published);
      when(() => supa.getUserCreatedRoutines(userId: 'u')).thenAnswer((_) async => mine);

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadRoutines(refresh: true);

      expect(rp.routines.map((r) => r.id).toList(), ['b', 'c', 'a']);
      expect(rp.curatedRoutines.map((r) => r.id).toList(), ['a']);
      expect(rp.aiRoutines.map((r) => r.id).toSet(), {'b', 'c'});
    });
  });

  group('favorites + completion', () {
    test('toggleFavoriteByRoutineId updates local state and calls service', () async {
      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenAnswer((_) async => [
            userRoutine(id: 'ur1', userId: 'u', routineId: 'r1', isFavorite: false),
          ]);
      when(() => supa.toggleFavorite('ur1', true)).thenAnswer((_) async {});

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');
      await rp.toggleFavoriteByRoutineId('r1');

      expect(rp.userRoutines.single.isFavorite, isTrue);
      verify(() => supa.toggleFavorite('ur1', true)).called(1);
    });

    test('recordCompletionForRoutine saves row if missing, then increments local completion', () async {
      final supa = MockSupabaseService();

      when(() => supa.getUserRoutines('u')).thenAnswer((_) async => <UserRoutine>[]);
      when(() => supa.saveRoutine('u', 'r1')).thenAnswer(
        (_) async => userRoutine(id: 'ur_new', userId: 'u', routineId: 'r1', timesCompleted: 0),
      );
      when(() => supa.recordCompletion('ur_new')).thenAnswer((_) async {});

      final rp = RoutineProvider(supabase: supa, currentUserId: () => 'u');
      await rp.loadUserRoutines('u');
      await rp.recordCompletionForRoutine(userId: 'u', routineId: 'r1');

      expect(rp.userRoutines.length, 1);
      expect(rp.userRoutines.single.routineId, 'r1');
      expect(rp.userRoutines.single.timesCompleted, 1);
      expect(rp.userRoutines.single.lastPlayedAt, isNotNull);
      verify(() => supa.saveRoutine('u', 'r1')).called(1);
      verify(() => supa.recordCompletion('ur_new')).called(1);
    });
  });
}

