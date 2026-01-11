import 'package:celia_flutter/providers/chat_provider.dart';
import 'package:celia_flutter/repositories/chat_history_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

class MockFirestore extends Mock implements FirebaseFirestore {}
class MockUsersCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockUserDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockUserSnap extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class MockConversationsCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockConversationDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(SetOptions(merge: true));
  });

  ChatHistoryRepository _repoWith({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return ChatHistoryRepository(
      auth: auth,
      firestore: firestore,
      retryDelays: const [Duration.zero],
      delay: (_) async {},
    );
  }

  test('ensureUserDocument creates doc when missing (saveConversation)', () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => auth.currentUser).thenReturn(user);

    final firestore = MockFirestore();
    final users = MockUsersCollection();
    final userDoc = MockUserDoc();
    final snap = MockUserSnap();
    final convs = MockConversationsCollection();
    final convDoc = MockConversationDoc();

    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.get()).thenAnswer((_) async => snap);
    when(() => snap.exists).thenReturn(false);
    when(() => userDoc.set(any(), any())).thenAnswer((_) async {});

    when(() => userDoc.collection('conversations')).thenReturn(convs);
    when(() => convs.doc('c1')).thenReturn(convDoc);
    when(() => convDoc.set(any(), any())).thenAnswer((_) async {});

    final repo = _repoWith(auth: auth, firestore: firestore);
    await repo.saveConversation(
      SavedConversation(
        id: 'c1',
        title: 't',
        lastMessage: 'm',
        timestamp: DateTime(2026, 1, 1),
        userId: 'u',
        userKey: 'k',
      ),
    );

    verify(() => userDoc.set(any(), any())).called(1);
    verify(() => convDoc.set(any(), any())).called(1);
  });

  test('getConversations success path adds missing id field', () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => auth.currentUser).thenReturn(user);

    final firestore = MockFirestore();
    final users = MockUsersCollection();
    final userDoc = MockUserDoc();
    final snap = MockUserSnap();
    final convs = MockConversationsCollection();
    final query = MockQuery();
    final qs = MockQuerySnapshot();
    final qdoc = MockQueryDocSnapshot();

    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.get()).thenAnswer((_) async => snap);
    when(() => snap.exists).thenReturn(true);

    when(() => userDoc.collection('conversations')).thenReturn(convs);
    when(() => convs.orderBy('timestamp', descending: true)).thenReturn(query);
    when(() => query.get()).thenAnswer((_) async => qs);
    when(() => qs.docs).thenReturn([qdoc]);
    when(() => qdoc.id).thenReturn('c1');
    when(() => qdoc.data()).thenReturn({
      'title': 't',
      'lastMessage': 'm',
      'timestamp': DateTime(2026, 1, 1).toIso8601String(),
      'userId': 'u',
      'userKey': 'k',
    });

    final repo = _repoWith(auth: auth, firestore: firestore);
    final list = await repo.getConversations();
    expect(list.single.id, 'c1');
  });

  test('getConversations fallback path when orderBy throws FirebaseException', () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => auth.currentUser).thenReturn(user);

    final firestore = MockFirestore();
    final users = MockUsersCollection();
    final userDoc = MockUserDoc();
    final snap = MockUserSnap();
    final convs = MockConversationsCollection();
    final query = MockQuery();
    final qs = MockQuerySnapshot();
    final qdoc = MockQueryDocSnapshot();

    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.get()).thenAnswer((_) async => snap);
    when(() => snap.exists).thenReturn(true);

    when(() => userDoc.collection('conversations')).thenReturn(convs);
    when(() => convs.orderBy('timestamp', descending: true)).thenReturn(query);
    when(() => query.get()).thenThrow(FirebaseException(plugin: 'cloud_firestore', code: 'failed-precondition'));

    // fallback .get() (no orderBy)
    when(() => convs.get()).thenAnswer((_) async => qs);
    when(() => qs.docs).thenReturn([qdoc]);
    when(() => qdoc.id).thenReturn('c2');
    when(() => qdoc.data()).thenReturn({
      'title': 't',
      'lastMessage': 'm',
      'timestamp': DateTime(2026, 1, 1).toIso8601String(),
      'userId': 'u',
      'userKey': 'k',
    });

    final repo = _repoWith(auth: auth, firestore: firestore);
    final list = await repo.getConversations();
    expect(list.single.id, 'c2');
  });

  test('deleteConversation retries on unavailable then succeeds', () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => auth.currentUser).thenReturn(user);

    final firestore = MockFirestore();
    final users = MockUsersCollection();
    final userDoc = MockUserDoc();
    final snap = MockUserSnap();
    final convs = MockConversationsCollection();
    final convDoc = MockConversationDoc();

    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.get()).thenAnswer((_) async => snap);
    when(() => snap.exists).thenReturn(true);

    when(() => userDoc.collection('conversations')).thenReturn(convs);
    when(() => convs.doc('c1')).thenReturn(convDoc);
    int calls = 0;
    when(() => convDoc.delete()).thenAnswer((_) async {
      calls += 1;
      if (calls == 1) {
        throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
      }
    });

    final repo = _repoWith(auth: auth, firestore: firestore);
    await repo.deleteConversation('c1');
    verify(() => convDoc.delete()).called(2);
  });

  test('deleteConversation does not retry on non-retryable FirebaseException', () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => auth.currentUser).thenReturn(user);

    final firestore = MockFirestore();
    final users = MockUsersCollection();
    final userDoc = MockUserDoc();
    final snap = MockUserSnap();
    final convs = MockConversationsCollection();
    final convDoc = MockConversationDoc();

    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.get()).thenAnswer((_) async => snap);
    when(() => snap.exists).thenReturn(true);

    when(() => userDoc.collection('conversations')).thenReturn(convs);
    when(() => convs.doc('c1')).thenReturn(convDoc);
    when(() => convDoc.delete()).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
    );

    final repo = _repoWith(auth: auth, firestore: firestore);
    expect(() => repo.deleteConversation('c1'), throwsA(isA<FirebaseException>()));
  });

  test('ensureUserDocument throws if auth becomes null between calls', () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('u1');

    int calls = 0;
    when(() => auth.currentUser).thenAnswer((_) {
      calls += 1;
      return calls == 1 ? user : null;
    });

    final repo = _repoWith(auth: auth, firestore: MockFirestore());
    await expectLater(
      repo.saveConversation(
        SavedConversation(
          id: 'c1',
          title: 't',
          lastMessage: 'm',
          timestamp: DateTime(2026, 1, 1),
          userId: 'u',
          userKey: 'k',
        ),
      ),
      throwsA(anything),
    );
  });
}

