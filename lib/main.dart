import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/avatar_mode_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/nutrition_profile_provider.dart';
import 'providers/nutrition_tracker_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/avatar/avatar_mode_shell.dart';
import 'screens/email_verification_screen.dart';
import 'screens/main_screen.dart';
import 'screens/name_setup_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/onboarding_service.dart';
import 'utils/responsive.dart';
import 'widgets/loading_indicator.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAppOrientations();
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _InitErrorScreen(),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..load()),
        ChangeNotifierProvider(create: (_) => AvatarModeProvider()..load()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProfileProvider()),
        ChangeNotifierProvider(create: (_) => NutritionTrackerProvider()),
      ],
      child: const CeliaApp(),
    );
  }
}

class CeliaApp extends StatelessWidget {
  const CeliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        localeProvider.publishEffectiveLocale(
          WidgetsBinding.instance.platformDispatcher.locales,
        );
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
          // Null means follow the device, which is what a fresh install does:
          // Flutter then resolves it against supportedLocales for us.
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: baseLight.copyWith(
            scaffoldBackgroundColor: ThemeProvider.lightBackground,
            textTheme: GoogleFonts.urbanistTextTheme(baseLight.textTheme),
          ),
          darkTheme: baseDark.copyWith(
            scaffoldBackgroundColor: ThemeProvider.darkBackground,
            textTheme: GoogleFonts.urbanistTextTheme(baseDark.textTheme),
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
        } else if (authProvider.needsDisplayName) {
          return const NameSetupScreen();
        } else {
          return const _AuthenticatedGate();
        }
      },
    );
  }
}

class _AuthenticatedGate extends StatefulWidget {
  const _AuthenticatedGate();

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    // Deferred: loadProfile notifies its listeners synchronously, which would
    // dirty an ancestor provider scope while this widget's tree is still being
    // built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resolveOnboarding();
    });
  }

  Future<void> _resolveOnboarding() async {
    final uid = context.read<AuthProvider>().uiState.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _onboardingComplete = true);
      return;
    }

    // Both providers are resolved before the first await: reading them off
    // `context` afterwards throws if the widget was disposed mid-load.
    final profileProvider = context.read<NutritionProfileProvider>();
    final trackerProvider = context.read<NutritionTrackerProvider>();
    await profileProvider.loadProfile();
    trackerProvider.syncProfile(profileProvider.profile);

    var complete = await OnboardingService.isComplete(uid);
    if (!complete && profileProvider.hasProfile) {
      await OnboardingService.markComplete(uid);
      complete = true;
    }

    if (mounted) setState(() => _onboardingComplete = complete);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return Scaffold(
        body: Center(
          child: LoadingIndicator(
            message: AppLocalizations.of(context).loadingPreparing,
          ),
        ),
      );
    }

    if (!_onboardingComplete!) {
      return OnboardingScreen(
        onComplete: () => setState(() => _onboardingComplete = true),
      );
    }

    return Consumer<AvatarModeProvider>(
      builder: (context, avatarMode, _) {
        if (!avatarMode.isLoaded) {
          return Scaffold(
            body: Center(
              child: LoadingIndicator(
                message: AppLocalizations.of(context).loadingPreparing,
              ),
            ),
          );
        }
        if (avatarMode.isEnabled) {
          return const AvatarModeShell();
        }
        return const MainScreen();
      },
    );
  }
}

class _InitErrorScreen extends StatelessWidget {
  const _InitErrorScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.error_outline,
                color: Colors.orangeAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.startupErrorTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.startupErrorBody,
                style: const TextStyle(color: Colors.white70, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
