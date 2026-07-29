import 'package:celia_flutter/providers/auth_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockUser());
  });

  test(
    'constructor initializes state from currentUser (verified + unverified)',
    () async {
      final verifiedRepo = MockAuthRepository();
      final verifiedUser = MockUser();
      when(() => verifiedUser.emailVerified).thenReturn(true);
      when(() => verifiedRepo.currentUser).thenReturn(verifiedUser);

      final p1 = AuthProvider(authRepository: verifiedRepo);
      expect(p1.uiState.isAuthenticated, isTrue);
      expect(p1.uiState.isEmailVerified, isTrue);
      expect(p1.uiState.needsEmailVerification, isFalse);

      final unverifiedRepo = MockAuthRepository();
      final unverifiedUser = MockUser();
      when(() => unverifiedUser.emailVerified).thenReturn(false);
      when(() => unverifiedRepo.currentUser).thenReturn(unverifiedUser);

      final p2 = AuthProvider(authRepository: unverifiedRepo);
      expect(p2.uiState.isAuthenticated, isTrue);
      expect(p2.uiState.isEmailVerified, isFalse);
      expect(p2.uiState.needsEmailVerification, isTrue);
    },
  );

  test(
    'reloadCurrentUser success updates verification flags; failure is swallowed',
    () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);

      final user = MockUser();
      when(() => user.emailVerified).thenReturn(false);
      when(() => repo.reloadUser()).thenAnswer((_) async => user);

      final p = AuthProvider(authRepository: repo);
      await p.reloadCurrentUser();
      expect(p.uiState.isAuthenticated, isTrue);
      expect(p.uiState.isEmailVerified, isFalse);
      expect(p.uiState.needsEmailVerification, isTrue);

      when(() => repo.reloadUser()).thenThrow(Exception('boom'));
      await p.reloadCurrentUser(); // should not throw
    },
  );

  test('updateProfile delegates and reloads user', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);

    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);
    when(
      () => repo.updateProfile(
        displayName: any(named: 'displayName'),
        photoUrl: any(named: 'photoUrl'),
      ),
    ).thenAnswer((_) async {});
    when(() => repo.reloadUser()).thenAnswer((_) async => user);

    final p = AuthProvider(authRepository: repo);
    await p.updateProfile(displayName: 'n', photoUrl: 'p');
    expect(p.uiState.isEmailVerified, isTrue);
  });

  test(
    'signIn success sets authenticated, lastUsedEmail; signIn error sets authError',
    () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);

      final user = MockUser();
      when(() => user.emailVerified).thenReturn(true);
      when(() => repo.signIn('e', 'p')).thenAnswer((_) async => user);
      when(() => repo.reloadUser()).thenAnswer((_) async => user);

      final p = AuthProvider(authRepository: repo);
      await p.signIn('e', 'p');
      expect(p.uiState.isAuthenticated, isTrue);
      expect(p.uiState.isEmailVerified, isTrue);
      expect(p.uiState.needsEmailVerification, isFalse);
      expect(p.uiState.lastUsedEmail, 'e');

      when(() => repo.signIn(any(), any())).thenThrow(Exception('bad'));
      await p.signIn('e2', 'p2');
      expect(p.uiState.isAuthenticated, isFalse);
      expect(p.uiState.authError, 'Could not sign in. Please try again.');
    },
  );

  test(
    'signUp success sets needsEmailVerification; verification email success + failure branches',
    () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);

      final user = MockUser();
      when(() => user.emailVerified).thenReturn(false);
      when(() => repo.signUp('e', 'p')).thenAnswer((_) async => user);
      when(
        () => repo.updateProfile(displayName: any(named: 'displayName')),
      ).thenAnswer((_) async {});
      when(() => repo.reloadUser()).thenAnswer((_) async => user);

      // verification email success
      when(() => repo.sendEmailVerification()).thenAnswer((_) async {});
      final p1 = AuthProvider(authRepository: repo);
      await p1.signUp('e', 'p', displayName: 'Alex');
      expect(p1.uiState.isAuthenticated, isTrue);
      expect(p1.uiState.needsEmailVerification, isTrue);
      expect(p1.uiState.verificationEmailSent, isTrue);
      expect(p1.uiState.lastUsedEmail, 'e');

      // verification email failure is swallowed
      final repo2 = MockAuthRepository();
      when(() => repo2.currentUser).thenReturn(null);
      when(() => repo2.signUp('e2', 'p2')).thenAnswer((_) async => user);
      when(
        () => repo2.updateProfile(displayName: any(named: 'displayName')),
      ).thenAnswer((_) async {});
      when(() => repo2.reloadUser()).thenAnswer((_) async => user);
      when(() => repo2.sendEmailVerification()).thenThrow(Exception('nope'));

      final p2 = AuthProvider(authRepository: repo2);
      await p2.signUp('e2', 'p2', displayName: 'Sam');
      expect(p2.uiState.isAuthenticated, isTrue);
      expect(p2.uiState.needsEmailVerification, isTrue);
      expect(p2.uiState.verificationEmailSent, isFalse);
    },
  );

  test('signUp error sets authError', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    when(() => repo.signUp(any(), any())).thenThrow(Exception('bad'));

    final p = AuthProvider(authRepository: repo);
    await p.signUp('e', 'p', displayName: 'Alex');
    expect(p.uiState.isAuthenticated, isFalse);
    expect(
      p.uiState.authError,
      'Could not create your account. Please try again.',
    );
  });

  test('resetPassword success + error', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);

    when(() => repo.resetPassword('e')).thenAnswer((_) async {});
    final p1 = AuthProvider(authRepository: repo);
    await p1.resetPassword('e');
    expect(p1.uiState.passwordResetEmailSent, isTrue);

    when(() => repo.resetPassword(any())).thenThrow(Exception('bad'));
    final p2 = AuthProvider(authRepository: repo);
    await p2.resetPassword('e2');
    expect(p2.uiState.passwordResetEmailSent, isFalse);
    expect(
      p2.uiState.authError,
      'Could not send reset email. Please try again.',
    );
  });

  test(
    'sendVerificationEmail: success starts cooldown, timer reaches 0, and early-return cooldown message',
    () {
      fakeAsync((async) {
        final repo = MockAuthRepository();
        when(() => repo.currentUser).thenReturn(null);
        when(() => repo.sendEmailVerification()).thenAnswer((_) async {});

        final start = DateTime(2026, 1, 1, 0, 0, 0);
        final p = AuthProvider(
          authRepository: repo,
          now: () => start.add(async.elapsed),
        );

        async.run((_) async {
          await p.sendVerificationEmail();
        });
        async.flushMicrotasks();

        expect(p.uiState.verificationEmailSent, isTrue);
        expect(p.uiState.resendCooldownSeconds, 60);

        // calling again immediately should hit local cooldown
        async.run((_) async {
          await p.sendVerificationEmail();
        });
        async.flushMicrotasks();
        expect(p.uiState.authError, contains('Please wait'));

        // advance time past cooldown so timer reaches 0 and cancels
        async.elapse(const Duration(seconds: 61));
        async.flushMicrotasks();
        expect(p.uiState.resendCooldownSeconds, 0);

        p.dispose();
      });
    },
  );

  test(
    'sendVerificationEmail: error maps too-many-requests to friendly message',
    () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(
        () => repo.sendEmailVerification(),
      ).thenThrow(Exception('too-many-requests'));

      final p = AuthProvider(authRepository: repo);
      await p.sendVerificationEmail();
      expect(
        p.uiState.authError,
        'Too many attempts. Please wait a minute and try again.',
      );
    },
  );

  test(
    'sendVerificationEmail: non-rate-limit error shows generic safe message',
    () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(
        () => repo.sendEmailVerification(),
      ).thenThrow(Exception('some-other-error'));

      final p = AuthProvider(authRepository: repo);
      await p.sendVerificationEmail();
      expect(
        p.uiState.authError,
        'Could not send verification email. Please try again.',
      );
    },
  );

  test(
    'uses defaultAuthRepository when authRepository is omitted; getter passthroughs',
    () async {
      final original = AuthProvider.defaultAuthRepository;
      addTearDown(() => AuthProvider.defaultAuthRepository = original);

      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.isUserAuthenticated).thenReturn(true);
      when(() => repo.isEmailVerified).thenReturn(false);
      AuthProvider.defaultAuthRepository = () => repo;

      final p = AuthProvider(now: () => DateTime(2026, 1, 1));
      expect(p.isUserAuthenticated, isTrue);
      expect(p.isEmailVerified, isFalse);
    },
  );

  test('checkEmailVerification updates flags; errors swallowed', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);

    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);
    when(() => repo.reloadUser()).thenAnswer((_) async => user);

    final p = AuthProvider(authRepository: repo);
    await p.checkEmailVerification();
    expect(p.uiState.isEmailVerified, isTrue);
    expect(p.uiState.needsEmailVerification, isFalse);

    when(() => repo.reloadUser()).thenThrow(Exception('boom'));
    await p.checkEmailVerification(); // no throw
  });

  test('signInWithGoogle + signInWithApple success and error', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);

    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);

    when(() => repo.signInWithGoogle()).thenAnswer((_) async => user);
    final p1 = AuthProvider(authRepository: repo);
    await p1.signInWithGoogle();
    expect(p1.uiState.isAuthenticated, isTrue);
    expect(p1.uiState.isEmailVerified, isTrue);
    expect(p1.uiState.needsEmailVerification, isFalse);

    when(() => repo.signInWithGoogle()).thenThrow(Exception('bad'));
    await p1.signInWithGoogle();
    expect(p1.uiState.isAuthenticated, isFalse);
    expect(p1.uiState.authError, 'Google sign-in failed. Please try again.');

    when(() => repo.signInWithApple()).thenAnswer((_) async => user);
    final p2 = AuthProvider(authRepository: repo);
    await p2.signInWithApple();
    expect(p2.uiState.isAuthenticated, isTrue);

    when(() => repo.signInWithApple()).thenThrow(Exception('bad2'));
    await p2.signInWithApple();
    expect(p2.uiState.isAuthenticated, isFalse);
    expect(p2.uiState.authError, 'Apple sign-in failed. Please try again.');
  });

  test('signOut resets uiState to defaults', () async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);
    when(() => repo.signOut()).thenAnswer((_) async {});

    final user = MockUser();
    when(() => user.emailVerified).thenReturn(true);
    when(() => repo.signIn('e', 'p')).thenAnswer((_) async => user);
    when(() => repo.reloadUser()).thenAnswer((_) async => user);

    final p = AuthProvider(authRepository: repo);
    await p.signIn('e', 'p');
    expect(p.uiState.isAuthenticated, isTrue);

    await p.signOut();
    expect(p.uiState.isAuthenticated, isFalse);
    expect(p.uiState.currentUser, isNull);
  });

  test(
    'helpers: saveEmailForVerification, clearError, clearVerificationEmailSent, clearPasswordResetEmailSent, setAuthError',
    () async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);

      final p = AuthProvider(authRepository: repo);
      p.saveEmailForVerification('e');
      expect(p.uiState.lastUsedEmail, 'e');

      p.setAuthError('x');
      expect(p.uiState.authError, 'x');
      expect(p.uiState.isLoading, isFalse);

      p.clearError();
      expect(p.uiState.authError, isNull);

      // mark flags true via state transitions then clear
      when(() => repo.resetPassword(any())).thenAnswer((_) async {});
      await p.resetPassword('e');
      expect(p.uiState.passwordResetEmailSent, isTrue);
      p.clearPasswordResetEmailSent();
      expect(p.uiState.passwordResetEmailSent, isFalse);

      when(() => repo.sendEmailVerification()).thenAnswer((_) async {});
      await p.sendVerificationEmail();
      expect(p.uiState.verificationEmailSent, isTrue);
      p.clearVerificationEmailSent();
      expect(p.uiState.verificationEmailSent, isFalse);

      p.dispose();
    },
  );
}
