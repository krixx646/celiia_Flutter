import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final ui = auth.uiState;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('A verification link has been sent to your email.'),
                const SizedBox(height: 12),
                if (ui.verificationEmailSent)
                  const Text('Verification email sent!', style: TextStyle(color: Colors.green)),
                if (ui.authError != null)
                  Text(ui.authError!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: ui.isLoading ? null : auth.sendVerificationEmail,
                  child: ui.isLoading
                      ? const LoadingIndicator(message: 'Sending...')
                      : const Text('Resend verification email'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: auth.checkEmailVerification,
                  child: const Text('I have verified, continue'),
                ),
                const SizedBox(height: 8),
                Text(ui.lastUsedEmail.isNotEmpty ? 'Email: ${ui.lastUsedEmail}' : ''),
                const Spacer(),
                TextButton(
                  onPressed: auth.signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


