import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Forgot Password'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final ui = auth.uiState;
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.32),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Enter your email to receive a password reset link.', style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white24)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white60)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (ui.authError != null)
                                Text(ui.authError!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 14)),
                                onPressed: ui.isLoading
                                    ? null
                                    : () async {
                                        final email = _emailController.text.trim();
                                        final messenger = ScaffoldMessenger.of(context);
                                        final navigator = Navigator.of(context);
                                        if (email.isEmpty) {
                                          messenger.showSnackBar(const SnackBar(content: Text('Please enter an email')));
                                          return;
                                        }
                                        await auth.resetPassword(email);
                                        if (!context.mounted) return;
                                        if (auth.uiState.passwordResetEmailSent) {
                                          messenger.showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
                                          navigator.pop();
                                        }
                                      },
                                child: ui.isLoading ? const LoadingIndicator(message: 'Sending...') : const Text('Send reset link'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


