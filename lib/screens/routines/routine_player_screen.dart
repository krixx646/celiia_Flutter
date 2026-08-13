import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../config/env.dart';
import '../../l10n/app_localizations.dart';
import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/cloudflare_stream_service.dart';
import '../../services/exercise_media_resolver.dart';
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
  final String? videoUrl;
  final String? gifUrl;
  final String? thumbnailUrl;

  const _PlayableStep({
    required this.step,
    this.videoUrl,
    this.gifUrl,
    this.thumbnailUrl,
  });

  /// True when this step has no real filmed video yet and is showing a
  /// temporary stock GIF preview instead.
  bool get isGifFallback => videoUrl == null && gifUrl != null;
}

class _RoutinePlayerScreenState extends State<RoutinePlayerScreen> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final CloudflareStreamService _cloudflareService = CloudflareStreamService();
  final ExerciseMediaResolver _exerciseMediaResolver = ExerciseMediaResolver();

  final List<_PlayableStep> _playableSteps = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isInitializingVideo = false;
  bool _isWorkoutComplete = false;
  bool _completionRecorded = false;
  bool _completionRecording = false;
  String? _completionError;
  String? _error;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _advancing = false;

  /// Drives auto-advance for the *current* step, whether it's a real video
  /// or a GIF preview: the clip loops (or the GIF stays put) while this
  /// counts down the step's prescribed duration, so a workout stays a real
  /// timed session instead of just cutting away whenever a short demo clip
  /// happens to finish playing.
  Timer? _stepAdvanceTimer;

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

    _stepAdvanceTimer?.cancel();
    _stepAdvanceTimer = null;
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isWorkoutComplete = false;
      _completionRecorded = false;
      _completionRecording = false;
      _completionError = null;
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
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _error = toUserFriendlyMessage(
        e,
        l10n: l10n,
        fallback: l10n.playerLoadRoutineFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<_PlayableStep>> _resolvePlayableSteps(
    List<RoutineStep> steps,
  ) async {
    final out = <_PlayableStep>[];

    for (final step in steps) {
      if (!Env.suspendRealVideos) {
        final videoStep = await _resolveVideoStep(step);
        if (videoStep != null) {
          out.add(videoStep);
          continue;
        }
      }

      if (Env.enableGifFallback) {
        final gifStep = await _resolveGifStep(step);
        if (gifStep != null) {
          out.add(gifStep);
          continue;
        }
      }
      // No real video and no stock GIF match; skip so the player keeps
      // moving through steps that do have something to show.
    }

    return out;
  }

  Future<_PlayableStep?> _resolveVideoStep(RoutineStep step) async {
    final id = (step.videoId ?? '').trim();
    if (id.isEmpty) return null;

    try {
      final video = await _supabaseService.getVideoByAnyId(id);

      // Prefer DB playback_url (works for both Cloudflare and external sources).
      if (video != null && video.playbackUrl.isNotEmpty) {
        final url = video.playbackUrl.toLowerCase();
        final looksLikeHls =
            url.contains('.m3u8') ||
            url.contains('cloudflarestream.com') ||
            url.contains('videodelivery.net');
        // Prevent infinite loading when a Cloudflare HLS URL exists but the asset is still processing.
        if (looksLikeHls && !video.isReady) {
          return null;
        }
        return _PlayableStep(
          step: step,
          videoUrl: video.playbackUrl,
          thumbnailUrl: step.thumbnailUrl ?? video.thumbnailUrl,
        );
      }

      // Fallback: Cloudflare HLS manifest (only if we have a Cloudflare UID).
      final cloudflareId = (video != null && video.streamId.isNotEmpty)
          ? video.streamId
          : null;
      if (video != null &&
          video.isReady &&
          cloudflareId != null &&
          cloudflareId.isNotEmpty) {
        return _PlayableStep(
          step: step,
          videoUrl: _cloudflareService.getPlaybackUrl(cloudflareId),
          thumbnailUrl:
              step.thumbnailUrl ??
              video.thumbnailUrl ??
              _cloudflareService.getThumbnailUrl(cloudflareId),
        );
      }
    } catch (_) {
      // Fall through to the GIF fallback (or skip) below.
    }

    return null;
  }

  Future<_PlayableStep?> _resolveGifStep(RoutineStep step) async {
    try {
      final media = await _exerciseMediaResolver.resolveForStep(step);
      final gifUrl = media?.gifUrl;
      if (gifUrl == null || gifUrl.isEmpty) return null;
      return _PlayableStep(step: step, gifUrl: gifUrl);
    } catch (_) {
      return null;
    }
  }

  /// Safety net for the rare step with no prescribed duration: since there's
  /// no timer to drive advancement, fall back to moving on once the (single,
  /// non-looping) clip finishes playing.
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

    if (current.isGifFallback) {
      _advancing = false;
      setState(() {
        _isInitializingVideo = false;
      });
      _startStepAdvanceTimer(current.step.durationSeconds, fallback: 30);
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(current.videoUrl!),
      );
      _videoController = controller;

      await controller.initialize().timeout(widget.initTimeout);

      // A prescribed step duration (e.g. "60s of squats") is almost always
      // longer than the demo clip itself, so loop the clip and let a timer
      // -- not the clip ending -- decide when the step is actually done.
      final hasTimedDuration = current.step.durationSeconds > 0;
      controller.setLooping(hasTimedDuration);
      if (!hasTimedDuration) {
        controller.addListener(_onVideoTick);
      }

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: autoPlay,
        looping: hasTimedDuration,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        errorBuilder: (context, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context).playerVideoUnavailable,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );

      _advancing = false;
      if (hasTimedDuration) {
        _startStepAdvanceTimer(current.step.durationSeconds);
      }

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

  /// Schedules auto-advance after [seconds] (or [fallback] when [seconds] is
  /// unset), mirroring a real timed workout interval.
  void _startStepAdvanceTimer(int seconds, {int fallback = 0}) {
    final duration = seconds > 0 ? seconds : fallback;
    if (duration <= 0) return;
    _stepAdvanceTimer = Timer(Duration(seconds: duration), () {
      if (!_advancing) {
        _advancing = true;
        _next(autoPlay: true);
      }
    });
  }

  Future<void> _autoRecordCompletion() async {
    if (_completionRecorded || _completionRecording) return;

    final user = context.read<AuthProvider>().uiState.currentUser;
    if (user == null) return;

    setState(() {
      _completionRecording = true;
      _completionError = null;
    });

    try {
      await context.read<RoutineProvider>().recordCompletionForRoutine(
        userId: user.uid,
        routineId: widget.routine.id,
      );
      if (!mounted) return;
      setState(() {
        _completionRecorded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _completionError =
            'Could not save completion. Tap retry to update your streak.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _completionRecording = false;
        });
      }
    }
  }

  Future<void> _next({required bool autoPlay}) async {
    if (_currentIndex + 1 >= _playableSteps.length) {
      if (!mounted) return;
      setState(() {
        _isWorkoutComplete = true;
      });
      await _autoRecordCompletion();
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

  void _openSteps(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final theme = context.watch<ThemeProvider>();
        return SafeArea(
          child: Container(
            decoration: theme.glassDecoration.copyWith(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                      l10n.playerSteps,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.playerStepCounter(
                        _currentIndex + 1,
                        _playableSteps.length,
                      ),
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
                            : Icon(
                                Icons.check_circle_outline,
                                color: theme.textSecondary,
                              ),
                        title: Text(
                          item.step.title,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          item.isGifFallback
                              ? '${_formatDuration(item.step.durationSeconds)} • Preview'
                              : _formatDuration(item.step.durationSeconds),
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
    final l10n = AppLocalizations.of(context);
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
            tooltip: l10n.playerSteps,
            onPressed: () => _openSteps(l10n),
            icon: const Icon(Icons.list, color: Colors.white),
          ),
          IconButton(
            tooltip: l10n.routineDetails,
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
          ? _buildFatalError(l10n, theme)
          : Column(
              children: [
                Expanded(child: _buildPlayerArea(l10n, theme)),
                _buildBottomControls(l10n, theme),
              ],
            ),
    );
  }

  Widget _buildFatalError(AppLocalizations l10n, ThemeProvider theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 14),
            Text(
              l10n.playerNoPlayableVideos,
              style: const TextStyle(
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
              child: Text(l10n.actionRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerArea(AppLocalizations l10n, ThemeProvider theme) {
    if (_isWorkoutComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: theme.accentOrange, size: 56),
              const SizedBox(height: 12),
              Text(
                l10n.playerWorkoutComplete,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_completionRecording)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(theme.accentOrange),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.playerSavingStreak,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              else if (_completionRecorded)
                Text(
                  l10n.playerSavedStreak,
                  style: TextStyle(
                    color: theme.accentOrange,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else if (_completionError != null) ...[
                Text(
                  _completionError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _autoRecordCompletion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.accentOrange,
                      side: BorderSide(color: theme.accentOrange),
                    ),
                    child: Text(l10n.playerRetrySave),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isWorkoutComplete = false;
                    _currentIndex = 0;
                    _completionRecorded = false;
                    _completionError = null;
                  });
                  await _loadCurrentVideo(autoPlay: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.playerReplay),
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
            Text(
              l10n.loadingGeneric,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    final current = _playableSteps.isNotEmpty
        ? _playableSteps[_currentIndex]
        : null;

    if (current != null && current.isGifFallback) {
      return _buildGifPreview(l10n, theme, current);
    }

    final chewie = _chewieController;
    if (chewie == null) {
      return Center(
        child: Text(
          l10n.playerNotReady,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return Chewie(controller: chewie);
  }

  Widget _buildGifPreview(
    AppLocalizations l10n,
    ThemeProvider theme,
    _PlayableStep current,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: Image.network(
            current.gifUrl!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (context, _, __) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.playerPreviewUnavailable,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(theme.accentOrange),
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              l10n.routinePreviewBanner,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n, ThemeProvider theme) {
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex + 1 < _playableSteps.length;
    final current = _playableSteps.isNotEmpty
        ? _playableSteps[_currentIndex]
        : null;

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
            l10n.playerClipCounter(
              _currentIndex + 1,
              _playableSteps.length,
              _formatDuration(current?.step.durationSeconds ?? 0),
            ),
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _playableSteps.isEmpty
                ? 0
                : (_currentIndex + 1) / _playableSteps.length,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(theme.accentOrange),
            minHeight: 6,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: hasPrev ? () => _prev(autoPlay: true) : null,
                icon: Icon(
                  Icons.skip_previous,
                  color: hasPrev ? Colors.white : Colors.white24,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: hasNext ? () => _next(autoPlay: true) : null,
                icon: Icon(
                  Icons.skip_next,
                  color: hasNext ? Colors.white : Colors.white24,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openSteps(l10n),
                icon: Icon(Icons.list, color: theme.accentOrange),
                label: Text(
                  l10n.playerSteps,
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
