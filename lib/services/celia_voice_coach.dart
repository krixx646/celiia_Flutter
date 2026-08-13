import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/app_localizations.dart';
import '../models/workout_session.dart';
import 'workout_coach.dart';

/// Celia speaks workout cues through the device's built-in TTS engine.
///
/// On-device speech is instant, works offline, and costs nothing — which is
/// what counting reps and countdown beeps need. OpenAI TTS
/// ([WorkoutTtsService]) is reserved for richer spoken persona / avatar
/// moments later; mixing network synthesis into every "three… four…" also
/// caused mute gaps whenever a fetch lagged or failed.
///
/// Haptics still fire so a silent tablet (volume zero / TTS engine missing)
/// does not leave the user without feedback. Speech mixes with the muted
/// demo video so Exclusive audio focus does not freeze the clip.
class CeliaVoiceCoach implements WorkoutCoach {
  CeliaVoiceCoach({
    required AppLocalizations l10n,
    HapticCoach? haptics,
    FlutterTts? tts,
  }) : _l10n = l10n,
       _haptics = haptics ?? HapticCoach(),
       _tts = tts ?? FlutterTts();

  final AppLocalizations _l10n;
  final HapticCoach _haptics;
  final FlutterTts _tts;

  final Queue<_SpeakJob> _queue = Queue<_SpeakJob>();
  bool _draining = false;
  bool _stopped = false;
  bool _engineReady = false;
  int _generation = 0;

  /// Init the engine + language before the first phase so "Get ready" is not
  /// racing the first speak call.
  Future<void> warmUp() async {
    await _ensureEngine();
  }

  Future<void> _ensureEngine() async {
    if (_engineReady) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setVolume(1.0);
      // Slightly brisk counts land closer to the beat of a rep.
      await _tts.setSpeechRate(Platform.isIOS ? 0.52 : 0.55);
      await _tts.setPitch(1.0);

      final locale = _ttsLocale(_l10n.localeName);
      final langResult = await _tts.setLanguage(locale);
      if (langResult == 0 || langResult == false) {
        // Engine does not have that locale; fall back so we still speak.
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
        // Navigation guidance rides the media volume slider (what users turn
        // up) and mixes with other app audio — unlike ASSISTANCE_SONIFICATION,
        // which often maps to a near-silent system stream on tablets.
        await _tts.setAudioAttributesForNavigation();
      }

      _engineReady = true;
    } catch (e) {
      debugPrint('CeliaVoiceCoach: TTS engine init failed: $e');
    }
  }

  /// Map app locale codes (`es`, `zh`, `pt`) to TTS BCP-47 tags.
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

  @override
  void onPhaseStart(WorkoutPhase phase) {
    _haptics.onPhaseStart(phase);
    final line = switch (phase.kind) {
      WorkoutPhaseKind.getReady => _l10n.coachGetReady(phase.step.title),
      WorkoutPhaseKind.work => phase.isCounted
          ? _l10n.coachStartReps(phase.reps!)
          : _l10n.coachStartHold(phase.duration.inSeconds),
      WorkoutPhaseKind.rest =>
        (phase.nextLabel != null && phase.nextLabel!.trim().isNotEmpty)
            ? _l10n.coachRest(phase.nextLabel!.trim())
            : _l10n.coachRestShort,
    };
    _enqueue(line, interrupt: true);
  }

  @override
  void onRep(int rep, int total) {
    _haptics.onRep(rep, total);
    // Interrupt so a late "two" never blocks the current "three". On-device
    // TTS is fast enough that cutting mid-utterance still sounds natural.
    _enqueue(_l10n.coachRep(rep), interrupt: true);
  }

  @override
  void onFinalSeconds(int secondsRemaining) {
    _haptics.onFinalSeconds(secondsRemaining);
    _enqueue(_l10n.coachCountdown(secondsRemaining), interrupt: true);
  }

  @override
  void onComplete() {
    _haptics.onComplete();
    _enqueue(_l10n.coachComplete, interrupt: true);
  }

  @override
  void stop() {
    _stopped = true;
    _generation++;
    _queue.clear();
    unawaited(_tts.stop());
  }

  /// Resume speaking after a pause. Does not replay what was cancelled.
  void resume() {
    _stopped = false;
  }

  void _enqueue(String text, {bool interrupt = false}) {
    if (_stopped) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (interrupt) {
      _generation++;
      _queue.clear();
      unawaited(_tts.stop());
    }

    _queue.add(_SpeakJob(trimmed, _generation));
    unawaited(_drain());
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      await _ensureEngine();
      while (_queue.isNotEmpty && !_stopped) {
        final job = _queue.removeFirst();
        if (job.generation != _generation) continue;
        try {
          final result = await _tts.speak(job.text);
          if (result != 1) {
            debugPrint(
              'CeliaVoiceCoach: speak returned $result for "${job.text}"',
            );
          }
        } catch (e) {
          debugPrint('CeliaVoiceCoach: speak failed for "${job.text}": $e');
        }
      }
    } finally {
      _draining = false;
      if (_queue.isNotEmpty && !_stopped) unawaited(_drain());
    }
  }

  Future<void> dispose() async {
    stop();
    // flutter_tts has no dispose; stop is enough to release focus.
  }
}

class _SpeakJob {
  const _SpeakJob(this.text, this.generation);
  final String text;
  final int generation;
}
