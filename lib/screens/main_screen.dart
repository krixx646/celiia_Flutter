import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/navigation_provider.dart';
import '../providers/nutrition_profile_provider.dart';
import '../providers/nutrition_tracker_provider.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'chat_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final List<Widget> screens;

  const MainScreen({super.key, List<Widget>? screens})
    : screens =
          screens ??
          const [HomeScreen(), LibraryScreen(), ChatScreen(), ProfileScreen()];

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController _pageController;
  late final NavigationProvider _navProvider;
  late final VoidCallback _navListener;

  @override
  void initState() {
    super.initState();
    _navProvider = context.read<NavigationProvider>();
    final initialIndex = _navProvider.currentIndex;
    _pageController = PageController(initialPage: initialIndex);

    // Keep PageView in sync even when other screens call `NavigationProvider.setIndex()`.
    _navListener = () {
      final target = _navProvider.currentIndex;
      if (!_pageController.hasClients) return;
      final current =
          (_pageController.page ?? _pageController.initialPage.toDouble())
              .round();
      if (current == target) return;
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    };
    _navProvider.addListener(_navListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profileProvider = context.read<NutritionProfileProvider>();
      profileProvider.loadProfile().then((_) {
        if (!mounted) return;
        final tracker = context.read<NutritionTrackerProvider>();
        tracker.syncProfile(profileProvider.profile);
        tracker.refresh(profile: profileProvider.profile);
      });
    });
  }

  @override
  void dispose() {
    _navProvider.removeListener(_navListener);
    _pageController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    // The listener above drives the PageView animation.
    context.read<NavigationProvider>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) =>
                context.read<NavigationProvider>().setIndex(index),
            children: widget.screens,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? const Color(0xFF1E2235).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: theme.isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(
                            0,
                            Icons.home_outlined,
                            Icons.home,
                            'Home',
                            nav.currentIndex,
                            theme,
                          ),
                          _buildNavItem(
                            1,
                            Icons.video_library_outlined,
                            Icons.video_library,
                            'Library',
                            nav.currentIndex,
                            theme,
                          ),
                          _buildNavItem(
                            2,
                            Icons.chat_bubble_outline,
                            Icons.chat_bubble,
                            'Chat',
                            nav.currentIndex,
                            theme,
                          ),
                          _buildNavItem(
                            3,
                            Icons.person_outline,
                            Icons.person,
                            'Profile',
                            nav.currentIndex,
                            theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    int currentIndex,
    ThemeProvider theme,
  ) {
    final isActive = currentIndex == index;
    final color = isActive
        ? theme.accentOrange
        : (theme.isDarkMode ? Colors.white54 : Colors.black54);

    return GestureDetector(
      onTap: () => _navigateTo(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
