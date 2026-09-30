import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Canonical mood slugs, stored untranslated so the agent reads one vocabulary.
const String kMoodGreat = 'great';
const String kMoodOkay = 'okay';
const String kMoodTired = 'tired';
const String kMoodStressed = 'stressed';
const String kMoodLow = 'low';

/// Step 6 — how the user is doing, and what they want coaching on.
class CoachingStep extends StatefulWidget {
  const CoachingStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  static String? validate(UserProfile draft, AppLocalizations l10n) {
    return draft.currentMood == null ? l10n.obAnswerRequired : null;
  }

  @override
  State<CoachingStep> createState() => _CoachingStepState();
}

class _CoachingStepState extends State<CoachingStep> {
  late final _focus = TextEditingController(
    text: widget.draft.coachingFocus ?? '',
  );

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSection(
          theme: theme,
          label: l10n.obMoodQuestion,
          child: ObSingleChoice<String>(
            theme: theme,
            selected: widget.draft.currentMood,
            options: [
              ObOption(kMoodGreat, l10n.obMoodGreat),
              ObOption(kMoodOkay, l10n.obMoodOkay),
              ObOption(kMoodTired, l10n.obMoodTired),
              ObOption(kMoodStressed, l10n.obMoodStressed),
              ObOption(kMoodLow, l10n.obMoodLow),
            ],
            onSelected: (mood) =>
                widget.onChanged(widget.draft.copyWith(currentMood: mood)),
          ),
        ),
        ObSection(
          theme: theme,
          label: l10n.obCoachingFocusLabel,
          optional: true,
          optionalLabel: l10n.obOptional,
          child: ObTextField(
            theme: theme,
            controller: _focus,
            label: l10n.obCoachingFocusHint,
            maxLines: 3,
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(coachingFocus: value.trim()),
            ),
          ),
        ),
      ],
    );
  }
}
