import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// On-device push-to-talk speech recognition for coach chat.
class ChatSttService {
  ChatSttService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _available = false;
  String _latest = '';

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;

  Future<bool> ensureReady() async {
    if (_initialized) return _available;
    try {
      _available = await _speech.initialize(
        onError: (error) => debugPrint('ChatSttService: $error'),
        onStatus: (status) => debugPrint('ChatSttService status: $status'),
      );
    } catch (e) {
      debugPrint('ChatSttService: init failed: $e');
      _available = false;
    }
    _initialized = true;
    return _available;
  }

  /// Starts listening. Partial results are pushed to [onPartial].
  Future<bool> start({
    required void Function(String text) onPartial,
    String localeId = 'en_US',
  }) async {
    final ready = await ensureReady();
    if (!ready) return false;
    if (_speech.isListening) {
      await _speech.stop();
    }
    _latest = '';

    try {
      await _speech.listen(
        onResult: (result) {
          _latest = result.recognizedWords;
          onPartial(_latest);
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
          localeId: localeId,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('ChatSttService: listen failed: $e');
      return false;
    }
  }

  /// Stops listening and returns the best transcript captured so far.
  Future<String> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
      // Give the engine a beat to flush a final partial.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return _latest.trim();
  }

  Future<void> cancel() async {
    _latest = '';
    try {
      await _speech.cancel();
    } catch (_) {}
  }

  void dispose() {
    cancel();
  }
}
