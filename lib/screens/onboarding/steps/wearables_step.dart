import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Step 8 — which wearable the user has, if any.
///
/// Nothing reads this yet: the integrations are their own piece of work. The
/// answer is recorded now so the rollout can start with the platforms people
/// actually use, and the copy is explicit that no data is being synced.
class WearablesStep extends StatelessWidget {
  const WearablesStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  static String? validate(UserProfile draft, AppLocalizations l10n) => null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.obWearablesBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 24),
        ObSingleChoice<WearableProvider?>(
          theme: theme,
          selected: draft.wearableProvider,
          // Brand names are not translated.
          options: [
            const ObOption(WearableProvider.googleFit, 'Google Fit'),
            const ObOption(WearableProvider.healthConnect, 'Health Connect'),
            const ObOption(WearableProvider.appleHealth, 'Apple Health'),
            const ObOption(WearableProvider.fitbit, 'Fitbit'),
            const ObOption(WearableProvider.garmin, 'Garmin'),
            ObOption(null, l10n.obWearableNone),
          ],
          onSelected: (provider) => onChanged(
            draft.copyWith(
              wearableProvider: provider,
              clearWearableProvider: provider == null,
            ),
          ),
        ),
      ],
    );
  }
}
