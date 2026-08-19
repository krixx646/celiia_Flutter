import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/env.dart';

/// Wipes the server-side data (Supabase) that belongs to the signed-in user.
///
/// Used by account deletion (Apple Guideline 5.1.1(v)): the backend call must
/// happen while the Firebase ID token is still valid, i.e. before the
/// Firebase Auth identity itself is deleted client-side.
class AccountService {
  AccountService({FirebaseAuth? firebaseAuth, http.Client? httpClient})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _firebaseAuth;
  final http.Client _httpClient;

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  Future<void> deleteAccountData() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Not signed in');

    final token = await user.getIdToken();
    final uri = Uri.parse('${backendBaseUrl()}/api/mobile/account');
    final response = await _httpClient.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 400) {
      throw Exception(
        'Failed to delete account data (${response.statusCode})',
      );
    }
  }
}
