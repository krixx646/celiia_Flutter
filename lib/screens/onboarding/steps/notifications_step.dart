import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Notification types the user can opt into. The keys are the map keys stored
/// in `user_profiles.notification_prefs`, so adding one here is all a new
/// reminder type needs on the data side.
const String kNotifyMeals = 'meals';
const String kNotifyWorkouts = 'workouts';
const String kNotifyWater = 'water';
const String kNotifyProgress = 'progress';
const String kNotifyCoach = 'coach';

const List<String> kNotificationKeys = [
  kNotifyMeals,
  kNotifyWorkouts,
  kNotifyWater,
  kNotifyProgress,
  kNotifyCoach,
];

/// Step 7 — what the user agrees to be contacted about.
///
/// Recording consent and delivering notifications are separate jobs, and only
/// the first is built. The step says so rather than implying reminders start
/// tomorrow.
class NotificationsStep extends StatelessWidget {
  const NotificationsStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  /// Nothing to validate: turning everything off is a valid answer. The step
  /// seeds defaults on first view so the map is never empty, which is what
  /// marks it answered.
  static String? validate(UserProfile draft, AppLocalizations l10n) => null;

  /// Sensible opt-ins for a coaching app, applied only when the user has never
  /// answered this step.
  static Map<String, bool> defaultPrefs() => const {
    kNotifyMeals: true,
    kNotifyWorkouts: true,
    kNotifyWater: false,
    kNotifyProgress: true,
    kNotifyCoach: true,
  };

  String _label(AppLocalizations l10n, String key) {
    return switch (key) {
      kNotifyMeals => l10n.obNotifyMeals,
      kNotifyWorkouts => l10n.obNotifyWorkouts,
      kNotifyWater => l10n.obNotifyWater,
      kNotifyProgress => l10n.obNotifyProgress,
      kNotifyCoach => l10n.obNotifyCoach,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = draft.notificationPrefs.isEmpty
        ? defaultPrefs()
        : draft.notificationPrefs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.obNotificationsBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 20),
        ...kNotificationKeys.map(
          (key) => ObToggleRow(
            theme: theme,
            label: _label(l10n, key),
            value: prefs[key] ?? false,
            onChanged: (value) => onChanged(
              draft.copyWith(
                notificationPrefs: {...prefs, key: value},
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ObCard(
          theme: theme,
          child: Text(
            l10n.obNotificationsPending,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
