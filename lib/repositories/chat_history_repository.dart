import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/chat_provider.dart';

class ChatHistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveConversation(SavedConversation conversation) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversation.id)
        .set({
          ...conversation.toJson(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<List<SavedConversation>> getConversations() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');

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
  }

  Future<void> deleteConversation(String conversationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No authenticated user');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .delete();
  }
}


