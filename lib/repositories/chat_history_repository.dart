import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import '../providers/chat_provider.dart';

class ChatHistoryRepository {
  @visibleForTesting
  static FirebaseFirestore Function() defaultFirestore = () =>
      FirebaseFirestore.instance;

  @visibleForTesting
  static FirebaseAuth Function() defaultAuth = () => FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final List<Duration> _retryDelays;
  final Future<void> Function(Duration) _delay;

  ChatHistoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    List<Duration>? retryDelays,
    Future<void> Function(Duration)? delay,
  }) : _firestore = firestore ?? defaultFirestore(),
       _auth = auth ?? defaultAuth(),
       _retryDelays =
           retryDelays ??
           const <Duration>[
             Duration(milliseconds: 400),
             Duration(milliseconds: 900),
             Duration(milliseconds: 1800),
           ],
       _delay = delay ?? Future<void>.delayed;

  Future<void> _ensureUserDocument() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');
    final DocumentReference<Map<String, dynamic>> userRef = _firestore
        .collection('users')
        .doc(userId);
    final DocumentSnapshot<Map<String, dynamic>> snap = await userRef.get();
    if (!snap.exists) {
      await userRef.set(<String, dynamic>{
        'uid': userId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveConversation(SavedConversation conversation) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');
    await _ensureUserDocument();
    await _withRetry(() async {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversation.id)
          .set({
            ...conversation.toJson(),
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    });
  }

  Future<List<SavedConversation>> getConversations() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');
    await _ensureUserDocument();
    return await _withRetry<List<SavedConversation>>(() async {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('conversations')
            .orderBy('timestamp', descending: true)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('id')) {
            data['id'] = doc.id;
          }
          return SavedConversation.fromJson(data);
        }).toList();
      } on FirebaseException {
        // Fallback without ordering if an index/field is missing
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('conversations')
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('id')) {
            data['id'] = doc.id;
          }
          return SavedConversation.fromJson(data);
        }).toList();
      }
    });
  }

  Future<void> deleteConversation(String conversationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');
    await _ensureUserDocument();
    await _withRetry(() async {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .delete();
    });
  }

  Future<T> _withRetry<T>(Future<T> Function() action) async {
    int attempt = 0;
    while (true) {
      try {
        return await action();
      } on FirebaseException catch (e) {
        final String code = e.code.toLowerCase();
        final bool retryable =
            code == 'unavailable' ||
            code == 'deadline-exceeded' ||
            code == 'aborted';
        if (attempt >= _retryDelays.length || !retryable) rethrow;
        await _delay(_retryDelays[attempt]);
        attempt += 1;
      }
    }
  }
}
