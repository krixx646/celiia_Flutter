import 'dart:async';

import 'package:flutter/material.dart';

import '../../avatar/celia_avatar_controller.dart';
import '../../avatar/celia_avatar_state.dart';
import '../../avatar/celia_avatar_view.dart';
import '../../avatar/celia_lip_sync.dart';
import '../../config/env.dart';
import '../../services/chat_tts_service.dart';

/// Dev screen to validate the native VRoid Filament / RealityKit spike.
class VrmAvatarTestScreen extends StatefulWidget {
  const VrmAvatarTestScreen({super.key});

  @override
  State<VrmAvatarTestScreen> createState() => _VrmAvatarTestScreenState();
}

class _VrmAvatarTestScreenState extends State<VrmAvatarTestScreen> {
  static const _sampleLine =
      'Nice work today. You hit your protein target, so tomorrow we can push a '
      'little harder on legs.';

  final _controller = CeliaAvatarController();
  final _tts = ChatTtsService();
  late final CeliaLipSync _lipSync;
  CeliaAvatarState _state = CeliaAvatarState.idle;
  String _lastWord = '';
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _lipSync = CeliaLipSync(onMorphs: _controller.setMorphs);
    _tts.onWord = (word) {
      if (!mounted) return;
      setState(() => _lastWord = word);
      _lipSync.speakWord(word);
    };
    _tts.onSpeechEnd = () {
      if (!mounted) return;
      _lipSync.close();
      setState(() {
        _state = CeliaAvatarState.idle;
        _lastWord = '';
      });
      unawaited(_controller.setState(CeliaAvatarState.idle));
    };
    // Idle blink so she does not look frozen between utterances.
    _blinkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_controller.blinkOnce());
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _lipSync.dispose();
    _tts.onWord = null;
    _tts.onSpeechEnd = null;
    unawaited(_tts.dispose());
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _setState(CeliaAvatarState state) async {
    setState(() => _state = state);
    await _controller.setState(state);
    if (state != CeliaAvatarState.speaking) {
      _lipSync.close();
    }
  }

  Future<void> _speakSample() async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    await _setState(CeliaAvatarState.speaking);
    await _tts.speak(_sampleLine, localeName: locale);
  }

  @override
  Widget build(BuildContext context) {
    if (!Env.enableVrmAvatar) {
      return Scaffold(
        appBar: AppBar(title: const Text('VRM Avatar')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Avatar is off. Rebuild without ENABLE_VRM_AVATAR=false (it is on by default).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      appBar: AppBar(
        title: const Text('Celia VRM (native spike)'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(child: CeliaAvatarView(controller: _controller)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _lastWord.isEmpty
                        ? 'state: ${_state.name}'
                        : 'state: ${_state.name}  ·  "$_lastWord"',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final s in CeliaAvatarState.values)
                        FilledButton(
                          onPressed: () => _setState(s),
                          child: Text(s.name),
                        ),
                      FilledButton.tonal(
                        onPressed: _speakSample,
                        child: const Text('speak (real TTS)'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => unawaited(_tts.stop()),
                        child: const Text('stop'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => unawaited(_controller.blinkOnce()),
                        child: const Text('blink'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
