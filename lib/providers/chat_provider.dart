import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/celia_chat_message.dart';
import '../models/nutrition_profile.dart';
import '../services/celia_chat_service.dart';
import '../utils/user_facing_error.dart';

/// Facts about the user sent with every turn.
///
/// The coach backend reads routines and meals from Supabase itself, but the
/// nutrition profile lives in Firestore, which it cannot reach — so the app
/// hands those numbers over instead of Celia having to ask for them.
Map<String, dynamic> buildUserState({
  String? displayName,
  NutritionProfile? profile,
}) {
  return {
    if (displayName != null && displayName.isNotEmpty)
      'displayName': displayName,
    if (profile != null) ...{
      'targets': {
        'dailyCalories': profile.dailyCalories,
        'proteinGrams': profile.dailyProteinGrams,
        'carbsGrams': profile.dailyCarbsGrams,
        'fatGrams': profile.dailyFatGrams,
      },
      'profile': {
        'weightKg': profile.weightKg,
        'heightCm': profile.heightCm,
        'age': profile.age,
        'gender': profile.gender.name,
      },
    },
  };
}

class ChatProvider extends ChangeNotifier {
  @visibleForTesting
  static CeliaChatService Function() defaultChatService = () =>
      CeliaChatService();

  ChatProvider({CeliaChatService? chatService})
    : _service = chatService ?? defaultChatService();

  final CeliaChatService _service;

  final List<CeliaMessage> _messages = [];
  List<CeliaMessage> get messages => List.unmodifiable(_messages);

  String? _conversationId;
  String? get conversationId => _conversationId;

  /// True from the moment a turn is sent until the stream closes.
  bool _isStreaming = false;
  bool get isStreaming => _isStreaming;

  String? _error;
  String? get error => _error;

  List<ChatConversation> _history = [];
  List<ChatConversation> get history => List.unmodifiable(_history);

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  bool _isLoadingConversation = false;
  bool get isLoadingConversation => _isLoadingConversation;

  bool _showHistory = false;
  bool get showHistory => _showHistory;

  StreamSubscription<CeliaStreamEvent>? _subscription;

  /// The state snapshot to send with each turn, refreshed by the screen.
  Map<String, dynamic>? _userState;
  void setUserState(Map<String, dynamic> state) => _userState = state;

  bool get hasMessages => _messages.isNotEmpty;

  /// The write Celia is currently waiting on permission for, if any.
  ChatToolCall? get pendingApproval =>
      _messages.isEmpty ? null : _messages.last.pendingApproval;

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      _history = await _service.listConversations();
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallback: 'Unable to load saved chats right now.',
      );
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isStreaming) return;

    _messages.add(CeliaMessage.user(trimmed));
    await _runTurn(message: trimmed);
  }

  /// Answers a confirmation Celia asked for. Approving resumes the same turn,
  /// so the tool runs and she carries on from where she paused.
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

    // The assistant bubble exists before any content arrives so the UI has
    // something to attach the thinking indicator to.
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
                update();
              case CeliaStreamError(message: final errorText):
                _error = errorText;
                update(error: errorText);
            }
          },
          onError: (Object e) {
            _error = toUserFriendlyMessage(
              e,
              fallback: 'Celia is unavailable right now. Please try again.',
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
    // A turn that produced nothing at all would leave an empty bubble behind.
    if (index < _messages.length && _messages[index].isEmpty) {
      _messages.removeAt(index);
      _error ??= 'Celia did not reply. Please try again.';
    } else {
      update(streaming: false);
    }
    notifyListeners();

    // The reply may have renamed or created the conversation.
    if (_error == null) unawaited(loadHistory());
  }

  /// Flips the pending approval to its answer so the buttons disappear as soon
  /// as the user taps, rather than when the next stream reports it.
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
    await _cancelStream();
    _conversationId = null;
    _messages.clear();
    _error = null;
    _showHistory = false;
    notifyListeners();
  }

  Future<void> openConversation(String id) async {
    await _cancelStream();
    _isLoadingConversation = true;
    _showHistory = false;
    _conversationId = id;
    _messages.clear();
    _error = null;
    notifyListeners();

    try {
      final loaded = await _service.loadConversation(id);
      _messages
        ..clear()
        ..addAll(loaded);
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallback: 'Could not open that conversation.',
      );
    } finally {
      _isLoadingConversation = false;
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      await _service.deleteConversation(id);
      if (_conversationId == id) await startNewConversation();
      await loadHistory();
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallback: 'Could not delete this conversation. Please try again.',
      );
      notifyListeners();
    }
  }

  void toggleHistory() {
    _showHistory = !_showHistory;
    if (_showHistory) unawaited(loadHistory());
    notifyListeners();
  }

  Future<void> _cancelStream() async {
    await _subscription?.cancel();
    _subscription = null;
    _isStreaming = false;
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
