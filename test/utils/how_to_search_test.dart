import 'package:celia_flutter/models/exercise_clip.dart';
import 'package:celia_flutter/utils/how_to_search.dart';
import 'package:flutter_test/flutter_test.dart';

ExerciseClip _clip(String slug, List<String> equipment) {
  final name = slug.replaceAll('_', ' ');
  return ExerciseClip(
    slug: slug,
    nameEn: name,
    nameEs: name,
    pattern: 'other',
    videoUrl: 'https://example.com/$slug.mp4',
    isCounted: true,
    clipSeconds: 20,
    equipment: equipment,
    source: ExerciseClip.howToSource,
  );
}

void main() {
  final clips = [
    _clip('dumbbell_bench_press_flat_setup_cue', ['dumbbell', 'bench']),
    _clip('barbell_bench_press_grip', ['barbell', 'bench']),
    _clip('cable_chest_fly_seated', ['cable']),
    _clip('cable_chest_fly_seated_2', ['cable']),
    _clip('cable_triceps_pushdown', ['cable']),
    _clip('dumbbell_biceps_curl_hammer', ['dumbbell']),
    _clip('dumbbell_goblet_squat_heel_lift_cue', ['dumbbell']),
  ];

  String slugs(List<ExerciseClip> list) => list.map((c) => c.slug).join(',');

  test('an empty query keeps every clip', () {
    expect(rankHowToClips(clips, '  '), clips);
  });

  test('named kit is required for every result', () {
    final result = rankHowToClips(clips, 'dumbbell chest');
    expect(slugs(result), 'dumbbell_bench_press_flat_setup_cue');
  });

  test('body areas find the clips that train them', () {
    final result = rankHowToClips(clips, 'chest and triceps with cables');
    expect(
      result.map((c) => c.slug).toSet(),
      {'cable_chest_fly_seated', 'cable_chest_fly_seated_2', 'cable_triceps_pushdown'},
    );
  });

  test('naming only kit lists everything that uses it', () {
    final result = rankHowToClips(clips, 'dumbbells');
    expect(result.length, 3);
  });

  test('Spanish words work too', () {
    final result = rankHowToClips(clips, 'pecho con mancuernas');
    expect(slugs(result), 'dumbbell_bench_press_flat_setup_cue');
  });

  test('a series keeps one take per exercise', () {
    final series = howToSeriesFor(rankHowToClips(clips, 'cable chest'));
    expect(slugs(series), 'cable_chest_fly_seated');
  });
}
