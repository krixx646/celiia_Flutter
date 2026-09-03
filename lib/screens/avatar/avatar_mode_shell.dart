import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../avatar/avatar_action_dispatcher.dart';
import '../../avatar/celia_avatar_controller.dart';
import '../../avatar/celia_avatar_state.dart';
import '../../avatar/celia_avatar_view.dart';
import '../../avatar/celia_lip_sync.dart';
import '../../config/env.dart';
import '../../l10n/app_localizations.dart';
import '../../models/celia_chat_message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_mode_provider.dart';
import '../../providers/avatar_session_provider.dart';
import '../../providers/chat_provider.dart' show buildUserState;
import '../../providers/nutrition_profile_provider.dart';
import '../../services/chat_stt_service.dart';
import '../../services/chat_tts_service.dart';

/// Full-screen, voice-only Avatar Mode shell.
///
/// Replaces the tab shell when [AvatarModeProvider.isEnabled]. Owns a nested
/// [Navigator] so Celia's app-control tools push real screens on top of her
/// and return here when they pop.
class AvatarModeShell extends StatefulWidget {
  const AvatarModeShell({super.key});

  @override
  State<AvatarModeShell> createState() => _AvatarModeShellState();
}

class _AvatarModeShellState extends State<AvatarModeShell> {
  final _navKey = GlobalKey<NavigatorState>();
  late final AvatarActionDispatcher _dispatcher;

  @override
  void initState() {
    super.initState();
    _dispatcher = AvatarActionDispatcher(_navKey);
    unawaited(WakelockPlus.enable());
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _AvatarHome(
            dispatcher: _dispatcher,
          ),
        );
      },
    );
  }
}

class _AvatarHome extends StatefulWidget {
  const _AvatarHome({required this.dispatcher});

  final AvatarActionDispatcher dispatcher;

  @override
  State<_AvatarHome> createState() => _AvatarHomeState();
}

class _AvatarHomeState extends State<_AvatarHome> {
  final _avatar = CeliaAvatarController();
  final _stt = ChatSttService();
  final _tts = ChatTtsService();
  late final CeliaLipSync _lipSync;
  late final AvatarSessionProvider _session;

