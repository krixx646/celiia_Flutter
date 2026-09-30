import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/equipment_tags.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Canonical injury slugs. The routine generator matches on these, so they are
/// stored untranslated; anything the user types goes through as free text.
const String kInjuryKnee = 'knee';
const String kInjuryLowerBack = 'lower_back';
const String kInjuryShoulder = 'shoulder';
const String kInjuryNeck = 'neck';
const String kInjuryAnkle = 'ankle';
const String kInjuryWrist = 'wrist';

const String kConditionHypertension = 'hypertension';
const String kConditionDiabetes = 'diabetes';
const String kConditionAsthma = 'asthma';
const String kConditionHeart = 'heart';
const String kConditionPregnancy = 'pregnancy';

const String kOutcomeStress = 'stress';
const String kOutcomeSleep = 'sleep';
const String kOutcomeEnergy = 'energy';
const String kOutcomeHabits = 'habits';
const String kOutcomeConfidence = 'confidence';

/// Session lengths offered, in minutes.
const List<int> kSessionMinutes = [15, 20, 30, 45, 60];

/// Step 5 — everything that shapes a workout: where, what to avoid, how hard,
/// how long, and when.
class TrainingStep extends StatelessWidget {
  const TrainingStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  static String? validate(UserProfile draft, AppLocalizations l10n) {
    if (draft.trainingLocation == null) return l10n.obAnswerRequired;
    if (draft.usesEquipment == null) return l10n.obEquipmentRequired;
    if (draft.usesEquipment == true && draft.availableEquipment.isEmpty) {
      return l10n.obEquipmentRequired;
    }
    if (draft.fitnessGoal == null) return l10n.obAnswerRequired;
    if (draft.experienceLevel == null) return l10n.obAnswerRequired;
    if (draft.trainingIntensity == null) return l10n.obAnswerRequired;
    return null;
  }

