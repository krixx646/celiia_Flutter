import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Canonical intolerance values. Stored as slugs rather than the translated
/// label so the backend and the agent read the same word in every language.
const String kIntoleranceGluten = 'gluten';
const String kIntoleranceLactose = 'lactose';
const String kIntoleranceFructose = 'fructose';

/// Step 4 — diet pattern, intolerances, allergies, and who plans the meals.
///
/// The eating-disorder question is asked because the answer changes what the
/// app is allowed to recommend, not for reporting: see
/// [UserProfile.calorieMultiplier].
class NutritionStep extends StatefulWidget {
  const NutritionStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  static String? validate(UserProfile draft, AppLocalizations l10n) {
    if (draft.dietPattern == null) return l10n.obAnswerRequired;
    if (draft.nutritionMode == null) return l10n.obAnswerRequired;
    if (draft.disorderedEatingHistory == null) return l10n.obAnswerRequired;
    return null;
  }

  @override
  State<NutritionStep> createState() => _NutritionStepState();
}

class _NutritionStepState extends State<NutritionStep> {
  late final _water = TextEditingController(
    text: widget.draft.dailyWaterMl?.toString() ?? '',
  );

  @override
  void dispose() {
    _water.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSection(
          theme: theme,
          label: l10n.obDietPattern,
          child: ObSingleChoice<DietPattern>(
            theme: theme,
            selected: draft.dietPattern,
            options: [
              ObOption(DietPattern.omnivore, l10n.obDietOmnivore),
              ObOption(DietPattern.vegetarian, l10n.obDietVegetarian),
              ObOption(DietPattern.vegan, l10n.obDietVegan),
              ObOption(DietPattern.pescatarian, l10n.obDietPescatarian),
            ],
            onSelected: (pattern) =>
                widget.onChanged(draft.copyWith(dietPattern: pattern)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obIntolerances,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: ObMultiChoice<String>(
            theme: theme,
            selected: draft.dietaryConditions,
            options: [
              ObOption(kIntoleranceGluten, l10n.obIntoleranceGluten),
              ObOption(kIntoleranceLactose, l10n.obIntoleranceLactose),
              ObOption(kIntoleranceFructose, l10n.obIntoleranceFructose),
            ],
            onChanged: (values) =>
                widget.onChanged(draft.copyWith(dietaryConditions: values)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obAllergiesLabel,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: ObFreeTextList(
            theme: theme,
            values: draft.foodAllergies,
            hint: l10n.obAddHint,
            onChanged: (values) =>
                widget.onChanged(draft.copyWith(foodAllergies: values)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obEatingDisorderQuestion,
          explainer: l10n.obEatingDisorderWhy,
          child: ObSingleChoice<bool>(
            theme: theme,
            selected: draft.disorderedEatingHistory,
            options: [ObOption(true, l10n.obYes), ObOption(false, l10n.obNo)],
            onSelected: (answer) => widget.onChanged(
              draft.copyWith(disorderedEatingHistory: answer),
            ),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obNutritionMode,
          child: ObSingleChoice<PlanningMode>(
            theme: theme,
            selected: draft.nutritionMode,
            options: [
              ObOption(PlanningMode.automatic, l10n.obModeAutomatic),
              ObOption(PlanningMode.manual, l10n.obModeManual),
            ],
            onSelected: (mode) =>
                widget.onChanged(draft.copyWith(nutritionMode: mode)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obWaterTarget,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: ObTextField(
            theme: theme,
            controller: _water,
            label: l10n.obWaterTarget,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: (value) => widget.onChanged(
              draft.copyWith(dailyWaterMl: int.tryParse(value.trim())),
            ),
          ),
        ),
      ],
    );
  }
}
