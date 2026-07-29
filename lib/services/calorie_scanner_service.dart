import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/meal_analysis.dart';
import '../models/meal_log.dart';
import 'supabase_service.dart';

class CalorieScannerService {
  CalorieScannerService({FirebaseAuth? firebaseAuth, http.Client? httpClient})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _firebaseAuth;
  final http.Client _httpClient;
  static const Duration _requestTimeout = Duration(seconds: 45);

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  Future<MealAnalysis> analyzeMealImage({
    required List<int> jpegBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define before using the calorie scanner.',
      );
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw SupabaseException(
        'Not signed in',
        'Please sign in before scanning meals.',
      );
    }

    final idToken = await user.getIdToken();
    final uri = Uri.parse('$base/api/mobile/analyze-meal');
    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'imageBase64': base64Encode(jpegBytes),
            'mimeType': mimeType,
            'timezoneOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
          }),
        )
        .timeout(_requestTimeout);

    final text = utf8.decode(response.bodyBytes);
    final json = text.isNotEmpty ? jsonDecode(text) : {};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = json is Map && json['error'] != null
          ? json['error'].toString()
          : 'Could not analyze this meal';
      throw SupabaseException(msg, text);
    }

    final analysisJson = json is Map ? json['analysis'] : null;
    if (analysisJson is! Map<String, dynamic>) {
      throw SupabaseException('Invalid meal analysis response', text);
    }

    return MealAnalysis.fromJson(analysisJson);
  }

  Future<MealLog> logMeal(MealAnalysis analysis) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define before logging meals.',
      );
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw SupabaseException(
        'Not signed in',
        'Please sign in before logging meals.',
      );
    }

    final idToken = await user.getIdToken();
    final uri = Uri.parse('$base/api/mobile/log-meal');
    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            ...analysis.toJson(),
            'loggedAt': DateTime.now().toIso8601String(),
          }),
        )
        .timeout(_requestTimeout);

    final text = utf8.decode(response.bodyBytes);
    final json = text.isNotEmpty ? jsonDecode(text) : {};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = json is Map && json['error'] != null
          ? json['error'].toString()
          : 'Could not log this meal';
      throw SupabaseException(msg, text);
    }

    final mealJson = json is Map ? json['meal'] : null;
    if (mealJson is! Map<String, dynamic>) {
      throw SupabaseException('Invalid meal log response', text);
    }

    return MealLog.fromJson(mealJson);
  }

  Future<List<MealLog>> getMealLogs({int limit = 60}) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define before loading meals.',
      );
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw SupabaseException('Not signed in', 'Please sign in to view meals.');
    }

    final idToken = await user.getIdToken();
    final uri = Uri.parse('$base/api/mobile/meals?limit=$limit');
    final response = await _httpClient
        .get(uri, headers: {'Authorization': 'Bearer $idToken'})
        .timeout(_requestTimeout);

    final text = utf8.decode(response.bodyBytes);
    final json = text.isNotEmpty ? jsonDecode(text) : {};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = json is Map && json['error'] != null
          ? json['error'].toString()
          : 'Could not load meals';
      throw SupabaseException(msg, text);
    }

    final mealsJson = json is Map ? json['meals'] : null;
    if (mealsJson is! List) {
      throw SupabaseException('Invalid meal list response', text);
    }

    return mealsJson
        .whereType<Map<String, dynamic>>()
        .map(MealLog.fromJson)
        .toList();
  }

  Future<MealLog> updateMealLog(MealLog meal) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define before updating meals.',
      );
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw SupabaseException(
        'Not signed in',
        'Please sign in to update meals.',
      );
    }

    final idToken = await user.getIdToken();
    final uri = Uri.parse('$base/api/mobile/meals/${meal.id}');
    final response = await _httpClient
        .patch(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode(meal.toUpdateJson()),
        )
        .timeout(_requestTimeout);

    final text = utf8.decode(response.bodyBytes);
    final json = text.isNotEmpty ? jsonDecode(text) : {};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = json is Map && json['error'] != null
          ? json['error'].toString()
          : 'Could not update meal';
      throw SupabaseException(msg, text);
    }

    final mealJson = json is Map ? json['meal'] : null;
    if (mealJson is! Map<String, dynamic>) {
      throw SupabaseException('Invalid meal update response', text);
    }

    return MealLog.fromJson(mealJson);
  }

  Future<void> deleteMealLog(String mealId) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw SupabaseException(
        'Backend not configured',
        'Provide CELIA_BACKEND_BASE_URL via --dart-define before deleting meals.',
      );
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw SupabaseException(
        'Not signed in',
        'Please sign in to delete meals.',
      );
    }

    final idToken = await user.getIdToken();
    final uri = Uri.parse('$base/api/mobile/meals/$mealId');
    final response = await _httpClient
        .delete(uri, headers: {'Authorization': 'Bearer $idToken'})
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final text = utf8.decode(response.bodyBytes);
      final json = text.isNotEmpty ? jsonDecode(text) : {};
      final msg = json is Map && json['error'] != null
          ? json['error'].toString()
          : 'Could not delete meal';
      throw SupabaseException(msg, text);
    }
  }
}
