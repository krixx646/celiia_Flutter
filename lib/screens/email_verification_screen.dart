import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _authBackground,
      appBar: AppBar(
        backgroundColor: _authBackground,
        foregroundColor: Colors.white,
        title: Text(l10n.verifyEmailTitle),
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
                    Text(
                      l10n.verifyEmailHeading,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.verifyEmailBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (ui.verificationEmailSent)
                      Text(
                        l10n.verifyEmailSent,
                        style: const TextStyle(color: Colors.green),
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
                          ? LoadingIndicator(message: l10n.verifyEmailSending)
                          : Text(
                              ui.resendCooldownSeconds > 0
                                  ? l10n.verifyEmailResendIn(
                                      ui.resendCooldownSeconds,
                                    )
                                  : l10n.verifyEmailResend,
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
                      child: Text(l10n.verifyEmailContinue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ui.lastUsedEmail.isNotEmpty
                          ? l10n.verifyEmailAddress(ui.lastUsedEmail)
                          : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: auth.signOut,
                      child: Text(
                        l10n.verifyEmailSignOut,
                        style: const TextStyle(color: Colors.white70),
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
