import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks Celia's chat replies with the device's built-in TTS engine.
///
/// Same on-device approach as workout coaching: free, offline, and already
/// available via [flutter_tts]. Cloud TTS stays reserved for a later branded
/// voice / avatar path.
class ChatTtsService {
  ChatTtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _engineReady = false;
  int _generation = 0;

  /// Called with each word as the engine speaks it, so the VRoid avatar can
  /// move its mouth in step with the voice. No audio buffer is available from
  /// on-device TTS, so word progress is the signal we have.
  void Function(String word)? onWord;

  /// Called when an utterance finishes or is cancelled.
  void Function()? onSpeechEnd;

  Future<void> warmUp({String localeName = 'en'}) async {
    await _ensureEngine(localeName);
  }

  Future<void> speak(String text, {String localeName = 'en'}) async {
    final cleaned = _forSpeech(text);
    if (cleaned.isEmpty) return;

    await _ensureEngine(localeName);
    if (!_engineReady) return;

    final generation = ++_generation;
    try {
      await _tts.stop();
      if (generation != _generation) return;
      await _tts.speak(cleaned);
      // awaitSpeakCompletion(true) means speak() returns once the utterance is
      // done, so this is also the end of the mouth movement.
      if (generation == _generation) onSpeechEnd?.call();
    } catch (e) {
      debugPrint('ChatTtsService: speak failed: $e');
      onSpeechEnd?.call();
    }
  }

  Future<void> stop() async {
    _generation++;
    try {
      await _tts.stop();
    } catch (_) {}
    onSpeechEnd?.call();
  }

  Future<void> dispose() async {
    await stop();
  }

  Future<void> _ensureEngine(String localeName) async {
    if (_engineReady) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setVolume(1.0);
      _tts.setProgressHandler((text, start, end, word) {
        onWord?.call(word);
      });
      // Slightly slower than workout counts — chat answers are sentences.
      await _tts.setSpeechRate(Platform.isIOS ? 0.48 : 0.5);
      await _tts.setPitch(1.0);

      final locale = _ttsLocale(localeName);
      final langResult = await _tts.setLanguage(locale);
      if (langResult == 0 || langResult == false) {
        await _tts.setLanguage('en-US');
      }

      if (Platform.isIOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      } else if (Platform.isAndroid) {
        await _tts.setAudioAttributesForNavigation();
      }

      _engineReady = true;
    } catch (e) {
      debugPrint('ChatTtsService: TTS engine init failed: $e');
    }
  }

  /// Strip markdown noise so TTS does not read asterisks and headings aloud.
  static String _forSpeech(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return '';
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
    // replaceAll takes the replacement literally, so keeping a captured group
    // needs replaceAllMapped.
    text = text.replaceAllMapped(RegExp(r'`([^`]*)`'), (m) => m[1] ?? '');
    text = text.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) => m[1] ?? '',
    );
    text = text.replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m[1] ?? '');
    text = text.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (m) => m[1] ?? '',
    );
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  static String _ttsLocale(String localeName) {
    final raw = localeName.trim().replaceAll('_', '-');
    if (raw.isEmpty) return 'en-US';
    final parts = raw.split('-');
    final lang = parts.first.toLowerCase();
    if (parts.length >= 2) {
      return '$lang-${parts[1].toUpperCase()}';
    }
    return switch (lang) {
      'en' => 'en-US',
      'es' => 'es-ES',
      'zh' => 'zh-CN',
      'hi' => 'hi-IN',
      'ar' => 'ar-SA',
      'fr' => 'fr-FR',
      'pt' => 'pt-BR',
      'ru' => 'ru-RU',
      'ja' => 'ja-JP',
      'de' => 'de-DE',
      'ko' => 'ko-KR',
      'it' => 'it-IT',
      'tr' => 'tr-TR',
      'id' => 'id-ID',
      'vi' => 'vi-VN',
      'th' => 'th-TH',
      'pl' => 'pl-PL',
      'nl' => 'nl-NL',
      _ => 'en-US',
    };
  }
}
