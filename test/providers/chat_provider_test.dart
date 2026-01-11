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

  test('initializeChat creates user key and loads history', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(() => repo.createUser(name: any(named: 'name'), email: any(named: 'email'))).thenAnswer(
      (_) async => m.User(id: 'ukey', name: 'n', email: null),
    );
    when(() => history.getConversations()).thenAnswer((_) async => <SavedConversation>[]);

    final p = ChatProvider(chatRepository: repo, historyRepository: history);
    await p.initializeChat();

    expect(p.uiState.hasInitialized, isTrue);
    expect(p.uiState.currentUserKey, 'ukey');
    verify(() => history.getConversations()).called(1);
  });

  test('sendMessage sets error when no active conversation', () async {
    final p = ChatProvider(
      chatRepository: MockChatRepository(),
      historyRepository: MockChatHistoryRepository(),
    );
    await p.sendMessage('hello');
    expect(p.uiState.error, isNotNull);
  });
}

