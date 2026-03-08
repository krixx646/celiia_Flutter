import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Object? fatalInitError;
  try {
    await FirebaseService.initialize();
  } catch (e, st) {
    debugPrint('Firebase init failed: $e');
    debugPrint('$st');
    fatalInitError = e;
  }

  // Supabase powers routines/library, but app can still boot without it.
  // Fail softly here and surface friendly errors where those features are used.
  try {
    await SupabaseService.initialize();
  } catch (e, st) {
    debugPrint('Supabase init failed (non-fatal): $e');
    debugPrint('$st');
  }

  runApp(CeliaRoot(initError: fatalInitError));
}

class CeliaRoot extends StatelessWidget {
  final Object? initError;
  const CeliaRoot({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _InitErrorScreen(),
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
  const _InitErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0B0B),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Icon(
                Icons.error_outline,
                color: Colors.orangeAccent,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Unable to start the app',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Please close and reopen the app. '
                'If this continues, contact support.',
                style: TextStyle(color: Colors.white70, height: 1.4),
                textAlign: TextAlign.center,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
