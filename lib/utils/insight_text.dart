import '../l10n/app_localizations.dart';
import '../services/nutrition_insights_service.dart';

/// Puts the words on a [NutritionInsight].
///
/// The service works out what is worth saying and keeps the numbers; this
/// turns that into a sentence in the language the app is currently showing.
/// Keeping the two apart is what lets an insight computed once still read
/// correctly after the user switches language.
extension NutritionInsightText on NutritionInsight {
  String title(AppLocalizations l10n) {
    switch (kind) {
      case NutritionInsightKind.startFueling:
        return l10n.insightStartFuelingTitle;
      case NutritionInsightKind.aboveTarget:
        return l10n.insightAboveTargetTitle;
      case NutritionInsightKind.lowProtein:
        return l10n.insightLowProteinTitle;
      case NutritionInsightKind.almostThere:
        return l10n.insightAlmostThereTitle;
      case NutritionInsightKind.onTrack:
        return l10n.insightOnTrackTitle;
      case NutritionInsightKind.weeklyRhythm:
        return l10n.insightWeeklyRhythmTitle;
      case NutritionInsightKind.weeklyTrend:
        return l10n.insightWeeklyTrendTitle;
    }
  }

  String message(AppLocalizations l10n) {
    switch (kind) {
      case NutritionInsightKind.startFueling:
        return l10n.insightStartFuelingBody;
      case NutritionInsightKind.aboveTarget:
        return l10n.insightAboveTargetBody(calories);
      case NutritionInsightKind.lowProtein:
        return l10n.insightLowProteinBody(grams);
      case NutritionInsightKind.almostThere:
        return l10n.insightAlmostThereBody(calories);
      case NutritionInsightKind.onTrack:
        return l10n.insightOnTrackBody(calories, grams);
      case NutritionInsightKind.weeklyRhythm:
        return l10n.insightWeeklyRhythmBody;
      case NutritionInsightKind.weeklyTrend:
        return l10n.insightWeeklyTrendBody(
          loggedDays,
          averageCalories,
          _trendDirection(l10n),
        );
    }
  }

  String _trendDirection(AppLocalizations l10n) {
    if (deltaCalories.abs() < 80) return l10n.insightTrendOnTarget;
    if (deltaCalories > 0) return l10n.insightTrendAbove(deltaCalories);
    return l10n.insightTrendBelow(-deltaCalories);
  }
}
