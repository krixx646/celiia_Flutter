import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudflare_stream_service.dart';
import '../../services/supabase_service.dart';
import 'routine_player_screen.dart';
import 'video_player_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final CloudflareStreamService _cloudflareService = CloudflareStreamService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  Map<String, String?> _videoThumbnails = {};
  Map<String, bool> _videoAvailability = {};
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

    for (final step in widget.routine.steps) {
      if (step.videoId != null && step.videoId!.isNotEmpty) {
        // Check if video exists in Supabase and is ready
        try {
          final video = await _supabaseService.getVideoByAnyId(step.videoId!);

          // Resolve Cloudflare UID (needed for thumbnails & fallback playback URL)
          final cloudflareId = (video != null && video.streamId.isNotEmpty)
              ? video.streamId
              : step.videoId!;

          if (video != null) {
            final hasPlaybackUrl = video.playbackUrl.isNotEmpty;
            availability[step.videoId!] =
                hasPlaybackUrl || (video.isReady && cloudflareId.isNotEmpty);
            thumbnails[step.videoId!] =
                step.thumbnailUrl ?? video.thumbnailUrl ?? _cloudflareService.getThumbnailUrl(cloudflareId);
          } else {
            availability[step.videoId!] = false;
            thumbnails[step.videoId!] =
                step.thumbnailUrl ?? _cloudflareService.getThumbnailUrl(cloudflareId);
          }
        } catch (e) {
          debugPrint('Error loading video ${step.videoId}: $e');
          availability[step.videoId!] = false;
          thumbnails[step.videoId!] = step.thumbnailUrl ?? 
              _cloudflareService.getThumbnailUrl(step.videoId!);
        }
      } else {
        availability[step.id] = false;
        thumbnails[step.id] = step.thumbnailUrl;
      }
    }

    setState(() {
      _videoThumbnails = thumbnails;
      _videoAvailability = availability;
      _loadingVideos = false;
    });
  }

  String? _getThumbnailForStep(RoutineStep step) {
    if (step.videoId != null && step.videoId!.isNotEmpty) {
      return _videoThumbnails[step.videoId];
    }
    return _videoThumbnails[step.id] ?? step.thumbnailUrl;
  }

  bool _isVideoAvailable(RoutineStep step) {
    if (step.videoId == null || step.videoId!.isEmpty) return false;
    return _videoAvailability[step.videoId] ?? false;
  }

  Future<void> _playVideo(RoutineStep step) async {
    if (step.videoId == null || step.videoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video available for this step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isVideoAvailable(step)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video is still processing. Please try again later.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Try to get playback URL from Supabase first, fallback to constructing it
    String playbackUrl = '';
    try {
      final video = await _supabaseService.getVideoByAnyId(step.videoId!);
      if (video != null && video.playbackUrl.isNotEmpty) {
        playbackUrl = video.playbackUrl;
      } else if (video != null && video.streamId.isNotEmpty) {
        playbackUrl = _cloudflareService.getPlaybackUrl(video.streamId);
      } else {
        // Last-resort fallback: assume the stored ID is the Cloudflare UID
        playbackUrl = _cloudflareService.getPlaybackUrl(step.videoId!);
      }
    } catch (e) {
      debugPrint('Error getting playback URL: $e');
      playbackUrl = _cloudflareService.getPlaybackUrl(step.videoId!);
    }

    if (playbackUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playback URL is missing for this video'),
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
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        title: Text(
          widget.routine.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accentOrange.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.routine.description != null) ...[
                  Text(
                    widget.routine.description!,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _buildInfoChip(
                      '${widget.routine.durationMinutes} min',
                      Icons.timer,
                      theme,
                    ),
                    _buildInfoChip(
                      widget.routine.difficultyLabel,
                      Icons.fitness_center,
                      theme,
                    ),
                    _buildInfoChip(
                      widget.routine.categoryLabel,
                      Icons.category,
                      theme,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoutinePlayerScreen(routine: widget.routine),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
                          'No steps available',
                          style: TextStyle(color: theme.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: widget.routine.steps.length,
                        itemBuilder: (context, index) {
                          final step = widget.routine.steps[index];
                          return _buildStepTile(step, theme);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : theme.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.accentOrange),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(RoutineStep step, ThemeProvider theme) {
    final thumbnailUrl = _getThumbnailForStep(step);
    final isAvailable = _isVideoAvailable(step);
    final hasVideo = step.videoId != null && step.videoId!.isNotEmpty;

    return GestureDetector(
      onTap: hasVideo ? () => _playVideo(step) : null,
      child: Container(
        decoration: theme.glassDecoration.copyWith(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation(
                                    theme.accentOrange,
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(theme),
                  ),

                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),

                  // Play Button / Status
                  Center(
                    child: hasVideo
                        ? Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? theme.accentOrange
                                  : Colors.grey.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isAvailable ? Icons.play_arrow : Icons.lock,
                              color: Colors.white,
                              size: 32,
                            ),
                          )
                        : Icon(
                            Icons.video_library_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 32,
                          ),
                  ),

                  // Duration Badge
                  if (hasVideo)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
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

                  // Unavailable Badge
                  if (hasVideo && !isAvailable)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Processing...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (step.description != null && step.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.description!,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
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
      color: theme.isDarkMode
          ? Colors.grey[900]
          : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          size: 48,
          color: theme.textSecondary,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${secs.toString().padLeft(2, '0')}';
  }
}

