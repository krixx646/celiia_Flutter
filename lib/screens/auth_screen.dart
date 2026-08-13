import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' show Platform;
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/loading_indicator.dart';
import 'forgot_password_screen.dart';

const Color _authBackground = Colors.black;
const Color _authSurface = Color(0xFF090909);
const Color _authBorder = Color(0xFF242424);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSignIn = true;
  bool _landing = true; // initial landing page like the reference

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: _authBackground,
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final ui = auth.uiState;

          if (ui.isLoading) {
            return Center(
              child: LoadingIndicator(message: l10n.authAuthenticating),
            );
          }

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double h = constraints.maxHeight;
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: h * 0.15),
                          const Text(
                            'celia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFF6F00),
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authTagline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFF6F00),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Image.asset(
                              'assets/images/auth_logo.jpeg',
                              height: 96,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_landing) ...[
                            SizedBox(height: h * 0.34),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.accentOrange,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () => setState(() {
                                _landing = false;
                                _isSignIn = false;
                              }),
                              child: Text(
                                l10n.authSignUp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () => setState(() {
                                _landing = false;
                                _isSignIn = true;
                              }),
                              child: Text(
                                l10n.authLogIn,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                l10n.authVersion('1.1.7'),
                                style: const TextStyle(color: Colors.white38),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            if (!_isSignIn) ...[
                              TextField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: l10n.authFieldName,
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
                                      color: Color(0xFFFF6F00),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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
                                    color: Color(0xFFFF6F00),
                                  ),
                                ),
                              ),
                              onChanged: auth.saveEmailForVerification,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: l10n.authFieldPassword,
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
                                    color: Color(0xFFFF6F00),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (ui.authError != null &&
                                !(ui.authError!.toLowerCase().contains(
                                      'canceled',
                                    ) ||
                                    ui.authError!.toLowerCase().contains(
                                      'cancelled',
                                    )))
                              Text(
                                ui.authError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.accentOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () {
                                final email = _emailController.text.trim();
                                final pwd = _passwordController.text.trim();
                                if (_isSignIn) {
                                  auth.signIn(email, pwd);
                                } else {
                                  final name = _nameController.text.trim();
                                  if (name.isEmpty) {
                                    auth.setAuthError(
                                      l10n.authEnterYourName,
                                    );
                                    return;
                                  }
                                  auth.signUp(email, pwd, displayName: name);
                                }
                              },
                              child: Text(
                                _isSignIn ? l10n.authLogIn : l10n.authSignUp,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _isSignIn = !_isSignIn),
                              child: Text(
                                _isSignIn
                                    ? l10n.authNeedAccount
                                    : l10n.authHaveAccount,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.authForgotPassword,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    l10n.authOr,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Google button styled
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: auth.signInWithGoogle,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.google,
                                    color: Color(0xFF4285F4),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.authContinueWithGoogle),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (Platform.isIOS || Platform.isAndroid)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: auth.signInWithApple,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const FaIcon(FontAwesomeIcons.apple),
                                    const SizedBox(width: 8),
                                    Text(l10n.authContinueWithApple),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Center(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _landing = true;
                                }),
                                child: Text(
                                  l10n.actionCancel,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 8,
                          ), // ensures slight bottom padding without large gap
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
