import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/user_profile.dart';

/// Talks to `/api/mobile/profile`.
///
/// The onboarding profile is held on the backend rather than in Firestore
/// because the routine generator and the Celia agent both need to read it, and
/// neither can reach Firestore.
class UserProfileService {
  UserProfileService({FirebaseAuth? firebaseAuth, http.Client? httpClient})
    : _injectedAuth = firebaseAuth,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth? _injectedAuth;
  final http.Client _httpClient;

  /// Resolved on use so constructing the service does not require Firebase to
  /// be initialised.
  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;

  static const Duration _timeout = Duration(seconds: 20);

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  /// The caller's profile, or null if they have never onboarded.
  Future<UserProfile?> fetch() async {
    final json = await _send('GET', null);
    final profile = json['profile'];
    if (profile is! Map) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(profile));
  }

  /// Writes the answers present in [profile] and returns the stored result.
  ///
  /// Partial by design: fields the draft has not filled in yet are left
  /// untouched, so onboarding can save after every step.
  Future<UserProfile> save(UserProfile profile) async {
    final json = await _send('PUT', profile.toWireJson());
    final saved = json['profile'];
    if (saved is! Map) {
      throw const UserProfileException('Profile was not saved');
    }
    return UserProfile.fromJson(Map<String, dynamic>.from(saved));
  }

  Future<Map<String, dynamic>> _send(
    String method,
    Map<String, dynamic>? body,
  ) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw const UserProfileException('CELIA_BACKEND_BASE_URL is not set');
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) throw const UserProfileException('Not signed in');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const UserProfileException('Not signed in');
    }

    final uri = Uri.parse('$base/api/mobile/profile');
    final headers = {
      'Authorization': 'Bearer $token',
      if (body != null) 'Content-Type': 'application/json',
    };

    final http.Response response;
    try {
      final request = method == 'GET'
          ? _httpClient.get(uri, headers: headers)
          : _httpClient.put(uri, headers: headers, body: jsonEncode(body));
      response = await request.timeout(_timeout);
    } on TimeoutException {
      throw const UserProfileException('Request timed out');
    } catch (e) {
      throw UserProfileException('Network error: $e');
    }

    final text = utf8.decode(response.bodyBytes);
    final decoded = text.isNotEmpty ? jsonDecode(text) : <String, dynamic>{};
    final json = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) return json;
    if (response.statusCode == 401) {
      throw const UserProfileException('Not signed in');
    }
    throw UserProfileException(
      json['error']?.toString() ?? 'Request failed (${response.statusCode})',
    );
  }
}

class UserProfileException implements Exception {
  const UserProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
