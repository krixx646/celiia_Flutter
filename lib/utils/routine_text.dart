import '../l10n/app_localizations.dart';
import '../models/routine.dart';

/// Localized duration for a routine length in minutes.
String localizedRoutineDuration(AppLocalizations l10n, int durationMinutes) {
  if (durationMinutes < 60) {
    return l10n.routineDurationMinutes(durationMinutes);
  }
  final hours = durationMinutes ~/ 60;
  final mins = durationMinutes % 60;
  return mins > 0
      ? l10n.routineDurationHoursMinutes(hours, mins)
      : l10n.routineDurationHours(hours);
}

/// Localized difficulty label for UI.
String localizedRoutineDifficulty(
  AppLocalizations l10n,
  RoutineDifficulty difficulty,
) {
  switch (difficulty) {
    case RoutineDifficulty.easy:
      return l10n.difficultyEasy;
    case RoutineDifficulty.medium:
      return l10n.difficultyMedium;
    case RoutineDifficulty.hard:
      return l10n.difficultyHard;
  }
}

/// Localized category label for UI.
String localizedRoutineCategory(
  AppLocalizations l10n,
  RoutineCategory category,
) {
  switch (category) {
    case RoutineCategory.strength:
      return l10n.categoryStrength;
    case RoutineCategory.cardio:
      return l10n.categoryCardio;
    case RoutineCategory.flexibility:
      return l10n.categoryFlexibility;
    case RoutineCategory.mindfulness:
      return l10n.categoryMindfulness;
    case RoutineCategory.dance:
      return l10n.categoryDance;
    case RoutineCategory.hiit:
      return l10n.categoryHiit;
    case RoutineCategory.yoga:
      return l10n.categoryYoga;
    case RoutineCategory.custom:
      return l10n.categoryCustom;
  }
}
