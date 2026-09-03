import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/body_scan.dart';
import '../models/nutrition_profile.dart';

/// Talks to `/api/mobile/body-scan`.
///
/// Photos are sent straight through to the backend and never written to disk
/// or kept after the request completes: the promise made on the consent screen
/// is that we do not store them.
class BodyScanService {
  BodyScanService({FirebaseAuth? firebaseAuth, http.Client? httpClient})
    : _injectedAuth = firebaseAuth,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth? _injectedAuth;
  final http.Client _httpClient;

  /// Resolved on use so constructing the service does not require Firebase to
  /// be initialised.
  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;

  /// Body composition takes longer than a chat turn; the backend allows 60s.
  static const Duration _scanTimeout = Duration(seconds: 90);
  static const Duration _historyTimeout = Duration(seconds: 30);

  /// Vercel caps a request body at 4.5 MB and base64 adds a third. The backend
  /// rejects anything larger, but failing here saves the upload entirely.
  static const int _maxPhotoBytes = 1300000;

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  /// Minimum age for body photography. Enforced again on the server.
  static const int minimumAge = 18;

  Future<BodyScanResult> submitScan({
    required List<int> frontJpegBytes,
    required List<int> rightJpegBytes,
    required int age,
    required NutritionGender gender,
    required double heightCm,
    required double weightKg,
  }) async {
    if (frontJpegBytes.length > _maxPhotoBytes ||
        rightJpegBytes.length > _maxPhotoBytes) {
      throw const BodyScanException(BodyScanError.photosTooLarge);
    }
    if (age < minimumAge) {
      throw const BodyScanException(BodyScanError.notEligibleAge);
    }

    // The vendor's model is trained on two categories only. Users who record
    // anything else choose which to estimate against during the scan flow, so
    // by the time we get here it must be one of the two.
    final vendorGender = switch (gender) {
      NutritionGender.male => 'male',
      NutritionGender.female => 'female',
      NutritionGender.other => null,
    };
    if (vendorGender == null) {
      throw const BodyScanException(BodyScanError.invalidStats);
    }

    final json = await _post('/api/mobile/body-scan', {
      'frontPhotoBase64': base64Encode(frontJpegBytes),
      'rightPhotoBase64': base64Encode(rightJpegBytes),
      'age': age,
      'gender': vendorGender,
      'heightCm': heightCm,
      'weightKg': weightKg,
    }, timeout: _scanTimeout);

    final scanJson = json['scan'];
    if (scanJson is! Map) {
      throw const BodyScanException(BodyScanError.server, details: 'No scan in response');
    }

    final quotaJson = json['quota'];
    return BodyScanResult(
      scan: BodyScan.fromJson(Map<String, dynamic>.from(scanJson)),
      quota: quotaJson is Map
          ? BodyScanQuota.fromJson(Map<String, dynamic>.from(quotaJson))
          : null,
    );
  }

  /// Past scans, newest first, for the trend and history views.
  Future<List<BodyScan>> fetchHistory({int limit = 20}) async {
    final json = await _get('/api/mobile/body-scan?limit=$limit');
    final scans = json['scans'];
    if (scans is! List) return const [];
    return scans
        .whereType<Map>()
        .map((s) => BodyScan.fromJson(Map<String, dynamic>.from(s)))
        .toList();
  }

  Future<Uri> _uri(String path) async {
    final base = backendBaseUrl().trim();
    if (base.isEmpty) {
      throw const BodyScanException(
        BodyScanError.notConfigured,
        details: 'CELIA_BACKEND_BASE_URL is not set',
      );
    }
    return Uri.parse('$base$path');
  }

  Future<String> _idToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const BodyScanException(BodyScanError.notSignedIn);
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const BodyScanException(BodyScanError.notSignedIn);
    }
    return token;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    required Duration timeout,
  }) async {
    final uri = await _uri(path);
    final token = await _idToken();

    final http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const BodyScanException(BodyScanError.network, details: 'Timed out');
    } catch (e) {
      throw BodyScanException(BodyScanError.network, details: e.toString());
    }

    return _decode(response);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = await _uri(path);
    final token = await _idToken();

    final http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(_historyTimeout);
    } on TimeoutException {
      throw const BodyScanException(BodyScanError.network, details: 'Timed out');
    } catch (e) {
      throw BodyScanException(BodyScanError.network, details: e.toString());
    }

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    final decoded = text.isNotEmpty ? jsonDecode(text) : <String, dynamic>{};
    final json = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) return json;

    throw _errorFor(response.statusCode, json, text);
  }

  BodyScanException _errorFor(int status, Map<String, dynamic> json, String raw) {
    final code = json['code']?.toString();
    final details = json['error']?.toString() ?? raw;

    // 422 is the vendor rejecting the photos: recoverable by retaking, so the
    // category decides which piece of guidance the user sees.
    if (status == 422) {
      final category = json['category']?.toString();
      return BodyScanException(
        switch (category) {
          'framing' => BodyScanError.photoFraming,
          'quality' => BodyScanError.photoQuality,
          'pose' => BodyScanError.photoPose,
          'clothing' => BodyScanError.photoClothing,
          _ => BodyScanError.photoUnknown,
        },
        details: code ?? details,
      );
    }

    if (status == 402 || code == 'quotaExhausted') {
      return BodyScanException(
        BodyScanError.quotaExhausted,
        details: details,
        resetsAt: DateTime.tryParse(json['resetsAt']?.toString() ?? '')?.toLocal(),
      );
    }

    if (status == 413) {
      return BodyScanException(BodyScanError.photosTooLarge, details: details);
    }

    if (code == 'ageNotEligible') {
      return BodyScanException(BodyScanError.notEligibleAge, details: details);
    }

    if (status == 401) {
      return BodyScanException(BodyScanError.notSignedIn, details: details);
    }

    if (status == 400) {
      return BodyScanException(BodyScanError.invalidStats, details: details);
    }

    if (status == 503) {
      return BodyScanException(BodyScanError.network, details: details);
    }

    return BodyScanException(BodyScanError.server, details: details);
  }
}
