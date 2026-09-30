import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/nutrition_profile.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Step 2 — sex, age, weight, height, and the basal metabolic rate they imply.
///
/// The BMR is shown as it is typed so the number the plan is built on is never
/// a surprise, and is written into the draft so the backend stores the same
/// figure the user saw.
class PhysicalStep extends StatefulWidget {
  const PhysicalStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  static String? validate(UserProfile draft, AppLocalizations l10n) {
    if (draft.sex == null) return l10n.obAnswerRequired;
    final age = draft.age ?? 0;
    if (age < 13 || age > 100) return l10n.onboardingInvalidAge;
    if ((draft.weightKg ?? 0) <= 0) return l10n.onboardingInvalidWeight;
    if ((draft.heightCm ?? 0) <= 0) return l10n.onboardingInvalidHeight;
    return null;
  }

  @override
  State<PhysicalStep> createState() => _PhysicalStepState();
}

class _PhysicalStepState extends State<PhysicalStep> {
  late final _weight = TextEditingController(
    text: _initial(widget.draft.weightKg),
  );
  late final _height = TextEditingController(
    text: _initial(widget.draft.heightCm),
  );
  late final _age = TextEditingController(
    text: widget.draft.age?.toString() ?? '',
  );

  static String _initial(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }

  void _publish() {
    final weight = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    final height = double.tryParse(_height.text.trim().replaceAll(',', '.'));
    final age = int.tryParse(_age.text.trim());

    var next = widget.draft.copyWith(
      weightKg: weight,
      heightCm: height,
      age: age,
    );
    // BMR needs all four answers, so it only lands once the step is filled in.
    if (next.hasPhysicalData) {
      next = next.copyWith(
        bmrKcal: NutritionProfile.basalMetabolicRate(
          weightKg: next.weightKg!,
          heightCm: next.heightCm!,
          age: next.age!,
          gender: next.sex!,
        ).roundToDouble(),
      );
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final bmr = widget.draft.bmrKcal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.obPhysicalBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 24),
        ObSection(
          theme: theme,
          label: l10n.onboardingGender,
          child: ObSingleChoice<NutritionGender>(
            theme: theme,
            selected: widget.draft.sex,
            options: [
              ObOption(NutritionGender.female, l10n.genderFemale),
              ObOption(NutritionGender.male, l10n.genderMale),
              ObOption(NutritionGender.other, l10n.genderOther),
            ],
            onSelected: (sex) {
              widget.onChanged(widget.draft.copyWith(sex: sex));
              // Sex changes the BMR, so recompute with the new answer applied.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _publish();
              });
            },
          ),
        ),
        ObTextField(
          theme: theme,
          controller: _age,
          label: l10n.onboardingAge,
          keyboardType: TextInputType.number,
          maxLength: 3,
          onChanged: (_) => _publish(),
        ),
        const SizedBox(height: 14),
        ObTextField(
          theme: theme,
          controller: _weight,
          label: l10n.onboardingWeightKg,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 6,
          onChanged: (_) => _publish(),
        ),
        const SizedBox(height: 14),
        ObTextField(
          theme: theme,
          controller: _height,
          label: l10n.onboardingHeightCm,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 6,
          onChanged: (_) => _publish(),
        ),
        if (bmr != null) ...[
          const SizedBox(height: 24),
          ObCard(
            theme: theme,
            accent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.obBmrTitle,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.obBmrValue(bmr.round()),
                  style: TextStyle(
                    color: theme.accentOrange,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.obBmrExplainer,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
