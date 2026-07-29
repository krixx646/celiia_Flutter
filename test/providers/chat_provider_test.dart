import 'package:celia_flutter/models/celia_chat_message.dart';
import 'package:celia_flutter/models/nutrition_profile.dart';
import 'package:celia_flutter/providers/chat_provider.dart';
import 'package:celia_flutter/services/celia_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCeliaChatService extends Mock implements CeliaChatService {}

void main() {
  late MockCeliaChatService service;
  late ChatProvider provider;

  /// Makes `send` reply with [events], and records the arguments it was given.
  void stubSend(List<CeliaStreamEvent> events) {
    when(
      () => service.send(
        conversationId: any(named: 'conversationId'),
        message: any(named: 'message'),
        userState: any(named: 'userState'),
        approvals: any(named: 'approvals'),
      ),
    ).thenAnswer((_) => Stream.fromIterable(events));
  }

  setUp(() {
    service = MockCeliaChatService();
    when(() => service.listConversations()).thenAnswer((_) async => []);
    provider = ChatProvider(chatService: service);
  });

  group('sendMessage', () {
    test('shows the user turn and then assembles the reply', () async {
      stubSend(const [
        CeliaConversationStarted('conv-1'),
        CeliaTextDelta('Three sets '),
        CeliaTextDelta('of ten.'),
      ]);

      await provider.sendMessage('how many sets?');

      expect(provider.messages, hasLength(2));
      expect(provider.messages.first.isUser, isTrue);
      expect(provider.messages.first.text, 'how many sets?');
      expect(provider.messages.last.text, 'Three sets of ten.');
      expect(provider.messages.last.isStreaming, isFalse);
      expect(provider.conversationId, 'conv-1');
      expect(provider.isStreaming, isFalse);
    });

    test('reuses the conversation id on the next turn', () async {
      stubSend(const [
        CeliaConversationStarted('conv-1'),
        CeliaTextDelta('hi'),
      ]);
      await provider.sendMessage('first');

      stubSend(const [CeliaTextDelta('again')]);
      await provider.sendMessage('second');

      final captured = verify(
        () => service.send(
          conversationId: captureAny(named: 'conversationId'),
          message: any(named: 'message'),
          userState: any(named: 'userState'),
          approvals: any(named: 'approvals'),
        ),
      ).captured;
      expect(captured, [null, 'conv-1']);
    });

    test('sends the user state snapshot it was given', () async {
      stubSend(const [CeliaTextDelta('ok')]);
      provider.setUserState(
        buildUserState(
          displayName: 'Ada',
          profile: const NutritionProfile(
            weightKg: 70,
            heightCm: 175,
            age: 30,
            gender: NutritionGender.female,
            dailyCalories: 2000,
            dailyProteinGrams: 150,
            dailyCarbsGrams: 200,
            dailyFatGrams: 60,
          ),
        ),
      );

      await provider.sendMessage('hi');

      final state = verify(
        () => service.send(
          conversationId: any(named: 'conversationId'),
          message: any(named: 'message'),
          userState: captureAny(named: 'userState'),
          approvals: any(named: 'approvals'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(state['displayName'], 'Ada');
      expect(state['targets']['dailyCalories'], 2000);
      expect(state['profile']['gender'], 'female');
    });

    test('ignores an empty message', () async {
      await provider.sendMessage('   ');

      expect(provider.messages, isEmpty);
      verifyNever(
        () => service.send(
          conversationId: any(named: 'conversationId'),
          message: any(named: 'message'),
          userState: any(named: 'userState'),
          approvals: any(named: 'approvals'),
        ),
      );
    });

    test('drops the empty bubble when a turn produces nothing', () async {
      stubSend(const []);

      await provider.sendMessage('hello');

      expect(provider.messages, hasLength(1));
      expect(provider.messages.single.isUser, isTrue);
      expect(provider.error, isNotNull);
    });

    test('keeps the partial reply when the stream errors mid-way', () async {
      stubSend(const [
        CeliaTextDelta('Here is the pl'),
        CeliaStreamError('connection lost'),
      ]);

      await provider.sendMessage('plan me');

      expect(provider.messages.last.text, 'Here is the pl');
      expect(provider.error, 'connection lost');
    });

    test('surfaces an error without leaving a blank bubble', () async {
      stubSend(const [CeliaStreamError('Celia is unavailable')]);

      await provider.sendMessage('hi');

      expect(provider.messages, hasLength(1));
      expect(provider.error, 'Celia is unavailable');
    });
  });

  group('tool activity', () {
    test('collects tool calls onto the assistant message', () async {
      stubSend(const [
        CeliaToolUpdate(
          ChatToolCall(
            toolCallId: 'call-1',
            toolName: 'search_exercises',
            phase: ToolPhase.running,
          ),
        ),
        CeliaToolUpdate(
          ChatToolCall(
            toolCallId: 'call-1',
            toolName: 'search_exercises',
            phase: ToolPhase.done,
            output: {'exercises': []},
          ),
        ),
        CeliaTextDelta('Found some.'),
      ]);

      await provider.sendMessage('find squats');

      final calls = provider.messages.last.toolCalls;
      // The same call updated twice must stay one entry.
      expect(calls, hasLength(1));
      expect(calls.single.phase, ToolPhase.done);
      expect(provider.messages.last.text, 'Found some.');
    });

    test('exposes a routine Celia created', () async {
      stubSend(const [
        CeliaToolUpdate(
          ChatToolCall(
            toolCallId: 'call-1',
            toolName: 'create_routine',
            phase: ToolPhase.done,
            output: {'created': true, 'routineId': 'r-1', 'title': 'Leg day'},
          ),
        ),
      ]);

      await provider.sendMessage('build legs');

      expect(provider.messages.last.createdRoutine?.routineId, 'r-1');
      expect(provider.messages.last.createdRoutine?.title, 'Leg day');
    });
  });

  group('approvals', () {
    Future<void> reachPendingApproval() async {
      stubSend(const [
        CeliaTextDelta('Ready to save this?'),
        CeliaToolUpdate(
          ChatToolCall(
            toolCallId: 'call-1',
            toolName: 'create_routine',
            phase: ToolPhase.awaitingApproval,
            approvalId: 'approval-1',
            input: {'title': 'Leg day'},
          ),
        ),
      ]);
      await provider.sendMessage('build legs');
    }

    test('exposes the pending approval', () async {
      await reachPendingApproval();

      expect(provider.pendingApproval?.approvalId, 'approval-1');
      expect(
        provider.pendingApproval?.approvalPrompt,
        contains('Leg day'),
      );
    });

    test('approving resumes the turn and clears the prompt', () async {
      await reachPendingApproval();

      stubSend(const [CeliaTextDelta('Saved.')]);
      await provider.respondToApproval(
        approvalId: 'approval-1',
        approved: true,
      );

      final approvals = verify(
        () => service.send(
          conversationId: any(named: 'conversationId'),
          message: any(named: 'message'),
          userState: any(named: 'userState'),
          approvals: captureAny(named: 'approvals'),
        ),
      ).captured.last as List<({String approvalId, bool approved})>;
      expect(approvals.single.approvalId, 'approval-1');
      expect(approvals.single.approved, isTrue);
      expect(provider.messages.last.text, 'Saved.');
      // The buttons must not linger on the earlier message.
      expect(provider.messages.any((m) => m.pendingApproval != null), isFalse);
    });

    test('declining marks the tool cancelled', () async {
      await reachPendingApproval();

      stubSend(const [CeliaTextDelta('No problem.')]);
      await provider.respondToApproval(
        approvalId: 'approval-1',
        approved: false,
      );

      final denied = provider.messages
          .expand((m) => m.toolCalls)
          .where((call) => call.phase == ToolPhase.denied);
      expect(denied, hasLength(1));
    });
  });

  group('conversations', () {
    test('starting a new one clears the thread', () async {
      stubSend(const [
        CeliaConversationStarted('conv-1'),
        CeliaTextDelta('hi'),
      ]);
      await provider.sendMessage('hello');

      await provider.startNewConversation();

      expect(provider.messages, isEmpty);
      expect(provider.conversationId, isNull);
      expect(provider.hasMessages, isFalse);
    });

    test('opening one replaces the thread with its stored messages', () async {
      when(() => service.loadConversation('conv-9')).thenAnswer(
        (_) async => const [
          CeliaMessage(id: 'm1', role: ChatRole.user, text: 'earlier question'),
          CeliaMessage(id: 'm2', role: ChatRole.assistant, text: 'earlier answer'),
        ],
      );

      await provider.openConversation('conv-9');

      expect(provider.messages, hasLength(2));
      expect(provider.messages.last.text, 'earlier answer');
      expect(provider.conversationId, 'conv-9');
      expect(provider.isLoadingConversation, isFalse);
    });

    test('reports a failure to open', () async {
      when(
        () => service.loadConversation(any()),
      ).thenThrow(Exception('offline'));

      await provider.openConversation('conv-9');

      expect(provider.error, isNotNull);
      expect(provider.isLoadingConversation, isFalse);
    });

    test('loads history', () async {
      when(() => service.listConversations()).thenAnswer(
        (_) async => [
          ChatConversation(
            id: 'c1',
            title: 'Leg day plan',
            updatedAt: DateTime(2026),
          ),
        ],
      );

      await provider.loadHistory();

      expect(provider.history.single.title, 'Leg day plan');
      expect(provider.isLoadingHistory, isFalse);
    });

    test('deleting the open conversation resets the thread', () async {
      when(() => service.deleteConversation('conv-1')).thenAnswer((_) async {});
      stubSend(const [
        CeliaConversationStarted('conv-1'),
        CeliaTextDelta('hi'),
      ]);
      await provider.sendMessage('hello');

      await provider.deleteConversation('conv-1');

      expect(provider.messages, isEmpty);
      expect(provider.conversationId, isNull);
    });

    test('reports a failed delete', () async {
      when(
        () => service.deleteConversation(any()),
      ).thenThrow(Exception('offline'));

      await provider.deleteConversation('conv-1');

      expect(provider.error, isNotNull);
    });
  });

  test('clearError clears it', () async {
    stubSend(const [CeliaStreamError('boom')]);
    await provider.sendMessage('hi');
    expect(provider.error, 'boom');

    provider.clearError();

    expect(provider.error, isNull);
  });
}
