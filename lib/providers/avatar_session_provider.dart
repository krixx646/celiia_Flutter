import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/celia_chat_message.dart';
import '../services/avatar_agent_service.dart';
import '../services/celia_chat_service.dart';
import '../utils/user_facing_error.dart';

/// Conversation state for Avatar Mode — separate from [ChatProvider] so the
/// manual chat tab never shares a thread or conversation id with the avatar.
class AvatarSessionProvider extends ChangeNotifier {
  @visibleForTesting
  static AvatarAgentService Function() defaultService = () =>
      AvatarAgentService();

  AvatarSessionProvider({AvatarAgentService? service})
    : _service = service ?? defaultService();

  final AvatarAgentService _service;

  final List<CeliaMessage> _messages = [];
  List<CeliaMessage> get messages => List.unmodifiable(_messages);

  String? _conversationId;
  String? get conversationId => _conversationId;

  bool _isStreaming = false;
  bool get isStreaming => _isStreaming;

  String? _error;
  String? get error => _error;

  String _lastAssistantText = '';
  String get lastAssistantText => _lastAssistantText;

  /// App-control tool calls ready for the local dispatcher (not yet consumed).
  final List<ChatToolCall> _pendingActions = [];
  List<ChatToolCall> takePendingActions() {
    final copy = List<ChatToolCall>.from(_pendingActions);
    _pendingActions.clear();
    return copy;
  }

  StreamSubscription<CeliaStreamEvent>? _subscription;
  Map<String, dynamic>? _userState;

  void setUserState(Map<String, dynamic> state) => _userState = state;

  ChatToolCall? get pendingApproval =>
      _messages.isEmpty ? null : _messages.last.pendingApproval;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isStreaming) return;

    _messages.add(CeliaMessage.user(trimmed));
    await _runTurn(message: trimmed);
  }

  Future<void> respondToApproval({
    required String approvalId,
    required bool approved,
  }) async {
    if (_isStreaming) return;
    _markApprovalAnswered(approvalId, approved);
    await _runTurn(approvals: [(approvalId: approvalId, approved: approved)]);
  }

  Future<void> _runTurn({
    String message = '',
    List<({String approvalId, bool approved})> approvals = const [],
  }) async {
    _error = null;
    _isStreaming = true;
    _lastAssistantText = '';

    final placeholder = CeliaMessage(
      id: 'stream_${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      isStreaming: true,
    );
    _messages.add(placeholder);
    notifyListeners();

    final index = _messages.length - 1;
    final buffer = StringBuffer();
    final calls = <String, ChatToolCall>{};
    final completion = Completer<void>();

    void update({bool? streaming, String? error}) {
      if (index >= _messages.length) return;
      _messages[index] = _messages[index].copyWith(
        text: buffer.toString(),
        toolCalls: calls.values.toList(),
        isStreaming: streaming ?? _messages[index].isStreaming,
        error: error,
      );
      notifyListeners();
    }

    _subscription = _service
        .send(
          conversationId: _conversationId,
          message: message,
          userState: _userState,
          approvals: approvals,
        )
        .listen(
          (event) {
            switch (event) {
              case CeliaConversationStarted(:final conversationId):
                _conversationId = conversationId;
              case CeliaTextDelta(:final delta):
                buffer.write(delta);
                update();
              case CeliaToolUpdate(:final call):
                calls[call.toolCallId] = call;
                if (AvatarAgentService.isAppControlTool(call.toolName) &&
                    call.phase == ToolPhase.running &&
                    call.input != null) {
                  _pendingActions.add(call);
                }
                update();
              case CeliaStreamError(message: final errorText):
                _error = errorText;
                update(error: errorText);
            }
          },
          onError: (Object e) {
            _error = toUserFriendlyMessage(
              e,
              fallbackOf: (l10n) => l10n.errorCeliaUnavailable,
            );
            update(error: _error);
          },
          onDone: () {
            if (!completion.isCompleted) completion.complete();
          },
          cancelOnError: false,
        );

    await completion.future;

    _isStreaming = false;
    _lastAssistantText = buffer.toString().trim();
    if (index < _messages.length && _messages[index].isEmpty) {
      _messages.removeAt(index);
      _error ??= 'Celia did not reply. Please try again.';
    } else {
      update(streaming: false);
    }
    notifyListeners();
  }

  void _markApprovalAnswered(String approvalId, bool approved) {
    for (var i = 0; i < _messages.length; i++) {
      final calls = _messages[i].toolCalls;
      final match = calls.indexWhere((call) => call.approvalId == approvalId);
      if (match == -1) continue;
      final updated = [...calls];
      updated[match] = updated[match].copyWith(
        phase: approved ? ToolPhase.running : ToolPhase.denied,
      );
      _messages[i] = _messages[i].copyWith(toolCalls: updated);
      notifyListeners();
      return;
    }
  }

  Future<void> startNewConversation() async {
    await _subscription?.cancel();
    _subscription = null;
    _isStreaming = false;
    _conversationId = null;
    _messages.clear();
    _pendingActions.clear();
    _lastAssistantText = '';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
