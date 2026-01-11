import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/progress.dart';
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
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Friend';
    final createdAt = user?.metadata.creationTime;
    final memberSince = createdAt == null
        ? 'Member'
        : 'Member since ${_monthName(createdAt.month)} ${createdAt.year}';

    final routinesCount = routineProvider.userRoutines.length;
    final streak = computeDayStreak(routineProvider.userRoutines);
    final level = computeLevel(routineProvider.userRoutines);

    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header
            Center(
              child: Column(
                children: [
                  // Avatar with glow + edit
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.isDarkMode ? const Color(0xFF2A2D3E) : const Color(0xFFFFE0B2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accentOrange.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: theme.isDarkMode ? theme.accentOrange.withValues(alpha: 0.5) : Colors.white,
                            width: 3,
                          ),
                          image: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                              ? DecorationImage(image: NetworkImage(user.photoURL!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                            ? null
                            : Center(
                                child: Icon(Icons.person, size: 60, color: theme.accentOrange),
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProfileScreen()));
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.accentOrange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProfileScreen()));
                    },
                    child: Text(
                      'Edit profile',
                      style: TextStyle(color: theme.accentOrange, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memberSince,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Stats Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: theme.glassDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    icon: Icons.fitness_center,
                    value: '$routinesCount',
                    label: 'Routines',
                    color: theme.accentOrange,
                    theme: theme,
                  ),
                  _VerticalDivider(color: theme.border),
                  _StatItem(
                    icon: Icons.local_fire_department,
                    value: '$streak',
                    label: 'Day Streak',
                    color: theme.isDarkMode ? const Color(0xFFFF3D00) : const Color(0xFFFF9800),
                    theme: theme,
                  ),
                  _VerticalDivider(color: theme.border),
                  _StatItem(
                    icon: Icons.star,
                    value: '$level',
                    label: 'Level',
                    color: const Color(0xFFFFB74D),
                    theme: theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    theme: theme,
                    onTap: () {
                      final email = user?.email ?? 'Unknown';
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Account'),
                          content: Text('Signed in as:\n$email'),
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
                  const SizedBox(height: 16),
                  
                  // Dark Mode Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: theme.glassDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFF3E0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: theme.accentOrange,
                            size: 22,
                          ),
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
                  ),
                  
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.favorite_border,
                    title: 'Favorite Routines',
                    theme: theme,
                    onTap: () {
                      if (user == null) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedRoutinesScreen(showFavoritesOnly: true)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    theme: theme,
                    onTap: () async {
                      final uri = Uri.parse('https://the-fit.eu/');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    isDestructive: true,
                    theme: theme,
                    onTap: () async {
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

                      if (confirm == true && context.mounted) {
                        await context.read<AuthProvider>().signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeProvider theme;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: color,
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final ThemeProvider theme;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: theme.glassDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? (theme.isDarkMode ? Colors.red.withValues(alpha: 0.1) : Colors.red[50])
                    : (theme.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFF3E0)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : theme.accentOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : theme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
