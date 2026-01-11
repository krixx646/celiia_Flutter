import 'package:celia_flutter/providers/auth_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:celia_flutter/screens/email_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockUser());
  });

  testWidgets('EmailVerificationScreen shows sent/error/cooldown states and buttons call provider', (tester) async {
    final repo = MockAuthRepository();
    when(() => repo.currentUser).thenReturn(null);

    when(() => repo.sendEmailVerification()).thenAnswer((_) async {});
    when(() => repo.signOut()).thenAnswer((_) async {});

    final verified = MockUser();
    when(() => verified.emailVerified).thenReturn(true);
    when(() => repo.reloadUser()).thenAnswer((_) async => verified);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(authRepository: repo, now: DateTime.now),
        child: const MaterialApp(home: EmailVerificationScreen()),
      ),
    );

    final auth = tester.element(find.byType(EmailVerificationScreen)).read<AuthProvider>();

    // Trigger resend
    await tester.tap(find.text('Resend verification email'));
    await tester.pump(); // rebuild with updated state

    expect(find.text('Verification email sent!'), findsOneWidget);
    expect(find.textContaining('Resend in '), findsOneWidget);

    // Surface an auth error
    auth.setAuthError('boom');
    await tester.pump();
    expect(find.text('boom'), findsOneWidget);

    // "I have verified" calls into provider/repo
    await tester.tap(find.text('I have verified, continue'));
    await tester.pump();
    verify(() => repo.reloadUser()).called(greaterThanOrEqualTo(1));

    // Sign out
    await tester.tap(find.text('Sign out'));
    await tester.pump();
    verify(() => repo.signOut()).called(1);
  });
}

