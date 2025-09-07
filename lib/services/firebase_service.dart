import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static GoogleSignIn get googleSignIn => GoogleSignIn.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    // Initialize Google Sign-In once per app start (required in v7+)
    await GoogleSignIn.instance.initialize();
  }

  static User? get currentUser => auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;
}


