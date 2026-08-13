import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/nutrition_tracker_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/insight_text.dart';
import '../utils/progress.dart';

/// Today's eating and activity at a glance: how far through the calorie budget
/// the user is, how the macros are tracking against it, and the one line of
/// coaching that is worth reading right now.
class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    super.key,
    required this.tracker,
    required this.streakStats,
  });

  final NutritionTrackerProvider tracker;
  final ActiveStreakStats streakStats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final profile = tracker.profile;
    final insight = tracker.todayInsight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.isDarkMode ? 0.18 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.progressToday,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (profile != null)
                _BudgetPill(
                  consumed: tracker.todayCalories,
                  target: profile.dailyCalories,
                ),
            ],
          ),
          if (profile == null) ...[
            const SizedBox(height: 14),
            Text(
              l10n.progressSetGoals,
              style: TextStyle(color: theme.textSecondary, height: 1.4),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Row(
              children: [
                _CalorieRing(
                  consumed: tracker.todayCalories,
                  target: profile.dailyCalories,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _MacroBar(
                        label: l10n.progressProtein,
                        consumed: tracker.todayProtein,
                        target: profile.dailyProteinGrams,
                        color: theme.accentOrange,
                      ),
                      const SizedBox(height: 12),
                      _MacroBar(
                        label: l10n.progressCarbs,
                        consumed: tracker.todayCarbs,
                        target: profile.dailyCarbsGrams,
                        color: const Color(0xFF3B9EFF),
                      ),
                      const SizedBox(height: 12),
                      _MacroBar(
                        label: l10n.progressFat,
                        consumed: tracker.todayFat,
                        target: profile.dailyFatGrams,
                        color: const Color(0xFF00E475),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Container(height: 1, color: theme.border),
          const SizedBox(height: 14),
          _CoachLine(
            icon: streakStats.streak > 0
                ? Icons.local_fire_department
                : Icons.bolt_outlined,
            iconColor: streakStats.streak > 0
                ? theme.accentOrange
                : theme.textSecondary,
            text: buildStreakNudge(l10n, streakStats),
          ),
          if (insight != null) ...[
            const SizedBox(height: 10),
            _CoachLine(
              icon: Icons.lightbulb_outline,
              iconColor: theme.textSecondary,
              text: insight.message(l10n),
            ),
          ],
        ],
      ),
    );
  }
}

/// How much of the day's calorie budget is left, or how far past it the user is.
class _BudgetPill extends StatelessWidget {
  const _BudgetPill({required this.consumed, required this.target});

  final double consumed;
  final double target;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final remaining = (target - consumed).round();
    final over = remaining < 0;
    final color = over ? const Color(0xFFFF6B6B) : theme.accentOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        over
            ? AppLocalizations.of(context).progressKcalOver(-remaining)
            : AppLocalizations.of(context).progressKcalLeft(remaining),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({required this.consumed, required this.target});

  final double consumed;
  final double target;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    // A zero target would otherwise divide to infinity on a half-set profile.
    final ratio = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final over = target > 0 && consumed > target;

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: ratio.toDouble(),
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              backgroundColor: theme.border,
              color: over ? const Color(0xFFFF6B6B) : theme.accentOrange,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                consumed.round().toString(),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).progressOfTarget(target.round()),
                style: TextStyle(color: theme.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final double consumed;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final ratio = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              AppLocalizations.of(
                context,
              ).progressMacroAmount(consumed.round(), target.round()),
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: ratio.toDouble(),
            backgroundColor: theme.border,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CoachLine extends StatelessWidget {
  const _CoachLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
