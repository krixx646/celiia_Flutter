import 'dart:async';

import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/providers/auth_provider.dart';
import 'package:celia_flutter/providers/routine_provider.dart';
import 'package:celia_flutter/providers/theme_provider.dart';
import 'package:celia_flutter/repositories/auth_repository.dart';
import 'package:celia_flutter/screens/profile/saved_routines_screen.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

class MockSupabaseService extends Mock implements SupabaseService {}

Routine routine({required String id, required String title}) {
  return Routine(
    id: id,
    title: title,
    durationMinutes: 5,
    difficulty: RoutineDifficulty.easy,
    category: RoutineCategory.custom,
    steps: const [],
    createdBy: 'u',
    createdAt: DateTime(2026, 1, 1),
    isPublished: false,
  );
}

Widget _wrap({
  required AuthProvider auth,
  required RoutineProvider routines,
  required ThemeProvider theme,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<RoutineProvider>.value(value: routines),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(RoutineCategory.custom);
  });

  testWidgets('shows empty states and favorites-only empty state', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    when(() => authRepo.currentUser).thenReturn(null);
    final auth = AuthProvider(authRepository: authRepo);
    addTearDown(auth.dispose);

    final supa = MockSupabaseService();
    when(() => supa.getUserRoutines(any())).thenAnswer((_) async => []);
    final routines = RoutineProvider(supabase: supa, currentUserId: () => null);

    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: const SavedRoutinesScreen(),
      ),
    );
    await tester.pump();
    expect(find.text('No saved routines yet.'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: const SavedRoutinesScreen(showFavoritesOnly: true),
      ),
    );
    await tester.pump();
    expect(find.text('No favorite routines yet.'), findsOneWidget);
  });

  testWidgets('shows loading indicator while user routines are loading', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    final user = MockUser();
    when(() => user.uid).thenReturn('u');
    when(() => user.emailVerified).thenReturn(true);
    when(() => authRepo.currentUser).thenReturn(user);
    final auth = AuthProvider(authRepository: authRepo);
    addTearDown(auth.dispose);

    final completer = Completer<List<UserRoutine>>();
    final supa = MockSupabaseService();
    when(() => supa.getUserRoutines('u')).thenAnswer((_) => completer.future);
    when(() => supa.getRoutine(any())).thenAnswer((_) async => null);

    final routines = RoutineProvider(supabase: supa, currentUserId: () => 'u');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: SavedRoutinesScreen(supabase: supa),
      ),
    );

    // post-frame triggers loadUserRoutines and sets loading=true
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(<UserRoutine>[]);
    await tester.pump();
    await tester.pump();
    expect(find.text('No saved routines yet.'), findsOneWidget);
  });

  testWidgets(
    'loads user routines post-frame, shows list, can favorite and refresh',
    (tester) async {
      final authRepo = MockAuthRepository();
      final user = MockUser();
      when(() => user.uid).thenReturn('u');
      when(() => user.emailVerified).thenReturn(true);
      when(() => authRepo.currentUser).thenReturn(user);
      final auth = AuthProvider(authRepository: authRepo);
      addTearDown(auth.dispose);

      final supa = MockSupabaseService();
      when(() => supa.getUserRoutines('u')).thenAnswer(
        (_) async => [
          UserRoutine(
            id: 'ur1',
            userId: 'u',
            routineId: 'r1',
            savedAt: DateTime(2026, 1, 1),
            lastPlayedAt: null,
            timesCompleted: 2,
            isFavorite: false,
          ),
        ],
      );
      when(() => supa.toggleFavorite('ur1', true)).thenAnswer((_) async {});

      // For title resolution
      when(
        () => supa.getRoutine('r1'),
      ).thenAnswer((_) async => routine(id: 'r1', title: 'My Routine'));

      final routines = RoutineProvider(
        supabase: supa,
        currentUserId: () => 'u',
      );
      final theme = ThemeProvider();

      await tester.pumpWidget(
        _wrap(
          auth: auth,
          routines: routines,
          theme: theme,
          child: SavedRoutinesScreen(supabase: supa),
        ),
      );

      // allow post-frame callback to run + provider to load
      await tester.pump();
      await tester.pump();

      expect(find.text('Completed 2x'), findsOneWidget);
      expect(find.text('My Routine'), findsOneWidget);

      // Toggle favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      verify(() => supa.toggleFavorite('ur1', true)).called(1);

      // Call RefreshIndicator callback directly (more deterministic than drag physics)
      final refresh = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await refresh.onRefresh();
      await tester.pump();
      verify(() => supa.getUserRoutines('u')).called(2);
    },
  );

  testWidgets('renders list separators when multiple saved routines exist', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    final user = MockUser();
    when(() => user.uid).thenReturn('u');
    when(() => user.emailVerified).thenReturn(true);
    when(() => authRepo.currentUser).thenReturn(user);
    final auth = AuthProvider(authRepository: authRepo);
    addTearDown(auth.dispose);

    final supa = MockSupabaseService();
    when(() => supa.getUserRoutines('u')).thenAnswer(
      (_) async => [
        UserRoutine(
          id: 'ur1',
          userId: 'u',
          routineId: 'r1',
          savedAt: DateTime(2026, 1, 1),
          lastPlayedAt: null,
          timesCompleted: 0,
          isFavorite: false,
        ),
        UserRoutine(
          id: 'ur2',
          userId: 'u',
          routineId: 'r2',
          savedAt: DateTime(2026, 1, 1),
          lastPlayedAt: null,
          timesCompleted: 0,
          isFavorite: false,
        ),
      ],
    );
    when(() => supa.getRoutine(any())).thenAnswer((inv) async {
      final id = inv.positionalArguments.first as String;
      return routine(id: id, title: id.toUpperCase());
    });

    final routines = RoutineProvider(supabase: supa, currentUserId: () => 'u');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: SavedRoutinesScreen(supabase: supa),
      ),
    );
    await tester.pump();
    await tester.pump();

    // ListView.separated should render at least one Divider.
    expect(find.byType(Divider), findsWidgets);
  });

  testWidgets('tapping a routine shows snackbar when routine not found', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    final user = MockUser();
    when(() => user.uid).thenReturn('u');
    when(() => user.emailVerified).thenReturn(true);
    when(() => authRepo.currentUser).thenReturn(user);
    final auth = AuthProvider(authRepository: authRepo);
    addTearDown(auth.dispose);

    final supa = MockSupabaseService();
    when(() => supa.getUserRoutines('u')).thenAnswer(
      (_) async => [
        UserRoutine(
          id: 'ur1',
          userId: 'u',
          routineId: 'r1',
          savedAt: DateTime(2026, 1, 1),
          lastPlayedAt: null,
          timesCompleted: 0,
          isFavorite: false,
        ),
      ],
    );
    when(() => supa.getRoutine('r1')).thenAnswer((_) async => null);

    final routines = RoutineProvider(supabase: supa, currentUserId: () => 'u');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: SavedRoutinesScreen(supabase: supa),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(ListTile));
    await tester.pump();
    expect(find.text('Routine not found'), findsOneWidget);
  });

  testWidgets('tapping a routine navigates via injected routineDetailBuilder', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    final user = MockUser();
    when(() => user.uid).thenReturn('u');
    when(() => user.emailVerified).thenReturn(true);
    when(() => authRepo.currentUser).thenReturn(user);
    final auth = AuthProvider(authRepository: authRepo);
    addTearDown(auth.dispose);

    final supa = MockSupabaseService();
    when(() => supa.getUserRoutines('u')).thenAnswer(
      (_) async => [
        UserRoutine(
          id: 'ur1',
          userId: 'u',
          routineId: 'r1',
          savedAt: DateTime(2026, 1, 1),
          lastPlayedAt: null,
          timesCompleted: 0,
          isFavorite: false,
        ),
      ],
    );
    when(
      () => supa.getRoutine('r1'),
    ).thenAnswer((_) async => routine(id: 'r1', title: 'My Routine'));

    final routines = RoutineProvider(supabase: supa, currentUserId: () => 'u');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: SavedRoutinesScreen(
          supabase: supa,
          routineDetailBuilder: (_) =>
              const Scaffold(body: Center(child: Text('DETAIL'))),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.text('DETAIL'), findsOneWidget);
  });

  testWidgets('title cache prevents repeated supabase.getRoutine calls', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    final user = MockUser();
    when(() => user.uid).thenReturn('u');
    when(() => user.emailVerified).thenReturn(true);
    when(() => authRepo.currentUser).thenReturn(user);
    final auth = AuthProvider(authRepository: authRepo);
    addTearDown(auth.dispose);

    final supa = MockSupabaseService();
    when(() => supa.getUserRoutines('u')).thenAnswer(
      (_) async => [
        UserRoutine(
          id: 'ur1',
          userId: 'u',
          routineId: 'r1',
          savedAt: DateTime(2026, 1, 1),
          lastPlayedAt: null,
          timesCompleted: 0,
          isFavorite: false,
        ),
      ],
    );
    when(
      () => supa.getRoutine('r1'),
    ).thenAnswer((_) async => routine(id: 'r1', title: 'My Routine'));

    final routines = RoutineProvider(supabase: supa, currentUserId: () => 'u');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: SavedRoutinesScreen(supabase: supa),
      ),
    );
    await tester.pump();
    await tester.pump();

    // rebuild to re-run FutureBuilder; should use cache
    await tester.pumpWidget(
      _wrap(
        auth: auth,
        routines: routines,
        theme: theme,
        child: SavedRoutinesScreen(supabase: supa),
      ),
    );
    await tester.pump();

    verify(() => supa.getRoutine('r1')).called(1);
  });
}
