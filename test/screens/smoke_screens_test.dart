import 'package:celia_flutter/l10n/app_localizations.dart';
import 'package:celia_flutter/providers/auth_provider.dart';
import 'package:celia_flutter/providers/chat_provider.dart';
import 'package:celia_flutter/providers/navigation_provider.dart';
import 'package:celia_flutter/providers/nutrition_tracker_provider.dart';
import 'package:celia_flutter/services/calorie_scanner_service.dart';
import 'package:celia_flutter/providers/routine_provider.dart';
import 'package:celia_flutter/providers/theme_provider.dart';
import 'package:celia_flutter/providers/nutrition_profile_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:celia_flutter/repositories/nutrition_profile_repository.dart';
import 'package:celia_flutter/services/celia_chat_service.dart';
import 'package:celia_flutter/screens/auth_screen.dart';
import 'package:celia_flutter/screens/email_verification_screen.dart';
import 'package:celia_flutter/screens/forgot_password_screen.dart';
import 'package:celia_flutter/screens/home/home_screen.dart';
import 'package:celia_flutter/screens/library/library_screen.dart';
import 'package:celia_flutter/screens/chat_screen.dart';
import 'package:celia_flutter/screens/profile/profile_screen.dart';
import 'package:celia_flutter/screens/profile/edit_profile_screen.dart';
import 'package:celia_flutter/screens/profile/saved_routines_screen.dart';
import 'package:celia_flutter/screens/routines/routine_detail_screen.dart';
import 'package:celia_flutter/screens/routines/routine_player_screen.dart';
import 'package:celia_flutter/screens/routines/video_player_screen.dart';
import 'package:celia_flutter/widgets/generate_routine_sheet.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class _FakeAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    // 1x1 transparent PNG
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMB/akG5S0AAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('AssetManifest.bin')) {
      final data = const StandardMessageCodec().encodeMessage(
        <String, dynamic>{},
      );
      return data ?? ByteData(0);
    }
    if (key.endsWith('AssetManifest.json')) {
      final bytes = utf8.encode('{}');
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    // Default: return a valid tiny image so Image.asset doesn't throw.
    return ByteData.view(_transparentPng.buffer);
  }
}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseService extends Mock implements SupabaseService {}

class MockCeliaChatService extends Mock implements CeliaChatService {}

class MockNutritionProfileRepository extends Mock
    implements NutritionProfileRepository {}

