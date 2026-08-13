import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/nutrition_tracker_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/routine_thumbnail_resolver.dart';
import '../../services/supabase_service.dart';
import '../../utils/progress.dart';
import '../../utils/responsive.dart';
import '../../utils/routine_text.dart';
import '../../widgets/daily_progress_card.dart';
import '../../widgets/generate_routine_sheet.dart';
import '../routines/routine_detail_screen.dart';
import '../routines/workout_launcher.dart';
import '../tools/calorie_scanner_screen.dart';
import '../tools/nutrition_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _heroImageAsset = 'assets/images/home_hero_fitness.jpg';
  final SupabaseService _supabase = SupabaseService.instance;
  final RoutineThumbnailResolver _thumbnailResolver =
      RoutineThumbnailResolver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      precacheImage(const AssetImage(_heroImageAsset), context);

      final rp = context.read<RoutineProvider>();
      final userId = context.read<AuthProvider>().uiState.currentUser?.uid;

      if (rp.routines.isEmpty && !rp.isLoading) {
        await rp.loadRoutines();
      }

      if (userId != null) {
        await rp.loadUserRoutines(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().uiState.currentUser;
    final theme = context.watch<ThemeProvider>();
    final rp = context.watch<RoutineProvider>();
    final tracker = context.watch<NutritionTrackerProvider>();
    final userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? l10n.profileFriend;

    final streakStats = computeActiveStreakStats(
      routines: rp.userRoutines,
      meals: tracker.meals,
    );

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TopAppBar
            _buildHeader(
              l10n,
              theme,
              userName,
              user?.photoURL,
              streakStats.streak,
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.contentHorizontalPadding,
                ),
                child: AdaptivePageBody(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeroSection(l10n, theme),
                    const SizedBox(height: 24),
                    DailyProgressCard(
                      tracker: tracker,
                      streakStats: streakStats,
                    ),
                    const SizedBox(height: 32),

                    // Up Next Section
                    _buildUpNextHeader(l10n, theme),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: _buildUpNextList(
                        l10n,
                        theme,
                        rp,
                        userId: user?.uid,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions Bento Grid
                    Text(
                      l10n.homeQuickActions,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(l10n, theme),

                    const SizedBox(height: 120), // Padding for bottom nav
                  ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppLocalizations l10n,
    ThemeProvider theme,
    String userName,
    String? photoUrl,
    int streak,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildUserAvatar(theme, photoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeGoodMorning,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.accentOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.accentOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: theme.accentOrange,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: TextStyle(
                    color: theme.accentOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? const Color(0xFF1E2235).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: theme.border),
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications,
                color: theme.accentOrange,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ThemeProvider theme, String? photoUrl) {
    final fallback = Container(
      color: theme.surface,
      child: Icon(Icons.person, color: theme.textSecondary),
    );

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.border),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return fallback;
                },
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n, ThemeProvider theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF7A00),
                          Color(0xFFB75014),
                          Color(0xFF171B2A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Image.asset(
                    _heroImageAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                    color: Colors.black.withValues(alpha: 0.55),
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  Positioned(
                    right: -42,
                    top: -34,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -26,
                    bottom: -34,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.42),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accentOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: theme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: theme.accentOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.homeCeliaActive,
                        style: TextStyle(
                          color: theme.accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.homeGenerateRoutine,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final nav = context.read<NavigationProvider>();
                    final routine = await showGenerateRoutineSheet(context);
                    if (!mounted || routine == null) return;
                    nav.setIndex(1);
                    if (!mounted) return;
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => RoutineDetailScreen(routine: routine),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome),
                      const SizedBox(width: 8),
                      Text(
                        l10n.homeCreateRoutine,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextHeader(AppLocalizations l10n, ThemeProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.homeUpNext,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        InkWell(
          onTap: () => context.read<NavigationProvider>().setIndex(1),
          child: Text(
            l10n.actionSeeAll,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpNextList(
    AppLocalizations l10n,
    ThemeProvider theme,
    RoutineProvider rp, {
    required String? userId,
  }) {
    final recentlyPlayed = [...rp.userRoutines]
      ..sort(
        (a, b) => (b.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(
              a.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
      );

    UserRoutine? continueUr;
    for (final ur in recentlyPlayed) {
      if (ur.lastPlayedAt != null) {
        continueUr = ur;
        break;
      }
    }
    continueUr ??= recentlyPlayed.isNotEmpty ? recentlyPlayed.first : null;
    final continueId = continueUr?.routineId;
    final curated = rp.curatedRoutines
        .where((r) => r.id != continueId)
        .toList();

    if (rp.isLoading && rp.routines.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(theme.accentOrange),
        ),
      );
    }

    final cards = <Widget>[];

    if (continueId != null) {
      final inMemory = rp.routines
          .where((r) => r.id == continueId)
          .cast<Routine?>()
          .firstWhere((_) => true, orElse: () => null);
      cards.add(
        FutureBuilder<Routine?>(
          future: inMemory != null
              ? Future.value(inMemory)
              : _supabase.getRoutine(continueId),
          builder: (context, snap) {
            final routine = snap.data;
            if (routine == null) return const SizedBox.shrink();
            return FutureBuilder<String?>(
              future: _getRoutineThumbnail(routine),
              builder: (context, thumbSnap) {
                return _buildNewRoutineCard(
                  l10n: l10n,
                  routine: routine,
                  theme: theme,
                  thumbnailUrl: thumbSnap.data,
                  onTap: () => _openRoutinePlayer(routine),
                );
              },
            );
          },
        ),
      );
      cards.add(const SizedBox(width: 16));
    }

    for (final r in curated.take(3)) {
      cards.add(
        FutureBuilder<String?>(
          future: _getRoutineThumbnail(r),
          builder: (context, snap) {
            return _buildNewRoutineCard(
              l10n: l10n,
              routine: r,
              theme: theme,
              thumbnailUrl: snap.data,
              onTap: () => _openRoutineDetails(r),
            );
          },
        ),
      );
      cards.add(const SizedBox(width: 16));
    }

    if (cards.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            l10n.homeNoUpcoming,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
      );
    }

    if (cards.isNotEmpty && cards.last is SizedBox) {
      cards.removeLast();
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      children: cards,
    );
  }

  Widget _buildNewRoutineCard({
    required AppLocalizations l10n,
    required Routine routine,
    required ThemeProvider theme,
    String? thumbnailUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Half
            SizedBox(
              height: 128,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _thumbPlaceholder(Icons.fitness_center, theme),
                          )
                        : _thumbPlaceholder(Icons.fitness_center, theme),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [theme.surface, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? const Color(0xFF1E2235).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.border),
                      ),
                      child: Icon(
                        Icons.bookmark_border,
                        color: theme.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Half
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        localizedRoutineDuration(l10n, routine.durationMinutes),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.speed, size: 16, color: theme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        localizedRoutineDifficulty(l10n, routine.difficulty),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbPlaceholder(IconData icon, ThemeProvider theme) {
    return Container(
      color: theme.isDarkMode
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey[100],
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: theme.isDarkMode ? Colors.white54 : Colors.grey[400],
        ),
      ),
    );
  }

  Future<String?> _getRoutineThumbnail(Routine routine) {
    return _thumbnailResolver.resolve(routine);
  }

  void _openRoutineDetails(Routine routine) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => RoutineDetailScreen(routine: routine)),
    );
  }

  void _openRoutinePlayer(Routine routine) {
    openWorkout(context, routine, useRootNavigator: true);
  }

  Widget _buildQuickActionsGrid(AppLocalizations l10n, ThemeProvider theme) {
    return Column(
      children: [
        // Chat Full Width
        _buildBentoItem(
          theme: theme,
          icon: Icons.forum,
          iconColor: theme.accentOrange,
          iconBg: theme.accentOrange.withValues(alpha: 0.1),
          title: l10n.homeChatWithCelia,
          subtitle: l10n.homeChatSubtitle,
          onTap: () => context.read<NavigationProvider>().setIndex(2),
        ),
        const SizedBox(height: 16),
        // Scan Full Width
        _buildBentoItem(
          theme: theme,
          icon: Icons.photo_camera,
          iconColor: const Color(0xFFFFB691),
          iconBg: const Color(0xFFFF6F00).withValues(alpha: 0.2),
          title: l10n.homeScanMeal,
          subtitle: l10n.homeScanMealSubtitle,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const CalorieScannerScreen()),
          ),
        ),
        const SizedBox(height: 16),
        _buildBentoItem(
          theme: theme,
          icon: Icons.restaurant_menu,
          iconColor: const Color(0xFF00D1FF),
          iconBg: const Color(0xFF00D1FF).withValues(alpha: 0.12),
          title: l10n.homeNutrition,
          subtitle: l10n.homeNutritionSubtitle,
          onTap: () => Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (_) => const NutritionScreen())),
        ),
        const SizedBox(height: 16),
        // Two Half Widths
        Row(
          children: [
            Expanded(
              child: _buildBentoSquare(
                theme: theme,
                icon: Icons.video_library,
                iconColor: const Color(0xFFFFB954),
                iconBg: const Color(0xFFFFB954).withValues(alpha: 0.1),
                title: l10n.homeBrowseLibrary,
                onTap: () => context.read<NavigationProvider>().setIndex(1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoSquare(
                theme: theme,
                icon: Icons.show_chart,
                iconColor: const Color(0xFF00E475),
                iconBg: const Color(0xFF00E475).withValues(alpha: 0.1),
                title: l10n.homeTrackProgress,
                onTap: () => context.read<NavigationProvider>().setIndex(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoItem({
    required ThemeProvider theme,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: theme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoSquare({
    required ThemeProvider theme,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
