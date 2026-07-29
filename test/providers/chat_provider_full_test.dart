import 'package:celia_flutter/models/chat_models.dart';
import 'package:celia_flutter/providers/chat_provider.dart';
import 'package:celia_flutter/repositories/chat_history_repository.dart';
import 'package:celia_flutter/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_async/fake_async.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockChatHistoryRepository extends Mock implements ChatHistoryRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CreateUserRequest());
    registerFallbackValue(CreateConversationRequest());
    registerFallbackValue(MessagePayload(type: 'text', text: 'x'));
    registerFallbackValue(SimpleMessageRequest(type: 'text', text: 'x'));
    registerFallbackValue(
      SavedConversation(
        id: 'cid',
        title: 't',
        lastMessage: 'm',
        timestamp: DateTime(2026, 1, 1),
        userId: 'u',
        userKey: 'uk',
      ),
    );
  });

  test(
    'SavedConversation.fromJson handles Timestamp, String, and fallback types',
    () {
      final fromTs = SavedConversation.fromJson({
        'id': 'c1',
        'title': 't',
        'lastMessage': 'm',
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(0),
        'userId': 'u',
        'userKey': 'uk',
      });
      expect(fromTs.timestamp, DateTime.fromMillisecondsSinceEpoch(0));

      final fromStr = SavedConversation.fromJson({
        'id': 'c2',
        'title': 't',
        'lastMessage': 'm',
        'timestamp': '2026-01-01T00:00:00.000Z',
        'userId': 'u',
        'userKey': 'uk',
      });
      expect(
        fromStr.timestamp.toUtc(),
        DateTime.parse('2026-01-01T00:00:00.000Z'),
      );

      final fromOther = SavedConversation.fromJson({
        'id': 'c3',
        'title': 't',
        'lastMessage': 'm',
        'timestamp': 123,
        'userId': 'u',
        'userKey': 'uk',
      });
      expect(fromOther.timestamp, isA<DateTime>());
    },
  );

  test(
    'constructor default factories can be overridden (no real deps)',
    () async {
      final originalChat = ChatProvider.defaultChatRepository;
      final originalHist = ChatProvider.defaultHistoryRepository;
      final originalPrefs = ChatProvider.defaultPrefs;
      addTearDown(() {
        ChatProvider.defaultChatRepository = originalChat;
        ChatProvider.defaultHistoryRepository = originalHist;
        ChatProvider.defaultPrefs = originalPrefs;
      });

      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();
      SharedPreferences.setMockInitialValues(<String, Object>{});

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => history.getConversations()).thenAnswer((_) async => []);

      ChatProvider.defaultChatRepository = () => repo;
      ChatProvider.defaultHistoryRepository = () => history;
      ChatProvider.defaultPrefs = () => SharedPreferences.getInstance();

      final p = ChatProvider();
      await p.initializeChat();
      expect(p.uiState.currentUserKey, 'uk');
    },
  );

  Future<SharedPreferences> prefsFactory() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return SharedPreferences.getInstance();
  }

  test(
    'initializeChat sets user key, handles errors, and is idempotent',
    () async {
      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => history.getConversations()).thenAnswer((_) async => []);

      final p = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );
      await p.initializeChat();
      expect(p.uiState.currentUserKey, 'uk');
      expect(p.uiState.hasInitialized, isTrue);
      expect(p.uiState.isLoadingInitial, isFalse);

      // Second call should early-return
      await p.initializeChat();

      // Error path
      final repo2 = MockChatRepository();
      when(
        () => repo2.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenThrow(Exception('boom'));
      final p2 = ChatProvider(
        chatRepository: repo2,
        historyRepository: history,
        prefs: prefsFactory,
      );
      await p2.initializeChat();
      expect(
        p2.uiState.error,
        'Chat is unavailable right now. Please try again.',
      );
      expect(p2.uiState.isLoadingInitial, isFalse);
    },
  );

  test(
    'startNewConversation success + error, and polling triggers loadMessages',
    () {
      fakeAsync((async) {
        final repo = MockChatRepository();
        final history = MockChatHistoryRepository();

        when(
          () => repo.createUser(
            name: any(named: 'name'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
        when(() => repo.createConversation(any())).thenAnswer(
          (_) async => Conversation(
            id: 'cid',
            userId: 'u',
            created: 't1',
            updated: 't2',
          ),
        );
        when(() => repo.getMessages(any(), any())).thenAnswer((_) async => []);
        when(() => history.getConversations()).thenAnswer((_) async => []);

        final p = ChatProvider(
          chatRepository: repo,
          historyRepository: history,
          prefs: prefsFactory,
        );

        async.run((_) async {
          await p.initializeChat();
          await p.startNewConversation();
        });
        async.flushMicrotasks();

        expect(p.uiState.currentConversationId, 'cid');
        expect(p.uiState.hasActiveConversation, isTrue);
        expect(p.uiState.pollingEnabled, isTrue);

        // Timer callback every 2s
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        verify(
          () => repo.getMessages('uk', 'cid'),
        ).called(greaterThanOrEqualTo(1));

        // Error path
        final repoErr = MockChatRepository();
        when(
          () => repoErr.createUser(
            name: any(named: 'name'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
        when(
          () => repoErr.createConversation(any()),
        ).thenThrow(Exception('nope'));
        when(() => history.getConversations()).thenAnswer((_) async => []);

        final pErr = ChatProvider(
          chatRepository: repoErr,
          historyRepository: history,
          prefs: prefsFactory,
        );
        async.run((_) async {
          await pErr.initializeChat();
          await pErr.startNewConversation();
        });
        async.flushMicrotasks();
        expect(
          pErr.uiState.error,
          'Could not start a new chat. Please try again.',
        );

        p.dispose();
        pErr.dispose();
      });
    },
  );

  test(
    'startNewConversation auto-initializes when user key is missing',
    () async {
      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => repo.createConversation(any())).thenAnswer(
        (_) async =>
            Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
      );
      when(() => history.getConversations()).thenAnswer((_) async => []);

      final p = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );
      await p.startNewConversation();
      expect(p.uiState.currentUserKey, 'uk');
      expect(p.uiState.currentConversationId, 'cid');
    },
  );

  test(
    'sendMessage covers no-active-conversation, optimistic replace, and error',
    () async {
      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => history.getConversations()).thenAnswer((_) async => []);
      when(() => repo.createConversation(any())).thenAnswer(
        (_) async =>
            Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
      );
      when(() => repo.sendMessage(any(), any(), any())).thenAnswer(
        (_) async => Message(
          id: 'm1',
          conversationId: 'cid',
          userId: 'user_uk',
          text: 'hello',
          type: 'text',
          created: DateTime(2026, 1, 1).toIso8601String(),
        ),
      );

      final p = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );

      // No active conversation
      await p.sendMessage('x');
      expect(p.uiState.error, 'No active conversation');

      await p.initializeChat();
      await p.startNewConversation();

      await p.sendMessage('hello');
      expect(p.uiState.messages.last.id, 'm1');
      expect(p.isUserMessage('m1'), isTrue);

      // Error
      when(
        () => repo.sendMessage(any(), any(), any()),
      ).thenThrow(Exception('nope'));
      await p.sendMessage('hello2');
      expect(p.uiState.error, 'Message could not be sent. Please try again.');
    },
  );

  test('sendMessageWithInteraction + interaction helpers', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(
      () => repo.createUser(
        name: any(named: 'name'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
    when(() => history.getConversations()).thenAnswer((_) async => []);
    when(() => repo.createConversation(any())).thenAnswer(
      (_) async =>
          Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
    );
    when(() => repo.sendMessage(any(), any(), any())).thenAnswer(
      (_) async => Message(
        id: 'm1',
        conversationId: 'cid',
        userId: 'user_uk',
        text: 'hello',
        type: 'text',
        created: DateTime(2026, 1, 1).toIso8601String(),
      ),
    );

    final p = ChatProvider(
      chatRepository: repo,
      historyRepository: history,
      prefs: prefsFactory,
    );
    await p.initializeChat();
    await p.startNewConversation();

    await p.sendMessageWithInteraction('hello', 'btn1');
    expect(p.hasMessageBeenInteracted('btn1'), isTrue);
  });

  test('loadMessages dedupes + direction pattern + preserves optimistic', () {
    fakeAsync((async) {
      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => history.getConversations()).thenAnswer((_) async => []);
      when(() => repo.createConversation(any())).thenAnswer(
        (_) async =>
            Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
      );

      // duplicate ids + various timestamps
      when(() => repo.getMessages('uk', 'cid')).thenAnswer((_) async {
        return [
          Message(
            id: 'a',
            conversationId: 'cid',
            userId: 'u',
            text: '1',
            type: 'text',
            created: '2026-01-01T00:00:00.000Z',
          ),
          Message(
            id: 'b',
            conversationId: 'cid',
            userId: 'u',
            text: '2',
            type: 'text',
            created: '2026-01-01T00:00:01.000Z',
          ),
          Message(
            id: 'b',
            conversationId: 'cid',
            userId: 'u',
            text: '2b',
            type: 'text',
            created: '2026-01-01T00:00:02.000Z',
          ),
          Message(
            id: 'c',
            conversationId: 'cid',
            userId: 'u',
            text: '3',
            type: 'text',
            created: '2026-01-01T00:00:03.000Z',
          ),
        ];
      });

      final p = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );

      async.run((_) async {
        await p.initializeChat();
        await p.startNewConversation();
      });
      async.flushMicrotasks();

      // Create an optimistic message by sending once (repo returns text)
      when(() => repo.sendMessage(any(), any(), any())).thenAnswer(
        (_) async => Message(
          id: 'm1',
          conversationId: 'cid',
          userId: 'user_uk',
          text: 'hello',
          type: 'text',
          created: DateTime(2026, 1, 1).toIso8601String(),
        ),
      );

      async.run((_) async {
        await p.sendMessage('hello');
      });
      async.flushMicrotasks();

      // Now loadMessages: should keep optimistic (none should remain after replace, but still exercise path)
      async.run((_) async {
        await p.loadMessages();
      });
      async.flushMicrotasks();

      // deduped should contain a,b,c (b last write wins)
      expect(p.uiState.messages.where((m) => m.id == 'b').single.text, '2b');

      // direction mapping should be set for fetched ids
      expect(p.isUserMessage('a'), isTrue);
      expect(p.isUserMessage('b'), isFalse);
    });
  });

  test('loadMessages error path sets uiState.error', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(
      () => repo.createUser(
        name: any(named: 'name'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
    when(() => repo.createConversation(any())).thenAnswer(
      (_) async =>
          Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
    );
    when(() => repo.getMessages('uk', 'cid')).thenThrow(Exception('boom'));
    when(() => history.getConversations()).thenAnswer((_) async => []);

    final p = ChatProvider(
      chatRepository: repo,
      historyRepository: history,
      prefs: prefsFactory,
    );
    await p.initializeChat();
    await p.startNewConversation();
    await p.loadMessages();
    expect(p.uiState.error, 'Unable to refresh messages right now.');
  });

  test('loadConversationHistory error path sets uiState.error', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(
      () => repo.createUser(
        name: any(named: 'name'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
    when(() => history.getConversations()).thenThrow(Exception('boom'));

    final p = ChatProvider(
      chatRepository: repo,
      historyRepository: history,
      prefs: prefsFactory,
    );
    await p.initializeChat();
    expect(p.uiState.error, 'Unable to load saved chats right now.');
    expect(p.uiState.isLoadingHistory, isFalse);
  });

  test(
    'history: loadConversationHistory + saveCurrentConversation + loadConversationFromHistory + deleteConversationById',
    () async {
      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => repo.createConversation(any())).thenAnswer(
        (_) async =>
            Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
      );

      // Start with empty history then a saved item
      when(() => history.getConversations()).thenAnswer((_) async => []);

      final p = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );
      await p.initializeChat();
      await p.startNewConversation();

      // saveCurrentConversation false when no conversation id
      final pNoId = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );
      await pNoId.initializeChat();
      expect(await pNoId.saveCurrentConversation(), isFalse);

      // Make first message an image (text null) so title falls back to "Conversation" and last message to "No message"
      when(() => repo.sendMessage(any(), any(), any())).thenAnswer(
        (_) async => Message(
          id: 'img1',
          conversationId: 'cid',
          userId: 'user_uk',
          text: null,
          type: 'image',
          created: DateTime(2026, 1, 1).toIso8601String(),
          imageUrl: 'https://example.test/x.png',
        ),
      );
      await p.sendMessage('https://example.test/x.png');

      when(() => history.saveConversation(any())).thenAnswer((_) async {});
      when(() => history.getConversations()).thenAnswer((_) async {
        return [
          SavedConversation(
            id: 'cid',
            title: 'Conversation',
            lastMessage: 'No message',
            timestamp: DateTime(2026, 1, 1),
            userId: 'u',
            userKey: 'uk',
          ),
        ];
      });
      final ok = await p.saveCurrentConversation();
      expect(ok, isTrue);
      expect(p.uiState.conversationHistory, isNotEmpty);

      // loadConversationFromHistory triggers loadMessages and enables polling
      when(() => repo.getMessages(any(), any())).thenAnswer((_) async => []);
      await p.loadConversationFromHistory(p.uiState.conversationHistory.first);
      expect(p.uiState.hasActiveConversation, isTrue);
      expect(p.uiState.pollingEnabled, isTrue);

      // deleteConversationById success and error branch
      when(() => history.deleteConversation('cid')).thenAnswer((_) async {});
      await p.deleteConversationById('cid');

      when(
        () => history.deleteConversation(any()),
      ).thenThrow(Exception('nope'));
      await p.deleteConversationById('cid');
      expect(
        p.uiState.error,
        'Could not delete this conversation. Please try again.',
      );
    },
  );

  test(
    'saveCurrentConversation error path returns false and sets uiState.error',
    () async {
      final repo = MockChatRepository();
      final history = MockChatHistoryRepository();

      when(
        () => repo.createUser(
          name: any(named: 'name'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
      when(() => repo.createConversation(any())).thenAnswer(
        (_) async =>
            Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
      );
      when(() => history.getConversations()).thenAnswer((_) async => []);
      when(() => history.saveConversation(any())).thenThrow(Exception('boom'));

      final p = ChatProvider(
        chatRepository: repo,
        historyRepository: history,
        prefs: prefsFactory,
      );
      await p.initializeChat();
      await p.startNewConversation();
      final ok = await p.saveCurrentConversation();
      expect(ok, isFalse);
      expect(p.uiState.error, 'Could not save this chat. Please try again.');
    },
  );

  test('handleOptionClick delegates to sendMessage', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(
      () => repo.createUser(
        name: any(named: 'name'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
    when(() => history.getConversations()).thenAnswer((_) async => []);
    when(() => repo.createConversation(any())).thenAnswer(
      (_) async =>
          Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
    );
    when(() => repo.sendMessage(any(), any(), any())).thenAnswer(
      (_) async => Message(
        id: 'm1',
        conversationId: 'cid',
        userId: 'user_uk',
        text: 'opt',
        type: 'text',
        created: DateTime(2026, 1, 1).toIso8601String(),
      ),
    );

    final p = ChatProvider(
      chatRepository: repo,
      historyRepository: history,
      prefs: prefsFactory,
    );
    await p.initializeChat();
    await p.startNewConversation();
    p.handleOptionClick('opt');
    await Future<void>.delayed(Duration.zero);

    verify(() => repo.sendMessage('uk', 'cid', 'opt')).called(1);
  });

  test('restart/toggles/clearError/dispose', () async {
    final repo = MockChatRepository();
    final history = MockChatHistoryRepository();

    when(
      () => repo.createUser(
        name: any(named: 'name'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => User(id: 'uk', name: 'N', email: 'E'));
    when(() => repo.createConversation(any())).thenAnswer(
      (_) async =>
          Conversation(id: 'cid', userId: 'u', created: 't1', updated: 't2'),
    );
    when(() => history.getConversations()).thenAnswer((_) async => []);
    when(() => history.saveConversation(any())).thenAnswer((_) async {});
    when(() => repo.getMessages(any(), any())).thenAnswer((_) async => []);

    final p = ChatProvider(
      chatRepository: repo,
      historyRepository: history,
      prefs: prefsFactory,
    );
    await p.initializeChat();
    await p.startNewConversation();

    p.toggleHistory();
    expect(p.uiState.showHistory, isTrue);
    p.toggleSettings();
    expect(p.uiState.showSettingsDialog, isTrue);
    p.toggleUserProfile();
    expect(p.uiState.showUserProfileDialog, isTrue);
    p.showRestartDialog();
    expect(p.uiState.showRestartConfirmation, isTrue);
    p.hideRestartDialog();
    expect(p.uiState.showRestartConfirmation, isFalse);

    // clearError
    await p.sendMessage(
      'x',
    ); // will send via repo, or if missing active it sets error; either way cover clearError
    p.clearError();
    expect(p.uiState.error, isNull);

    // restartConversation resets state and shows new conversation button
    await p.restartConversation();
    expect(p.uiState.currentConversationId, isNull);
    expect(p.uiState.showNewConversationButton, isTrue);

    when(() => repo.dispose()).thenReturn(null);
    p.dispose();
    verify(() => repo.dispose()).called(1);
  });
}
