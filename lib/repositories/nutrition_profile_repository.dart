import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../models/nutrition_profile.dart';

class NutritionProfileRepository {
  @visibleForTesting
  static FirebaseFirestore Function() defaultFirestore = () =>
      FirebaseFirestore.instance;

  @visibleForTesting
  static FirebaseAuth Function() defaultAuth = () => FirebaseAuth.instance;

  final FirebaseFirestore? _injectedFirestore;
  final FirebaseAuth? _injectedAuth;

  NutritionProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _injectedFirestore = firestore,
      _injectedAuth = auth;

  // Resolved on first use and then cached, rather than in the constructor:
  // AuthProvider builds this repository eagerly, so constructing it must not
  // require Firebase to be initialised (widget tests hit `[core/no-app]`).
  FirebaseFirestore? _firestoreCache;
  FirebaseAuth? _authCache;

  FirebaseFirestore get _firestore =>
      _firestoreCache ??= _injectedFirestore ?? defaultFirestore();

  FirebaseAuth get _auth => _authCache ??= _injectedAuth ?? defaultAuth();

  Future<NutritionProfile?> getProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final snap = await _firestore.collection('users').doc(userId).get();
    final data = snap.data()?['nutritionProfile'];
    if (data is! Map<String, dynamic>) return null;

    final profile = NutritionProfile.fromJson(data);
    return profile.isComplete ? profile : null;
  }

  Future<NutritionProfile> saveProfile(NutritionProfile profile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not signed in');
    }

    final payload = profile.toJson()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).set({
      'nutritionProfile': payload,
    }, SetOptions(merge: true));

    return profile;
  }

  /// Removes the user's Firestore document entirely. Part of account
  /// deletion (Apple Guideline 5.1.1(v)) — must run before the Firebase Auth
  /// identity is deleted, since it relies on the caller's own auth session.
  Future<void> deleteProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).delete();
  }
}
