import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/onboarding_widgets.dart';

/// Step 1 — terms and the non-medical disclaimer.
///
/// The account itself already exists by the time onboarding runs (Firebase
/// handles name, email and password), so this step collects the part of
/// registration that has to be recorded rather than authenticated: an explicit,
/// timestamped acceptance.
class ConsentStep extends StatefulWidget {
  const ConsentStep({
    super.key,
    required this.theme,
    required this.draft,
    required this.onChanged,
  });

  final ThemeProvider theme;
  final UserProfile draft;
  final ValueChanged<UserProfile> onChanged;

  /// Both boxes must be ticked, which the step reports through the draft.
  static String? validate(UserProfile draft, AppLocalizations l10n) {
    return draft.hasAcceptedTerms ? null : l10n.obConsentRequired;
  }

  @override
  State<ConsentStep> createState() => _ConsentStepState();
}

class _ConsentStepState extends State<ConsentStep> {
  late bool _terms = widget.draft.hasAcceptedTerms;
  late bool _disclaimer = widget.draft.hasAcceptedTerms;

  /// The acceptance is only written once both boxes are ticked; until then the
  /// draft carries no timestamp and the step cannot be passed.
  void _publish() {
    setState(() {});
    if (!_terms || !_disclaimer) return;
    widget.onChanged(
      widget.draft.copyWith(
        termsAcceptedAt: DateTime.now(),
        termsVersion: kTermsVersion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.obConsentBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 22),
        ObCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.obDisclaimerTitle,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.obDisclaimerBody,
                style: TextStyle(
                  color: theme.textSecondary,
                  height: 1.45,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ObToggleRow(
          theme: theme,
          label: l10n.obAcceptTerms,
          value: _terms,
          onChanged: (value) {
            _terms = value;
            _publish();
          },
        ),
        ObToggleRow(
          theme: theme,
          label: l10n.obAcceptDisclaimer,
          value: _disclaimer,
          onChanged: (value) {
            _disclaimer = value;
            _publish();
          },
        ),
      ],
    );
  }
}
