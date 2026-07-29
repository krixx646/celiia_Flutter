import 'package:celia_flutter/providers/auth_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockUser());
  });

  test('signIn success updates uiState', () async {
    final repo = MockAuthRepository();
    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);
    when(() => repo.currentUser).thenReturn(null);
    when(() => repo.signIn('e', 'p')).thenAnswer((_) async => user);
    when(() => repo.reloadUser()).thenAnswer((_) async => user);

    final p = AuthProvider(authRepository: repo);
    await p.signIn('e', 'p');

    expect(p.uiState.isAuthenticated, isTrue);
    expect(p.uiState.isEmailVerified, isTrue);
    expect(p.uiState.authError, isNull);
  });

  test('signIn failure sets authError', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    when(() => repo.signIn(any(), any())).thenThrow(Exception('bad'));

    final p = AuthProvider(authRepository: repo);
    await p.signIn('e', 'p');
    expect(p.uiState.isAuthenticated, isFalse);
    expect(p.uiState.authError, 'Could not sign in. Please try again.');
  });

  test('sendVerificationEmail enforces local cooldown', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    when(() => repo.sendEmailVerification()).thenAnswer((_) async {});

    final p = AuthProvider(authRepository: repo);
    await p.sendVerificationEmail();
    expect(p.uiState.verificationEmailSent, isTrue);
    expect(p.uiState.resendCooldownSeconds, greaterThan(0));

    await p.sendVerificationEmail();
    expect(p.uiState.authError, contains('Please wait'));
    p.dispose();
  });
}
