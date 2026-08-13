import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// The language providers use when they format an error without a BuildContext.
///
/// [LocaleProvider] keeps this in sync with the language the UI is showing, so
/// a Spanish user still gets Spanish copy when a sign-in failure is phrased
/// deep in [AuthProvider].
class AppLocale {
  AppLocale._();

  static Locale current = const Locale('en');
}

/// Turns whatever went wrong into a sentence worth showing someone.
///
/// Prefer passing [l10n] from a widget. Providers may omit it; the active
/// [AppLocale] is used instead. [fallback] is a ready-made sentence; use
/// [fallbackOf] when the fallback itself needs translating.
String toUserFriendlyMessage(
  Object? error, {
  AppLocalizations? l10n,
  String? fallback,
  String Function(AppLocalizations l10n)? fallbackOf,
}) {
  final loc = l10n ?? lookupAppLocalizations(AppLocale.current);
  final generic = fallback ?? fallbackOf?.call(loc) ?? loc.errorGeneric;
  if (error == null) return generic;
  final isRawString = error is String;

  var raw = error.toString().trim();
  if (raw.isEmpty) return generic;

  raw = raw
      .replaceFirst(
        RegExp(
          r'^(Exception|FirebaseException|SupabaseException|CloudflareException)\s*:?\s*',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'\s+'), ' ');

  final lower = raw.toLowerCase();

  if (lower.contains('canceled') || lower.contains('cancelled')) {
    return loc.errorCanceled;
  }
  if (lower.contains('too-many-requests')) {
    return loc.errorTooManyRequests;
  }
  if (lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('timeout') ||
      lower.contains('timed out') ||
      lower.contains('unavailable')) {
    return loc.errorNetwork;
  }
  if (lower.contains('invalid-credential') ||
      lower.contains('wrong-password') ||
      lower.contains('user-not-found') ||
      lower.contains('invalid email') ||
      lower.contains('authentication failed')) {
    return loc.errorBadCredentials;
  }
  if (lower.contains('email-already-in-use')) {
    return loc.errorEmailInUse;
  }
  if (lower.contains('weak-password')) {
    return loc.errorWeakPassword;
  }
  if (lower.contains('invalid-email')) {
    return loc.errorInvalidEmail;
  }
  if (lower.contains('permission-denied') ||
      lower.contains('forbidden') ||
      lower.contains('unauthorized')) {
    return loc.errorNoPermission;
  }
  if (lower.contains('not signed in') ||
      lower.contains('no authenticated user') ||
      lower.contains('no user logged in')) {
    return loc.errorNotSignedIn;
  }
  if (lower.contains('no active conversation')) {
    return loc.errorNoConversation;
  }
  if (lower.contains('no playable videos')) {
    return loc.errorNoPlayableVideos;
  }

  // Anything left is either a message written for a person, which is worth
  // showing as-is, or a machine's idea of one, which is not. The raw text is
  // only trusted when a caller passed a plain string in the first place.
  if (_looksTechnical(raw, lower)) return generic;
  return isRawString ? raw : generic;
}

bool _looksTechnical(String raw, String lower) {
  if (raw.length > 140) return true;
  if (raw.contains('http://') || raw.contains('https://')) return true;
  if (raw.contains('{') || raw.contains('}') || raw.contains('->')) return true;
  if (raw.contains('stack trace') || raw.contains('type ')) return true;
  if (RegExp(
    r'\b(firebase|supabase|cloudflare|status code|exception|socketexception|formatexception)\b',
    caseSensitive: false,
  ).hasMatch(lower)) {
    return true;
  }
  return false;
}
