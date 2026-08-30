import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/env.dart';

/// OpenAI TTS via the Celia backend — reserved for future avatar / persona
/// speech, not for workout counting.
///
/// Guided workouts use on-device [CeliaVoiceCoach] TTS so reps stay offline,
/// free, and reliable. Keep this client for longer, branded voice lines when
/// the avatar ships.
class WorkoutTtsService {
  WorkoutTtsService({
    http.Client? client,
    FirebaseAuth? auth,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _injectedAuth = auth,
       _baseUrl = baseUrl ?? Env.celiaBackendBaseUrl;

  final http.Client _client;
  final FirebaseAuth? _injectedAuth;
  final String _baseUrl;

  /// Resolved on use so constructing the service does not require Firebase to
  /// be initialised.
  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  Directory? _cacheDir;

  Future<Directory> _dir() async {
    final existing = _cacheDir;
    if (existing != null) return existing;
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'workout_tts'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return _cacheDir = dir;
  }

  String _fileKey(String text, String locale) {
    final digest = sha256.convert(utf8.encode('$locale\u0000$text'));
    return digest.toString();
  }

  /// Returns a local file path for [text] spoken in [locale], synthesizing
  /// through the backend when the clip is not already cached.
  Future<String?> speakFile(String text, {required String locale}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final dir = await _dir();
    final key = _fileKey(trimmed, locale);
    final file = File(p.join(dir.path, '$key.mp3'));
    if (await file.exists() && await file.length() > 0) return file.path;

    final user = _auth.currentUser;
    if (user == null) return null;
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) return null;

    final uri = Uri.parse('$_baseUrl/api/mobile/workout-coach/speak');
    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'text': trimmed, 'locale': locale}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      debugPrint(
        'WorkoutTtsService: speak failed ${response.statusCode} '
        '${response.body}',
      );
      return null;
    }

    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  /// Warm the disk cache for the lines a session is about to need.
  Future<void> prefetch(Iterable<String> lines, {required String locale}) async {
    for (final line in lines) {
      try {
        await speakFile(line, locale: locale);
      } catch (e) {
        debugPrint('WorkoutTtsService: prefetch skipped "$line": $e');
      }
    }
  }
}
