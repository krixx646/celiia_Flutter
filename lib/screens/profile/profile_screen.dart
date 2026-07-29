import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/nutrition_tracker_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/progress.dart';
import '../tools/nutrition_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_routines_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<AuthProvider>().uiState.currentUser;
      if (user == null) return;
      await context.read<RoutineProvider>().loadUserRoutines(user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().uiState;
    final user = auth.currentUser;
    final theme = context.watch<ThemeProvider>();
    final routineProvider = context.watch<RoutineProvider>();
    final nutritionTracker = context.watch<NutritionTrackerProvider>();
    final userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Friend';

    final savedCount = routineProvider.userRoutines.length;
    final streakStats = computeActiveStreakStats(
      routines: routineProvider.userRoutines,
      meals: nutritionTracker.meals,
    );
    final workoutCompletions = computeTotalWorkoutCompletions(
      routineProvider.userRoutines,
    );

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TopAppBar
            _buildHeader(theme),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Profile Header
                    _buildProfileHeader(theme, userName, user?.photoURL),

                    const SizedBox(height: 32),

                    // Stats Bento Card
                    _buildStatsCard(
                      theme,
                      savedCount,
                      streakStats,
                      workoutCompletions,
                    ),

                    const SizedBox(height: 32),

                    // Settings List
                    _buildSettingsList(theme, user?.email),

                    const SizedBox(height: 24),

                    // Log Out
                    _buildLogoutButton(theme),

                    const SizedBox(height: 120), // Padding for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.menu, color: theme.accentOrange),
              const SizedBox(width: 16),
              Text(
                'Celia AI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: theme.accentOrange,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: theme.accentOrange),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    ThemeProvider theme,
    String userName,
    String? photoUrl,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Avatar Glow
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.accentOrange.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Avatar Image
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.surface, width: 4),
                image: (photoUrl != null && photoUrl.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Icon(Icons.person, size: 64, color: theme.textSecondary)
                  : null,
            ),
            // Edit Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditProfileScreen()),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.accentOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          userName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Elite Member',
          style: TextStyle(
            fontSize: 16,
            color: theme.accentOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    ThemeProvider theme,
    int savedCount,
    ActiveStreakStats streakStats,
    int workoutCompletions,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? const Color(0xFF1E2235).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(theme, '$savedCount', 'Saved', null),
              ),
              Container(width: 1, height: 40, color: theme.border),
              Expanded(
                child: _buildStatItem(
                  theme,
                  '${streakStats.streak}',
                  'Active Streak',
                  Icons.local_fire_department,
                ),
              ),
              Container(width: 1, height: 40, color: theme.border),
              Expanded(
                child: _buildStatItem(
                  theme,
                  '$workoutCompletions',
                  'Workouts',
                  null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            buildStreakNudge(streakStats),
            style: TextStyle(color: theme.textSecondary, height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeProvider theme,
    String value,
    String label,
    IconData? icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.accentOrange, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList(ThemeProvider theme, String? email) {
    return Column(
      children: [
        _buildMenuItem(
          theme: theme,
          icon: Icons.person,
          title: 'Profile',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Account'),
                content: Text('Signed in as:\n${email ?? "Unknown"}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          theme: theme,
          icon: Icons.favorite_border,
          title: 'Favorite Routines',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const SavedRoutinesScreen(showFavoritesOnly: true),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          theme: theme,
          icon: Icons.workspace_premium,
          title: 'Subscription',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          theme: theme,
          icon: Icons.restaurant_menu,
          title: 'Nutrition',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NutritionScreen()));
          },
        ),
        const SizedBox(height: 8),
        _buildDarkModeToggle(theme),
        const SizedBox(height: 16), // Extra space before Help
        _buildMenuItem(
          theme: theme,
          icon: Icons.help_outline,
          title: 'Help & Support',
          iconColor: theme.textSecondary,
          iconBg: theme.textSecondary.withValues(alpha: 0.1),
          onTap: () async {
            final uri = Uri.parse('https://the-fit.eu/');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required ThemeProvider theme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBg,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg ?? theme.accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.accentOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.accentOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dark_mode, color: theme.accentOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: theme.isDarkMode,
            activeThumbColor: theme.accentOrange,
            activeTrackColor: theme.accentOrange.withValues(alpha: 0.3),
            onChanged: (val) => theme.toggleTheme(val),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeProvider theme) {
    return TextButton.icon(
      onPressed: () async {
        final auth = context.read<AuthProvider>();
        final nutritionProfile = context.read<NutritionProfileProvider>();
        final nutritionTracker = context.read<NutritionTrackerProvider>();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Log out'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          nutritionProfile.clear();
          nutritionTracker.clear();
          await auth.signOut();
        }
      },
      icon: Icon(Icons.logout, color: theme.textSecondary),
      label: Text(
        'Log Out',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.textSecondary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
