import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';

const Color _authBackground = Colors.black;
const Color _authSurface = Color(0xFF090909);
const Color _authBorder = Color(0xFF242424);
const Color _authOrange = Color(0xFFFF6F00);

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _authBackground,
      appBar: AppBar(
        backgroundColor: _authBackground,
        foregroundColor: Colors.white,
        title: Text(l10n.forgotPasswordTitle),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final ui = auth.uiState;
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.22),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.forgotPasswordBody,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: l10n.authFieldEmail,
                                  filled: true,
                                  fillColor: _authSurface,
                                  labelStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: _authBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                      color: _authOrange,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (ui.authError != null)
                                Text(
                                  ui.authError!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _authOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: ui.isLoading
                                    ? null
                                    : () async {
                                        final email = _emailController.text
                                            .trim();
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final navigator = Navigator.of(context);
                                        if (email.isEmpty) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.forgotPasswordEmptyEmail,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        await auth.resetPassword(email);
                                        if (!context.mounted) return;
                                        if (auth
                                            .uiState
                                            .passwordResetEmailSent) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.forgotPasswordSent,
                                              ),
                                            ),
                                          );
                                          navigator.pop();
                                        }
                                      },
                                child: ui.isLoading
                                    ? LoadingIndicator(
                                        message: l10n.forgotPasswordSending,
                                      )
                                    : Text(l10n.forgotPasswordSend),
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
