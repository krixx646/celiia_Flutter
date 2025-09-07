import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/chat_models.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/chat_repository.dart';
import '../repositories/chat_history_repository.dart';

class SavedConversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final String userId;
  final String userKey;

  SavedConversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.userId,
    required this.userKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userKey': userKey,
    };
  }

  factory SavedConversation.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
    DateTime parsed;
    if (ts is Timestamp) {
      parsed = ts.toDate();
    } else if (ts is String) {
      parsed = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsed = DateTime.now();
    }
    return SavedConversation(
      id: json['id'],
      title: json['title'],
      lastMessage: json['lastMessage'],
      timestamp: parsed,
      userId: json['userId'],
      userKey: json['userKey'],
    );
  }
}

class ChatUiState {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingInitial;
  final bool isSendingMessage;
  final bool pollingEnabled;
  final String? error;
  final bool hasActiveConversation;
  final bool isTyping;
  final List<SavedConversation> conversationHistory;
  final bool isLoadingHistory;
  final bool showNewConversationButton;
  final bool showStartNewConversationDialog;
  final bool showHistory;
  final bool showSettingsDialog;
  final bool showUserProfileDialog;
  final bool showRestartConfirmation;
  final String? currentConversationId;
  final String? currentUserKey;
  final String? userIdForBotpress;
  final bool hasInitialized;

