import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/routine_thumbnail_resolver.dart';
import '../routines/routine_detail_screen.dart';
import 'dart:ui';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 0;
  final RoutineThumbnailResolver _thumbnailResolver =
      RoutineThumbnailResolver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final routineProvider = context.watch<RoutineProvider>();

    final routines = _selectedIndex == 0
        ? routineProvider.curatedRoutines
        : routineProvider.aiRoutines;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TopAppBar
            _buildHeader(
              theme,
              context.watch<AuthProvider>().uiState.currentUser?.photoURL,
            ),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _buildTabItem('Curated', 0, theme),
                        const SizedBox(width: 8),
                        _buildTabItem('AI-Generated', 1, theme),
                      ],
                    ),
                  ),

                  // Grid
                  Expanded(
                    child: routineProvider.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                theme.accentOrange,
                              ),
                            ),
                          )
                        : routineProvider.error != null
                        ? _buildErrorState(theme, routineProvider.error!)
                        : routines.isEmpty
                        ? _buildEmptyState(theme)
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      1, // Full width on mobile, could be 2 on tablet
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.3,
                                ),
                            itemCount: routines.length,
                            itemBuilder: (context, index) {
                              final routine = routines[index];
                              return _buildRoutineCard(routine, theme);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider theme, String? photoUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.border),
                  image: (photoUrl != null && photoUrl.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Icon(Icons.person, color: theme.textSecondary)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Routine Library',
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

  Widget _buildTabItem(String text, int index, ThemeProvider theme) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentOrange : theme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? theme.accentOrange : theme.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Routine routine, ThemeProvider theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routine: routine),
          ),
        );
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: FutureBuilder<String?>(
                      future: _getRoutineThumbnail(routine),
                      builder: (context, snapshot) {
                        final thumb = snapshot.data;
                        if (thumb != null && thumb.isNotEmpty) {
                          return Image.network(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _routineThumbPlaceholder(theme),
                          );
                        }
                        return _routineThumbPlaceholder(theme);
                      },
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.background.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Glassmorphic Play Button
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? const Color(0xFF1E2235).withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.border),
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: theme.accentOrange,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Duration Pill
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: Colors.black.withValues(alpha: 0.6),
                          child: Text(
                            routine.durationLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      color: theme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDifficultyPill(theme, routine.difficulty),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${routine.steps.length} steps',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
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

  Widget _buildDifficultyPill(
    ThemeProvider theme,
    RoutineDifficulty difficulty,
  ) {
    Color bgColor;
    Color textColor;

    switch (difficulty) {
      case RoutineDifficulty.easy:
        textColor = const Color(0xFF00E676);
        bgColor = const Color(0xFF00b25a).withValues(alpha: 0.2);
        break;
      case RoutineDifficulty.medium:
        textColor = const Color(0xFFFFB74D);
        bgColor = const Color(0xFFc3841b).withValues(alpha: 0.2);
        break;
      case RoutineDifficulty.hard:
        textColor = const Color(0xFFFFb4ab);
        bgColor = const Color(0xFF93000a).withValues(alpha: 0.2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty.name.substring(0, 1).toUpperCase() +
            difficulty.name.substring(1),
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _routineThumbPlaceholder(ThemeProvider theme) {
    return Container(
      color: const Color(0xFF1A1D2D),
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          color: theme.textSecondary,
          size: 48,
        ),
      ),
    );
  }

  Future<String?> _getRoutineThumbnail(Routine routine) {
    return _thumbnailResolver.resolve(routine);
  }

  Widget _buildEmptyState(ThemeProvider theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: theme.textSecondary,
              size: 56,
            ),
            const SizedBox(height: 14),
            Text(
              'No routines yet',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create and publish routines in the admin dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeProvider theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 14),
            Text(
              'Failed to load routines',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () =>
                  context.read<RoutineProvider>().loadRoutines(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