  Future<void> _pickTime(BuildContext context) async {
    final existing = draft.preferredTrainingTime;
    final parts = existing?.split(':');
    final initial = parts != null && parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 18,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 18, minute: 0);

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final hour = picked.hour.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    onChanged(draft.copyWith(preferredTrainingTime: '$hour:$minute'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSection(
          theme: theme,
          label: l10n.obTrainingLocation,
          child: ObSingleChoice<TrainingLocation>(
            theme: theme,
            selected: draft.trainingLocation,
            options: [
              ObOption(TrainingLocation.home, l10n.obLocationHome),
              ObOption(TrainingLocation.gym, l10n.obLocationGym),
              ObOption(TrainingLocation.both, l10n.obLocationBoth),
            ],
            onSelected: (location) =>
                onChanged(draft.copyWith(trainingLocation: location)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obEquipmentMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ObSingleChoice<bool>(
                theme: theme,
                selected: draft.usesEquipment,
                options: [
                  ObOption(false, l10n.obEquipmentBodyweight),
                  ObOption(true, l10n.obEquipmentWith),
                ],
                onSelected: (withEquipment) {
                  onChanged(
                    draft.copyWith(
                      usesEquipment: withEquipment,
                      availableEquipment:
                          withEquipment ? draft.availableEquipment : const [],
                    ),
                  );
                },
              ),
              if (draft.usesEquipment == true) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.obEquipmentWhich,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ObMultiChoice<String>(
                  theme: theme,
                  selected: draft.availableEquipment,
                  options: [
                    ObOption(EquipmentTags.dumbbell, l10n.obEquipDumbbell),
                    ObOption(EquipmentTags.barbell, l10n.obEquipBarbell),
                    ObOption(EquipmentTags.kettlebell, l10n.obEquipKettlebell),
                    ObOption(EquipmentTags.band, l10n.obEquipBand),
                    ObOption(EquipmentTags.cable, l10n.obEquipCable),
                    ObOption(EquipmentTags.machine, l10n.obEquipMachine),
                    ObOption(EquipmentTags.pullUpBar, l10n.obEquipPullUpBar),
                    ObOption(EquipmentTags.jumpRope, l10n.obEquipJumpRope),
                    ObOption(EquipmentTags.mat, l10n.obEquipMat),
                  ],
                  onChanged: (values) =>
                      onChanged(draft.copyWith(availableEquipment: values)),
                ),
              ],
            ],
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obFitnessGoalLabel,
          child: ObSingleChoice<FitnessGoal>(
            theme: theme,
            selected: draft.fitnessGoal,
            options: [
              ObOption(FitnessGoal.loseFat, l10n.obFitnessLoseFat),
              ObOption(FitnessGoal.strength, l10n.obFitnessStrength),
              ObOption(FitnessGoal.tone, l10n.obFitnessTone),
              ObOption(FitnessGoal.health, l10n.obFitnessHealth),
              ObOption(FitnessGoal.tactical, l10n.obFitnessTactical),
              ObOption(FitnessGoal.custom, l10n.obFitnessCustom),
            ],
            onSelected: (goal) => onChanged(draft.copyWith(fitnessGoal: goal)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obExperienceLabel,
          child: ObSingleChoice<ExperienceLevel>(
            theme: theme,
            selected: draft.experienceLevel,
            options: [
              ObOption(ExperienceLevel.beginner, l10n.obExperienceBeginner),
              ObOption(ExperienceLevel.regular, l10n.obExperienceRegular),
            ],
            onSelected: (level) =>
                onChanged(draft.copyWith(experienceLevel: level)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obIntensityLabel,
          child: ObSingleChoice<TrainingIntensity>(
            theme: theme,
            selected: draft.trainingIntensity,
            options: [
              ObOption(TrainingIntensity.easy, l10n.obIntensityEasy),
              ObOption(TrainingIntensity.moderate, l10n.obIntensityModerate),
              ObOption(TrainingIntensity.intense, l10n.obIntensityIntense),
            ],
            onSelected: (intensity) =>
                onChanged(draft.copyWith(trainingIntensity: intensity)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obInjuriesLabel,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ObMultiChoice<String>(
                theme: theme,
                selected: draft.injuries
                    .where(_isKnownInjury)
                    .toList(growable: false),
                options: [
                  ObOption(kInjuryKnee, l10n.obInjuryKnee),
                  ObOption(kInjuryLowerBack, l10n.obInjuryLowerBack),
                  ObOption(kInjuryShoulder, l10n.obInjuryShoulder),
                  ObOption(kInjuryNeck, l10n.obInjuryNeck),
                  ObOption(kInjuryAnkle, l10n.obInjuryAnkle),
                  ObOption(kInjuryWrist, l10n.obInjuryWrist),
                ],
                // Chips own the known slugs; anything typed in the field below
                // is preserved alongside them.
                onChanged: (selected) => onChanged(
                  draft.copyWith(
                    injuries: [
                      ...selected,
                      ...draft.injuries.where((i) => !_isKnownInjury(i)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ObFreeTextList(
                theme: theme,
                values: draft.injuries
                    .where((i) => !_isKnownInjury(i))
                    .toList(growable: false),
                hint: l10n.obAddHint,
                onChanged: (custom) => onChanged(
                  draft.copyWith(
                    injuries: [
                      ...draft.injuries.where(_isKnownInjury),
                      ...custom,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obConditionsLabel,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: ObMultiChoice<String>(
            theme: theme,
            selected: draft.medicalConditions,
            options: [
              ObOption(kConditionHypertension, l10n.obConditionHypertension),
              ObOption(kConditionDiabetes, l10n.obConditionDiabetes),
              ObOption(kConditionAsthma, l10n.obConditionAsthma),
              ObOption(kConditionHeart, l10n.obConditionHeart),
              ObOption(kConditionPregnancy, l10n.obConditionPregnancy),
            ],
            onChanged: (values) =>
                onChanged(draft.copyWith(medicalConditions: values)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obOutcomesLabel,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: ObMultiChoice<String>(
            theme: theme,
            selected: draft.desiredOutcomes,
            options: [
              ObOption(kOutcomeStress, l10n.obOutcomeStress),
              ObOption(kOutcomeSleep, l10n.obOutcomeSleep),
              ObOption(kOutcomeEnergy, l10n.obOutcomeEnergy),
              ObOption(kOutcomeHabits, l10n.obOutcomeHabits),
              ObOption(kOutcomeConfidence, l10n.obOutcomeConfidence),
            ],
            onChanged: (values) =>
                onChanged(draft.copyWith(desiredOutcomes: values)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obPlanningMode,
          child: ObSingleChoice<PlanningMode>(
            theme: theme,
            selected: draft.planningMode,
            options: [
              ObOption(PlanningMode.automatic, l10n.obModeAutomatic),
              ObOption(PlanningMode.manual, l10n.obModeManual),
            ],
            onSelected: (mode) => onChanged(draft.copyWith(planningMode: mode)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obMinutesPerDay,
          child: ObSingleChoice<int>(
            theme: theme,
            selected: draft.minutesPerDay,
            options: kSessionMinutes
                .map((minutes) => ObOption(minutes, l10n.obMinutesValue(minutes)))
                .toList(),
            onSelected: (minutes) =>
                onChanged(draft.copyWith(minutesPerDay: minutes)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obPreferredTime,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: OutlinedButton.icon(
            onPressed: () => _pickTime(context),
            icon: Icon(Icons.schedule, color: theme.textPrimary),
            label: Text(
              draft.preferredTrainingTime ?? l10n.obPickTime,
              style: TextStyle(color: theme.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              side: BorderSide(color: theme.border),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }

  static bool _isKnownInjury(String value) {
    return const [
      kInjuryKnee,
      kInjuryLowerBack,
      kInjuryShoulder,
      kInjuryNeck,
      kInjuryAnkle,
      kInjuryWrist,
    ].contains(value);
  }
}
