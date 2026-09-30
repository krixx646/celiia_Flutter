import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/nutrition_profile.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/nutrition_sources_citation.dart';
import '../widgets/onboarding_widgets.dart';
import 'coaching_step.dart' show kMoodGreat, kMoodLow, kMoodOkay, kMoodStressed, kMoodTired;

/// Step 9 — what Celia now knows, and the first thing to do about it.
///
/// The recommendation is derived on the device from the answers the user just
/// gave. It is deliberately not an LLM call: the last screen of onboarding
/// should not be able to fail, hang, or cost a token, and everything it says
/// is already decided by the profile.
class SummaryStep extends StatelessWidget {
  const SummaryStep({
    super.key,
    required this.theme,
    required this.draft,
  });

  final ThemeProvider theme;
  final UserProfile draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final targets = draft.computeTargets();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.obSummaryBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 22),
        if (targets != null) _targetsCard(l10n, targets),
        const SizedBox(height: 16),
        _factsCard(l10n),
        const SizedBox(height: 16),
        ObCard(
          theme: theme,
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.obFirstRecommendation,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ..._recommendations(l10n, targets).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: theme.accentOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          line,
                          style: TextStyle(
                            color: theme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.obSummaryEditLater,
          style: TextStyle(color: theme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _targetsCard(AppLocalizations l10n, NutritionProfile targets) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFF171B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingDailyTargets,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.nutritionKcal(targets.dailyCalories.round()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.onboardingMacroTargets(
              targets.dailyProteinGrams.round(),
              targets.dailyCarbsGrams.round(),
              targets.dailyFatGrams.round(),
            ),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
          ),
          const SizedBox(height: 14),
          NutritionSourcesCitation(theme: theme, compact: true, onDark: true),
        ],
      ),
    );
  }

  Widget _factsCard(AppLocalizations l10n) {
    final rows = <(String, String)>[
      (l10n.obSummaryGoal, _goalLabel(l10n)),
      (l10n.obSummaryNutrition, _nutritionLabel(l10n)),
      (l10n.obSummaryTraining, _trainingLabel(l10n)),
      (l10n.obSummaryCoaching, _coachingLabel(l10n)),
    ].where((row) => row.$2.isNotEmpty).toList();

    return ObCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1.toUpperCase(),
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.$2,
                    style: TextStyle(color: theme.textPrimary, height: 1.35),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _goalLabel(AppLocalizations l10n) {
    return switch (draft.primaryGoal) {
      PrimaryGoal.loseWeight => l10n.obGoalLoseWeight,
      PrimaryGoal.gainWeight => l10n.obGoalGainWeight,
      PrimaryGoal.buildMuscle => l10n.obGoalBuildMuscle,
      null => '',
    };
  }

  String _nutritionLabel(AppLocalizations l10n) {
    final parts = <String>[
      switch (draft.dietPattern) {
        DietPattern.omnivore => l10n.obDietOmnivore,
        DietPattern.vegetarian => l10n.obDietVegetarian,
        DietPattern.vegan => l10n.obDietVegan,
        DietPattern.pescatarian => l10n.obDietPescatarian,
        null => '',
      },
      switch (draft.nutritionMode) {
        PlanningMode.automatic => l10n.obModeAutomatic,
        PlanningMode.manual => l10n.obModeManual,
        null => '',
      },
      // Allergies are the part of this the user most needs to see echoed back,
      // since a missed one means a meal suggestion they cannot eat.
      ...draft.foodAllergies,
    ];
    return parts.where((part) => part.isNotEmpty).join(' · ');
  }

  String _trainingLabel(AppLocalizations l10n) {
    final parts = <String>[
      switch (draft.trainingLocation) {
        TrainingLocation.home => l10n.obLocationHome,
        TrainingLocation.gym => l10n.obLocationGym,
        TrainingLocation.both => l10n.obLocationBoth,
        null => '',
      },
      switch (draft.trainingIntensity) {
        TrainingIntensity.easy => l10n.obIntensityEasy,
        TrainingIntensity.moderate => l10n.obIntensityModerate,
        TrainingIntensity.intense => l10n.obIntensityIntense,
        null => '',
      },
      if (draft.minutesPerDay != null) l10n.obMinutesValue(draft.minutesPerDay!),
      if (draft.preferredTrainingTime != null) draft.preferredTrainingTime!,
    ];
    return parts.where((part) => part.isNotEmpty).join(' · ');
  }

  String _coachingLabel(AppLocalizations l10n) {
    final focus = draft.coachingFocus;
    if (focus != null && focus.isNotEmpty) return focus;
    return switch (draft.currentMood) {
      kMoodGreat => l10n.obMoodGreat,
      kMoodOkay => l10n.obMoodOkay,
      kMoodTired => l10n.obMoodTired,
      kMoodStressed => l10n.obMoodStressed,
      kMoodLow => l10n.obMoodLow,
      _ => '',
    };
  }

  /// Today's first step: one nutrition line, one training line, and a check-in
  /// when the mood answer suggests it is the more useful thing to ask for.
  List<String> _recommendations(
    AppLocalizations l10n,
    NutritionProfile? targets,
  ) {
    final lines = <String>[];
    if (targets != null) {
      lines.add(
        l10n.obRecoCalories(
          targets.dailyCalories.round(),
          targets.dailyProteinGrams.round(),
        ),
      );
    }
    final minutes = draft.minutesPerDay;
    if (minutes != null) lines.add(l10n.obRecoTraining(minutes));
    final water = draft.dailyWaterMl;
    if (water != null) lines.add(l10n.obRecoWater(water));
    if (draft.currentMood == kMoodStressed ||
        draft.currentMood == kMoodLow ||
        draft.currentMood == kMoodTired) {
      lines.add(l10n.obRecoCheckIn);
    }
    return lines;
  }
}
