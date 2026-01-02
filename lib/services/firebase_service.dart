import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static GoogleSignIn get googleSignIn => GoogleSignIn.instance;

  static Future<void> initialize() async {
    try {
      // Try default init (works when GoogleService-Info.plist / google-services.json are bundled)
      await Firebase.initializeApp();
    } catch (_) {
      // Fallback for iOS simulator builds where GoogleService-Info.plist is not included.
      if (Platform.isIOS) {
        const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
        const appId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
        const messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
        const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
        const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

        if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
          // Re-throw with a clear message so the UI can still boot and we can see logs on simulator
          throw FirebaseException(
            plugin: 'firebase_core',
            message: 'Missing Firebase iOS options. Supply FIREBASE_API_KEY, FIREBASE_IOS_APP_ID, FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID (and optional FIREBASE_STORAGE_BUCKET) via --dart-define.',
          );
        }

        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            storageBucket: storageBucket.isEmpty ? null : storageBucket,
            iosBundleId: 'eu.thefit.celia',
          ),
        );
      } else {
        rethrow;
      }
    }
    // Initialize Google Sign-In once per app start (required in v7+)
    await GoogleSignIn.instance.initialize();

    // Initialize Firebase App Check (protects Firestore/Storage in production)
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
        appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
        // webProvider: ReCaptchaV3Provider('unused'), 
      );
    } catch (_) {
      // If App Check init fails, proceed to avoid blocking startup; server rules may allow debug
    }
  }

  static User? get currentUser => auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;
}


