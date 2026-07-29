import 'package:celia_flutter/models/chat_models.dart';
import 'package:celia_flutter/repositories/chat_repository.dart';
import 'package:celia_flutter/services/botpress_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBotpressApi extends Mock implements BotpressApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(CreateUserRequest(name: 'x', email: 'y'));
    registerFallbackValue(CreateConversationRequest());
    registerFallbackValue(SimpleMessageRequest(text: 'x'));
    registerFallbackValue(MessagePayload(type: 'text', text: 'x'));
  });

  test(
    'ChatRepository.createUser throws when API response contains error code/message',
    () async {
      final api = MockBotpressApi();
      when(() => api.createUser(any())).thenAnswer(
        (_) async => BotpressUserResponse(code: 400, message: 'bad'),
      );

      final repo = ChatRepository(api: api);
      expect(() => repo.createUser(), throwsException);
    },
  );

  test(
    'ChatRepository.getMessages dedupes options and sets user/bot ids',
    () async {
      final api = MockBotpressApi();

      when(() => api.getMessages('uk', 'cid')).thenAnswer((_) async {
        return BotpressMessagesResponse(
          messages: [
            BotpressMessage(
              id: 'm1',
              conversationId: 'cid',
              userId: null,
              payload: MessagePayload(
                type: 'text',
                text: 'hi',
                options: [
                  MessageOption(label: 'A', value: 'a'),
                  MessageOption(label: 'A', value: 'a'),
                ],
              ),
              createdAt: 't',
            ),
            BotpressMessage(
              id: 'm2',
              conversationId: 'cid',
              userId: 'botpress',
              payload: MessagePayload(type: 'text', text: 'yo'),
              createdAt: 't2',
            ),
          ],
        );
      });

      final repo = ChatRepository(api: api);
      final msgs = await repo.getMessages('uk', 'cid');

      expect(msgs.length, 2);
      expect(msgs[0].options?.length, 1); // deduped
      expect(msgs[0].userId.startsWith('user_'), isTrue);
      expect(msgs[1].userId.startsWith('bot_'), isTrue);
    },
  );

  test(
    'ChatRepository.createUser success + parse failures + api exception',
    () async {
      final api = MockBotpressApi();

      when(() => api.createUser(any())).thenAnswer(
        (_) async => BotpressUserResponse(
          key: 'k1',
          user: BotpressUser(id: 'u', createdAt: 't1', updatedAt: 't2'),
        ),
      );
      final repo = ChatRepository(api: api);
      final u = await repo.createUser(name: 'N', email: 'E');
      expect(u.id, 'k1');

      when(
        () => api.createUser(any()),
      ).thenAnswer((_) async => BotpressUserResponse(key: null, user: null));
      expect(() => repo.createUser(), throwsException);

      when(() => api.createUser(any())).thenThrow(Exception('nope'));
      expect(() => repo.createUser(), throwsException);
    },
  );

  test('ChatRepository.createConversation success + error wrap', () async {
    final api = MockBotpressApi();
    when(() => api.createConversation(any(), any())).thenAnswer(
      (_) async => BotpressConversationResponse(
        conversation: BotpressConversation(
          id: 'c',
          createdAt: 't1',
          updatedAt: 't2',
        ),
      ),
    );
    final repo = ChatRepository(api: api);
    final c = await repo.createConversation('uk');
    expect(c.id, 'c');

    when(
      () => api.createConversation(any(), any()),
    ).thenThrow(Exception('nope'));
    expect(() => repo.createConversation('uk'), throwsException);
  });

  test(
    'ChatRepository.sendMessage uses text or image endpoint and wraps errors',
    () async {
      final api = MockBotpressApi();
      when(() => api.sendMessage(any(), any(), any())).thenAnswer(
        (_) async => BotpressMessageResponse(
          message: BotpressMessage(
            id: 'm1',
            conversationId: 'cid',
            userId: 'u',
            payload: MessagePayload(type: 'text', text: 'hi'),
            createdAt: 't',
          ),
        ),
      );
      when(() => api.sendMessagePayload(any(), any(), any())).thenAnswer(
        (_) async => BotpressMessageResponse(
          message: BotpressMessage(
            id: 'm2',
            conversationId: 'cid',
            userId: 'u',
            payload: MessagePayload(type: 'image', imageUrl: 'https://x.png'),
            createdAt: 't',
          ),
        ),
      );

      final repo = ChatRepository(api: api);
      final m1 = await repo.sendMessage('uk', 'cid', 'hello');
      expect(m1.type, 'text');

      final m2 = await repo.sendMessage(
        'uk',
        'cid',
        'https://example.test/x.png',
      );
      expect(m2.type, 'image');

      when(
        () => api.sendMessage(any(), any(), any()),
      ).thenThrow(Exception('nope'));
      expect(() => repo.sendMessage('uk', 'cid', 'hello'), throwsException);
    },
  );

  test(
    'ChatRepository.getMessages maps message types and wraps errors',
    () async {
      final api = MockBotpressApi();
      when(() => api.getMessages('uk', 'cid')).thenAnswer((_) async {
        return BotpressMessagesResponse(
          messages: [
            BotpressMessage(
              id: 'c',
              conversationId: 'cid',
              userId: 'uk',
              payload: MessagePayload(type: 'choice', text: 'x'),
              createdAt: 't',
            ),
            BotpressMessage(
              id: 'd',
              conversationId: 'cid',
              userId: 'botpress',
              payload: MessagePayload(type: 'dropdown', text: 'x'),
              createdAt: 't',
            ),
            BotpressMessage(
              id: 'i',
              conversationId: 'cid',
              userId: null,
              payload: MessagePayload(type: 'image', imageUrl: 'u'),
              createdAt: 't',
            ),
            BotpressMessage(
              id: 'b',
              conversationId: 'cid',
              userId: 'botpress',
              payload: MessagePayload(type: 'button', text: 'x'),
              createdAt: 't',
            ),
            BotpressMessage(
              id: 'bo',
              conversationId: 'cid',
              userId: 'botpress',
              payload: MessagePayload(
                type: 'text',
                options: [MessageOption(label: 'A', value: 'a')],
              ),
              createdAt: 't',
            ),
            BotpressMessage(
              id: 't',
              conversationId: 'cid',
              userId: 'botpress',
              payload: MessagePayload(type: 'text', text: 'plain'),
              createdAt: 't',
            ),
          ],
        );
      });

      final repo = ChatRepository(api: api);
      final msgs = await repo.getMessages('uk', 'cid');
      expect(msgs[0].type, 'choice');
      expect(msgs[1].type, 'dropdown');
      expect(msgs[2].type, 'image');
      expect(msgs[3].type, 'button');
      expect(msgs[4].type, 'button');
      expect(msgs[5].type, 'text');

      when(() => api.getMessages(any(), any())).thenThrow(Exception('nope'));
      expect(() => repo.getMessages('uk', 'cid'), throwsException);
    },
  );

  test('ChatRepository.dispose calls api.dispose', () {
    final api = MockBotpressApi();
    when(() => api.dispose()).thenReturn(null);
    final repo = ChatRepository(api: api);
    repo.dispose();
    verify(() => api.dispose()).called(1);
  });

  test('ChatRepository constructor defaults api when not provided', () {
    final repo = ChatRepository();
    repo.dispose();
  });
}
