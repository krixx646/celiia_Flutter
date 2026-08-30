import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'celia_avatar_morphs.dart';
import 'celia_avatar_state.dart';

/// Dart side of the native VRoid viewer (Filament Android / RealityKit iOS).
class CeliaAvatarController {
  CeliaAvatarController({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('eu.thefit.celia/vrm_avatar');

  final MethodChannel _channel;
  CeliaAvatarState _state = CeliaAvatarState.idle;
  double _mouthOpen = 0;
  bool _ready = false;

  CeliaAvatarState get state => _state;
  bool get isReady => _ready;

  Future<void> attach() async {
    try {
      await _channel.invokeMethod<void>('attach');
      _ready = true;
    } on PlatformException catch (e) {
      debugPrint('CeliaAvatarController.attach failed: $e');
      _ready = false;
    }
  }

  Future<void> loadBundledModel() async {
    try {
      await _channel.invokeMethod<void>('loadBundledModel');
      _ready = true;
    } on PlatformException catch (e) {
      debugPrint('CeliaAvatarController.loadBundledModel failed: $e');
      rethrow;
    }
  }

  Future<void> setState(CeliaAvatarState state) async {
    _state = state;
    if (!_ready) return;
    try {
      await _channel.invokeMethod<void>('setState', {'state': state.name});
    } on PlatformException catch (e) {
      debugPrint('CeliaAvatarController.setState failed: $e');
    }
  }

  /// Drive lip morphs from a 0..1 speech amplitude (TTS / mic level).
  Future<void> setSpeechAmplitude(double amplitude) async {
    _mouthOpen = amplitude.clamp(0.0, 1.0);
    await setMorphs(CeliaAvatarMorphs.fromSpeechAmplitude(_mouthOpen));
  }

  /// Applies named VRM morph weights directly (used by lip-sync visemes).
  Future<void> setMorphs(Map<String, double> morphs) async {
    if (!_ready) return;
    try {
      await _channel.invokeMethod<void>('setMorphs', {'morphs': morphs});
    } on PlatformException catch (e) {
      debugPrint('CeliaAvatarController.setMorphs failed: $e');
    }
  }

  /// Lightweight idle blink while not speaking.
  Future<void> blinkOnce() async {
    if (!_ready || _state == CeliaAvatarState.speaking) return;
    try {
      await _channel.invokeMethod<void>('setMorphs', {
        'morphs': {CeliaAvatarMorphs.eyeClose: 1.0},
      });
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await _channel.invokeMethod<void>('setMorphs', {
        'morphs': {CeliaAvatarMorphs.eyeClose: 0.0},
      });
    } on PlatformException catch (e) {
      debugPrint('CeliaAvatarController.blinkOnce failed: $e');
    }
  }

  Future<void> dispose() async {
    _ready = false;
    try {
      await _channel.invokeMethod<void>('dispose');
    } on PlatformException catch (_) {}
  }
}
