import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';

const Color _authBackground = Colors.black;
const Color _authSurface = Color(0xFF090909);
const Color _authBorder = Color(0xFF242424);
const Color _authOrange = Color(0xFFFF6F00);

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _authBackground,
      appBar: AppBar(
        backgroundColor: _authBackground,
        foregroundColor: Colors.white,
        title: const Text('Verify your email'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final ui = auth.uiState;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _authSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _authBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      color: _authOrange,
                      size: 54,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Check your inbox',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A verification link has been sent to your email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    if (ui.verificationEmailSent)
                      const Text(
                        'Verification email sent!',
                        style: TextStyle(color: Colors.green),
                      ),
                    if (ui.authError != null)
                      Text(
                        ui.authError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _authOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: (ui.isLoading || ui.resendCooldownSeconds > 0)
                          ? null
                          : auth.sendVerificationEmail,
                      child: ui.isLoading
                          ? const LoadingIndicator(message: 'Sending...')
                          : Text(
                              ui.resendCooldownSeconds > 0
                                  ? 'Resend in ${ui.resendCooldownSeconds}s'
                                  : 'Resend verification email',
                            ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: auth.checkEmailVerification,
                      child: const Text('I have verified, continue'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ui.lastUsedEmail.isNotEmpty
                          ? 'Email: ${ui.lastUsedEmail}'
                          : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: auth.signOut,
                      child: const Text(
                        'Sign out',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
