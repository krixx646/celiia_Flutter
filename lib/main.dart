import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/env.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initError;
  try {
    await FirebaseService.initialize();
    await SupabaseService.initialize();
  } catch (e) {
    initError = e;
  }
  runApp(CeliaRoot(initError: initError));
}

class CeliaRoot extends StatelessWidget {
  final Object? initError;
  const CeliaRoot({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _InitErrorScreen(error: initError.toString()),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
      ],
      child: const CeliaApp(),
    );
  }
}

class CeliaApp extends StatelessWidget {
  const CeliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final lightScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00),
          surface: ThemeProvider.lightSurface,
        );
        final darkScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6F00),
          brightness: Brightness.dark,
          surface: ThemeProvider.darkSurface,
        );

        final baseLight = ThemeData.from(
          colorScheme: lightScheme,
          useMaterial3: true,
        );
        final baseDark = ThemeData.from(
          colorScheme: darkScheme,
          useMaterial3: true,
        );

        return MaterialApp(
          title: 'Celia Integral Coach',
          themeMode: themeProvider.themeMode,
          theme: baseLight.copyWith(
            scaffoldBackgroundColor: ThemeProvider.lightBackground,
            textTheme: baseLight.textTheme.apply(fontFamily: 'Urbanist'),
          ),
          darkTheme: baseDark.copyWith(
            scaffoldBackgroundColor: ThemeProvider.darkBackground,
            textTheme: baseDark.textTheme.apply(fontFamily: 'Urbanist'),
        ),
        home: const AppNavigator(),
        debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final uiState = authProvider.uiState;
        if (!uiState.isAuthenticated) {
          return const AuthScreen();
        } else if (!uiState.isEmailVerified) {
          return const EmailVerificationScreen();
        } else {
          return const MainScreen();
        }
      },
    );
  }
}

class _InitErrorScreen extends StatelessWidget {
  final String error;
  const _InitErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'App config missing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This build is missing required runtime values (Supabase/Backend). '
                'Add them using --dart-define and relaunch.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Required (mobile):\n'
                '- SUPABASE_URL\n'
                '- SUPABASE_ANON_KEY\n'
                '\nOptional (for AI routine generation):\n'
                '- CELIA_BACKEND_BASE_URL (your Vercel/Next.js base URL)\n',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Android Studio:\n'
                'Run → Edit Configurations… → Additional run args:\n'
                '--dart-define=SUPABASE_URL=... '
                '--dart-define=SUPABASE_ANON_KEY=... '
                '--dart-define=CELIA_BACKEND_BASE_URL=...\n',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'SUPABASE_URL: ${Env.supabaseUrl.isEmpty ? '(empty)' : Env.supabaseUrl}\n'
                'SUPABASE_ANON_KEY: ${Env.supabaseAnonKey.isEmpty ? '(empty)' : '(set)'}\n'
                'CELIA_BACKEND_BASE_URL: ${Env.celiaBackendBaseUrl.isEmpty ? '(empty)' : Env.celiaBackendBaseUrl}',
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
