import '../models/exercise_clip.dart';

/// Most clips a typed series is turned into. Enough for a full session
/// without dumping every dumbbell clip on someone who typed "dumbbell".
const int kHowToSeriesMaxClips = 8;

const Set<String> _stopWords = {
  'a', 'an', 'and', 'the', 'with', 'using', 'for', 'of', 'on', 'to', 'in',
  'how', 'do', 'i', 'my', 'me', 'some', 'series', 'set', 'sets',
  'exercise', 'exercises', 'workout', 'workouts', 'routine', 'day',
  'y', 'con', 'de', 'la', 'el', 'los', 'las', 'para', 'ejercicio',
  'ejercicios', 'et', 'avec', 'le', 'les', 'des', 'du', 'exercice',
  'exercices',
};

/// Words that name kit. When the user names one, every result must use it.
const Map<String, String> _equipmentWords = {
  'dumbbell': 'dumbbell',
  'dumbbells': 'dumbbell',
  'mancuerna': 'dumbbell',
  'mancuernas': 'dumbbell',
  'haltere': 'dumbbell',
  'halteres': 'dumbbell',
  'barbell': 'barbell',
  'barbells': 'barbell',
  'barra': 'barbell',
  'cable': 'cable',
  'cables': 'cable',
  'polea': 'cable',
  'poulie': 'cable',
  'machine': 'machine',
  'machines': 'machine',
  'maquina': 'machine',
  'smith': 'smith',
  'bench': 'bench',
  'banco': 'bench',
};

/// Body areas people type, mapped to the words the clip slugs use.
const Map<String, List<String>> _areaTerms = {
  'chest': ['chest', 'bench_press', 'fly', 'pec', 'push_up'],
  'pecho': ['chest', 'bench_press', 'fly', 'pec', 'push_up'],
  'pectoraux': ['chest', 'bench_press', 'fly', 'pec', 'push_up'],
  'back': ['row', 'pulldown', 'pull_up', 'lat', 'back'],
  'espalda': ['row', 'pulldown', 'pull_up', 'lat', 'back'],
  'dos': ['row', 'pulldown', 'pull_up', 'lat', 'back'],
  'lats': ['lat', 'pulldown', 'row'],
  'shoulder': ['shoulder', 'lateral_raise', 'overhead_press', 'delt', 'face_pull'],
  'shoulders': ['shoulder', 'lateral_raise', 'overhead_press', 'delt', 'face_pull'],
  'hombros': ['shoulder', 'lateral_raise', 'overhead_press', 'delt', 'face_pull'],
  'epaules': ['shoulder', 'lateral_raise', 'overhead_press', 'delt', 'face_pull'],
  'delts': ['delt', 'lateral_raise', 'shoulder', 'face_pull'],
  'traps': ['shrug', 'traps', 'face_pull'],
  'arms': ['curl', 'biceps', 'triceps', 'pushdown'],
  'brazos': ['curl', 'biceps', 'triceps', 'pushdown'],
  'bras': ['curl', 'biceps', 'triceps', 'pushdown'],
  'biceps': ['curl', 'biceps'],
  'bicep': ['curl', 'biceps'],
  'triceps': ['triceps', 'pushdown', 'close_grip'],
  'tricep': ['triceps', 'pushdown', 'close_grip'],
  'forearm': ['forearm'],
  'forearms': ['forearm'],
  'legs': ['squat', 'lunge', 'leg_press', 'leg_extension', 'deadlift', 'calf', 'lower_body'],
  'leg': ['squat', 'lunge', 'leg_press', 'leg_extension', 'deadlift', 'calf', 'lower_body'],
  'piernas': ['squat', 'lunge', 'leg_press', 'leg_extension', 'deadlift', 'calf', 'lower_body'],
  'jambes': ['squat', 'lunge', 'leg_press', 'leg_extension', 'deadlift', 'calf', 'lower_body'],
  'glutes': ['glute', 'hip_thrust', 'kickback', 'sumo'],
  'glute': ['glute', 'hip_thrust', 'kickback', 'sumo'],
  'gluteos': ['glute', 'hip_thrust', 'kickback', 'sumo'],
  'fessiers': ['glute', 'hip_thrust', 'kickback', 'sumo'],
  'quads': ['quad', 'leg_extension', 'squat'],
  'hamstrings': ['hamstring', 'deadlift'],
  'calves': ['calf'],
  'core': ['crunch', 'plank', 'v_up', 'leg_raise', 'core'],
  'abs': ['crunch', 'plank', 'v_up', 'leg_raise', 'core'],
  'abdominales': ['crunch', 'plank', 'v_up', 'leg_raise', 'core'],
  'abdos': ['crunch', 'plank', 'v_up', 'leg_raise', 'core'],
};

String _fold(String input) {
  const accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'í': 'i',
    'î': 'i', 'ó': 'o', 'ô': 'o', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ñ': 'n',
    'ç': 'c',
  };
  final buffer = StringBuffer();
  for (final char in input.toLowerCase().split('')) {
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString();
}

List<String> _queryWords(String query) {
  return _fold(query)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty && !_stopWords.contains(word))
      .toList();
}

/// A "_2" / "_3" re-take of a clip already in the list adds nothing to a
/// series, so only the first take is kept.
String _takeBase(String slug) => slug.replaceFirst(RegExp(r'_\d+$'), '');

/// Clips that answer what the user typed, best match first.
///
/// Every named piece of kit must be used by a result. Every other word
/// scores a clip when it appears in its name, or when it names a body area
/// the clip trains ("chest" finds presses and flies).
List<ExerciseClip> rankHowToClips(List<ExerciseClip> clips, String query) {
  final words = _queryWords(query);
  if (words.isEmpty) return clips;

  final requiredKit = {
    for (final word in words)
      if (_equipmentWords[word] != null) _equipmentWords[word]!,
  };
  final contentWords =
      words.where((w) => !_equipmentWords.containsKey(w)).toList();

  final scored = <(ExerciseClip, int)>[];
  for (final clip in clips) {
    if (!requiredKit.every(clip.equipment.contains) &&
        !requiredKit.every(clip.slug.contains)) {
      continue;
    }
    final haystack = _fold('${clip.slug} ${clip.nameEn} ${clip.nameEs}');
    // Naming only kit ("dumbbell") lists everything that uses it.
    var score = contentWords.isEmpty ? 1 : 0;
    for (final word in contentWords) {
      final singular = word.endsWith('s') ? word.substring(0, word.length - 1) : word;
      if (haystack.contains(word) || haystack.contains(singular)) {
        score += 3;
        continue;
      }
      final terms = _areaTerms[word];
      if (terms != null && terms.any(clip.slug.contains)) score += 2;
    }
    if (score > 0) scored.add((clip, score));
  }

  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    return byScore != 0 ? byScore : a.$1.nameEn.compareTo(b.$1.nameEn);
  });
  return [for (final entry in scored) entry.$1];
}

/// The clips a typed request becomes when played as a series: the best
/// matches, one take per exercise, at most [kHowToSeriesMaxClips].
List<ExerciseClip> howToSeriesFor(List<ExerciseClip> ranked) {
  final seen = <String>{};
  final series = <ExerciseClip>[];
  for (final clip in ranked) {
    if (!seen.add(_takeBase(clip.slug))) continue;
    series.add(clip);
    if (series.length == kHowToSeriesMaxClips) break;
  }
  return series;
}
