String toUserFriendlyMessage(
  Object? error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error == null) return fallback;
  final isRawString = error is String;

  var raw = error.toString().trim();
  if (raw.isEmpty) return fallback;

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
    return 'Action canceled.';
  }
  if (lower.contains('too-many-requests')) {
    return 'Too many attempts. Please wait a minute and try again.';
  }
  if (lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('timeout') ||
      lower.contains('timed out') ||
      lower.contains('unavailable')) {
    return 'Please check your internet connection and try again.';
  }
  if (lower.contains('invalid-credential') ||
      lower.contains('wrong-password') ||
      lower.contains('user-not-found') ||
      lower.contains('invalid email') ||
      lower.contains('authentication failed')) {
    return 'Incorrect email or password.';
  }
  if (lower.contains('email-already-in-use')) {
    return 'This email is already in use. Try logging in instead.';
  }
  if (lower.contains('weak-password')) {
    return 'Use a stronger password and try again.';
  }
  if (lower.contains('invalid-email')) {
    return 'Please enter a valid email address.';
  }
  if (lower.contains('permission-denied') ||
      lower.contains('forbidden') ||
      lower.contains('unauthorized')) {
    return 'You do not have permission to do that.';
  }
  if (lower.contains('not signed in') ||
      lower.contains('no authenticated user') ||
      lower.contains('no user logged in')) {
    return 'Please sign in and try again.';
  }
  if (lower.contains('no active conversation')) {
    return 'Start a new chat to continue.';
  }
  if (lower.contains('no playable videos')) {
    return 'No playable videos are available for this routine yet.';
  }

  if (_looksTechnical(raw, lower)) return fallback;
  return isRawString ? raw : fallback;
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
