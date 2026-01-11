import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/foundation.dart' show visibleForTesting;

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static GoogleSignIn get googleSignIn => GoogleSignIn.instance;

  @visibleForTesting
  static bool Function() isIOS = () => Platform.isIOS;

  @visibleForTesting
  static String Function(String key) env = (key) => String.fromEnvironment(key);

  @visibleForTesting
  static Future<void> Function({FirebaseOptions? options}) firebaseInitializeApp = ({FirebaseOptions? options}) {
    if (options == null) return Firebase.initializeApp();
    return Firebase.initializeApp(options: options);
  };

  @visibleForTesting
  static Future<void> Function() googleSignInInitialize = () => GoogleSignIn.instance.initialize();

  @visibleForTesting
  static Future<void> Function({required AndroidProvider androidProvider, required AppleProvider appleProvider}) appCheckActivate =
      ({required AndroidProvider androidProvider, required AppleProvider appleProvider}) {
    return FirebaseAppCheck.instance.activate(
      androidProvider: androidProvider,
      appleProvider: appleProvider,
    );
  };

  static Future<void> initialize() async {
    try {
      // Try default init (works when GoogleService-Info.plist / google-services.json are bundled)
      await firebaseInitializeApp();
    } catch (_) {
      // Fallback for iOS simulator builds where GoogleService-Info.plist is not included.
      if (isIOS()) {
        final apiKey = env('FIREBASE_API_KEY');
        final appId = env('FIREBASE_IOS_APP_ID');
        final messagingSenderId = env('FIREBASE_MESSAGING_SENDER_ID');
        final projectId = env('FIREBASE_PROJECT_ID');
        final storageBucket = env('FIREBASE_STORAGE_BUCKET');

        if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
          // Re-throw with a clear message so the UI can still boot and we can see logs on simulator
          throw FirebaseException(
            plugin: 'firebase_core',
            message: 'Missing Firebase iOS options. Supply FIREBASE_API_KEY, FIREBASE_IOS_APP_ID, FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID (and optional FIREBASE_STORAGE_BUCKET) via --dart-define.',
          );
        }

        await firebaseInitializeApp(
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
    await googleSignInInitialize();

    // Initialize Firebase App Check (protects Firestore/Storage in production)
    try {
      await appCheckActivate(
        androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
        appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
      );
    } catch (_) {
      // If App Check init fails, proceed to avoid blocking startup; server rules may allow debug
    }
  }

  static User? get currentUser => auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;
}


