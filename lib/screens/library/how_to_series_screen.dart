import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/app_localizations.dart';
import '../../models/exercise_clip.dart';
import '../../models/workout_session.dart';
import '../../providers/theme_provider.dart';

enum _SeriesStage { playing, resting, done }

/// Plays a series of how-to demonstrations back to back. Each video plays
/// once at normal speed, never looped; a rest follows, then the next one
/// starts on its own. The user can pick which exercise comes next.
class HowToSeriesScreen extends StatefulWidget {
  const HowToSeriesScreen({
    super.key,
    required this.clips,
    required this.titleFor,
    this.initTimeout = const Duration(seconds: 20),
  });

  final List<ExerciseClip> clips;
  final String Function(ExerciseClip clip) titleFor;
  final Duration initTimeout;

  @override
  State<HowToSeriesScreen> createState() => _HowToSeriesScreenState();
}

class _HowToSeriesScreenState extends State<HowToSeriesScreen> {
  static const _curve = Cubic(0.34, 1.56, 0.64, 1);

  VideoPlayerController? _video;
  bool _videoFailed = false;
  int _current = 0;
  int? _upNext;
  int _playedCount = 0;
  final Set<int> _played = {};
  _SeriesStage _stage = _SeriesStage.playing;
  Timer? _restTimer;
  int _restLeft = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_play(0));
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _video?.removeListener(_onVideoTick);
    _video?.dispose();
    super.dispose();
  }

  int? _defaultNextAfter(int index) {
    final count = widget.clips.length;
    for (var step = 1; step <= count; step++) {
      final candidate = (index + step) % count;
      if (!_played.contains(candidate) && candidate != index) return candidate;
    }
    return null;
  }

  Future<void> _play(int index) async {
    _restTimer?.cancel();
    final previous = _video;
    previous?.removeListener(_onVideoTick);

    setState(() {
      _current = index;
      _stage = _SeriesStage.playing;
      _video = null;
      _videoFailed = false;
      _upNext = _defaultNextAfter(index);
    });
    await previous?.dispose();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.clips[index].videoUrl),
    );
    try {
      await controller.initialize().timeout(widget.initTimeout);
      await controller.setLooping(false);
      if (!mounted || _current != index) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onVideoTick);
      setState(() => _video = controller);
      await controller.play();
    } catch (_) {
      await controller.dispose();
      if (mounted && _current == index) setState(() => _videoFailed = true);
    }
  }

  void _onVideoTick() {
    final video = _video;
    if (video == null || _stage != _SeriesStage.playing) return;
    final value = video.value;
    if (!value.isInitialized || value.duration <= Duration.zero) return;
    final ended = value.isCompleted ||
        value.position >= value.duration - const Duration(milliseconds: 120);
    if (ended) _finishCurrent();
  }

  void _finishCurrent() {
    if (_stage != _SeriesStage.playing) return;
    _video?.removeListener(_onVideoTick);
    unawaited(_video?.pause());
    if (_played.add(_current)) _playedCount++;

    final next = _upNext != null && !_played.contains(_upNext)
        ? _upNext
        : _defaultNextAfter(_current);
    if (next == null) {
      setState(() => _stage = _SeriesStage.done);
      return;
    }

    final rest = restSecondsFor(
      stepIndex: _playedCount - 1,
      isLastSetOfExercise: true,
    );
    setState(() {
      _upNext = next;
      _stage = _SeriesStage.resting;
      _restLeft = rest;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_restLeft <= 1) {
        timer.cancel();
        unawaited(_play(_upNext!));
        return;
      }
      setState(() => _restLeft--);
    });
  }

  void _goNext() {
    HapticFeedback.lightImpact();
    switch (_stage) {
      case _SeriesStage.playing:
        _finishCurrent();
      case _SeriesStage.resting:
        unawaited(_play(_upNext!));
      case _SeriesStage.done:
        break;
    }
  }

  void _choose(int index) {
    if (index == _current && _stage == _SeriesStage.playing) return;
    HapticFeedback.lightImpact();
    switch (_stage) {
      case _SeriesStage.playing:
        setState(() => _upNext = index);
      case _SeriesStage.resting:
      case _SeriesStage.done:
        unawaited(_play(index));
    }
  }

  void _restart() {
    HapticFeedback.lightImpact();
    _played.clear();
    _playedCount = 0;
    unawaited(_play(0));
  }

  void _togglePlay() {
    final video = _video;
    if (video == null || _stage != _SeriesStage.playing) return;
    HapticFeedback.lightImpact();
    if (video.value.isPlaying) {
      unawaited(video.pause().then((_) => mounted ? setState(() {}) : null));
    } else {
      unawaited(video.play().then((_) => mounted ? setState(() {}) : null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final clip = widget.clips[_current];

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textPrimary),
        title: Text(
          l10n.howToSeriesTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Colors.black,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: _curve,
                  child: switch (_stage) {
                    _SeriesStage.playing => _buildVideo(l10n),
                    _SeriesStage.resting => _buildRest(l10n, theme),
                    _SeriesStage.done => _buildDone(l10n, theme),
                  },
                ),
              ),
            ),
            if (_stage == _SeriesStage.playing && _video != null)
              VideoProgressIndicator(
                _video!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: theme.accentOrange,
                  bufferedColor: theme.border,
                  backgroundColor: theme.surface,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_current + 1} / ${widget.clips.length}',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.titleFor(clip),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_stage != _SeriesStage.done)
                    FilledButton.icon(
                      onPressed: _goNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.accentOrange,
                        foregroundColor: Colors.black87,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: Text(l10n.howToNext),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                l10n.howToChooseNextHint,
                style: TextStyle(color: theme.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                itemCount: widget.clips.length,
                itemBuilder: (context, index) =>
                    _buildQueueItem(l10n, theme, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo(AppLocalizations l10n) {
    final video = _video;
    if (_videoFailed) {
      return Center(
        key: const ValueKey('failed'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              l10n.playerFailedToLoadVideo,
              style: const TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => _play(_current),
              child: Text(l10n.actionRetry),
            ),
          ],
        ),
      );
    }
    if (video == null) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }
    return GestureDetector(
      key: ValueKey('video-$_current'),
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: video.value.aspectRatio,
            child: VideoPlayer(video),
          ),
          if (!video.value.isPlaying)
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white70,
              size: 64,
            ),
        ],
      ),
    );
  }

  Widget _buildRest(AppLocalizations l10n, ThemeProvider theme) {
    final next = _upNext == null ? null : widget.clips[_upNext!];
    return Center(
      key: const ValueKey('rest'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.howToRest,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$_restLeft',
            style: TextStyle(
              color: theme.accentOrange,
              fontSize: 64,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (next != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.howToUpNext(widget.titleFor(next)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDone(AppLocalizations l10n, ThemeProvider theme) {
    return Center(
      key: const ValueKey('done'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: theme.accentOrange, size: 48),
          const SizedBox(height: 8),
          Text(
            l10n.howToSeriesDone,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              OutlinedButton(
                onPressed: _restart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: Text(l10n.howToPlayAgain),
              ),
              FilledButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.black87,
                  shape: const StadiumBorder(),
                ),
                child: Text(l10n.howToDone),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(
    AppLocalizations l10n,
    ThemeProvider theme,
    int index,
  ) {
    final clip = widget.clips[index];
    final isCurrent = index == _current && _stage == _SeriesStage.playing;
    final isNext = index == _upNext && _stage != _SeriesStage.done;
    final isPlayed = _played.contains(index);

    final Widget trailing;
    if (isCurrent) {
      trailing = Icon(Icons.graphic_eq, color: theme.accentOrange);
    } else if (isNext) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: ShapeDecoration(
          color: theme.accentOrange.withValues(alpha: 0.2),
          shape: const StadiumBorder(),
        ),
        child: Text(
          l10n.howToUpNextBadge,
          style: TextStyle(
            color: theme.accentOrange,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (isPlayed) {
      trailing = Icon(Icons.check, color: theme.textSecondary);
    } else {
      trailing = const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: _curve,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent || isNext ? theme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNext ? theme.accentOrange : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: () => _choose(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: clip.posterUrl == null
                ? ColoredBox(
                    color: const Color(0xFF1A1D2D),
                    child: Icon(Icons.fitness_center, color: theme.textSecondary),
                  )
                : Image.network(
                    clip.posterUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: const Color(0xFF1A1D2D),
                      child: Icon(
                        Icons.fitness_center,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
          ),
        ),
        title: Text(
          widget.titleFor(clip),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPlayed && !isCurrent
                ? theme.textSecondary
                : theme.textPrimary,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
