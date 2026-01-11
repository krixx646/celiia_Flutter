import 'dart:convert';

import 'package:celia_flutter/services/botpress_api.dart';
import 'package:celia_flutter/models/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.test/'));
  });

  test('BotpressApi createUser parses 2xx JSON', () async {
    final client = MockClient((req) async {
      expect(req.method, 'POST');
      expect(req.url.toString(), 'https://example.test/users');
      return http.Response(
        jsonEncode({
          'user': {'id': 'u', 'createdAt': 't1', 'updatedAt': 't2'},
          'key': 'k1'
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = BotpressApi(client: client, baseUrl: 'https://example.test/');
    final res = await api.createUser(CreateUserRequest(name: 'N', email: 'E'));
    expect(res.key, 'k1');
    expect(res.user?.id, 'u');
  });

  test('BotpressApi createConversation/sendMessage/sendMessagePayload/getMessages/deleteConversation', () async {
    final client = MockClient((req) async {
      if (req.method == 'POST' && req.url.toString() == 'https://example.test/conversations') {
        expect(req.headers['X-User-Key'], 'uk');
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['metadata'], isNotNull);
        return http.Response(
          jsonEncode({
            'conversation': {'id': 'c1', 'createdAt': 't1', 'updatedAt': 't2'}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (req.method == 'POST' && req.url.toString() == 'https://example.test/messages') {
        expect(req.headers['X-User-Key'], 'uk');
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['conversationId'], 'c1');
        final payload = body['payload'] as Map<String, dynamic>;
        expect(payload['type'], isNotEmpty);
        return http.Response(
          jsonEncode({
            'message': {
              'id': 'm1',
              'conversationId': 'c1',
              'userId': 'u1',
              'tags': const <String>[],
              'payload': payload,
              'createdAt': 't1',
              'updatedAt': null,
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (req.method == 'GET' && req.url.toString() == 'https://example.test/conversations/c1/messages') {
        expect(req.headers['X-User-Key'], 'uk');
        return http.Response(
          jsonEncode({
            'messages': [
              {
                'id': 'm1',
                'conversationId': 'c1',
                'userId': 'u1',
                'tags': const <String>[],
                'payload': {'type': 'text', 'text': 'hi'},
                'createdAt': 't1',
                'updatedAt': null,
              }
            ],
            'meta': {'nextToken': 'n'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (req.method == 'DELETE' && req.url.toString() == 'https://example.test/conversations/c1') {
        expect(req.headers['X-User-Key'], 'uk');
        return http.Response('', 204);
      }

      return http.Response('unhandled', 500);
    });

    final api = BotpressApi(client: client, baseUrl: 'https://example.test/');

    final convo = await api.createConversation('uk', CreateConversationRequest(userId: 'u1'));
    expect(convo.conversation.id, 'c1');

    final sent1 = await api.sendMessage('uk', 'c1', SimpleMessageRequest(type: 'text', text: 'hello'));
    expect(sent1.message.conversationId, 'c1');

    final sent2 = await api.sendMessagePayload('uk', 'c1', MessagePayload(type: 'text', text: 'hello2'));
    expect(sent2.message.conversationId, 'c1');

    final messages = await api.getMessages('uk', 'c1');
    expect(messages.messages, isNotEmpty);

    await api.deleteConversation('uk', 'c1');
  });

  test('BotpressApi deleteConversation throws on non-2xx', () async {
    final client = MockClient((req) async {
      return http.Response('nope', 500);
    });
    final api = BotpressApi(client: client, baseUrl: 'https://example.test/');
    expect(() => api.deleteConversation('uk', 'c1'), throwsException);
  });

  test('BotpressApi throws on non-2xx', () async {
    final client = MockClient((req) async {
      return http.Response('nope', 500);
    });
    final api = BotpressApi(client: client, baseUrl: 'https://example.test/');
    expect(() => api.getMessages('uk', 'cid'), throwsException);
  });

  test('BotpressApi.dispose closes http client', () {
    final client = MockHttpClient();
    when(() => client.close()).thenReturn(null);
    final api = BotpressApi(client: client, baseUrl: 'https://example.test/');
    api.dispose();
    verify(() => client.close()).called(1);
  });

  test('BotpressApi constructor defaults http client when not provided', () {
    final api = BotpressApi(baseUrl: 'https://example.test/');
    api.dispose();
  });
}

