import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import '../services/firebase_service.dart';

abstract class PlatformInfo {
  bool get isAndroid;
  bool get isIOS;
}

class DefaultPlatformInfo implements PlatformInfo {
  @override
  bool get isAndroid => Platform.isAndroid;
  @override
  bool get isIOS => Platform.isIOS;
}

abstract class AppleSignInClient {
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    required String nonce,
    required WebAuthenticationOptions webAuthenticationOptions,
  });
}

class DefaultAppleSignInClient implements AppleSignInClient {
  @override
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    required String nonce,
    required WebAuthenticationOptions webAuthenticationOptions,
  }) {
    return SignInWithApple.getAppleIDCredential(
      scopes: scopes,
      nonce: nonce,
      webAuthenticationOptions: webAuthenticationOptions,
    );
  }
}

class AuthRepository {
  @visibleForTesting
  static FirebaseAuth Function() defaultAuth = () => FirebaseService.auth;

  @visibleForTesting
  static GoogleSignIn Function() defaultGoogleSignIn = () =>
      FirebaseService.googleSignIn;

  @visibleForTesting
  static PlatformInfo Function() defaultPlatform = () => DefaultPlatformInfo();

  @visibleForTesting
  static AppleSignInClient Function() defaultApple = () =>
      DefaultAppleSignInClient();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final PlatformInfo _platform;
  final AppleSignInClient _apple;
  final String _appleServiceId;
  final String _appleRedirectUri;

  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    PlatformInfo? platform,
    AppleSignInClient? apple,
    String? appleServiceId,
    String? appleRedirectUri,
  }) : _auth = auth ?? defaultAuth(),
       _googleSignIn = googleSignIn ?? defaultGoogleSignIn(),
       _platform = platform ?? defaultPlatform(),
       _apple = apple ?? defaultApple(),
       _appleServiceId =
           appleServiceId ?? const String.fromEnvironment('APPLE_SERVICE_ID'),
       _appleRedirectUri =
           appleRedirectUri ??
           const String.fromEnvironment('APPLE_REDIRECT_URI');

  User? get currentUser => _auth.currentUser;
  bool get isUserAuthenticated => currentUser != null;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<User> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        return result.user!;
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<User> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        try {
          // Send verification with explicit ActionCodeSettings to avoid invalid/expired links
          final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
            url:
                'https://the-fit-87c3d.web.app', // authorized domain in your project
            handleCodeInApp:
                false, // let Firebase hosted page complete verification
            androidPackageName: 'eu.thefit.celia',
            androidInstallApp: false,
            iOSBundleId: 'eu.thefit.celia',
          );
          await result.user!.sendEmailVerification(actionCodeSettings);
        } catch (e) {
          // ignore send verification errors here
        }
        return result.user!;
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      // Use new v7 API: authenticate() returns account with tokens
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        return result.user!;
      } else {
        throw Exception('Google sign-in failed');
      }
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
          url: 'https://the-fit-87c3d.web.app',
          handleCodeInApp: false,
          androidPackageName: 'eu.thefit.celia',
          androidInstallApp: false,
          iOSBundleId: 'eu.thefit.celia',
        );
        await user.sendEmailVerification(actionCodeSettings);
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  Future<User> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return _auth.currentUser!;
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      throw Exception('User reload failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
  }

  // ----- Sign in with Apple -----
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      AuthorizationCredentialAppleID appleCredential;

      if (_platform.isAndroid) {
        // Android uses the web flow. Requires Apple Service ID and redirect URI.
        final serviceId = _appleServiceId;
        final redirectUri = _appleRedirectUri;
        if (serviceId.isEmpty || redirectUri.isEmpty) {
          throw Exception(
            'Missing APPLE_SERVICE_ID or APPLE_REDIRECT_URI. Provide as --dart-define.',
          );
        }
        appleCredential = await _apple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: serviceId,
            redirectUri: Uri.parse(redirectUri),
          ),
        );
      } else {
        // Prefer Firebase's native provider on iOS to avoid token/nonce mismatches
        final provider = AppleAuthProvider();
        provider.addScope('email');
        provider.addScope('name');
        final result = await _auth.signInWithProvider(provider);
        if (result.user != null) {
          return result.user!;
        } else {
          throw Exception('Apple sign-in failed');
        }
      }

      // Android path continues here (web flow returns identityToken)
      final oauth = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final result = await _auth.signInWithCredential(oauth);
      if (result.user != null) {
        final givenName = appleCredential.givenName?.trim();
        final familyName = appleCredential.familyName?.trim();
        final fullName = [
          givenName,
          familyName,
        ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
        if (fullName.isNotEmpty &&
            (result.user!.displayName == null ||
                result.user!.displayName!.trim().isEmpty)) {
          await result.user!.updateDisplayName(fullName);
          await result.user!.reload();
          return _auth.currentUser ?? result.user!;
        }
        return result.user!;
      } else {
        throw Exception('Apple sign-in failed');
      }
    } catch (e) {
      throw Exception('Apple sign in failed: ${e.toString()}');
    }
  }
}
