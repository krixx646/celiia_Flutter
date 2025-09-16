import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        final apiKey = const String.fromEnvironment('FIREBASE_API_KEY');
        final appId = const String.fromEnvironment('FIREBASE_IOS_APP_ID');
        final messagingSenderId = const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
        final projectId = const String.fromEnvironment('FIREBASE_PROJECT_ID');
        final storageBucket = const String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

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
  }

  static User? get currentUser => auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;
}


