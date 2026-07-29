import 'package:celia_flutter/models/exercise_media.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/services/exercise_media_resolver.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

RoutineStep _step({String title = 'Step', String? exerciseSlug}) {
  return RoutineStep(
    id: 's',
    title: title,
    durationSeconds: 30,
    orderIndex: 0,
    exerciseSlug: exerciseSlug,
  );
}

ExerciseMedia _media(String slug, {String category = 'strength'}) {
  return ExerciseMedia(
    slug: slug,
    displayName: slug,
    category: category,
    gifUrl: 'https://gifs.test/$slug.gif',
  );
}

void main() {
  test('resolves by slug derived from the step title', () async {
    final supabase = MockSupabaseService();
    when(
      () => supabase.getExerciseMediaLibrary(),
    ).thenAnswer((_) async => [_media('jumping-jacks')]);
    final resolver = ExerciseMediaResolver(supabase: supabase);

    final match = await resolver.resolveForStep(_step(title: 'Jumping Jacks'));

    expect(match?.slug, 'jumping-jacks');
  });

  test('prefers explicit exerciseSlug over the title-derived slug', () async {
    final supabase = MockSupabaseService();
    when(() => supabase.getExerciseMediaLibrary()).thenAnswer(
      (_) async => [_media('burpees'), _media('mountain-climber-1')],
    );
    final resolver = ExerciseMediaResolver(supabase: supabase);

    final match = await resolver.resolveForStep(
      _step(title: 'Burpees', exerciseSlug: 'mountain-climber-1'),
    );

    expect(match?.slug, 'mountain-climber-1');
  });

  test(
    'falls back to a close-match alias when there is no exact slug',
    () async {
      final supabase = MockSupabaseService();
      when(
        () => supabase.getExerciseMediaLibrary(),
      ).thenAnswer((_) async => [_media('knee-push-ups-1')]);
      final resolver = ExerciseMediaResolver(supabase: supabase);

      final match = await resolver.resolveForStep(_step(title: 'Push-ups'));

      expect(match?.slug, 'knee-push-ups-1');
    },
  );

  test('falls back to a close-match alias for real AI-generated routine step '
      'titles seen in production (typos and generic names included)', () async {
    final supabase = MockSupabaseService();
    when(() => supabase.getExerciseMediaLibrary()).thenAnswer(
      (_) async => [
        _media('squat-free-feet-together-1'),
        _media('jumping-jacks'),
        _media('circles-with-arms'),
        _media('burpees'),
        _media('knee-push-ups-1'),
      ],
    );
    final resolver = ExerciseMediaResolver(supabase: supabase);

    expect(
      (await resolver.resolveForStep(_step(title: 'Squats')))?.slug,
      'squat-free-feet-together-1',
    );
    expect(
      (await resolver.resolveForStep(_step(title: 'jump')))?.slug,
      'jumping-jacks',
    );
    // Real production data has a title typo ("Soulder  Focus", double
    // space) that must still resolve.
    expect(
      (await resolver.resolveForStep(_step(title: 'Soulder  Focus')))?.slug,
      'circles-with-arms',
    );
    expect(
      (await resolver.resolveForStep(_step(title: 'full body')))?.slug,
      'burpees',
    );
    expect(
      (await resolver.resolveForStep(_step(title: 'Press UP')))?.slug,
      'knee-push-ups-1',
    );
  });

  test(
    'returns null when neither an exact nor an alias match exists',
    () async {
      final supabase = MockSupabaseService();
      when(
        () => supabase.getExerciseMediaLibrary(),
      ).thenAnswer((_) async => [_media('jumping-jacks')]);
      final resolver = ExerciseMediaResolver(supabase: supabase);

      final match = await resolver.resolveForStep(_step(title: 'Yoga Nidra'));

      expect(match, isNull);
    },
  );

  test('caches the library and only fetches it once', () async {
    final supabase = MockSupabaseService();
    when(
      () => supabase.getExerciseMediaLibrary(),
    ).thenAnswer((_) async => [_media('lunge')]);
    final resolver = ExerciseMediaResolver(supabase: supabase);

    await resolver.resolveForStep(_step(title: 'Lunges'));
    await resolver.resolveForStep(_step(title: 'Lunges'));

    verify(() => supabase.getExerciseMediaLibrary()).called(1);
  });

  test('never blocks on a failed library fetch', () async {
    final supabase = MockSupabaseService();
    when(
      () => supabase.getExerciseMediaLibrary(),
    ).thenThrow(Exception('offline'));
    final resolver = ExerciseMediaResolver(supabase: supabase);

    final match = await resolver.resolveForStep(_step(title: 'Lunges'));

    expect(match, isNull);
  });
}
