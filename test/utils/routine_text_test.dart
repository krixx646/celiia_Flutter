import 'package:celia_flutter/l10n/app_localizations.dart';
import 'package:celia_flutter/models/routine.dart';
import 'package:celia_flutter/utils/routine_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localizedRoutineDuration formats minutes and hours', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final es = await AppLocalizations.delegate.load(const Locale('es'));

    expect(localizedRoutineDuration(en, 20), '20 min');
    expect(localizedRoutineDuration(en, 60), '1h');
    expect(localizedRoutineDuration(en, 75), '1h 15m');

    expect(localizedRoutineDuration(es, 20), '20 min');
    expect(localizedRoutineDuration(es, 60), '1 h');
    expect(localizedRoutineDuration(es, 75), '1 h 15 min');
  });

  test('localizedRoutineDifficulty switches exhaustively', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final es = await AppLocalizations.delegate.load(const Locale('es'));

    expect(
      localizedRoutineDifficulty(en, RoutineDifficulty.easy),
      'Easy',
    );
    expect(
      localizedRoutineDifficulty(en, RoutineDifficulty.medium),
      'Medium',
    );
    expect(
      localizedRoutineDifficulty(en, RoutineDifficulty.hard),
      'Hard',
    );

    expect(
      localizedRoutineDifficulty(es, RoutineDifficulty.easy),
      'Fácil',
    );
    expect(
      localizedRoutineDifficulty(es, RoutineDifficulty.medium),
      'Media',
    );
    expect(
      localizedRoutineDifficulty(es, RoutineDifficulty.hard),
      'Difícil',
    );
  });

  test('localizedRoutineCategory covers all categories', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final es = await AppLocalizations.delegate.load(const Locale('es'));

    expect(
      localizedRoutineCategory(en, RoutineCategory.strength),
      'Strength',
    );
    expect(
      localizedRoutineCategory(es, RoutineCategory.strength),
      'Fuerza',
    );
    expect(localizedRoutineCategory(en, RoutineCategory.hiit), 'HIIT');
    expect(
      localizedRoutineCategory(es, RoutineCategory.custom),
      'Personalizada',
    );
  });
}