  CeliaAvatarState _state = CeliaAvatarState.idle;
  bool _listening = false;
  bool _speaking = false;
  String _partial = '';
  String _caption = '';
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _session = AvatarSessionProvider();
    _lipSync = CeliaLipSync(onMorphs: _avatar.setMorphs);
    _tts.onWord = (word) => _lipSync.speakWord(word);
    _tts.onSpeechEnd = _onSpeechEnd;
    _blinkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_state == CeliaAvatarState.speaking) return;
      unawaited(_avatar.blinkOnce());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _publishUserState();
      final locale = Localizations.localeOf(context).toLanguageTag();
      unawaited(_tts.warmUp(localeName: locale));
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _lipSync.dispose();
    _tts.onWord = null;
    _tts.onSpeechEnd = null;
    unawaited(_tts.dispose());
    _stt.dispose();
    unawaited(_avatar.dispose());
    _session.dispose();
    super.dispose();
  }

  void _publishUserState() {
    final user = context.read<AuthProvider>().uiState.currentUser;
    final name = user?.displayName?.trim();
    _session.setUserState(
      buildUserState(
        displayName: name != null && name.isNotEmpty
            ? name
            : user?.email?.split('@').first,
        profile: context.read<NutritionProfileProvider>().profile,
      ),
    );
  }

  Future<void> _setState(CeliaAvatarState next) async {
    if (_state == next) return;
    if (mounted) setState(() => _state = next);
    await _avatar.setState(next);
  }

  void _syncState({required bool streaming}) {
    final next = _listening
        ? CeliaAvatarState.listening
        : _speaking
            ? CeliaAvatarState.speaking
            : streaming
                ? CeliaAvatarState.thinking
                : CeliaAvatarState.idle;
    unawaited(_setState(next));
  }

  void _onSpeechEnd() {
    if (!mounted) return;
    _lipSync.close();
    setState(() => _speaking = false);
    _syncState(streaming: _session.isStreaming);
  }

  /// Barge-in: stop her voice immediately when the user grabs the mic.
  Future<void> _stopSpeaking() async {
    await _tts.stop();
    if (!mounted) return;
    _lipSync.close();
    setState(() => _speaking = false);
  }

  Future<void> _onMicDown() async {
    if (!Env.enableChatVoice) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await _stopSpeaking();
    if (!mounted) return;

    final ready = await _stt.ensureReady();
    if (!mounted) return;
    if (!ready) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.chatSpeechUnavailable)),
      );
      return;
    }

    final locale = Localizations.localeOf(context);
    final localeId = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';

    final started = await _stt.start(
      localeId: localeId,
      onPartial: (text) {
        if (!mounted) return;
        setState(() => _partial = text);
      },
    );
    if (!mounted) return;
    if (!started) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.chatMicDenied)));
      return;
    }
    setState(() {
      _listening = true;
      _partial = '';
    });
    _syncState(streaming: false);
  }

  Future<void> _onMicUp() async {
    if (!_listening) return;
    final transcript = await _stt.stop();
    if (!mounted) return;
    setState(() => _listening = false);
    _syncState(streaming: false);

    final text = transcript.trim().isNotEmpty
        ? transcript.trim()
        : _partial.trim();
    setState(() => _partial = '');
    if (text.isEmpty) return;
    await _send(text);
  }

  Future<void> _send(String text) async {
    _publishUserState();
    setState(() => _caption = '');
    _syncState(streaming: true);
    await _session.sendMessage(text);
    if (!mounted) return;

    final actions = _session.takePendingActions();
    if (actions.isNotEmpty) {
      unawaited(widget.dispatcher.dispatchAll(actions));
    }

    final approval = _session.pendingApproval;
    if (approval != null && approval.approvalId != null) {
      _syncState(streaming: false);
      await _promptApproval(approval);
      return;
    }

    final reply = _session.lastAssistantText;
    if (reply.isNotEmpty) {
      setState(() {
        _caption = reply;
        _speaking = true;
      });
      _syncState(streaming: false);
      final locale = Localizations.localeOf(context).toLanguageTag();
      await _tts.speak(reply, localeName: locale);
    } else {
      _syncState(streaming: false);
    }
  }

  Future<void> _promptApproval(ChatToolCall approval) async {
    final l10n = AppLocalizations.of(context);
    final approvalId = approval.approvalId;
    if (approvalId == null) return;
    final approved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.avatarModeConfirmTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.avatarModeConfirmBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.actionCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.avatarModeConfirmYes),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || approved == null) return;
    await _session.respondToApproval(
      approvalId: approvalId,
      approved: approved,
    );
    if (!mounted) return;
    final actions = _session.takePendingActions();
    if (actions.isNotEmpty) {
      unawaited(widget.dispatcher.dispatchAll(actions));
    }
    final reply = _session.lastAssistantText;
    if (reply.isNotEmpty) {
      setState(() {
        _caption = reply;
        _speaking = true;
      });
      final locale = Localizations.localeOf(context).toLanguageTag();
      await _tts.speak(reply, localeName: locale);
    }
  }

  Future<void> _exitAvatarMode() async {
    await _stopSpeaking();
    await _stt.cancel();
    if (!mounted) return;
    await context.read<AvatarModeProvider>().setEnabled(false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _listening
        ? l10n.chatListening
        : _speaking
            ? l10n.avatarModeSpeaking
            : _session.isStreaming
                ? l10n.avatarModeThinking
                : l10n.avatarModeReady;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _exitAvatarMode,
                    icon: const Icon(Icons.close, color: Colors.black87),
                    label: Text(
                      l10n.avatarModeExit,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: Env.enableVrmAvatar
                  ? CeliaAvatarView(controller: _avatar)
                  : const Center(
                      child: Icon(
                        Icons.face_retouching_natural,
                        size: 96,
                        color: Colors.black26,
                      ),
                    ),
            ),
            if (_partial.isNotEmpty || _caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  _partial.isNotEmpty ? _partial : _caption,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _partial.isNotEmpty
                        ? Colors.black87
                        : Colors.black54,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ),
            if (_session.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _session.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Center(
                child: GestureDetector(
                  onTapDown: (_) => unawaited(_onMicDown()),
                  onTapUp: (_) => unawaited(_onMicUp()),
                  onTapCancel: () => unawaited(_onMicUp()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _listening ? 88 : 76,
                    height: _listening ? 88 : 76,
                    decoration: BoxDecoration(
                      color: _listening
                          ? const Color(0xFFFF6F00)
                          : const Color(0xFFF57C00),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF57C00)
                              .withValues(alpha: _listening ? 0.45 : 0.25),
                          blurRadius: _listening ? 24 : 12,
                          spreadRadius: _listening ? 4 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _listening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              l10n.avatarModeHoldToTalk,
              style: const TextStyle(color: Colors.black45, fontSize: 13),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
