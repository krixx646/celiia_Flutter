import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final GoogleSignIn _googleSignIn = FirebaseService.googleSignIn;

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
          await result.user!.sendEmailVerification();
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
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
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
        await user.sendEmailVerification();
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
}


