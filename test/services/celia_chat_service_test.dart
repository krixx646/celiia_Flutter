import 'dart:convert';

import 'package:celia_flutter/models/celia_chat_message.dart';
import 'package:celia_flutter/services/celia_chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

/// Serialises parts the way the backend does: one `data:` line each.
String _sse(List<Map<String, dynamic>> parts) {
  return parts.map((part) => 'data: ${jsonEncode(part)}\n\n').join();
}

void main() {
  late MockFirebaseAuth auth;

  setUp(() {
    auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'token');
    CeliaChatService.backendBaseUrl = () => 'https://example.test';
  });

  CeliaChatService serviceReturning(
    String body, {
    int status = 200,
    Map<String, String> headers = const {},
    void Function(http.BaseRequest request, String body)? onRequest,
  }) {
    final client = MockClient.streaming((request, bodyStream) async {
      if (onRequest != null) {
        onRequest(request, await bodyStream.bytesToString());
      }
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        status,
        headers: {'content-type': 'text/event-stream', ...headers},
      );
    });
    return CeliaChatService(firebaseAuth: auth, httpClient: client);
  }

  group('send', () {
    test('emits the conversation id from the response header', () async {
      final service = serviceReturning(
        _sse([
          {'type': 'text-delta', 'delta': 'hi'},
        ]),
        headers: {'x-conversation-id': 'conv-1'},
      );

      final events = await service.send(message: 'hello').toList();

      expect(events.first, isA<CeliaConversationStarted>());
      expect(
        (events.first as CeliaConversationStarted).conversationId,
        'conv-1',
      );
    });

    test('streams text deltas in order', () async {
      final service = serviceReturning(
        _sse([
          {'type': 'start'},
          {'type': 'text-start', 'id': '0'},
          {'type': 'text-delta', 'delta': 'Three '},
          {'type': 'text-delta', 'delta': 'sets '},
          {'type': 'text-delta', 'delta': 'of ten.'},
          {'type': 'text-end', 'id': '0'},
          {'type': 'finish'},
        ]),
      );

      final deltas = await service
          .send(message: 'how many sets?')
          .where((event) => event is CeliaTextDelta)
          .cast<CeliaTextDelta>()
          .map((event) => event.delta)
          .toList();

      expect(deltas.join(), 'Three sets of ten.');
    });

    test('carries a tool from input through to its output', () async {
      final service = serviceReturning(
        _sse([
          {
            'type': 'tool-input-start',
            'toolCallId': 'call-1',
            'toolName': 'search_exercises',
          },
          {
            'type': 'tool-input-available',
            'toolCallId': 'call-1',
            'toolName': 'search_exercises',
            'input': {'query': 'squat'},
          },
          {
            'type': 'tool-output-available',
            'toolCallId': 'call-1',
            'output': {'exercises': []},
          },
        ]),
      );

      final updates = await service
          .send(message: 'find squats')
          .where((event) => event is CeliaToolUpdate)
          .cast<CeliaToolUpdate>()
          .map((event) => event.call)
          .toList();

      expect(updates.map((call) => call.phase), [
        ToolPhase.preparing,
        ToolPhase.running,
        ToolPhase.done,
      ]);
      // The name arrives with the first part but must survive to the last.
      expect(updates.last.toolName, 'search_exercises');
      expect(updates.last.input, {'query': 'squat'});
      expect(updates.last.output, {'exercises': []});
    });

    test('surfaces an approval request with its id', () async {
      final service = serviceReturning(
        _sse([
          {
            'type': 'tool-input-available',
            'toolCallId': 'call-2',
            'toolName': 'create_routine',
            'input': {'title': 'Leg day'},
          },
          {
            'type': 'tool-approval-request',
            'toolCallId': 'call-2',
            'approvalId': 'approval-9',
          },
        ]),
      );

      final updates = await service
          .send(message: 'build me legs')
          .where((event) => event is CeliaToolUpdate)
          .cast<CeliaToolUpdate>()
          .map((event) => event.call)
          .toList();

      expect(updates.last.phase, ToolPhase.awaitingApproval);
      expect(updates.last.approvalId, 'approval-9');
      // The input has to survive so the card can describe what it will save.
      expect(updates.last.input?['title'], 'Leg day');
    });

    test('does not prompt for approvals the backend decided itself', () async {
      final service = serviceReturning(
        _sse([
          {
            'type': 'tool-input-available',
            'toolCallId': 'call-3',
            'toolName': 'create_routine',
            'input': {'title': 'Leg day'},
          },
          {
            'type': 'tool-approval-request',
            'toolCallId': 'call-3',
            'approvalId': 'approval-10',
            'isAutomatic': true,
          },
        ]),
      );

      final updates = await service
          .send(message: 'build me legs')
          .where((event) => event is CeliaToolUpdate)
          .cast<CeliaToolUpdate>()
          .toList();

      expect(updates.last.call.phase, ToolPhase.running);
    });

    test('reports a denied tool', () async {
      final service = serviceReturning(
        _sse([
          {
            'type': 'tool-input-available',
            'toolCallId': 'call-4',
            'toolName': 'log_meal',
            'input': {'title': 'Pizza'},
          },
          {'type': 'tool-output-denied', 'toolCallId': 'call-4'},
        ]),
      );

      final updates = await service
          .send(message: 'log pizza')
          .where((event) => event is CeliaToolUpdate)
          .cast<CeliaToolUpdate>()
          .toList();

      expect(updates.last.call.phase, ToolPhase.denied);
    });

    test('emits stream errors as events rather than throwing', () async {
      final service = serviceReturning(
        _sse([
          {'type': 'error', 'errorText': 'model exploded'},
        ]),
      );

      final events = await service.send(message: 'hi').toList();

      expect(events.whereType<CeliaStreamError>().single.message,
          'model exploded');
    });

    test('ignores unknown parts and malformed json', () async {
      final service = serviceReturning(
        'data: {"type":"something-new"}\n\n'
        'data: not json\n\n'
        ': a comment line\n\n'
        '${_sse([
              {'type': 'text-delta', 'delta': 'ok'},
            ])}',
      );

      final events = await service.send(message: 'hi').toList();

      expect(events.whereType<CeliaTextDelta>().single.delta, 'ok');
      expect(events.whereType<CeliaStreamError>(), isEmpty);
    });

    test('turns an expired session into a readable message', () async {
      final service = serviceReturning('{"error":"Unauthorized"}', status: 401);

      final events = await service.send(message: 'hi').toList();

      expect(
        events.whereType<CeliaStreamError>().single.message,
        contains('sign in'),
      );
    });

    test('reports the backend error message on failure', () async {
      final service = serviceReturning(
        '{"error":"Could not start conversation"}',
        status: 500,
      );

      final events = await service.send(message: 'hi').toList();

      expect(
        events.whereType<CeliaStreamError>().single.message,
        'Could not start conversation',
      );
    });

    test('sends the conversation id, timezone, state and approvals', () async {
      String? sentBody;
      final service = serviceReturning(
        _sse([
          {'type': 'text-delta', 'delta': 'ok'},
        ]),
        onRequest: (_, body) => sentBody = body,
      );

      await service
          .send(
            conversationId: 'conv-7',
            message: 'yes',
            userState: {'displayName': 'Ada'},
            approvals: [(approvalId: 'approval-1', approved: true)],
          )
          .toList();

      final json = jsonDecode(sentBody!) as Map<String, dynamic>;
      expect(json['conversationId'], 'conv-7');
      expect(json['message'], 'yes');
      expect(json['state'], {'displayName': 'Ada'});
      expect(json['approvals'], [
        {'approvalId': 'approval-1', 'approved': true},
      ]);
      expect(json['tzOffsetMinutes'], isA<int>());
    });

    test('omits an empty message so approvals can be sent alone', () async {
      String? sentBody;
      final service = serviceReturning(
        _sse([
          {'type': 'text-delta', 'delta': 'ok'},
        ]),
        onRequest: (_, body) => sentBody = body,
      );

      await service
          .send(approvals: [(approvalId: 'approval-1', approved: false)])
          .toList();

      expect(jsonDecode(sentBody!), isNot(contains('message')));
    });

    test('reports being signed out instead of calling the backend', () async {
      when(() => auth.currentUser).thenReturn(null);
      final service = serviceReturning('');

      final events = await service.send(message: 'hi').toList();

      expect(
        events.whereType<CeliaStreamError>().single.message,
        contains('signed in'),
      );
    });

    test('reports a missing backend url', () async {
      CeliaChatService.backendBaseUrl = () => '';
      final service = serviceReturning('');

      final events = await service.send(message: 'hi').toList();

      expect(
        events.whereType<CeliaStreamError>().single.message,
        'Backend not configured',
      );
    });
  });

  group('conversations', () {
    test('lists saved conversations', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/mobile/chat/conversations');
        return http.Response(
          jsonEncode({
            'conversations': [
              {
                'id': 'c1',
                'title': 'Leg day plan',
                'updatedAt': '2026-01-02T03:04:05Z',
              },
            ],
          }),
          200,
        );
      });
      final service = CeliaChatService(firebaseAuth: auth, httpClient: client);

      final conversations = await service.listConversations();

      expect(conversations.single.title, 'Leg day plan');
      expect(conversations.single.updatedAt.year, 2026);
    });

    test('rebuilds stored messages including tool calls', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'messages': [
              {'id': 'm1', 'role': 'user', 'content': 'build legs', 'parts': []},
              {
                'id': 'm2',
                'role': 'assistant',
                'content': 'Done.',
                'parts': [
                  {
                    'type': 'tool-create_routine',
                    'toolCallId': 'call-1',
                    'state': 'output-available',
                    'input': {'title': 'Leg day'},
                    'output': {'created': true, 'routineId': 'r1'},
                  },
                  {'type': 'text', 'text': 'Done.'},
                ],
              },
            ],
          }),
          200,
        );
      });
      final service = CeliaChatService(firebaseAuth: auth, httpClient: client);

      final messages = await service.loadConversation('c1');

      expect(messages.first.role, ChatRole.user);
      expect(messages.last.text, 'Done.');
      expect(messages.last.toolCalls.single.toolName, 'create_routine');
      expect(messages.last.createdRoutine?.routineId, 'r1');
    });

    test('a reloaded conversation does not re-prompt for answered approvals',
        () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'messages': [
              {
                'id': 'm1',
                'role': 'assistant',
                'content': '',
                'parts': [
                  {
                    'type': 'tool-create_routine',
                    'toolCallId': 'call-1',
                    'state': 'approval-responded',
                    'input': {'title': 'Leg day'},
                  },
                ],
              },
            ],
          }),
          200,
        );
      });
      final service = CeliaChatService(firebaseAuth: auth, httpClient: client);

      final messages = await service.loadConversation('c1');

      expect(messages.single.pendingApproval, isNull);
    });
  });
}
