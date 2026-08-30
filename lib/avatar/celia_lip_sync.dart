import 'dart:async';

import 'celia_avatar_morphs.dart';

/// Turns spoken words into VRM mouth morph weights.
///
/// On-device TTS gives no audio buffer to analyse, but [FlutterTts] reports
/// each word as it is spoken. Stepping through that word's vowels is enough to
/// read as speech, and it costs nothing extra.
class CeliaLipSync {
  CeliaLipSync({
    required this.onMorphs,
    this.visemeDuration = const Duration(milliseconds: 105),
  });

  final void Function(Map<String, double> morphs) onMorphs;

  /// How long a single mouth shape is held.
  final Duration visemeDuration;

  Timer? _timer;
  List<String> _queue = const [];
  var _index = 0;

  static const _vowelMorphs = <String, String>{
    'a': CeliaAvatarMorphs.mouthA,
    'e': CeliaAvatarMorphs.mouthE,
    'i': CeliaAvatarMorphs.mouthI,
    'o': CeliaAvatarMorphs.mouthO,
    'u': CeliaAvatarMorphs.mouthU,
    'y': CeliaAvatarMorphs.mouthI,
    'á': CeliaAvatarMorphs.mouthA,
    'à': CeliaAvatarMorphs.mouthA,
    'â': CeliaAvatarMorphs.mouthA,
    'é': CeliaAvatarMorphs.mouthE,
    'è': CeliaAvatarMorphs.mouthE,
    'ê': CeliaAvatarMorphs.mouthE,
    'í': CeliaAvatarMorphs.mouthI,
    'ó': CeliaAvatarMorphs.mouthO,
    'ô': CeliaAvatarMorphs.mouthO,
    'õ': CeliaAvatarMorphs.mouthO,
    'ú': CeliaAvatarMorphs.mouthU,
    'ü': CeliaAvatarMorphs.mouthU,
  };

  /// Queues the mouth shapes for [word] and starts playing them.
  void speakWord(String word) {
    final visemes = _visemesFor(word);
    if (visemes.isEmpty) {
      close();
      return;
    }
    _queue = visemes;
    _index = 0;
    _timer?.cancel();
    _emitCurrent();
    _timer = Timer.periodic(visemeDuration, (_) {
      _index++;
      if (_index >= _queue.length) {
        close();
        return;
      }
      _emitCurrent();
    });
  }

  /// Closes the mouth and stops any queued shapes.
  void close() {
    _timer?.cancel();
    _timer = null;
    _queue = const [];
    _index = 0;
    onMorphs({CeliaAvatarMorphs.mouthClose: 0.3});
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void _emitCurrent() {
    final morph = _queue[_index];
    // Consonant gaps read as a softer, mostly-closed mouth.
    if (morph == CeliaAvatarMorphs.mouthClose) {
      onMorphs({CeliaAvatarMorphs.mouthClose: 0.55});
      return;
    }
    onMorphs({morph: 0.85});
  }

  /// Vowels carry the visible shape; a closed beat is inserted between them so
  /// consecutive vowels do not blur into one held pose.
  static List<String> _visemesFor(String word) {
    final letters = word.toLowerCase().split('');
    final result = <String>[];
    for (final letter in letters) {
      final morph = _vowelMorphs[letter];
      if (morph == null) continue;
      if (result.isNotEmpty) result.add(CeliaAvatarMorphs.mouthClose);
      result.add(morph);
    }
    // A word with no vowels (or an abbreviation) still needs some movement.
    if (result.isEmpty && word.trim().isNotEmpty) {
      return [CeliaAvatarMorphs.mouthA];
    }
    return result;
  }
}
