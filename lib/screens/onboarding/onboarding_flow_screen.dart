import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/nutrition_profile.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/nutrition_tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/onboarding_service.dart';
import 'steps/coaching_step.dart';
import 'steps/consent_step.dart';
import 'steps/goal_step.dart';
import 'steps/notifications_step.dart';
import 'steps/nutrition_step.dart';
import 'steps/physical_step.dart';
import 'steps/summary_step.dart';
import 'steps/training_step.dart';
import 'steps/wearables_step.dart';

/// The onboarding flow (eight questions plus the summary; the wearable
/// question is not offered).
///
/// Only the steps the user has no answer for are shown, so someone who signed
/// up before a step existed is asked the new question and nothing else. The
/// draft is pushed to the server after every step, which is what makes that
/// possible across sessions and devices.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late UserProfile _draft;
  late List<OnboardingStep> _steps;
  int _index = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final existing = context.read<UserProfileProvider>().profile;
    _draft = existing ?? const UserProfile();
    // Someone who signed up before this flow existed already told us their
    // body stats on the old screen. Carry them over rather than asking twice.
    final legacy = context.read<NutritionProfileProvider>().profile;
    if (!_draft.hasPhysicalData && legacy != null) {
      _draft = _draft.copyWith(
        sex: legacy.gender,
        age: legacy.age,
        weightKg: legacy.weightKg,
        heightCm: legacy.heightCm,
      );
    }
    // Notification defaults are seeded into the draft rather than shown as
    // phantom toggles, so the step counts as answered even if the user agrees
    // with every default and touches nothing.
    if (_draft.notificationPrefs.isEmpty) {
      _draft = _draft.copyWith(
        notificationPrefs: NotificationsStep.defaultPrefs(),
      );
    }

    final missing = existing?.missingSteps ?? _allCollectingSteps;
    // The wearable question is not offered: no device integration exists (direct
    // Garmin access is closed to new apps), so asking would promise something
    // the app cannot do. The step, enum value and stored column stay in place
    // for when an integration is built.
    _steps = [...missing, OnboardingStep.summary];
  }

  static List<OnboardingStep> get _allCollectingSteps => OnboardingStep.values
      .where(
        (step) =>
            step != OnboardingStep.summary && step != OnboardingStep.wearables,
      )
      .toList(growable: false);

  OnboardingStep get _current => _steps[_index];
  bool get _isLast => _index == _steps.length - 1;

  void _update(UserProfile next) => setState(() => _draft = next);

  String? _validate(AppLocalizations l10n) {
    return switch (_current) {
      OnboardingStep.consent => ConsentStep.validate(_draft, l10n),
      OnboardingStep.physical => PhysicalStep.validate(_draft, l10n),
      OnboardingStep.goal => GoalStep.validate(_draft, l10n),
      OnboardingStep.nutrition => NutritionStep.validate(_draft, l10n),
      OnboardingStep.training => TrainingStep.validate(_draft, l10n),
      OnboardingStep.coaching => CoachingStep.validate(_draft, l10n),
      OnboardingStep.notifications => NotificationsStep.validate(_draft, l10n),
      OnboardingStep.wearables => WearablesStep.validate(_draft, l10n),
      OnboardingStep.summary => null,
    };
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    final problem = _validate(l10n);
    if (problem != null) {
      _showSnack(problem);
      return;
    }

    HapticFeedback.lightImpact();

    if (_isLast) {
      await _finish(l10n);
      return;
    }

    // Saving is not awaited: the answers so far are already in the draft and
    // every later save resends them, so a slow or failed request must not make
    // the user wait between questions.
    context.read<UserProfileProvider>().save(_draft);
    setState(() => _index += 1);
  }

  void _back() {
    if (_index == 0) return;
    HapticFeedback.lightImpact();
    setState(() => _index -= 1);
  }

  Future<void> _finish(AppLocalizations l10n) async {
    setState(() => _finishing = true);

    final profiles = context.read<UserProfileProvider>();
    final saved = await profiles.completeOnboarding(_withDerivedTargets(_draft));
    if (!mounted) return;

    if (!saved) {
      // Finishing is the one save that has to land: without it the gate would
      // send the user back through the whole flow on next launch.
      setState(() => _finishing = false);
      _showSnack(profiles.error ?? l10n.onboardingSaveFailed);
      return;
    }

    await _publishNutritionTargets();
    if (!mounted) return;

    // Kept as an offline fallback for the gate: if the profile cannot be
    // fetched at launch, this is how we know not to onboard someone twice.
    final uid = context.read<AuthProvider>().uiState.currentUser?.uid;
    if (uid != null) await OnboardingService.markComplete(uid);

    widget.onComplete();
  }

  /// Stores the numbers the profile implies alongside the answers, so the
  /// backend and the agent read the same targets the user was shown instead of
  /// each re-deriving them from the formula.
  UserProfile _withDerivedTargets(UserProfile draft) {
    final targets = draft.computeTargets();
    if (targets == null) return draft;
    return draft.copyWith(
      bmrKcal: NutritionProfile.basalMetabolicRate(
        weightKg: draft.weightKg!,
        heightCm: draft.heightCm!,
        age: draft.age!,
        gender: draft.sex!,
      ).roundToDouble(),
      dailyCalories: targets.dailyCalories,
      dailyProteinGrams: targets.dailyProteinGrams,
      dailyCarbsGrams: targets.dailyCarbsGrams,
      dailyFatGrams: targets.dailyFatGrams,
    );
  }

  /// Pushes the goal-adjusted targets into the nutrition feature, so the
  /// dashboard and the tracker show the numbers onboarding just promised.
  Future<void> _publishNutritionTargets() async {
    if (!_draft.hasPhysicalData) return;

    final nutrition = context.read<NutritionProfileProvider>();
    final tracker = context.read<NutritionTrackerProvider>();
    await nutrition.saveProfile(
      weightKg: _draft.weightKg!,
      heightCm: _draft.heightCm!,
      age: _draft.age!,
      gender: _draft.sex!,
      activityMultiplier: _draft.activityMultiplier,
      calorieMultiplier: _draft.calorieMultiplier,
    );
    tracker.syncProfile(nutrition.profile);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final userName =
        context.watch<AuthProvider>().uiState.currentUser?.displayName ??
        l10n.profileFriend;

    return PopScope(
      // Onboarding is the root of the tree at this point, so an un-handled
      // system back closes the app mid-flow. Step back instead.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: Column(
            children: [
              _header(l10n, theme, userName),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: _body(theme),
                ),
              ),
              _footer(l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, ThemeProvider theme, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // Animated rather than snapped: this is the only motion in the
            // flow and the cheapest way to make it read as progress.
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (_index + 1) / _steps.length),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: theme.border,
                valueColor: AlwaysStoppedAnimation(theme.accentOrange),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.obStepOf(_index + 1, _steps.length),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _title(l10n, userName),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n, String userName) {
    return switch (_current) {
      OnboardingStep.consent => l10n.obConsentTitle,
      OnboardingStep.physical => l10n.obPhysicalTitle,
      OnboardingStep.goal => l10n.obGoalTitle,
      OnboardingStep.nutrition => l10n.obNutritionTitle,
      OnboardingStep.training => l10n.obTrainingTitle,
      OnboardingStep.coaching => l10n.obCoachingTitle,
      OnboardingStep.notifications => l10n.obNotificationsTitle,
      OnboardingStep.wearables => l10n.obWearablesTitle,
      OnboardingStep.summary => l10n.obSummaryTitle(userName),
    };
  }

  Widget _body(ThemeProvider theme) {
    // Keyed on the step so text controllers inside a step are rebuilt with the
    // right initial values when the flow moves on.
    return KeyedSubtree(
      key: ValueKey(_current),
      child: switch (_current) {
        OnboardingStep.consent => ConsentStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.physical => PhysicalStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.goal => GoalStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.nutrition => NutritionStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.training => TrainingStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.coaching => CoachingStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.notifications => NotificationsStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.wearables => WearablesStep(
          theme: theme,
          draft: _draft,
          onChanged: _update,
        ),
        OnboardingStep.summary => SummaryStep(theme: theme, draft: _draft),
      },
    );
  }

  Widget _footer(AppLocalizations l10n, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          if (_index > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: _finishing ? null : _back,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  side: BorderSide(color: theme.border),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  l10n.obBack,
                  style: TextStyle(color: theme.textPrimary),
                ),
              ),
            ),
          Expanded(
            child: ElevatedButton(
              onPressed: _finishing ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentOrange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: theme.accentOrange.withValues(
                  alpha: 0.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: _finishing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isLast ? l10n.obFinish : l10n.actionContinue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}