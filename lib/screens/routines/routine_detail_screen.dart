import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/env.dart';
import '../../l10n/app_localizations.dart';
import '../../models/routine.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudflare_stream_service.dart';
import '../../services/exercise_clip_library.dart';
import '../../services/exercise_media_resolver.dart';
import '../../services/supabase_service.dart';
import '../../utils/routine_text.dart';
import 'video_player_screen.dart';
import 'workout_launcher.dart';
import 'dart:ui';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final CloudflareStreamService _cloudflareService = CloudflareStreamService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final ExerciseMediaResolver _exerciseMediaResolver = ExerciseMediaResolver();
  final ExerciseClipLibrary _clipLibrary = ExerciseClipLibrary();
  Map<String, String?> _videoThumbnails = {};
  Map<String, bool> _videoAvailability = {};
  Map<String, String?> _clipPosters = {};
  Map<String, String?> _gifFallbacks = {};
  bool _loadingVideos = false;

  @override
  void initState() {
    super.initState();
    _loadVideoMetadata();
  }

  Future<void> _loadVideoMetadata() async {
    setState(() => _loadingVideos = true);

    final thumbnails = <String, String?>{};
    final availability = <String, bool>{};
    final clipPosters = <String, String?>{};
    final gifFallbacks = <String, String?>{};

    for (final step in widget.routine.steps) {
      var stepHasVideo = false;

      try {
        final poster = (await _clipLibrary.resolveForStep(step))?.posterUrl;
        if (poster != null && poster.isNotEmpty) clipPosters[step.id] = poster;
      } catch (_) {
        // Artwork is best-effort; the step still lists and still plays.
      }
      if (!Env.suspendRealVideos &&
          step.videoId != null &&
          step.videoId!.isNotEmpty) {
        try {
          final video = await _supabaseService.getVideoByAnyId(step.videoId!);
          final cloudflareId = (video != null && video.streamId.isNotEmpty)
              ? video.streamId
              : step.videoId!;

          if (video != null) {
            final hasPlaybackUrl = video.playbackUrl.isNotEmpty;
            availability[step.videoId!] =
                hasPlaybackUrl || (video.isReady && cloudflareId.isNotEmpty);
            thumbnails[step.videoId!] =
                step.thumbnailUrl ??
                video.thumbnailUrl ??
                _cloudflareService.getThumbnailUrl(cloudflareId);
            stepHasVideo = availability[step.videoId!] ?? false;
          } else {
            availability[step.videoId!] = false;
            thumbnails[step.videoId!] =
                step.thumbnailUrl ??
                _cloudflareService.getThumbnailUrl(cloudflareId);
          }
        } catch (e) {
          debugPrint('Error loading video ${step.videoId}: $e');
          availability[step.videoId!] = false;
          thumbnails[step.videoId!] =
              step.thumbnailUrl ??
              _cloudflareService.getThumbnailUrl(step.videoId!);
        }
      } else {
        availability[step.id] = false;
        thumbnails[step.id] = step.thumbnailUrl;
      }

      if (!stepHasVideo && Env.enableGifFallback) {
        try {
          final media = await _exerciseMediaResolver.resolveForStep(step);
          if (media?.gifUrl != null && media!.gifUrl!.isNotEmpty) {
            gifFallbacks[step.id] = media.gifUrl;
          }
        } catch (_) {
          // Stock preview is best-effort; skip silently.
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _videoThumbnails = thumbnails;
      _videoAvailability = availability;
      _clipPosters = clipPosters;
      _gifFallbacks = gifFallbacks;
      _loadingVideos = false;
    });
  }

  String? _getThumbnailForStep(RoutineStep step) {
    if (!Env.suspendRealVideos &&
        step.videoId != null &&
        step.videoId!.isNotEmpty) {
      final videoThumb = _videoThumbnails[step.videoId];
      if (videoThumb != null && videoThumb.isNotEmpty) return videoThumb;
    }
    final poster = _clipPosters[step.id];
    if (poster != null && poster.isNotEmpty) return poster;
    if (!_isVideoAvailable(step)) {
      final gifUrl = _gifFallbacks[step.id];
      if (gifUrl != null && gifUrl.isNotEmpty) return gifUrl;
    }
    return _videoThumbnails[step.id] ?? step.thumbnailUrl;
  }

  bool _isVideoAvailable(RoutineStep step) {
    if (Env.suspendRealVideos) return false;
    if (step.videoId == null || step.videoId!.isEmpty) return false;
    return _videoAvailability[step.videoId] ?? false;
  }

  bool _hasGifFallback(RoutineStep step) {
    if (_isVideoAvailable(step)) return false;
    final gifUrl = _gifFallbacks[step.id];
    return gifUrl != null && gifUrl.isNotEmpty;
  }

  Future<void> _playVideo(AppLocalizations l10n, RoutineStep step) async {
    if (Env.suspendRealVideos) return;
    if (step.videoId == null || step.videoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routineNoVideoForStep),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isVideoAvailable(step)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routineVideoProcessing),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String playbackUrl = '';
    try {
      final video = await _supabaseService.getVideoByAnyId(step.videoId!);
      if (video != null && video.playbackUrl.isNotEmpty) {
        playbackUrl = video.playbackUrl;
      } else if (video != null && video.streamId.isNotEmpty) {
        playbackUrl = _cloudflareService.getPlaybackUrl(video.streamId);
      } else {
        playbackUrl = _cloudflareService.getPlaybackUrl(step.videoId!);
      }
    } catch (e) {
      debugPrint('Error getting playback URL: $e');
      playbackUrl = _cloudflareService.getPlaybackUrl(step.videoId!);
    }

    if (playbackUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.routineMissingPlaybackUrl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoUrl: playbackUrl,
          title: step.title,
          thumbnailUrl: _getThumbnailForStep(step),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.routine.title,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.routine.description != null) ...[
                  Text(
                    widget.routine.description!,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _buildInfoChip(
                      localizedRoutineDuration(
                        l10n,
                        widget.routine.durationMinutes,
                      ),
                      Icons.timer,
                      theme,
                    ),
                    _buildInfoChip(
                      localizedRoutineDifficulty(
                        l10n,
                        widget.routine.difficulty,
                      ),
                      Icons.fitness_center,
                      theme,
                    ),
                    _buildInfoChip(
                      localizedRoutineCategory(l10n, widget.routine.category),
                      Icons.category,
                      theme,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    openWorkout(context, widget.routine);
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
                      const Icon(Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(
                        l10n.routineStartWorkout,
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

          // Steps Grid
          Expanded(
            child: _loadingVideos
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(theme.accentOrange),
                    ),
                  )
                : widget.routine.steps.isEmpty
                ? Center(
                    child: Text(
                      l10n.routineNoSteps,
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: widget.routine.steps.length,
                    itemBuilder: (context, index) {
                      final step = widget.routine.steps[index];
                      return _buildStepTile(l10n, step, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.accentOrange),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _previewGif(AppLocalizations l10n, RoutineStep step) {
    final gifUrl = _gifFallbacks[step.id];
    if (gifUrl == null || gifUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    width: double.infinity,
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Image.network(gifUrl, fit: BoxFit.contain),
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    width: double.infinity,
                    child: Text(
                      l10n.routinePreviewBanner,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile(
    AppLocalizations l10n,
    RoutineStep step,
    ThemeProvider theme,
  ) {
    final thumbnailUrl = _getThumbnailForStep(step);
    final isAvailable = _isVideoAvailable(step);
    final hasVideo =
        !Env.suspendRealVideos &&
        step.videoId != null &&
        step.videoId!.isNotEmpty;
    final hasGif = _hasGifFallback(step);

    return GestureDetector(
      onTap: hasVideo
          ? () => _playVideo(l10n, step)
          : (hasGif ? () => _previewGif(l10n, step) : null),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),
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
                  // Play Button
                  Center(
                    child: hasVideo || hasGif
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isAvailable || hasGif
                                      ? (theme.isDarkMode
                                            ? const Color(
                                                0xFF1E2235,
                                              ).withValues(alpha: 0.6)
                                            : Colors.white.withValues(
                                                alpha: 0.8,
                                              ))
                                      : Colors.grey.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.border),
                                ),
                                child: Icon(
                                  isAvailable || hasGif
                                      ? Icons.play_arrow
                                      : Icons.lock,
                                  color: isAvailable || hasGif
                                      ? theme.accentOrange
                                      : Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 32,
                          ),
                  ),
                  // Duration Badge
                  if (hasVideo)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            color: Colors.black.withValues(alpha: 0.6),
                            child: Text(
                              _formatDuration(step.durationSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (hasGif)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            color: Colors.black.withValues(alpha: 0.6),
                            child: Text(
                              l10n.routinePreview,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Step Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (step.description != null &&
                      step.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.description!,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeProvider theme) {
    return Container(
      color: const Color(0xFF1A1D2D),
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          size: 32,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
