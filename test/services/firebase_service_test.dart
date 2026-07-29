import 'package:celia_flutter/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FirebaseService getters execute', () {
    // In unit tests Firebase isn't initialized; these getters may throw.
    // We still want to execute them for coverage.
    expect(() => FirebaseService.auth, throwsA(anything));
    expect(FirebaseService.googleSignIn, isNotNull);
    expect(() => FirebaseService.currentUser, throwsA(anything));
    expect(() => FirebaseService.isAuthenticated, throwsA(anything));
    expect(() => FirebaseService.isEmailVerified, throwsA(anything));
  });

  test(
    'FirebaseService.initialize iOS fallback throws when env missing',
    () async {
      // Save originals
      final origIsIOS = FirebaseService.isIOS;
      final origEnv = FirebaseService.env;
      final origInit = FirebaseService.firebaseInitializeApp;
      final origGoogleInit = FirebaseService.googleSignInInitialize;
      final origAppCheck = FirebaseService.appCheckActivate;

      try {
        FirebaseService.isIOS = () => true;
        FirebaseService.env = (_) => '';
        FirebaseService.firebaseInitializeApp =
            ({FirebaseOptions? options}) async {
              // Force the fallback path
              throw Exception('boom');
            };
        FirebaseService.googleSignInInitialize = () async {};
        FirebaseService.appCheckActivate =
            ({required androidProvider, required appleProvider}) async {};

        await expectLater(
          FirebaseService.initialize(),
          throwsA(isA<FirebaseException>()),
        );
      } finally {
        FirebaseService.isIOS = origIsIOS;
        FirebaseService.env = origEnv;
        FirebaseService.firebaseInitializeApp = origInit;
        FirebaseService.googleSignInInitialize = origGoogleInit;
        FirebaseService.appCheckActivate = origAppCheck;
      }
    },
  );

  test(
    'FirebaseService.initialize iOS fallback succeeds when env provided',
    () async {
      // Save originals
      final origIsIOS = FirebaseService.isIOS;
      final origEnv = FirebaseService.env;
      final origInit = FirebaseService.firebaseInitializeApp;
      final origGoogleInit = FirebaseService.googleSignInInitialize;
      final origAppCheck = FirebaseService.appCheckActivate;

      int calls = 0;
      try {
        FirebaseService.isIOS = () => true;
        FirebaseService.env = (k) {
          switch (k) {
            case 'FIREBASE_API_KEY':
              return 'k';
            case 'FIREBASE_IOS_APP_ID':
              return 'app';
            case 'FIREBASE_MESSAGING_SENDER_ID':
              return 'sender';
            case 'FIREBASE_PROJECT_ID':
              return 'proj';
            case 'FIREBASE_STORAGE_BUCKET':
              return '';
            default:
              return '';
          }
        };
        FirebaseService.firebaseInitializeApp =
            ({FirebaseOptions? options}) async {
              calls += 1;
              if (calls == 1) {
                // Force fallback
                throw Exception('boom');
              }
              // second call (with options) succeeds
            };
        FirebaseService.googleSignInInitialize = () async {};
        FirebaseService.appCheckActivate =
            ({required androidProvider, required appleProvider}) async {};

        await FirebaseService.initialize();
        expect(calls, 2);
      } finally {
        FirebaseService.isIOS = origIsIOS;
        FirebaseService.env = origEnv;
        FirebaseService.firebaseInitializeApp = origInit;
        FirebaseService.googleSignInInitialize = origGoogleInit;
        FirebaseService.appCheckActivate = origAppCheck;
      }
    },
  );
}
