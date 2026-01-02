import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'chat_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final List<Widget> screens;

  const MainScreen({
    super.key,
    List<Widget>? screens,
  }) : screens = screens ??
            const [
              HomeScreen(),
              LibraryScreen(),
              ChatScreen(),
              ProfileScreen(),
            ];

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController _pageController;
  late final NavigationProvider _navProvider;
  late final VoidCallback _navListener;
  bool _navVisible = true;

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
      final current = (_pageController.page ?? _pageController.initialPage.toDouble()).round();
      if (current == target) return;
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    };
    _navProvider.addListener(_navListener);
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
    final double basePadding = _navVisible ? 120 : 70;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: basePadding),
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => context.read<NavigationProvider>().setIndex(index),
              children: widget.screens,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: _navVisible ? Offset.zero : const Offset(0, 1.2),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? theme.surfaceGlass : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: NavigationBar(
                      selectedIndex: nav.currentIndex,
                      backgroundColor: Colors.transparent,
                      height: 72,
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      indicatorColor: theme.accentOrange.withValues(alpha: 0.2),
                      onDestinationSelected: _navigateTo,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.video_library_outlined),
                          selectedIcon: Icon(Icons.video_library),
                          label: 'Library',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.chat_bubble_outline),
                          selectedIcon: Icon(Icons.chat_bubble),
                          label: 'Chat',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _navVisible ? 90 : 24,
            child: FloatingActionButton.small(
              elevation: 0,
              heroTag: 'navToggle',
              backgroundColor: theme.accentOrange.withValues(alpha: 0.9),
              onPressed: () => setState(() => _navVisible = !_navVisible),
              child: Icon(
                _navVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 