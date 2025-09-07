import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignIn = true;
  bool _landing = true; // initial landing page like the reference

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final ui = auth.uiState;

          if (ui.isLoading) {
            return const Center(child: LoadingIndicator(message: 'Authenticating...'));
          }

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double h = constraints.maxHeight;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  onPressed: () => launchUrl(Uri.parse('https://the-fit.eu/'), mode: LaunchMode.externalApplication),
                                  child: const Text('Visit The Fit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  onPressed: () => launchUrl(Uri.parse('https://the-fit.eu/deleteaccount/'), mode: LaunchMode.externalApplication),
                                  child: const Text('Delete My Data'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.15),
                          const Text('celia', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFF9800), fontSize: 64, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Your fitness buddy', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFF9800), fontSize: 18)),
                          const SizedBox(height: 12),
                          Center(
                            child: Image.asset('assets/images/auth_logo.jpeg', height: 96),
                          ),
                          const SizedBox(height: 32),
                          if (_landing) ...[
                            SizedBox(height: h * 0.34),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 16)),
                              onPressed: () => setState(() { _landing = false; _isSignIn = false; }),
                              child: const Text('Sign Up'),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () => setState(() { _landing = false; _isSignIn = true; }),
                              child: const Text('Log In', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            ),
                            const SizedBox(height: 24),
                            const Center(child: Text('Version 1.1.4', style: TextStyle(color: Colors.white38))),
                            const SizedBox(height: 16),
                          ] else ...[
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Email', labelStyle: const TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white60))),
                              onChanged: auth.saveEmailForVerification,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(labelText: 'Password', labelStyle: const TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white60))),
                            ),
                            const SizedBox(height: 16),
                            if (ui.authError != null &&
                                !(ui.authError!.toLowerCase().contains('canceled') || ui.authError!.toLowerCase().contains('cancelled')))
                              const Text('Sign-in failed. Please try again.', style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: () {
                                final email = _emailController.text.trim();
                                final pwd = _passwordController.text.trim();
                                if (_isSignIn) {
                                  auth.signIn(email, pwd);
                                } else {
                                  auth.signUp(email, pwd);
                                }
                              },
                              child: Text(_isSignIn ? 'Log In' : 'Sign Up'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() => _isSignIn = !_isSignIn),
                              child: Text(_isSignIn ? 'Need an account? Sign Up' : "Already have an account? Log In", style: const TextStyle(color: Colors.white70)),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                              },
                              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white24)),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR', style: TextStyle(color: Colors.white54))),
                                Expanded(child: Divider(color: Colors.white24)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Google button styled
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: auth.signInWithGoogle,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(FontAwesomeIcons.google, color: Color(0xFF4285F4)),
                                  SizedBox(width: 8),
                                  Text('Continue with Google'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: InkWell(
                                onTap: () => setState(() { _landing = true; }),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8), // ensures slight bottom padding without large gap
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


