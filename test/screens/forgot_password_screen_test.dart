import 'package:celia_flutter/providers/auth_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:celia_flutter/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets(
    'ForgotPasswordScreen validates email, calls reset, shows snackbars, and pops on success',
    (tester) async {
      final repo = MockAuthRepository();
      when(() => repo.currentUser).thenReturn(null);
      when(() => repo.resetPassword(any())).thenAnswer((_) async {});

      final auth = AuthProvider(authRepository: repo);
      addTearDown(auth.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: const Text('OPEN_FORGOT'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN_FORGOT'));
      await tester.pumpAndSettle();
      expect(find.text('Forgot Password'), findsOneWidget);

      // Force an auth error to show error text branch
      auth.setAuthError('err');
      await tester.pump();
      expect(find.text('err'), findsOneWidget);

      // Empty email -> snackbar validation
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      expect(find.text('Please enter an email'), findsOneWidget);

      // Enter email and submit -> resetPassword called and screen pops
      await tester.enterText(find.byType(TextField), 'e@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pump(); // start async + show loading
      await tester.pumpAndSettle();

      verify(() => repo.resetPassword('e@example.com')).called(1);
      // Back to root screen after pop
      expect(find.text('OPEN_FORGOT'), findsOneWidget);
    },
  );
}
