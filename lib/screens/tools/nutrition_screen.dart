import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/meal_analysis.dart';
import '../../models/meal_log.dart';
import '../../models/nutrition_profile.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/nutrition_tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/nutrition_insights_service.dart';
import '../../services/calorie_scanner_service.dart';
import '../../utils/insight_text.dart';
import '../../widgets/nutrition_sources_citation.dart';
import 'nutrition_profile_setup_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key, this.highlightMealId});

  final String? highlightMealId;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final CalorieScannerService _service = CalorieScannerService();
  late Future<List<MealLog>> _futureMeals;

  @override
  void initState() {
    super.initState();
    _futureMeals = _service.getMealLogs();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final profileProvider = context.read<NutritionProfileProvider>();
      await profileProvider.loadProfile();
      if (!mounted) return;
      await context.read<NutritionTrackerProvider>().refresh(
        profile: profileProvider.profile,
      );
    });
  }

  Future<void> _openProfileSetup() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NutritionProfileSetupScreen()),
    );
    if (saved == true && mounted) {
      await context.read<NutritionTrackerProvider>().refresh(
        profile: context.read<NutritionProfileProvider>().profile,
      );
      if (mounted) setState(() {});
    }
  }

  void _reload() {
    setState(() => _futureMeals = _service.getMealLogs());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final profileProvider = context.watch<NutritionProfileProvider>();
    final profile = profileProvider.profile;
    final tracker = context.watch<NutritionTrackerProvider>();
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<MealLog>>(
          future: _futureMeals,
          builder: (context, snapshot) {
            final meals = snapshot.data ?? const <MealLog>[];
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final todayMeals = meals.where(_isToday).toList();
            final todayCalories = todayMeals.fold<double>(
              0,
              (sum, meal) => sum + meal.calories,
            );
            final todayProtein = todayMeals.fold<double>(
              0,
              (sum, meal) => sum + meal.proteinGrams,
            );
            final todayCarbs = todayMeals.fold<double>(
              0,
              (sum, meal) => sum + meal.carbsGrams,
            );
            final todayFat = todayMeals.fold<double>(
              0,
              (sum, meal) => sum + meal.fatGrams,
            );

            return RefreshIndicator(
              color: theme.accentOrange,
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                children: [
                  _buildHeader(l10n, theme),
                  const SizedBox(height: 20),
                  if (!profileProvider.hasProfile)
                    _buildProfilePrompt(l10n, theme)
                  else ...[
                    _buildGoalsSummary(l10n, theme, profile!),
                    const SizedBox(height: 12),
                    NutritionSourcesCitation(theme: theme, compact: true),
                  ],
                  const SizedBox(height: 18),
                  _buildTodayCard(
                    l10n,
                    theme,
                    calories: todayCalories,
                    protein: todayProtein,
                    carbs: todayCarbs,
                    fat: todayFat,
                    mealCount: todayMeals.length,
                    profile: profile,
                  ),
                  const SizedBox(height: 18),
                  _buildWeeklyTrend(l10n, theme, meals),
                  if (tracker.todayInsight != null ||
                      tracker.weeklyInsight != null) ...[
                    const SizedBox(height: 18),
                    _buildInsightsSection(l10n, theme, tracker),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, l10n.nutritionMealHistory),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    _buildEmptyState(
                      theme,
                      icon: Icons.cloud_off,
                      title: l10n.nutritionLoadFailed,
                      subtitle: l10n.nutritionLoadFailedBody,
                    )
                  else if (meals.isEmpty)
                    _buildEmptyState(
                      theme,
                      icon: Icons.restaurant_menu,
                      title: l10n.nutritionNoMeals,
                      subtitle: l10n.nutritionNoMealsBody,
                    )
                  else
                    ...meals.map((meal) => _buildMealTile(l10n, theme, meal)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeProvider theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nutritionTitle,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                l10n.nutritionSubtitle,
                style: TextStyle(color: theme.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.nutritionDailyGoals,
          onPressed: _openProfileSetup,
          icon: Icon(Icons.tune, color: theme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildProfilePrompt(AppLocalizations l10n, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nutritionSetGoalsTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.nutritionSetGoalsBody,
            style: TextStyle(color: theme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _openProfileSetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(l10n.nutritionSetUpGoals),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSummary(
    AppLocalizations l10n,
    ThemeProvider theme,
    NutritionProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nutritionDailyTarget,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.nutritionKcal(profile.dailyCalories.round()),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nutritionMacroSummary(
                    profile.dailyProteinGrams.round(),
                    profile.dailyCarbsGrams.round(),
                    profile.dailyFatGrams.round(),
                  ),
                  style: TextStyle(color: theme.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openProfileSetup,
            child: Text(
              l10n.actionEdit,
              style: TextStyle(color: theme.accentOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    AppLocalizations l10n,
    ThemeProvider theme,
    NutritionTrackerProvider tracker,
  ) {
    final insights = [
      if (tracker.todayInsight != null) tracker.todayInsight!,
      if (tracker.weeklyInsight != null) tracker.weeklyInsight!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, l10n.nutritionCeliaInsights),
        const SizedBox(height: 12),
        ...insights.map((insight) => _buildInsightCard(l10n, theme, insight)),
      ],
    );
  }

  Widget _buildInsightCard(
    AppLocalizations l10n,
    ThemeProvider theme,
    NutritionInsight insight,
  ) {
    final color = switch (insight.tone) {
      NutritionInsightTone.positive => theme.accentOrange,
      NutritionInsightTone.warning => Colors.redAccent,
      NutritionInsightTone.neutral => theme.textSecondary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title(l10n),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.message(l10n),
                  style: TextStyle(color: theme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(
    AppLocalizations l10n,
    ThemeProvider theme, {
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required int mealCount,
    NutritionProfile? profile,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFF171B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nutritionToday,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calories.round().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  profile == null
                      ? l10n.nutritionTodayMeals(mealCount)
                      : l10n.nutritionTodayOfTargetMeals(
                          profile.dailyCalories.round(),
                          mealCount,
                        ),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                ),
              ),
            ],
          ),
          if (profile != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: (calories / profile.dailyCalories).clamp(0, 1),
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMacroPill(l10n, l10n.progressProtein, protein),
              const SizedBox(width: 10),
              _buildMacroPill(l10n, l10n.progressCarbs, carbs),
              const SizedBox(width: 10),
              _buildMacroPill(l10n, l10n.progressFat, fat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(AppLocalizations l10n, String label, double grams) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.nutritionGrams(grams.toStringAsFixed(0)),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrend(
    AppLocalizations l10n,
    ThemeProvider theme,
    List<MealLog> meals,
  ) {
    final dailyCalories = List<double>.generate(7, (index) {
      final day = DateTime.now().subtract(Duration(days: 6 - index));
      return meals
          .where((meal) => _sameDay(meal.loggedAt, day))
          .fold<double>(0, (sum, meal) => sum + meal.calories);
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(theme, l10n.nutritionWeeklyTrend),
          const SizedBox(height: 18),
          SizedBox(
            height: 130,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const labelSpace = 22.0;
                final barMaxHeight = constraints.maxHeight - labelSpace;
                final maxCalories = dailyCalories.fold<double>(
                  1,
                  (max, value) => value > max ? value : max,
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final value = dailyCalories[index];
                    final height = value > 0
                        ? (value / maxCalories * barMaxHeight).clamp(
                            16.0,
                            barMaxHeight,
                          )
                        : 16.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              bottom: labelSpace,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: height,
                                decoration: BoxDecoration(
                                  color: value > 0
                                      ? theme.accentOrange
                                      : theme.border.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Text(
                                _weekdayLabel(l10n, index),
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTile(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealLog meal,
  ) {
    final isHighlighted = meal.id == widget.highlightMealId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
          );
          if (changed == true && mounted) _reload();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighlighted
                ? theme.accentOrange.withValues(alpha: 0.12)
                : theme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isHighlighted ? theme.accentOrange : theme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.accentOrange.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant, color: theme.accentOrange),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.nutritionMealSubtitle(
                        _timeLabel(l10n, meal.loggedAt),
                        meal.items.length,
                      ),
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.nutritionKcal(meal.calories.round()),
                style: TextStyle(
                  color: theme.accentOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeProvider theme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: theme.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeProvider theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.accentOrange, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  bool _isToday(MealLog meal) => _sameDay(meal.loggedAt, DateTime.now());

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayLabel(AppLocalizations l10n, int trendIndex) {
    final day = DateTime.now().subtract(Duration(days: 6 - trendIndex));
    final labels = l10n.nutritionWeekdayInitials.split(',');
    return labels[day.weekday - 1];
  }

  String _timeLabel(AppLocalizations l10n, DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    if (_sameDay(date, DateTime.now())) {
      return '${l10n.nutritionToday} $hour:$minute';
    }
    return '${date.month}/${date.day} $hour:$minute';
  }
}

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.meal});

  final MealLog meal;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final CalorieScannerService _service = CalorieScannerService();
  late MealLog _meal;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        title: Text(l10n.nutritionMealDetails),
        actions: [
          IconButton(
            tooltip: l10n.nutritionDeleteMeal,
            onPressed: _isSaving ? null : _deleteMeal,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
        children: [
          _buildSummary(l10n, theme),
          const SizedBox(height: 18),
          Text(
            l10n.nutritionFoodItems,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ..._meal.items.map((item) => _buildItemTile(l10n, theme, item)),
        ],
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _meal.title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.nutritionKcal(_meal.calories.round()),
            style: TextStyle(
              color: theme.accentOrange,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMacro(
                l10n,
                theme,
                l10n.progressProtein,
                _meal.proteinGrams,
              ),
              const SizedBox(width: 10),
              _buildMacro(l10n, theme, l10n.progressCarbs, _meal.carbsGrams),
              const SizedBox(width: 10),
              _buildMacro(l10n, theme, l10n.progressFat, _meal.fatGrams),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacro(
    AppLocalizations l10n,
    ThemeProvider theme,
    String label,
    double value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: theme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              l10n.nutritionGrams(value.toStringAsFixed(0)),
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealFoodItem item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nutritionItemSubtitle(
                    item.servingGrams.round(),
                    item.calories.round(),
                  ),
                  style: TextStyle(color: theme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSaving ? null : () => _editItem(item),
            icon: Icon(Icons.edit, color: theme.accentOrange),
          ),
          IconButton(
            onPressed: _isSaving ? null : () => _removeItem(item),
            icon: const Icon(Icons.close, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(MealFoodItem item) async {
    final edited = await showModalBottomSheet<MealFoodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealItemEditor(item: item),
    );
    if (edited == null) return;
    final items = _meal.items
        .map((entry) => entry == item ? edited : entry)
        .toList();
    await _saveMeal(_meal.copyWith(items: items));
  }

  Future<void> _removeItem(MealFoodItem item) async {
    if (_meal.items.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).nutritionNeedsOneItem),
        ),
      );
      return;
    }
    final items = _meal.items.where((entry) => entry != item).toList();
    await _saveMeal(_meal.copyWith(items: items));
  }

  Future<void> _saveMeal(MealLog meal) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      final updated = await _service.updateMealLog(meal);
      if (!mounted) return;
      setState(() => _meal = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.nutritionMealUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nutritionUpdateFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteMeal() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.nutritionDeleteMealTitle),
        content: Text(l10n.nutritionDeleteMealBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await _service.deleteMealLog(_meal.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nutritionDeleteFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _MealItemEditor extends StatefulWidget {
  const _MealItemEditor({required this.item});

  final MealFoodItem item;

  @override
  State<_MealItemEditor> createState() => _MealItemEditorState();
}

class _MealItemEditorState extends State<_MealItemEditor> {
  late final TextEditingController _name;
  late final TextEditingController _grams;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item.name);
    _grams = TextEditingController(
      text: widget.item.servingGrams.round().toString(),
    );
    _calories = TextEditingController(
      text: widget.item.calories.round().toString(),
    );
    _protein = TextEditingController(
      text: widget.item.proteinGrams.toStringAsFixed(1),
    );
    _carbs = TextEditingController(
      text: widget.item.carbsGrams.toStringAsFixed(1),
    );
    _fat = TextEditingController(text: widget.item.fatGrams.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _name.dispose();
    _grams.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.border),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.nutritionEditFood,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _field(theme, _name, l10n.nutritionFieldFoodName),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _field(theme, _grams, l10n.nutritionFieldGrams),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(theme, _calories, l10n.nutritionFieldCalories),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _field(theme, _protein, l10n.progressProtein),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _field(theme, _carbs, l10n.progressCarbs)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(theme, _fat, l10n.progressFat)),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    widget.item.copyWith(
                      name: _name.text.trim().isEmpty
                          ? widget.item.name
                          : _name.text.trim(),
                      servingGrams:
                          double.tryParse(_grams.text) ??
                          widget.item.servingGrams,
                      calories:
                          double.tryParse(_calories.text) ??
                          widget.item.calories,
                      proteinGrams:
                          double.tryParse(_protein.text) ??
                          widget.item.proteinGrams,
                      carbsGrams:
                          double.tryParse(_carbs.text) ??
                          widget.item.carbsGrams,
                      fatGrams:
                          double.tryParse(_fat.text) ?? widget.item.fatGrams,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(l10n.nutritionSaveFood),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    ThemeProvider theme,
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary),
        filled: true,
        fillColor: theme.background.withValues(alpha: 0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.border),
        ),
      ),
    );
  }
}
