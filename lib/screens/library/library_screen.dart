import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudflare_stream_service.dart';
import '../../services/supabase_service.dart';
import '../routines/routine_detail_screen.dart';
import '../routines/routine_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 0;
  final SupabaseService _supabaseService = SupabaseService.instance;
  final CloudflareStreamService _cloudflareService = CloudflareStreamService();
  final Map<String, String?> _resolvedRoutineThumbs = {};
  final Set<String> _thumbRequestsInFlight = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load routines once when screen mounts
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ROUTINE LIBRARY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 22,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Top extension
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF57C00), Color(0xFFEF6C00)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: 16),
              // Custom Pill Tabs
              Center(child: _buildPillTabs(theme)),
              const SizedBox(height: 24),
              
              // List
              Expanded(
                child: routineProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(theme.accentOrange),
                        ),
                      )
                    : routineProvider.error != null
                        ? _buildErrorState(theme, routineProvider.error!)
                        : routines.isEmpty
                            ? _buildEmptyState(theme)
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.72,
                                ),
                                itemCount: routines.length,
                                itemBuilder: (context, index) {
                                  final routine = routines[index];
                                  return _buildRoutineTile(routine, theme);
                                },
                              ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillTabs(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: theme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem('Curated', 0, theme),
          const SizedBox(width: 4),
          _buildTabItem('AI-generated', 1, theme),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (theme.isDarkMode ? Colors.white70 : const Color(0xFFF57C00)),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineTile(Routine routine, ThemeProvider theme) {
    final thumb = _getRoutineThumbnail(routine);
    final difficultyColor = _difficultyColor(theme, routine.difficulty);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutinePlayerScreen(routine: routine),
          ),
        );
      },
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routine: routine),
          ),
        );
      },
      child: Container(
        decoration: theme.glassDecoration.copyWith(
          borderRadius: BorderRadius.circular(18),
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
                      top: Radius.circular(18),
                    ),
                    child: thumb != null && thumb.isNotEmpty
                        ? Image.network(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _routineThumbPlaceholder(theme),
                          )
                        : _routineThumbPlaceholder(theme),
                  ),
                  // Dark gradient for readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.accentOrange.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  // Badges
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        routine.difficultyLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _metaItem(
                        icon: Icons.timer,
                        label: routine.durationLabel,
                        theme: theme,
                      ),
                      _metaItem(
                        icon: Icons.list,
                        label: '${routine.steps.length} steps',
                        theme: theme,
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

  Widget _metaItem({
    required IconData icon,
    required String label,
    required ThemeProvider theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _routineThumbPlaceholder(ThemeProvider theme) {
    return Container(
      color: theme.isDarkMode ? const Color(0xFF151829) : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          color: theme.textSecondary,
          size: 42,
        ),
      ),
    );
  }

  String? _getRoutineThumbnail(Routine routine) {
    // 1) Cached resolution (async)
    if (_resolvedRoutineThumbs.containsKey(routine.id)) {
      return _resolvedRoutineThumbs[routine.id];
    }

    // 2) Routine-level thumbnail from DB
    final routineThumb = routine.thumbnailUrl;
    if (routineThumb != null && routineThumb.isNotEmpty) {
      return routineThumb;
    }

    // 3) Step-level thumbnail (often stored in steps JSON)
    for (final step in routine.steps) {
      final stepThumb = step.thumbnailUrl;
      if (stepThumb != null && stepThumb.isNotEmpty) {
        _resolvedRoutineThumbs[routine.id] = stepThumb;
        return stepThumb;
      }
    }

    // 4) Resolve from step video_id (can be videos.id or Cloudflare UID)
    final firstWithVideo = routine.steps
        .where((s) => (s.videoId ?? '').trim().isNotEmpty)
        .cast<RoutineStep?>()
        .firstWhere((_) => true, orElse: () => null);

    final stepVideoId = firstWithVideo?.videoId?.trim();
    if (stepVideoId == null || stepVideoId.isEmpty) {
      _resolvedRoutineThumbs[routine.id] = null;
      return null;
    }

    if (_thumbRequestsInFlight.contains(routine.id)) return null;
    _thumbRequestsInFlight.add(routine.id);

    () async {
      try {
        final video = await _supabaseService.getVideoByAnyId(stepVideoId);
        final cloudflareId = (video != null && video.streamId.isNotEmpty)
            ? video.streamId
            : stepVideoId;

        final resolved = (video?.thumbnailUrl?.isNotEmpty ?? false)
            ? video!.thumbnailUrl
            : _cloudflareService.getThumbnailUrl(cloudflareId);

        if (!mounted) return;
        setState(() {
          _resolvedRoutineThumbs[routine.id] = resolved;
          _thumbRequestsInFlight.remove(routine.id);
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _resolvedRoutineThumbs[routine.id] = null;
          _thumbRequestsInFlight.remove(routine.id);
        });
      }
    }();

    return null;
  }

  Color _difficultyColor(ThemeProvider theme, RoutineDifficulty difficulty) {
    switch (difficulty) {
      case RoutineDifficulty.easy:
        return Colors.green.withValues(alpha: theme.isDarkMode ? 0.45 : 0.8);
      case RoutineDifficulty.medium:
        return Colors.orange.withValues(alpha: theme.isDarkMode ? 0.45 : 0.8);
      case RoutineDifficulty.hard:
        return Colors.red.withValues(alpha: theme.isDarkMode ? 0.45 : 0.8);
    }
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
              onPressed: () => context.read<RoutineProvider>().loadRoutines(refresh: true),
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