/// The screens only build the chat UI; nothing sends a turn, so the service just
/// has to exist.
ChatProvider _chatProvider() {
  final service = MockCeliaChatService();
  when(() => service.listConversations()).thenAnswer((_) async => []);
  return ChatProvider(chatService: service);
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockImagePicker extends Mock implements ImagePicker {}

Widget _wrap(
  Widget child, {
  required AuthProvider auth,
  required RoutineProvider routines,
  required ChatProvider chat,
}) {
  return DefaultAssetBundle(
    bundle: _FakeAssetBundle(),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) => NutritionTrackerProvider(
            mealService: CalorieScannerService(
              firebaseAuth: MockFirebaseAuth(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NutritionProfileProvider(
            repository: MockNutritionProfileRepository(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<RoutineProvider>.value(value: routines),
        ChangeNotifierProvider<ChatProvider>.value(value: chat),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuthScreen builds', (tester) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final chat = _chatProvider();

    await tester.pumpWidget(
      _wrap(const AuthScreen(), auth: auth, routines: routines, chat: chat),
    );
    await tester.pump();
  });

  testWidgets('Home/Library/Profile/Chat screens build', (tester) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    when(() => supa.getUserRoutines(any())).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final chat = _chatProvider();

    for (final screen in const [
      HomeScreen(),
      LibraryScreen(),
      ProfileScreen(),
      ChatScreen(),
    ]) {
      await tester.pumpWidget(
        _wrap(screen, auth: auth, routines: routines, chat: chat),
      );
      await tester.pump();
    }
  });

  testWidgets('GenerateRoutineSheet builds', (tester) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final chat = _chatProvider();
    await tester.pumpWidget(
      _wrap(
        const Scaffold(body: GenerateRoutineSheet()),
        auth: auth,
        routines: routines,
        chat: chat,
      ),
    );
    await tester.pump();
  });

  testWidgets('SavedRoutinesScreen builds (empty)', (tester) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    when(() => supa.getUserRoutines(any())).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final chat = _chatProvider();
    await tester.pumpWidget(
      _wrap(
        const SavedRoutinesScreen(),
        auth: auth,
        routines: routines,
        chat: chat,
      ),
    );
    await tester.pump();
  });

  testWidgets('EmailVerificationScreen & ForgotPasswordScreen build', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final chat = _chatProvider();

    for (final screen in const [
      EmailVerificationScreen(),
      ForgotPasswordScreen(),
    ]) {
      await tester.pumpWidget(
        _wrap(screen, auth: auth, routines: routines, chat: chat),
      );
      await tester.pump();
    }
  });

  testWidgets(
    'RoutineDetailScreen / RoutinePlayerScreen / VideoPlayerScreen build',
    (tester) async {
      final authRepo = MockAuthRepository();
      when(() => authRepo.currentUser).thenReturn(null);
      final auth = AuthProvider(authRepository: authRepo);

      final supa = MockSupabaseService();
      when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
      when(
        () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
      ).thenAnswer((_) async => []);
      when(() => supa.getUserRoutines(any())).thenAnswer((_) async => []);
      final routines = RoutineProvider(
        supabase: supa,
        currentUserId: () => null,
      );

      final chat = _chatProvider();

      final routine = Routine(
        id: 'r',
        title: 'T',
        durationMinutes: 5,
        difficulty: RoutineDifficulty.easy,
        category: RoutineCategory.custom,
        steps: const [
          RoutineStep(
            id: 's1',
            title: 'Step 1',
            durationSeconds: 10,
            orderIndex: 0,
            videoId: null,
            thumbnailUrl: null,
          ),
        ],
        createdBy: 'u',
        createdAt: DateTime(2026, 1, 1),
        isPublished: false,
      );

      await tester.pumpWidget(
        _wrap(
          RoutineDetailScreen(routine: routine),
          auth: auth,
          routines: routines,
          chat: chat,
        ),
      );
      await tester.pump(const Duration(milliseconds: 10));

      await tester.pumpWidget(
        _wrap(
          RoutinePlayerScreen(
            routine: routine,
            initTimeout: const Duration(milliseconds: 1),
          ),
          auth: auth,
          routines: routines,
          chat: chat,
        ),
      );
      await tester.pump(const Duration(milliseconds: 10));

      await tester.pumpWidget(
        _wrap(
          const VideoPlayerScreen(
            videoUrl: 'https://example.invalid/video.m3u8',
            title: 'V',
            initTimeout: Duration(milliseconds: 1),
          ),
          auth: auth,
          routines: routines,
          chat: chat,
        ),
      );
      await tester.pump(const Duration(milliseconds: 10));
    },
  );

  testWidgets('EditProfileScreen builds', (tester) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final chat = _chatProvider();

    final firebaseAuth = MockFirebaseAuth();
    when(() => firebaseAuth.currentUser).thenReturn(null);

    final storage = MockFirebaseStorage();
    final picker = MockImagePicker();

    await tester.pumpWidget(
      _wrap(
        EditProfileScreen(auth: firebaseAuth, storage: storage, picker: picker),
        auth: auth,
        routines: routines,
        chat: chat,
      ),
    );
    await tester.pump();
  });

  testWidgets('the three profile stats line up with each other', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);

    final supa = MockSupabaseService();
    when(() => supa.getPublishedRoutines()).thenAnswer((_) async => []);
    when(
      () => supa.getUserCreatedRoutines(userId: any(named: 'userId')),
    ).thenAnswer((_) async => []);
    when(() => supa.getUserRoutines(any())).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    // A phone's width, not the 800pt test default: the row only has room to go
    // wrong at the size it is actually used at.
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        const ProfileScreen(),
        auth: auth,
        routines: routines,
        chat: _chatProvider(),
      ),
    );
    await tester.pump();

    // 'WORKOUTS' used to wrap onto a second line while its neighbours stayed on
    // one, which is what threw the row out of line. A single line is under 20pt
    // tall at this size; a wrapped one is about twice that.
    final saved = tester.getRect(find.text('SAVED'));
    final streak = tester.getRect(find.text('STREAK'));
    final workouts = tester.getRect(find.text('WORKOUTS'));

    for (final label in [saved, streak, workouts]) {
      expect(label.height, lessThan(20));
      expect(label.top, saved.top);
    }
    expect(tester.takeException(), isNull);
  });
}
