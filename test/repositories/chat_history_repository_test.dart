import 'package:celia_flutter/repositories/chat_history_repository.dart';
import 'package:celia_flutter/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {}

void main() {
  test('throws when no authenticated user', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    final repo = ChatHistoryRepository(auth: auth, firestore: MockFirestore());
    await expectLater(repo.getConversations(), throwsA(anything));
    await expectLater(repo.deleteConversation('c'), throwsA(anything));

    final saved = SavedConversation(
      id: 'c',
      title: 't',
      lastMessage: 'm',
      timestamp: DateTime(2026, 1, 1),
      userId: 'u',
      userKey: 'k',
    );
    await expectLater(repo.saveConversation(saved), throwsA(anything));
  });

  test('constructor uses default factories when deps not provided', () async {
    final origAuth = ChatHistoryRepository.defaultAuth;
    final origFirestore = ChatHistoryRepository.defaultFirestore;

    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    final firestore = MockFirestore();

    try {
      ChatHistoryRepository.defaultAuth = () => auth;
      ChatHistoryRepository.defaultFirestore = () => firestore;

      final repo = ChatHistoryRepository();
      await expectLater(repo.getConversations(), throwsA(anything));
    } finally {
      ChatHistoryRepository.defaultAuth = origAuth;
      ChatHistoryRepository.defaultFirestore = origFirestore;
    }
  });
}
