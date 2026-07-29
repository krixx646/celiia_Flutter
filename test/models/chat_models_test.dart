import 'package:celia_flutter/models/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat models round-trip JSON', () {
    final user = User(
      id: 'u1',
      name: 'Ada',
      email: 'a@b.com',
      metadata: const {'k': 'v'},
    );
    expect(User.fromJson(user.toJson()).id, 'u1');

    final convo = Conversation(
      id: 'c1',
      userId: 'u1',
      created: '2026-01-10T00:00:00Z',
      updated: null,
    );
    expect(Conversation.fromJson(convo.toJson()).id, 'c1');

    final msg = Message(
      id: 'm1',
      conversationId: 'c1',
      userId: 'u1',
      text: 'hi',
      type: 'text',
      created: '2026-01-10T00:00:01Z',
      options: [MessageOption(label: 'A', value: 'a')],
      interacted: true,
    );
    final msg2 = Message.fromJson(msg.toJson());
    expect(msg2.id, 'm1');
    expect(msg2.options?.single.label, 'A');
    expect(msg2.interacted, isTrue);

    final payload = MessagePayload(
      type: 'button',
      text: 't',
      options: [MessageOption(label: 'B', value: 'b')],
    );
    expect(MessagePayload.fromJson(payload.toJson()).type, 'button');

    final withConvo = MessageWithConversation(
      conversationId: 'c1',
      payload: payload,
    );
    expect(
      MessageWithConversation.fromJson(withConvo.toJson()).conversationId,
      'c1',
    );
  });
}
