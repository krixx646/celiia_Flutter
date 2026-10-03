import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/env.dart';

/// Where the club's own app lives and whether to offer it.
class ClubLink {
  const ClubLink({required this.enabled, required this.url});

  final bool enabled;
  final Uri url;
}

/// Reads `/api/mobile/club-link`, so the provisional club link can be replaced
/// or switched off from the backend without a new release of the app.
class ClubLinkService {
  ClubLinkService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const Duration _timeout = Duration(seconds: 8);

  /// Used when the backend cannot be reached, so the club stays reachable
  /// offline-ish instead of the entry silently disappearing.
  static final Uri fallbackUrl = Uri.parse(
    'https://preview.builtwithrocket.new/thefitclub-0ewx?p=c',
  );

  @visibleForTesting
  static String Function() backendBaseUrl = () => Env.celiaBackendBaseUrl;

  Future<ClubLink> fetch() async {
    final fallback = ClubLink(enabled: true, url: fallbackUrl);
    final base = backendBaseUrl().trim();
    if (base.isEmpty) return fallback;

    try {
      final response = await _httpClient
          .get(Uri.parse('$base/api/mobile/club-link'))
          .timeout(_timeout);
      if (response.statusCode != 200) return fallback;

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map) return fallback;

      final url = Uri.tryParse('${json['url']}');
      if (url == null || url.scheme != 'https' || url.host.isEmpty) {
        return fallback;
      }
      return ClubLink(enabled: json['enabled'] != false, url: url);
    } on TimeoutException {
      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}
