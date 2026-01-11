import 'package:celia_flutter/models/chat_models.dart' as m;
import 'package:celia_flutter/providers/chat_provider.dart';
import 'package:celia_flutter/repositories/chat_history_repository.dart';
import 'package:celia_flutter/repositories/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockChatRepository extends Mock implements ChatRepository {}
class MockChatHistoryRepository extends Mock implements ChatHistoryRepository {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('startNewConversation sets conversation id + enables polling', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(() => repo.createUser(name: any(named: 'name'), email: any(named: 'email')))
        .thenAnswer((_) async => m.User(id: 'ukey'));
    when(() => repo.createConversation('ukey')).thenAnswer(
      (_) async => m.Conversation(id: 'cid', userId: 'user', created: 't'),
    );
    when(() => history.getConversations()).thenAnswer((_) async => <SavedConversation>[]);

    final p = ChatProvider(chatRepository: repo, historyRepository: history);
    await p.initializeChat();
    await p.startNewConversation();

    expect(p.uiState.currentConversationId, 'cid');
    expect(p.uiState.hasActiveConversation, isTrue);
    expect(p.uiState.pollingEnabled, isTrue);
    p.dispose();
  });

  test('sendMessage replaces optimistic message with confirmed message', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(() => repo.createUser(name: any(named: 'name'), email: any(named: 'email')))
        .thenAnswer((_) async => m.User(id: 'ukey'));
    when(() => repo.createConversation('ukey')).thenAnswer(
      (_) async => m.Conversation(id: 'cid', userId: 'user', created: 't'),
    );
    when(() => repo.sendMessage('ukey', 'cid', 'hello')).thenAnswer(
      (_) async => m.Message(id: 'mid', conversationId: 'cid', userId: 'user_ukey', created: 't', text: 'hello', type: 'text'),
    );
    when(() => history.getConversations()).thenAnswer((_) async => <SavedConversation>[]);

    final p = ChatProvider(chatRepository: repo, historyRepository: history);
    await p.initializeChat();
    await p.startNewConversation();
    await p.sendMessage('hello');

    expect(p.uiState.messages.isNotEmpty, isTrue);
    expect(p.uiState.messages.last.id, 'mid');
    p.dispose();
  });

  test('toggleHistory flips flag', () async {
    final p = ChatProvider(chatRepository: MockChatRepository(), historyRepository: MockChatHistoryRepository());
    expect(p.uiState.showHistory, isFalse);
    p.toggleHistory();
    expect(p.uiState.showHistory, isTrue);
    p.toggleHistory();
    expect(p.uiState.showHistory, isFalse);
    p.dispose();
  });
}