  ChatUiState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingInitial = false,
    this.isSendingMessage = false,
    this.pollingEnabled = false,
    this.error,
    this.hasActiveConversation = false,
    this.isTyping = false,
    this.conversationHistory = const [],
    this.isLoadingHistory = false,
    this.showNewConversationButton = false,
    this.showStartNewConversationDialog = false,
    this.showHistory = false,
    this.showSettingsDialog = false,
    this.showUserProfileDialog = false,
    this.showRestartConfirmation = false,
    this.currentConversationId,
    this.currentUserKey,
    this.userIdForBotpress,
    this.hasInitialized = false,
  });

  ChatUiState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingInitial,
    bool? isSendingMessage,
    bool? pollingEnabled,
    String? error,
    bool? hasActiveConversation,
    bool? isTyping,
    List<SavedConversation>? conversationHistory,
    bool? isLoadingHistory,
    bool? showNewConversationButton,
    bool? showStartNewConversationDialog,
    bool? showHistory,
    bool? showSettingsDialog,
    bool? showUserProfileDialog,
    bool? showRestartConfirmation,
    String? currentConversationId,
    String? currentUserKey,
    String? userIdForBotpress,
    bool? hasInitialized,
  }) {
    return ChatUiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      pollingEnabled: pollingEnabled ?? this.pollingEnabled,
      error: error,
      hasActiveConversation: hasActiveConversation ?? this.hasActiveConversation,
      isTyping: isTyping ?? this.isTyping,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      showNewConversationButton: showNewConversationButton ?? this.showNewConversationButton,
      showStartNewConversationDialog: showStartNewConversationDialog ?? this.showStartNewConversationDialog,
      showHistory: showHistory ?? this.showHistory,
      showSettingsDialog: showSettingsDialog ?? this.showSettingsDialog,
      showUserProfileDialog: showUserProfileDialog ?? this.showUserProfileDialog,
      showRestartConfirmation: showRestartConfirmation ?? this.showRestartConfirmation,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      currentUserKey: currentUserKey ?? this.currentUserKey,
      userIdForBotpress: userIdForBotpress ?? this.userIdForBotpress,
      hasInitialized: hasInitialized ?? this.hasInitialized,
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final ChatHistoryRepository _historyRepository = ChatHistoryRepository();
  
  ChatUiState _uiState = ChatUiState();
  ChatUiState get uiState => _uiState;

  Timer? _pollingTimer;
  final Set<String> _interactedMessageIds = {};
  final Map<String, bool> _messageDirections = {}; // true = user, false = bot

  Future<void> initializeChat() async {
    if (_uiState.hasInitialized) return;

    _uiState = _uiState.copyWith(
      isLoadingInitial: true,
      error: null,
    );
    notifyListeners();

    try {
      // Persist Botpress user key across launches to avoid 403 on history
      final prefs = await SharedPreferences.getInstance();
      String? userKey = prefs.getString('botpress_user_key');
      if (userKey == null) {
        final user = await _chatRepository.createUser();
        userKey = user.id;
        await prefs.setString('botpress_user_key', userKey);
      }
      
      _uiState = _uiState.copyWith(
        currentUserKey: userKey,
        userIdForBotpress: userKey,
        hasInitialized: true,
        isLoadingInitial: false,
      );
      notifyListeners();
      
      await loadConversationHistory();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isLoadingInitial: false,
      );
      notifyListeners();
    }
  }

  Future<void> startNewConversation() async {
    if (_uiState.currentUserKey == null) {
      await initializeChat();
    }

    _uiState = _uiState.copyWith(
      isLoading: true,
      error: null,
    );
    notifyListeners();

    try {
      final conversation = await _chatRepository.createConversation(_uiState.currentUserKey!);
      
      _uiState = _uiState.copyWith(
        currentConversationId: conversation.id,
        messages: [],
        hasActiveConversation: true,
        isLoading: false,
        showNewConversationButton: false,
      );
      notifyListeners();
      
      _startPolling();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
    }
  }

  bool hasMessageBeenInteracted(String messageId) {
    return _interactedMessageIds.contains(messageId);
  }

  bool isUserMessage(String messageId) {
    return _messageDirections[messageId] ?? false;
  }

  Future<void> sendMessageWithInteraction(String text, String messageId) async {
    _interactedMessageIds.add(messageId);
    notifyListeners();
    await sendMessage(text);
  }

  Future<void> sendMessage(String text) async {
    if (_uiState.currentUserKey == null || _uiState.currentConversationId == null) {
      _uiState = _uiState.copyWith(error: "No active conversation");
      notifyListeners();
      return;
    }

    _uiState = _uiState.copyWith(isSendingMessage: true, error: null);
    // Optimistically append the user's message with a special marker
    final optimisticId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final isImageUrl = text.startsWith('http') && (text.endsWith('.png') || text.endsWith('.jpg') || text.endsWith('.jpeg') || text.endsWith('.gif') || text.contains('imgbb.com') || text.contains('i.imgur.com'));
    final optimistic = Message(
      id: optimisticId,
      conversationId: _uiState.currentConversationId!,
      userId: 'user_${_uiState.currentUserKey}', // Use actual user key
      text: isImageUrl ? null : text,
      type: isImageUrl ? 'image' : 'text',
      created: DateTime.now().toIso8601String(),
      imageUrl: isImageUrl ? text : null,
    );
    _messageDirections[optimisticId] = true; // Mark as user message
    final updated = [..._uiState.messages, optimistic];
    _uiState = _uiState.copyWith(messages: updated);
    notifyListeners();

    try {
      final sent = await _chatRepository.sendMessage(
        _uiState.currentUserKey!,
        _uiState.currentConversationId!,
        text,
      );
      // Mark the sent message as a user message
      _messageDirections[sent.id] = true;
      
      // Replace last optimistic message with the confirmed one
      final current = [..._uiState.messages];
      final lastIndex = current.lastIndexWhere((m) => m.id.startsWith('local_'));
      if (lastIndex != -1) {
        // Remove the optimistic message direction tracking
        _messageDirections.remove(current[lastIndex].id);
        current[lastIndex] = sent;
      } else {
        current.add(sent);
      }
      _uiState = _uiState.copyWith(messages: current, isSendingMessage: false);
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isSendingMessage: false,
      );
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    if (_uiState.currentUserKey == null || _uiState.currentConversationId == null) {
      return;
    }

    try {
      final messages = await _chatRepository.getMessages(
        _uiState.currentUserKey!,
        _uiState.currentConversationId!,
      );
      
      // Track message directions based on the pattern
      // We'll use a simple algorithm: user messages are at even indices when sorted
      final fetchedSorted = [...messages]..sort((a, b) {
        final aTime = DateTime.tryParse(a.created) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = DateTime.tryParse(b.created) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
      
      // Update message directions based on pattern
      for (int i = 0; i < fetchedSorted.length; i++) {
        final msg = fetchedSorted[i];
        // User messages are typically at even indices (0, 2, 4...)
        // Bot messages at odd indices (1, 3, 5...)
        // Special handling for indices 2 and 6 as bot messages
        bool isUser = (i == 2 || i == 6) ? false : (i % 2 == 0);
        _messageDirections[msg.id] = isUser;
      }
      
      // Keep existing optimistic messages
      final optimisticMessages = _uiState.messages.where((m) => m.id.startsWith('local_')).toList();
      final combined = [...fetchedSorted, ...optimisticMessages];

      _uiState = _uiState.copyWith(
        messages: combined,
        error: null,
      );
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  void _startPolling() {
    // ensure no duplicate timers
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_uiState.hasActiveConversation) {
        loadMessages();
      }
    });
    
    _uiState = _uiState.copyWith(pollingEnabled: true);
    notifyListeners();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _uiState = _uiState.copyWith(pollingEnabled: false);
    notifyListeners();
  }

  Future<void> loadConversationHistory() async {
    _uiState = _uiState.copyWith(isLoadingHistory: true);
    notifyListeners();

    try {
      final history = await _historyRepository.getConversations();
      _uiState = _uiState.copyWith(
        conversationHistory: history,
        isLoadingHistory: false,
      );
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(
        error: e.toString(),
        isLoadingHistory: false,
      );
      notifyListeners();
    }
  }

  Future<bool> saveCurrentConversation() async {
    if (_uiState.currentConversationId == null) {
      return false;
    }

    try {
      final lastMessageRaw = _uiState.messages.isNotEmpty ? (_uiState.messages.last.text ?? '') : '';
      final lastMessage = lastMessageRaw.isEmpty ? 'No message' : lastMessageRaw;

      String firstText = _uiState.messages.isNotEmpty ? (_uiState.messages.first.text ?? '') : '';
      if (firstText.trim().isEmpty) {
        firstText = 'Conversation';
      }
      final int end = firstText.length < 30 ? firstText.length : 30;
      final String title = firstText.substring(0, end);

      final savedConversation = SavedConversation(
        id: _uiState.currentConversationId!,
        title: title,
        lastMessage: lastMessage,
        timestamp: DateTime.now(),
        userId: _uiState.userIdForBotpress ?? "unknown",
        userKey: _uiState.currentUserKey ?? "unknown",
      );

      await _historyRepository.saveConversation(savedConversation);
      await loadConversationHistory();
      if (kDebugMode) {
        // ignore: avoid_print
        print('[History] Saved conversation ${savedConversation.id} title="$title" last="$lastMessage"');
      }
      return true;
    } catch (e) {
      _uiState = _uiState.copyWith(error: e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> restartConversation() async {
    _stopPolling();
    await saveCurrentConversation();
    
    // Clear message tracking
    _messageDirections.clear();
    _interactedMessageIds.clear();
    
    _uiState = _uiState.copyWith(
      messages: [],
      hasActiveConversation: false,
      currentConversationId: null,
      showNewConversationButton: true,
      showRestartConfirmation: false,
    );
    notifyListeners();
  }

  void handleOptionClick(String value) {
    sendMessage(value);
  }

  void toggleHistory() {
    _uiState = _uiState.copyWith(showHistory: !_uiState.showHistory);
    notifyListeners();
  }

  Future<void> loadConversationFromHistory(SavedConversation saved) async {
    _stopPolling();
    _uiState = _uiState.copyWith(
      currentConversationId: saved.id,
      hasActiveConversation: true,
      messages: [],
      error: null,
    );
    notifyListeners();
    await loadMessages();
    _startPolling();
  }

  Future<void> deleteConversationById(String conversationId) async {
    try {
      await _historyRepository.deleteConversation(conversationId);
      await loadConversationHistory();
    } catch (e) {
      _uiState = _uiState.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  void toggleSettings() {
    _uiState = _uiState.copyWith(showSettingsDialog: !_uiState.showSettingsDialog);
    notifyListeners();
  }

  void toggleUserProfile() {
    _uiState = _uiState.copyWith(showUserProfileDialog: !_uiState.showUserProfileDialog);
    notifyListeners();
  }

  void showRestartDialog() {
    _uiState = _uiState.copyWith(showRestartConfirmation: true);
    notifyListeners();
  }

  void hideRestartDialog() {
    _uiState = _uiState.copyWith(showRestartConfirmation: false);
    notifyListeners();
  }

  void clearError() {
    _uiState = _uiState.copyWith(error: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _chatRepository.dispose();
    super.dispose();
  }
}


