import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudflare_stream_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/generate_routine_sheet.dart';
import '../routines/routine_detail_screen.dart';
import '../routines/routine_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabase = SupabaseService.instance;
  final CloudflareStreamService _cloudflare = CloudflareStreamService();

  final Map<String, String?> _resolvedThumbs = {};
  final Map<String, Future<String?>> _thumbFutures = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Capture dependencies up-front to avoid using BuildContext across async gaps.
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
    final user = context.watch<AuthProvider>().uiState.currentUser;
    final theme = context.watch<ThemeProvider>();
    final rp = context.watch<RoutineProvider>();
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Friend';

    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Header
                Container(
                  height: 320,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                theme.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white24,
                            child: const Icon(Icons.emoji_emotions, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Good Morning, $userName!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.notifications, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),

                // "Ask Celia" Promo Card (Overlapping)
                Positioned(
                  top: 120,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: theme.isDarkMode
                        ? BoxDecoration(
                            color: const Color(0xFF1E2235).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.accentOrange.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: theme.accentOrange.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          )
                        : BoxDecoration(
                            color: const Color(0xFFF57C00),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.0)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Generate your personalized routine with AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            final routine = await showGenerateRoutineSheet(context);
                            if (!context.mounted || routine == null) return;

                            // Ensure the new routine shows up in the Library tab immediately.
                            context.read<NavigationProvider>().setIndex(1);

                            // Open details on the root navigator so the sheet/tab nesting can't swallow the push.
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (_) => RoutineDetailScreen(routine: routine),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                theme.isDarkMode ? theme.accentOrange : const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Create Routine', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Space for overlapping card

            // Up Next Section (REAL DATA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Up Next',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildUpNextList(theme, rp, userId: user?.uid),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionBtn(
                          context,
                          'Browse Library',
                          Icons.book_outlined,
                          () => context.read<NavigationProvider>().setIndex(1),
                          theme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionBtn(
                          context,
                          'Chat with Celia',
                          Icons.chat_bubble_outline,
                          () => context.read<NavigationProvider>().setIndex(2),
                          theme,
                        ),
                      ),
                    ],
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

  Widget _buildUpNextList(ThemeProvider theme, RoutineProvider rp, {required String? userId}) {
    // 1) Continue: most recently played routine
    final recentlyPlayed = [...rp.userRoutines]
      ..sort((a, b) => (b.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

    UserRoutine? continueUr;
    for (final ur in recentlyPlayed) {
      if (ur.lastPlayedAt != null) {
        continueUr = ur;
        break;
      }
    }
    // Fallback: if user has saved routines but none played yet, show the most recently saved.
    continueUr ??= recentlyPlayed.isNotEmpty ? recentlyPlayed.first : null;

    final continueId = continueUr?.routineId;

    final curated = rp.curatedRoutines.where((r) => r.id != continueId).toList();

    // If nothing loaded yet, show loading affordance
    if (rp.isLoading && rp.routines.isEmpty) {
      return Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(theme.accentOrange)),
      );
    }

    // Build a list of up to 3 cards: Continue + 2 curated suggestions
    final cards = <Widget>[];

    if (continueId != null) {
      final inMemory = rp.routines.where((r) => r.id == continueId).cast<Routine?>().firstWhere((_) => true, orElse: () => null);
      cards.add(
        FutureBuilder<Routine?>(
          future: inMemory != null ? Future.value(inMemory) : _supabase.getRoutine(continueId),
          builder: (context, snap) {
            final routine = snap.data;
            if (routine == null) {
              return _buildUpNextCard(
                'Continue',
                'Loading…',
                Icons.play_circle_outline,
                theme,
                thumbnailUrl: null,
                onTap: null,
              );
            }
            return FutureBuilder<String?>(
              future: _getRoutineThumbnail(routine),
              builder: (context, thumbSnap) {
                return _buildRoutineCard(
                  label: 'Continue',
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

    for (final r in curated.take(2)) {
      cards.add(
        FutureBuilder<String?>(
          future: _getRoutineThumbnail(r),
          builder: (context, snap) {
            return _buildRoutineCard(
              label: 'Recommended',
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
      return _buildEmptyUpNext(theme);
    }

    // Remove trailing spacer
    if (cards.isNotEmpty && cards.last is SizedBox) {
      cards.removeLast();
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      children: cards,
    );
  }

  Widget _buildEmptyUpNext(ThemeProvider theme) {
    return Container(
      width: double.infinity,
      decoration: theme.glassDecoration,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No upcoming routines yet.\nCreate one or browse the library.',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.textSecondary),
        ),
      ),
    );
  }

  void _openRoutineDetails(Routine routine) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => RoutineDetailScreen(routine: routine)),
    );
  }

  void _openRoutinePlayer(Routine routine) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => RoutinePlayerScreen(routine: routine)),
    );
  }

  Widget _buildUpNextCard(
    String title,
    String subtitle,
    IconData icon,
    ThemeProvider theme, {
    String? thumbnailUrl,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: theme.glassDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbPlaceholder(icon, theme),
                        )
                      : _thumbPlaceholder(icon, theme),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard({
    required String label,
    required Routine routine,
    required ThemeProvider theme,
    String? thumbnailUrl,
    required VoidCallback onTap,
  }) {
    final subtitle = '${routine.durationLabel} • ${routine.difficultyLabel}';
    return Stack(
      children: [
        _buildUpNextCard(
          routine.title,
          subtitle,
          Icons.fitness_center,
          theme,
          thumbnailUrl: thumbnailUrl,
          onTap: onTap,
        ),
        Positioned(
          left: 14,
          top: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.accentOrange.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: theme.accentOrange, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _thumbPlaceholder(IconData icon, ThemeProvider theme) {
    return Center(
      child: Icon(icon, size: 48, color: theme.isDarkMode ? Colors.white54 : Colors.grey[400]),
    );
  }

  Future<String?> _getRoutineThumbnail(Routine routine) {
    // 1) Cached
    if (_resolvedThumbs.containsKey(routine.id)) {
      return Future.value(_resolvedThumbs[routine.id]);
    }
    // 2) In-flight
    final existing = _thumbFutures[routine.id];
    if (existing != null) return existing;

    final fut = () async {
      // a) Routine thumbnail
      final routineThumb = routine.thumbnailUrl;
      if (routineThumb != null && routineThumb.isNotEmpty) {
        _resolvedThumbs[routine.id] = routineThumb;
        return routineThumb;
      }

      // b) Step thumbnail
      for (final step in routine.steps) {
        final stepThumb = step.thumbnailUrl;
        if (stepThumb != null && stepThumb.isNotEmpty) {
          _resolvedThumbs[routine.id] = stepThumb;
          return stepThumb;
        }
      }

      // c) Resolve via video id (DB -> Cloudflare fallback)
      final stepVideoId = routine.steps
          .map((s) => (s.videoId ?? '').trim())
          .firstWhere((v) => v.isNotEmpty, orElse: () => '');
      if (stepVideoId.isEmpty) {
        _resolvedThumbs[routine.id] = null;
        return null;
      }

      try {
        final video = await _supabase.getVideoByAnyId(stepVideoId);
        final cloudflareId = (video != null && video.streamId.isNotEmpty) ? video.streamId : stepVideoId;
        final resolved = (video?.thumbnailUrl?.isNotEmpty ?? false)
            ? video!.thumbnailUrl
            : _cloudflare.getThumbnailUrl(cloudflareId);
        _resolvedThumbs[routine.id] = resolved;
        return resolved;
      } catch (_) {
        final resolved = _cloudflare.getThumbnailUrl(stepVideoId);
        _resolvedThumbs[routine.id] = resolved;
        return resolved;
      } finally {
        _thumbFutures.remove(routine.id);
      }
    }();

    _thumbFutures[routine.id] = fut;
    return fut;
  }

  Widget _buildQuickActionBtn(BuildContext context, String label, IconData icon, VoidCallback onTap, ThemeProvider theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: theme.glassDecoration,
        child: Column(
          children: [
            Icon(icon, color: theme.accentOrange),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
