import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../config/env.dart';
import '../../l10n/app_localizations.dart';
import '../../models/routine.dart';
import '../../models/workout_session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/celia_voice_coach.dart';
import '../../services/exercise_clip_library.dart';
import '../../services/exercise_media_resolver.dart';
import '../../services/workout_coach.dart';
import '../../utils/user_facing_error.dart';
import '../../utils/responsive.dart';

/// Runs a routine as a coached session rather than a playlist.
///
/// The demo clip loops underneath while the app counts the prescribed reps,
/// holds the clock for timed exercises, and rests alongside the user between
/// sets before calling them back in for the next one.
class GuidedWorkoutScreen extends StatefulWidget {
  const GuidedWorkoutScreen({
    super.key,
    required this.routine,
    this.coach,
    this.initTimeout = const Duration(seconds: 20),
  });

  final Routine routine;

  /// Injectable so tests can run a workout without touching audio or haptics.
  final WorkoutCoach? coach;

  final Duration initTimeout;

  @override
  State<GuidedWorkoutScreen> createState() => _GuidedWorkoutScreenState();
}

class _GuidedWorkoutScreenState extends State<GuidedWorkoutScreen>
    with WidgetsBindingObserver {
  static const Duration _tick = Duration(milliseconds: 100);

  /// How far out from the end of a phase the countdown starts being called.
  static const int _finalSecondsCue = 3;

  final ExerciseClipLibrary _clips = ExerciseClipLibrary();
  final ExerciseMediaResolver _gifs = ExerciseMediaResolver();

  WorkoutCoach? _coach;
  CeliaVoiceCoach? _voiceCoach;

  WorkoutPlan _plan = const WorkoutPlan([]);
  final Map<int, String> _gifByStepIndex = {};

  int _phaseIndex = 0;
  bool _isLoading = true;
  bool _isPaused = false;
  bool _isComplete = false;
  String? _error;

  /// The clock for the current phase. A stopwatch rather than a countdown
  /// timer so a pause is exact and resumes where it left off.
  final Stopwatch _phaseClock = Stopwatch();
  Timer? _ticker;

  int? _lastSpokenRep;
  int? _lastSpokenSecond;

  VideoPlayerController? _video;
  String? _loadedClipUrl;
  VoidCallback? _videoListener;

  /// Set once a hold clip has finished its single play-through so we never
  /// seek/play it again during that hold (repeated seek looked like a glitch).
  bool _holdClipPinned = false;

  bool _completionRecorded = false;
  bool _completionSaving = false;
  String? _completionError;

  WorkoutPhase? get _phase =>
      _plan.phases.isEmpty || _phaseIndex >= _plan.phases.length
      ? null
      : _plan.phases[_phaseIndex];

  Duration get _elapsed => _phaseClock.elapsed;

  Duration get _remaining {
    final phase = _phase;
    if (phase == null) return Duration.zero;
    final left = phase.duration - _elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_coach != null) return;
    _coach = _createCoach();
    _prepare();
  }

  WorkoutCoach _createCoach() {
    final injected = widget.coach;
    if (injected != null) return injected;
    if (!Env.enableVoiceCoach) return HapticCoach();

    final voice = CeliaVoiceCoach(l10n: AppLocalizations.of(context));
    _voiceCoach = voice;
    unawaited(voice.warmUp());
    return voice;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _coach?.stop();
    unawaited(_voiceCoach?.dispose());
    _detachVideoListener();
    _video?.dispose();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app mid-set should not leave the count running on without
    // the user; they come back to exactly where they stopped.
    if (state != AppLifecycleState.resumed && !_isPaused && !_isComplete) {
      _setPaused(true);
    }
  }

  Future<void> _prepare() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prepared = <PreparedExercise>[];

      for (final step in widget.routine.steps) {
        final clip = await _clips.resolveForStep(step);
        prepared.add(PreparedExercise(step: step, clip: clip));

        // Steps the filmed library does not cover still run as real timed
        // work; a stock GIF just stands in for the demonstration. Dropping
        // them would silently shorten the workout the user was promised.
        if (clip == null && Env.enableGifFallback) {
          final media = await _gifs.resolveForStep(step);
          final gifUrl = media?.gifUrl;
          if (gifUrl != null && gifUrl.isNotEmpty) {
            _gifByStepIndex[prepared.length - 1] = gifUrl;
          }
        }
      }

      if (!mounted) return;
      if (prepared.isEmpty) {
        throw Exception(AppLocalizations.of(context).guidedNoExercises);
      }

      _plan = WorkoutPlan.from(prepared);
      _phaseIndex = 0;

      setState(() => _isLoading = false);
      await WakelockPlus.enable();
      await _enterPhase(0);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _error = toUserFriendlyMessage(
          e,
          l10n: l10n,
          fallback: l10n.guidedStartFailed,
        );
      });
    }
  }

  Future<void> _enterPhase(int index) async {
    if (index >= _plan.phases.length) {
      await _finish();
      return;
    }

    final phase = _plan.phases[index];

    setState(() {
      _phaseIndex = index;
      _lastSpokenRep = null;
      _lastSpokenSecond = null;
      _holdClipPinned = false;
    });

    await _loadClipFor(phase);

    _phaseClock
      ..reset()
      ..start();
    _isPaused = false;
    _startTicker();

    // Start the demo before Celia speaks. Voice coaching is mixed with the
    // video, but starting speech first still races the player into a paused
    // state on some devices when focus is first claimed.
    await _applyPlaybackForPhase(phase, fromStart: true);
    _coach?.onPhaseStart(phase);
  }

  /// Reps loop with the user. Holds play through once, then freeze on the
  /// final frame for the rest of the timer — never looped, never scrubbed.
  Future<void> _applyPlaybackForPhase(
    WorkoutPhase phase, {
    required bool fromStart,
  }) async {
    final video = _video;
    if (video == null) return;

    _detachVideoListener();

    if (phase.kind != WorkoutPhaseKind.work) {
      await video.setLooping(false);
      await video.pause();
      await video.seekTo(Duration.zero);
      return;
    }

    if (phase.isCounted) {
      _holdClipPinned = false;
      await video.setLooping(true);
      if (fromStart) await video.seekTo(Duration.zero);
      await video.play();
      return;
    }

    // Hold: one clean play-through, then stay on the last frame.
    await video.setLooping(false);
    if (_holdClipPinned) {
      await video.pause();
      return;
    }

    if (fromStart) {
      await video.seekTo(Duration.zero);
      _attachHoldCompletionListener(video);
      await video.play();
      return;
    }

    // Resume after a user pause: continue only if the one-shot is unfinished.
    if (video.value.isCompleted || _holdClipFinished(video)) {
      await _pinHoldLastFrame(video);
    } else {
      _attachHoldCompletionListener(video);
      await video.play();
    }
  }

  void _attachHoldCompletionListener(VideoPlayerController video) {
    _detachVideoListener();
    void listener() {
      if (_holdClipPinned) return;
      if (!video.value.isInitialized) return;
      if (!(video.value.isCompleted || _holdClipFinished(video))) return;
      _detachVideoListener();
      unawaited(_pinHoldLastFrame(video));
    }

    _videoListener = listener;
    video.addListener(listener);
  }

  void _detachVideoListener() {
    final video = _video;
    final listener = _videoListener;
    if (video != null && listener != null) {
      video.removeListener(listener);
    }
    _videoListener = null;
  }

  bool _holdClipFinished(VideoPlayerController video) {
    final duration = video.value.duration;
    if (duration <= Duration.zero) return false;
    return video.value.position >=
        duration - const Duration(milliseconds: 120);
  }

  Future<void> _pinHoldLastFrame(VideoPlayerController video) async {
    if (_holdClipPinned) return;
    _holdClipPinned = true;
    final duration = video.value.duration;
    // Pause first so ExoPlayer cannot restart; then settle on the last frame
    // only if the player reset the playhead (common on completion).
    await video.pause();
    await video.setLooping(false);
    if (duration > Duration.zero &&
        video.value.position < duration - const Duration(milliseconds: 120)) {
      await video.seekTo(duration);
      await video.pause();
    }
  }

  Future<void> _loadClipFor(WorkoutPhase phase) async {
    final url = phase.clip?.videoUrl;

    if (url == null) {
      await _video?.pause();
      return;
    }
    // Sets of the same exercise share one controller, so only a genuine
    // change of exercise pays the cost of setting up a new one.
    if (url == _loadedClipUrl && _video != null) {
      await _video!.setLooping(false);
      return;
    }

    final previous = _video;
    _detachVideoListener();
    _video = null;
    _loadedClipUrl = null;
    await previous?.dispose();

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        // Keep the muted demo mixable while Celia's TTS claims the speaker.
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await controller.initialize().timeout(widget.initTimeout);
      await controller.setLooping(false);
      await controller.setVolume(0);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _video = controller;
        _loadedClipUrl = url;
      });
    } catch (_) {
      // A clip that will not load is not worth abandoning the workout over:
      // the count and the clock carry the session on their own.
      if (mounted) setState(() => _loadedClipUrl = null);
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    final phase = _phase;
    if (phase == null || _isPaused) return;

    if (_elapsed >= phase.duration) {
      unawaited(_enterPhase(_phaseIndex + 1));
      return;
    }

    // If TTS briefly stole focus and froze ExoPlayer, nudge counted demos
    // back into motion. Holds are handled by a one-shot completion listener.
    _ensureDemoPlaying(phase);

    if (phase.isCounted) {
      final rep = phase.repAt(_elapsed);
      if (rep != null && rep != _lastSpokenRep) {
        _lastSpokenRep = rep;
        _coach?.onRep(rep, phase.reps!);
      }
    } else {
      final secondsLeft = _remaining.inSeconds + 1;
      if (secondsLeft <= _finalSecondsCue && secondsLeft != _lastSpokenSecond) {
        _lastSpokenSecond = secondsLeft;
        _coach?.onFinalSeconds(secondsLeft);
      }
    }

    setState(() {});
  }

  void _ensureDemoPlaying(WorkoutPhase phase) {
    // Only counted sets need the loop kept alive. Holds play once via their
    // own completion listener; touching them here caused the glitchy replay.
    if (phase.kind != WorkoutPhaseKind.work || !phase.isCounted) return;
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    if (video.value.isPlaying) return;
    unawaited(video.play());
  }

  void _setPaused(bool paused) {
    setState(() => _isPaused = paused);
    if (paused) {
      _phaseClock.stop();
      _coach?.stop();
      unawaited(_video?.pause());
    } else {
      _phaseClock.start();
      _voiceCoach?.resume();
      final phase = _phase;
      if (phase != null) {
        unawaited(_applyPlaybackForPhase(phase, fromStart: false));
      }
    }
  }

  Future<void> _skip(int delta) async {
    final target = _phaseIndex + delta;
    if (target < 0) return;
    await _enterPhase(target);
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _phaseClock.stop();
    await _video?.pause();
    _coach?.onComplete();
    unawaited(WakelockPlus.disable());

    if (!mounted) return;
    setState(() => _isComplete = true);
    await _recordCompletion();
  }

  Future<void> _recordCompletion() async {
    if (_completionRecorded || _completionSaving) return;

    final l10n = AppLocalizations.of(context);
    final user = context.read<AuthProvider>().uiState.currentUser;
    if (user == null) return;

    setState(() {
      _completionSaving = true;
      _completionError = null;
    });

    try {
      await context.read<RoutineProvider>().recordCompletionForRoutine(
        userId: user.uid,
        routineId: widget.routine.id,
      );
      if (!mounted) return;
      setState(() => _completionRecorded = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _completionError = l10n.guidedSaveFailed);
    } finally {
      if (mounted) setState(() => _completionSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmQuit(l10n, theme);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: _buildBody(l10n, theme)),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeProvider theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(theme.accentOrange),
        ),
      );
    }
    if (_error != null) return _buildError(l10n, theme);
    if (_isComplete) return _buildComplete(l10n, theme);

    final phase = _phase;
    if (phase == null) return const SizedBox.shrink();

    final landscapeTablet = context.isTablet && context.isLandscape;

    if (landscapeTablet) {
      return Column(
        children: [
          _buildHeader(l10n, theme, phase),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildStage(
                    l10n,
                    theme,
                    phase,
                    overlaysOnVideo: false,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: _buildLandscapeSidePanel(l10n, theme, phase)),
                      _buildControls(theme, phase),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHeader(l10n, theme, phase),
        Expanded(child: _buildStage(l10n, theme, phase)),
        _buildControls(theme, phase),
      ],
    );
  }

  /// Side column for tablet landscape: cue text without covering the demo.
  Widget _buildLandscapeSidePanel(
    AppLocalizations l10n,
    ThemeProvider theme,
    WorkoutPhase phase,
  ) {
    if (phase.kind == WorkoutPhaseKind.rest) {
      return _buildRest(l10n, theme, phase);
    }
    if (phase.kind == WorkoutPhaseKind.getReady) {
      return _buildScrim(l10n, theme, phase);
    }
    return ColoredBox(
      color: Colors.black,
      child: Center(child: _buildWorkOverlay(l10n, theme, phase)),
    );
  }

  Widget _buildHeader(
    AppLocalizations l10n,
    ThemeProvider theme,
    WorkoutPhase phase,
  ) {
    final progress = _plan.phases.isEmpty
        ? 0.0
        : (_phaseIndex + 1) / _plan.phases.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _confirmQuit(l10n, theme),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  widget.routine.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                l10n.guidedExerciseCounter(
                  phase.stepIndex + 1,
                  phase.totalSteps,
                ),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(theme.accentOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(
    AppLocalizations l10n,
    ThemeProvider theme,
    WorkoutPhase phase, {
    bool overlaysOnVideo = true,
  }) {
    if (phase.kind == WorkoutPhaseKind.rest && overlaysOnVideo) {
      return _buildRest(l10n, theme, phase);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildDemo(phase),
        if (overlaysOnVideo) ...[
          if (phase.kind == WorkoutPhaseKind.getReady)
            _buildScrim(l10n, theme, phase)
          else if (phase.kind != WorkoutPhaseKind.rest)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildWorkOverlay(l10n, theme, phase),
            ),
        ],
        if (_isPaused) _buildPausedVeil(l10n, theme),
      ],
    );
  }

  Widget _buildDemo(WorkoutPhase phase) {
    final video = _video;
    if (video != null && video.value.isInitialized) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: video.value.aspectRatio,
            child: VideoPlayer(video),
          ),
        ),
      );
    }

    final gifUrl = _gifByStepIndex[phase.stepIndex];
    if (gifUrl != null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Image.network(gifUrl, fit: BoxFit.contain, gaplessPlayback: true),
        ),
      );
    }

    final poster = phase.clip?.posterUrl;
    if (poster != null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(child: Image.network(poster, fit: BoxFit.contain)),
      );
    }

    return const ColoredBox(color: Colors.black);
  }

  Widget _buildScrim(
    AppLocalizations l10n,
    ThemeProvider theme,
    WorkoutPhase phase,
  ) {
    return Container(
      color: Colors.black.withValues(alpha: 0.66),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.guidedGetReady,
              style: const TextStyle(
                color: Colors.white70,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_remaining.inSeconds + 1}',
              style: TextStyle(
                color: theme.accentOrange,
                fontSize: 88,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                phase.step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _prescriptionLabel(l10n, phase),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOverlay(
    AppLocalizations l10n,
    ThemeProvider theme,
    WorkoutPhase phase,
  ) {
    final rep = phase.repAt(_elapsed);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phase.step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.guidedSetOf(phase.setNumber, phase.totalSets),
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (rep != null)
            _BigReadout(
              value: '$rep',
              caption: l10n.guidedOfReps(phase.reps!),
              colour: theme.accentOrange,
            )
          else
            _BigReadout(
              value: _clock(_remaining),
              caption: l10n.guidedHold,
              colour: theme.accentOrange,
            ),
        ],
      ),
    );
  }

  Widget _buildRest(
    AppLocalizations l10n,
    ThemeProvider theme,
    WorkoutPhase phase,
  ) {
    return Container(
      color: const Color(0xFF06131C),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.guidedRest,
            style: const TextStyle(
              color: Colors.white70,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _clock(_remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 76,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            phase.setNumber < phase.totalSets
                ? l10n.guidedNextSet
                : l10n.guidedUpNext,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            phase.nextLabel ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          OutlinedButton.icon(
            onPressed: () => _skip(1),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.accentOrange,
              side: BorderSide(color: theme.accentOrange),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.guidedSkipRest),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedVeil(AppLocalizations l10n, ThemeProvider theme) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, color: Colors.white, size: 64),
            const SizedBox(height: 10),
            Text(
              l10n.guidedPaused,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _setPaused(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentOrange,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.guidedResume),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ThemeProvider theme, WorkoutPhase phase) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            iconSize: 32,
            onPressed: _phaseIndex > 0 ? () => _skip(-1) : null,
            icon: Icon(
              Icons.skip_previous,
              color: _phaseIndex > 0 ? Colors.white : Colors.white24,
            ),
          ),
          ElevatedButton(
            onPressed: () => _setPaused(!_isPaused),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentOrange,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(18),
            ),
            child: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 30),
          ),
          IconButton(
            iconSize: 32,
            onPressed: () => _skip(1),
            icon: const Icon(Icons.skip_next, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildComplete(AppLocalizations l10n, ThemeProvider theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: theme.accentOrange, size: 64),
            const SizedBox(height: 14),
            Text(
              l10n.guidedWorkoutComplete,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_completionSaving)
              Text(
                l10n.playerSavingStreak,
                style: const TextStyle(color: Colors.white70),
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
              OutlinedButton(
                onPressed: _recordCompletion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accentOrange,
                  side: BorderSide(color: theme.accentOrange),
                ),
                child: Text(l10n.playerRetrySave),
              ),
            ],
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 13,
                ),
              ),
              child: Text(l10n.actionDone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, ThemeProvider theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _prepare,
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

  Future<void> _confirmQuit(
    AppLocalizations l10n,
    ThemeProvider theme,
  ) async {
    if (_isComplete) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final wasPaused = _isPaused;
    if (!wasPaused) _setPaused(true);

    final quit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF15202B),
        title: Text(
          l10n.guidedEndTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.guidedEndBody,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.guidedKeepGoing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.guidedEnd,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (quit == true) {
      Navigator.of(context).pop();
    } else if (!wasPaused) {
      _setPaused(false);
    }
  }

  String _prescriptionLabel(AppLocalizations l10n, WorkoutPhase phase) {
    if (phase.isCounted || (phase.reps ?? 0) > 0) {
      return '${phase.totalSets} × ${l10n.guidedReps(phase.reps!)}';
    }
    final workPhase = _plan.phases.firstWhere(
      (candidate) =>
          candidate.stepIndex == phase.stepIndex &&
          candidate.kind == WorkoutPhaseKind.work,
      orElse: () => phase,
    );
    return l10n.guidedSetsHold(
      phase.totalSets,
      workPhase.duration.inSeconds,
    );
  }

  String _clock(Duration duration) {
    final total = duration.inSeconds;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    if (minutes == 0) return '$seconds';
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _BigReadout extends StatelessWidget {
  const _BigReadout({
    required this.value,
    required this.caption,
    required this.colour,
  });

  final String value;
  final String caption;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: colour,
            fontSize: 72,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(caption, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
