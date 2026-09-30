import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Step 3 — the one answer that sets the direction of every plan.
class GoalStep extends StatelessWidget {
  const GoalStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  static String? validate(UserProfile draft, AppLocalizations l10n) {
    return draft.primaryGoal == null ? l10n.obAnswerRequired : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.obGoalBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 24),
        ObSingleChoice<PrimaryGoal>(
          theme: theme,
          selected: draft.primaryGoal,
          options: [
            ObOption(PrimaryGoal.loseWeight, l10n.obGoalLoseWeight),
            ObOption(PrimaryGoal.gainWeight, l10n.obGoalGainWeight),
            ObOption(PrimaryGoal.buildMuscle, l10n.obGoalBuildMuscle),
          ],
          onSelected: (goal) => onChanged(draft.copyWith(primaryGoal: goal)),
        ),
      ],
    );
  }
}
