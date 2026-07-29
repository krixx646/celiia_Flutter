import 'package:celia_flutter/config/env.dart';
import 'package:celia_flutter/services/supabase_service.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Env now ships real Supabase defaults, so the credentials have to be
  // blanked explicitly for these "not configured" paths to be reachable.
  setUp(() {
    SupabaseService.supabaseUrl = () => '';
    SupabaseService.supabaseAnonKey = () => '';
    SupabaseService.resetForTesting();
  });

  tearDown(() {
    SupabaseService.supabaseUrl = () => Env.supabaseUrl;
    SupabaseService.supabaseAnonKey = () => Env.supabaseAnonKey;
    SupabaseService.resetForTesting();
  });

  test('client getter throws before initialize', () {
    expect(() => SupabaseService.instance.client, throwsException);
  });

  test('initialize throws when credentials are not configured', () async {
    expect(() => SupabaseService.initialize(), throwsException);
  });

  test(
    'generateRoutineOnServer throws when backend base url missing',
    () async {
      final s = SupabaseService.instance;
      expect(
        () => s.generateRoutineOnServer(
          request: 'x',
          durationMinutes: 10,
          difficulty: RoutineDifficulty.easy,
          equipment: const ['None'],
        ),
        throwsException,
      );
    },
  );

  test('getVideoByAnyId returns null for empty input', () async {
    final s = SupabaseService.instance;
    final v = await s.getVideoByAnyId('   ');
    expect(v, isNull);
  });
}
