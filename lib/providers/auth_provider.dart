import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

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
  }) {
    return AuthUiState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      needsEmailVerification: needsEmailVerification ?? this.needsEmailVerification,
      verificationEmailSent: verificationEmailSent ?? this.verificationEmailSent,
      authError: authError,
      passwordResetEmailSent: passwordResetEmailSent ?? this.passwordResetEmailSent,
      lastUsedEmail: lastUsedEmail ?? this.lastUsedEmail,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  AuthUiState _uiState = AuthUiState();
  AuthUiState get uiState => _uiState;

  bool get isUserAuthenticated => _authRepository.isUserAuthenticated;
  bool get isEmailVerified => _authRepository.isEmailVerified;

  AuthProvider() {
    _initialize();
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
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
    );
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
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  void saveEmailForVerification(String email) {
    _uiState = _uiState.copyWith(lastUsedEmail: email);
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    saveEmailForVerification(email);
    
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
    );
    notifyListeners();

    try {
      final user = await _authRepository.signUp(email, password);
      // Immediately send verification email for new users
      try {
        await _authRepository.sendEmailVerification();
        _uiState = _uiState.copyWith(verificationEmailSent: true);
      } catch (_) {}
      
      _uiState = _uiState.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        isEmailVerified: false,
        needsEmailVerification: true,
        authError: null,
        lastUsedEmail: email,
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isAuthenticated: false,
        isLoading: false,
        authError: e.toString(),
      );
    }
    notifyListeners();
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
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> sendVerificationEmail() async {
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
      );
    } catch (e) {
      _uiState = _uiState.copyWith(
        isLoading: false,
        authError: e.toString(),
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
    _uiState = _uiState.copyWith(
      isLoading: true,
      authError: null,
    );
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
        authError: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _uiState = AuthUiState();
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
      authError: errorMessage,
      isLoading: false,
    );
    notifyListeners();
  }
}


