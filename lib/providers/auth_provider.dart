import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../utils/user_facing_error.dart';

class AuthUiState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? currentUser;
  final bool isEmailVerified;
  final bool needsEmailVerification;
  final bool verificationEmailSent;
  final String? authError;
  final bool passwordResetEmailSent;
  final String lastUsedEmail;
  final int resendCooldownSeconds;

  AuthUiState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.currentUser,
    this.isEmailVerified = false,
    this.needsEmailVerification = false,
    this.verificationEmailSent = false,
    this.authError,
    this.passwordResetEmailSent = false,
    this.lastUsedEmail = '',
    this.resendCooldownSeconds = 0,
  });

  AuthUiState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? currentUser,
    bool? isEmailVerified,
    bool? needsEmailVerification,
    bool? verificationEmailSent,
    String? authError,
    bool? passwordResetEmailSent,
    String? lastUsedEmail,
    int? resendCooldownSeconds,
  }) {
    return AuthUiState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      needsEmailVerification:
          needsEmailVerification ?? this.needsEmailVerification,
      verificationEmailSent:
          verificationEmailSent ?? this.verificationEmailSent,
      authError: authError,
      passwordResetEmailSent:
          passwordResetEmailSent ?? this.passwordResetEmailSent,
      lastUsedEmail: lastUsedEmail ?? this.lastUsedEmail,
      resendCooldownSeconds:
          resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  @visibleForTesting
  static AuthRepository Function() defaultAuthRepository = () =>
      AuthRepository();

  final AuthRepository _authRepository;
  final DateTime Function() _now;

  AuthUiState _uiState = AuthUiState();
  AuthUiState get uiState => _uiState;
  Timer? _cooldownTimer;
  DateTime? _resendNotBefore;

  bool get isUserAuthenticated => _authRepository.isUserAuthenticated;
  bool get isEmailVerified => _authRepository.isEmailVerified;

  AuthProvider({AuthRepository? authRepository, DateTime Function()? now})
    : _authRepository = authRepository ?? defaultAuthRepository(),
      _now = now ?? DateTime.now {
    _initialize();
  }

  Future<void> reloadCurrentUser() async {
    try {
      final user = await _authRepository.reloadUser();
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        currentUser: user,
        isEmailVerified: user.emailVerified,
        needsEmailVerification: !user.emailVerified,
      );
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    await _authRepository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
    await reloadCurrentUser();
  }

  void _initialize() {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        currentUser: currentUser,
        isEmailVerified: currentUser.emailVerified,
      );

      if (!currentUser.emailVerified) {
        _uiState = _uiState.copyWith(needsEmailVerification: true);
      }
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _uiState = _uiState.copyWith(isLoading: true, authError: null);
    notifyListeners();

    try {
      final user = await _authRepository.signIn(email, password);
      await _authRepository.reloadUser();

      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: user.emailVerified,
        needsEmailVerification: !user.emailVerified,
        authError: null,
        lastUsedEmail: email,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: toUserFriendlyMessage(
          e,
          fallback: 'Could not sign in. Please try again.',
        ),
      );
    }
    notifyListeners();
  }

  void saveEmailForVerification(String email) {
    _uiState = _uiState.copyWith(lastUsedEmail: email);
    notifyListeners();
  }

  Future<void> signUp(
    String email,
    String password, {
    required String displayName,
  }) async {
    saveEmailForVerification(email);

    _uiState = _uiState.copyWith(isLoading: true, authError: null);
    notifyListeners();

    try {
      final user = await _authRepository.signUp(email, password);
      final trimmedName = displayName.trim();
      if (trimmedName.isNotEmpty) {
        await _authRepository.updateProfile(displayName: trimmedName);
        await _authRepository.reloadUser();
      }
      // Immediately send verification email for new users
      try {
        await _authRepository.sendEmailVerification();
        _uiState = _uiState.copyWith(verificationEmailSent: true);
      } catch (_) {}

      final refreshedUser = _authRepository.currentUser ?? user;
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: refreshedUser,
        isEmailVerified: false,
        needsEmailVerification: true,
        authError: null,
        lastUsedEmail: email,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: toUserFriendlyMessage(
          e,
          fallback: 'Could not create your account. Please try again.',
        ),
      );
    }
    notifyListeners();
  }

  bool get needsDisplayName {
    final name = _uiState.currentUser?.displayName?.trim();
    return name == null || name.isEmpty;
  }

  Future<void> resetPassword(String email) async {
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
      passwordResetEmailSent: false,
    );
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _uiState = _uiState.copyWith(
        isLoading: false,
        passwordResetEmailSent: true,
        authError: null,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        passwordResetEmailSent: false,
        authError: toUserFriendlyMessage(
          e,
          fallback: 'Could not send reset email. Please try again.',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> sendVerificationEmail() async {
    // Local cooldown to avoid Firebase rate limit
    final now = _now();
    if (_resendNotBefore != null && now.isBefore(_resendNotBefore!)) {
      final remaining = _resendNotBefore!.difference(now).inSeconds;
      _uiState = _uiState.copyWith(
        authError: 'Please wait ${remaining}s before requesting another email.',
      );
      notifyListeners();
      return;
    }

    _uiState = _uiState.copyWith(
      isLoading: true,
      verificationEmailSent: false,
      authError: null,
    );
    notifyListeners();

    try {
      await _authRepository.sendEmailVerification();
      _uiState = _uiState.copyWith(
        isLoading: false,
        verificationEmailSent: true,
        resendCooldownSeconds: 60,
      );
      _resendNotBefore = _now().add(const Duration(seconds: 60));
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        final secs = _resendNotBefore!.difference(_now()).inSeconds;
        if (secs <= 0) {
          _uiState = _uiState.copyWith(resendCooldownSeconds: 0);
          t.cancel();
        } else {
          _uiState = _uiState.copyWith(resendCooldownSeconds: secs);
        }
        notifyListeners();
      });
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        authError: toUserFriendlyMessage(
          e,
          fallback: 'Could not send verification email. Please try again.',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> checkEmailVerification() async {
    try {
      final user = await _authRepository.reloadUser();
      _uiState = _uiState.copyWith(
        isEmailVerified: user.emailVerified,
        needsEmailVerification: !user.emailVerified,
      );
      notifyListeners();
    } catch (e) {
      // swallow error
    }
  }

  Future<void> signInWithGoogle() async {
    _uiState = _uiState.copyWith(isLoading: true, authError: null);
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: true,
        needsEmailVerification: false,
        authError: null,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: toUserFriendlyMessage(
          e,
          fallback: 'Google sign-in failed. Please try again.',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _uiState = AuthUiState();
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    _uiState = _uiState.copyWith(isLoading: true, authError: null);
    notifyListeners();

    try {
      final user = await _authRepository.signInWithApple();
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: true,
        needsEmailVerification: false,
        authError: null,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: toUserFriendlyMessage(
          e,
          fallback: 'Apple sign-in failed. Please try again.',
        ),
      );
    }
    notifyListeners();
  }

  void clearError() {
    _uiState = _uiState.copyWith(authError: null);
    notifyListeners();
  }

  void clearPasswordResetEmailSent() {
    _uiState = _uiState.copyWith(passwordResetEmailSent: false);
    notifyListeners();
  }

  void clearVerificationEmailSent() {
    _uiState = _uiState.copyWith(verificationEmailSent: false);
    notifyListeners();
  }

  void setAuthError(String errorMessage) {
    _uiState = _uiState.copyWith(
      authError: toUserFriendlyMessage(errorMessage),
      isLoading: false,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
