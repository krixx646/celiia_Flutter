import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockPlatformInfo extends Mock implements PlatformInfo {}
class FakeFirebaseAuthProvider extends Fake implements AuthProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFirebaseAuthProvider());
  });

  test('signOut signs out of auth + google', () async {
    final auth = MockFirebaseAuth();
    final google = MockGoogleSignIn();
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => google.signOut()).thenAnswer((_) async => null);

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: google,
      platform: MockPlatformInfo(),
      apple: DefaultAppleSignInClient(),
    );

    await repo.signOut();
    verify(() => auth.signOut()).called(1);
    verify(() => google.signOut()).called(1);
  });

  test('updateProfile throws when no user', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: MockGoogleSignIn(),
      platform: MockPlatformInfo(),
      apple: DefaultAppleSignInClient(),
    );

    expect(() => repo.updateProfile(displayName: 'x'), throwsException);
  });

  test('sendEmailVerification throws when no user', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: MockGoogleSignIn(),
      platform: MockPlatformInfo(),
      apple: DefaultAppleSignInClient(),
    );

    expect(() => repo.sendEmailVerification(), throwsException);
  });

  test('signInWithApple (non-Android path) uses Firebase provider flow', () async {
    final auth = MockFirebaseAuth();
    final cred = MockUserCredential();
    final user = MockUser();
    when(() => cred.user).thenReturn(user);
    when(() => auth.signInWithProvider(any())).thenAnswer((_) async => cred);

    final platform = MockPlatformInfo();
    when(() => platform.isAndroid).thenReturn(false);
    when(() => platform.isIOS).thenReturn(true);

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: MockGoogleSignIn(),
      platform: platform,
      apple: DefaultAppleSignInClient(),
    );

    final u = await repo.signInWithApple();
    expect(u, user);
  });
}

