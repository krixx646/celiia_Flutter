import 'package:celia_flutter/services/supabase_service.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('client getter throws before initialize', () {
    expect(() => SupabaseService.instance.client, throwsException);
  });

  test('initialize throws when env not provided (test environment)', () async {
    expect(() => SupabaseService.initialize(), throwsException);
  });

  test('generateRoutineOnServer throws when backend base url missing', () async {
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
  });

  test('getVideoByAnyId returns null for empty input', () async {
    final s = SupabaseService.instance;
    final v = await s.getVideoByAnyId('   ');
    expect(v, isNull);
  });
}

