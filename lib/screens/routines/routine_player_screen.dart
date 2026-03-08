import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudflare_stream_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/user_facing_error.dart';
import 'routine_detail_screen.dart';

class RoutinePlayerScreen extends StatefulWidget {
  final Routine routine;
  final Duration initTimeout;

  const RoutinePlayerScreen({
    super.key,
    required this.routine,
    this.initTimeout = const Duration(seconds: 20),
  });

  @override
  State<RoutinePlayerScreen> createState() => _RoutinePlayerScreenState();
}

class _PlayableStep {
  final RoutineStep step;
  final String playbackUrl;
  final String? thumbnailUrl;

  const _PlayableStep({
    required this.step,
    required this.playbackUrl,
    this.thumbnailUrl,
  });
}

class _RoutinePlayerScreenState extends State<RoutinePlayerScreen> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final CloudflareStreamService _cloudflareService = CloudflareStreamService();

  final List<_PlayableStep> _playableSteps = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isInitializingVideo = false;
  bool _isWorkoutComplete = false;
  String? _error;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;

    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isWorkoutComplete = false;
    });

    try {
      final resolved = await _resolvePlayableSteps(widget.routine.steps);
      _playableSteps
        ..clear()
        ..addAll(resolved);

      if (_playableSteps.isEmpty) {
        throw Exception('No playable videos found in this routine.');
      }

      _currentIndex = 0;
      await _loadCurrentVideo(autoPlay: true);
    } catch (e) {
      _error = toUserFriendlyMessage(
        e,
        fallback: 'Unable to load this routine right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<_PlayableStep>> _resolvePlayableSteps(List<RoutineStep> steps) async {
    final out = <_PlayableStep>[];

    for (final step in steps) {
      final id = (step.videoId ?? '').trim();
      if (id.isEmpty) continue;

      try {
        final video = await _supabaseService.getVideoByAnyId(id);

        // Prefer DB playback_url (works for both Cloudflare and external sources).
        if (video != null && video.playbackUrl.isNotEmpty) {
          final url = video.playbackUrl.toLowerCase();
          final looksLikeHls = url.contains('.m3u8') || url.contains('cloudflarestream.com') || url.contains('videodelivery.net');
          // Prevent infinite loading when a Cloudflare HLS URL exists but the asset is still processing.
          if (looksLikeHls && !video.isReady) {
            continue;
          }
          out.add(
            _PlayableStep(
              step: step,
              playbackUrl: video.playbackUrl,
              thumbnailUrl: step.thumbnailUrl ?? video.thumbnailUrl,
            ),
          );
          continue;
        }

        // Fallback: Cloudflare HLS manifest (only if we have a Cloudflare UID).
        final cloudflareId =
            (video != null && video.streamId.isNotEmpty) ? video.streamId : null;
        if (video != null && video.isReady && cloudflareId != null && cloudflareId.isNotEmpty) {
          out.add(
            _PlayableStep(
              step: step,
              playbackUrl: _cloudflareService.getPlaybackUrl(cloudflareId),
              thumbnailUrl:
                  step.thumbnailUrl ?? video.thumbnailUrl ?? _cloudflareService.getThumbnailUrl(cloudflareId),
            ),
          );
        }
      } catch (_) {
        // Skip unresolvable steps; the player should still work for the rest.
      }
    }

    return out;
  }

  void _onVideoTick() {
    final vc = _videoController;
    if (vc == null) return;

    final value = vc.value;
    if (!value.isInitialized) return;

    if (!_advancing && value.isCompleted) {
      _advancing = true;
      _next(autoPlay: true);
    }
  }

  Future<void> _loadCurrentVideo({required bool autoPlay}) async {
    if (_currentIndex < 0 || _currentIndex >= _playableSteps.length) return;

    setState(() {
      _isInitializingVideo = true;
      _error = null;
    });

    _disposeControllers();

    final current = _playableSteps[_currentIndex];

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(current.playbackUrl));
      _videoController = controller;

      await controller.initialize().timeout(widget.initTimeout);
      controller.addListener(_onVideoTick);

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: autoPlay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
        errorBuilder: (context, _) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'This video is not available right now.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );

      _advancing = false;

      setState(() {
        _isInitializingVideo = false;
      });
    } catch (e) {
      // If a clip fails to load, don't hang forever; allow navigation/retry.
      if (!mounted) return;
      final hasNext = _currentIndex + 1 < _playableSteps.length;
      setState(() {
        _isInitializingVideo = false;
        _error = hasNext
            ? 'Failed to load "${current.step.title}". Skipping…'
            : 'Failed to load "${current.step.title}".';
      });
      if (hasNext) {
      _next(autoPlay: true);
      }
    }
  }

  Future<void> _next({required bool autoPlay}) async {
    if (_currentIndex + 1 >= _playableSteps.length) {
      if (!mounted) return;
      setState(() {
        _isWorkoutComplete = true;
      });
      return;
    }

    setState(() {
      _currentIndex += 1;
    });

    await _loadCurrentVideo(autoPlay: autoPlay);
  }

  Future<void> _prev({required bool autoPlay}) async {
    if (_currentIndex - 1 < 0) return;

    setState(() {
      _currentIndex -= 1;
    });

    await _loadCurrentVideo(autoPlay: autoPlay);
  }

  void _openSteps() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final theme = context.watch<ThemeProvider>();
        return SafeArea(
          child: Container(
            decoration: theme.glassDecoration.copyWith(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Steps',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1}/${_playableSteps.length}',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _playableSteps.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _playableSteps[index];
                      final isCurrent = index == _currentIndex;
                      return ListTile(
                        leading: isCurrent
                            ? Icon(Icons.play_arrow, color: theme.accentOrange)
                            : Icon(Icons.check_circle_outline, color: theme.textSecondary),
                        title: Text(
                          item.step.title,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _formatDuration(item.step.durationSeconds),
                          style: TextStyle(color: theme.textSecondary),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          setState(() => _currentIndex = index);
                          await _loadCurrentVideo(autoPlay: true);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
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
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Steps',
            onPressed: _openSteps,
            icon: const Icon(Icons.list, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Details',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoutineDetailScreen(routine: widget.routine),
                ),
              );
            },
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.accentOrange),
              ),
            )
          : _error != null && _playableSteps.isEmpty
              ? _buildFatalError(theme)
              : Column(
                  children: [
                    Expanded(
                      child: _buildPlayerArea(theme),
                    ),
                    _buildBottomControls(theme),
                  ],
                ),
    );
  }

  Widget _buildFatalError(ThemeProvider theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 14),
            const Text(
              'No playable videos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'This routine has no videos ready to play yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _initialize,
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

  Widget _buildPlayerArea(ThemeProvider theme) {
    if (_isWorkoutComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: theme.accentOrange, size: 56),
              const SizedBox(height: 12),
              const Text(
                'Workout complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = context.read<AuthProvider>().uiState.currentUser;
                    if (user == null) return;
                    final rp = context.read<RoutineProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    await rp.recordCompletionForRoutine(
                          userId: user.uid,
                          routineId: widget.routine.id,
                        );
                    if (!mounted) return;
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Nice! Completion recorded.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark complete'),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isWorkoutComplete = false;
                    _currentIndex = 0;
                  });
                  await _loadCurrentVideo(autoPlay: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Replay'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitializingVideo) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.accentOrange),
            ),
            const SizedBox(height: 12),
            const Text('Loading…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    final chewie = _chewieController;
    if (chewie == null) {
      return const Center(
        child: Text('Player not ready', style: TextStyle(color: Colors.white70)),
      );
    }

    return Chewie(controller: chewie);
  }

  Widget _buildBottomControls(ThemeProvider theme) {
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex + 1 < _playableSteps.length;
    final current = _playableSteps.isNotEmpty ? _playableSteps[_currentIndex] : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null && _playableSteps.isNotEmpty) ...[
            Text(
              _error!,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            current?.step.title ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'Clip ${_currentIndex + 1} of ${_playableSteps.length} • ${_formatDuration(current?.step.durationSeconds ?? 0)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _playableSteps.isEmpty ? 0 : (_currentIndex + 1) / _playableSteps.length,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(theme.accentOrange),
            minHeight: 6,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: hasPrev ? () => _prev(autoPlay: true) : null,
                icon: Icon(Icons.skip_previous, color: hasPrev ? Colors.white : Colors.white24),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: hasNext ? () => _next(autoPlay: true) : null,
                icon: Icon(Icons.skip_next, color: hasNext ? Colors.white : Colors.white24),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openSteps,
                icon: Icon(Icons.list, color: theme.accentOrange),
                label: Text(
                  'Steps',
                  style: TextStyle(color: theme.accentOrange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}


