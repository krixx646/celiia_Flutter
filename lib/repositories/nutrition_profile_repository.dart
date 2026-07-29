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

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NutritionProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? defaultFirestore(),
      _auth = auth ?? defaultAuth();

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
}
