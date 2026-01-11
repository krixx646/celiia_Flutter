import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleAuth extends Mock implements GoogleSignInAuthentication {}
class MockPlatformInfo extends Mock implements PlatformInfo {}

void main() {
  setUpAll(() {
    registerFallbackValue(EmailAuthProvider.credential(email: 'e', password: 'p'));
  });

  test('signIn wraps firebase errors', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(Exception('nope'));

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: MockGoogleSignIn(),
      platform: MockPlatformInfo(),
      apple: DefaultAppleSignInClient(),
    );

    expect(() => repo.signIn('e', 'p'), throwsException);
  });

  test('reloadUser throws when no user', () async {
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: MockGoogleSignIn(),
      platform: MockPlatformInfo(),
      apple: DefaultAppleSignInClient(),
    );

    expect(() => repo.reloadUser(), throwsException);
  });

  test('signInWithGoogle uses injected GoogleSignIn', () async {
    final auth = MockFirebaseAuth();
    final google = MockGoogleSignIn();
    final account = MockGoogleAccount();
    final googleAuth = MockGoogleAuth();
    final cred = MockUserCredential();
    final user = MockUser();

    when(() => google.authenticate()).thenAnswer((_) async => account);
    when(() => account.authentication).thenReturn(googleAuth);
    when(() => googleAuth.idToken).thenReturn('idtoken');

    when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
    when(() => cred.user).thenReturn(user);

    final repo = AuthRepository(
      auth: auth,
      googleSignIn: google,
      platform: MockPlatformInfo(),
      apple: DefaultAppleSignInClient(),
    );

    final got = await repo.signInWithGoogle();
    expect(got, user);
  });
}

