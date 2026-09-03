import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/body_scan.dart';
import '../../models/nutrition_profile.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/body_scan_service.dart';
import '../../widgets/body_scan_sources_citation.dart';
import 'widgets/body_silhouette_overlay.dart';

enum _Step { consent, stats, capture, processing, result }

/// The end-to-end body scan: consent, stats, two guided photos, results.
///
/// Kept as one screen with an explicit step so the photos never outlive the
/// flow — they are held in memory here and dropped when this widget is
/// disposed, which is the promise the consent step makes.
class BodyScanFlowScreen extends StatefulWidget {
  const BodyScanFlowScreen({super.key});

  @override
  State<BodyScanFlowScreen> createState() => _BodyScanFlowScreenState();
}

class _BodyScanFlowScreenState extends State<BodyScanFlowScreen>
    with WidgetsBindingObserver {
  final BodyScanService _service = BodyScanService();

  _Step _step = _Step.consent;
  bool _consentGiven = false;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  NutritionGender _sex = NutritionGender.female;

  CameraController? _camera;
  bool _initializingCamera = false;
  String? _cameraError;

  BodyScanPose _pose = BodyScanPose.front;
  List<int>? _frontPhoto;
  List<int>? _rightPhoto;

  Timer? _countdown;
  int _secondsLeft = 0;

  BodyScan? _result;
  BodyScanQuota? _quota;
  String? _error;
  bool _errorIsRetakeable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final profile = context.read<NutritionProfileProvider>().profile;
    if (profile != null) {
      _heightController.text = profile.heightCm.round().toString();
      _weightController.text = profile.weightKg.toStringAsFixed(1);
      _ageController.text = profile.age.toString();
      // NutritionGender.other has no vendor equivalent, so the user picks on
      // the stats step rather than being silently assigned one.
      if (profile.gender != NutritionGender.other) _sex = profile.gender;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdown?.cancel();
    _camera?.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_step != _Step.capture) return;
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cancelCountdown();
      camera.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializingCamera = true;
      _cameraError = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('no-camera');

      // Back camera: the phone has to be propped up for a full-body shot, so
      // the user is never holding it and the selfie camera buys nothing.
      final lens = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        lens,
        // Silhouette accuracy benefits from the extra detail, and two 1080p
        // JPEGs still fit inside the request body limit.
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _initializingCamera = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _initializingCamera = false;
        _cameraError = e.toString().contains('CameraAccessDenied')
            ? l10n.bodyScanErrorCameraPermission
            : l10n.bodyScanErrorNoCamera;
      });
    }
  }

  void _startCountdown() {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || _secondsLeft > 0) return;

    HapticFeedback.lightImpact();
    setState(() => _secondsLeft = 8);

    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        await _capture();
        return;
      }
      HapticFeedback.selectionClick();
      setState(() => _secondsLeft -= 1);
    });
  }

  void _cancelCountdown() {
    _countdown?.cancel();
    _countdown = null;
    if (mounted && _secondsLeft != 0) setState(() => _secondsLeft = 0);
  }

  Future<void> _capture() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    if (camera.value.isTakingPicture) return;

    try {
      final file = await camera.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;

      HapticFeedback.mediumImpact();
      setState(() {
        if (_pose == BodyScanPose.front) {
          _frontPhoto = bytes;
        } else {
          _rightPhoto = bytes;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = e.toString());
    }
  }

  Future<void> _submit() async {
    final front = _frontPhoto;
    final right = _rightPhoto;
    if (front == null || right == null) return;

    setState(() {
      _step = _Step.processing;
      _error = null;
    });

    // The preview is no longer needed and holding the camera open through a
    // 90-second request keeps the sensor warm for nothing.
    await _camera?.dispose();
    _camera = null;

    try {
      final result = await _service.submitScan(
        frontJpegBytes: front,
        rightJpegBytes: right,
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _sex,
        heightCm: double.tryParse(_heightController.text.trim()) ?? 0,
        weightKg: double.tryParse(_weightController.text.trim()) ?? 0,
      );
      if (!mounted) return;
      setState(() {
        _result = result.scan;
        _quota = result.quota;
        _step = _Step.result;
        // Photos have served their purpose; drop them.
        _frontPhoto = null;
        _rightPhoto = null;
      });
    } on BodyScanException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _messageFor(e);
        _errorIsRetakeable = e.isRetakeable;
        _step = _Step.capture;
        if (e.isRetakeable) {
          _frontPhoto = null;
          _rightPhoto = null;
          _pose = BodyScanPose.front;
        }
      });
      if (_errorIsRetakeable) await _initCamera();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = l10n.bodyScanErrorServer;
        _errorIsRetakeable = false;
        _step = _Step.capture;
      });
    }
  }

  String _messageFor(BodyScanException e) {
    final l10n = AppLocalizations.of(context);
    return switch (e.error) {
      BodyScanError.photoFraming => l10n.bodyScanErrorFraming,
      BodyScanError.photoQuality => l10n.bodyScanErrorQuality,
      BodyScanError.photoPose => l10n.bodyScanErrorPose,
      BodyScanError.photoClothing => l10n.bodyScanErrorClothing,
      BodyScanError.photoUnknown => l10n.bodyScanErrorPhotoUnknown,
      BodyScanError.photosTooLarge => l10n.bodyScanErrorPhotosTooLarge,
      BodyScanError.quotaExhausted => l10n.bodyScanErrorQuota,
      BodyScanError.notEligibleAge => l10n.bodyScanErrorAge,
      BodyScanError.invalidStats => l10n.bodyScanErrorStats,
      BodyScanError.notSignedIn => l10n.bodyScanErrorSignedIn,
      BodyScanError.notConfigured => l10n.bodyScanErrorUnavailable,
      BodyScanError.network => l10n.bodyScanErrorNetwork,
      BodyScanError.server => l10n.bodyScanErrorServer,
    };
  }

  bool get _statsAreValid {
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final age = int.tryParse(_ageController.text.trim());
    return height != null &&
        height >= 50 &&
        height <= 250 &&
        weight != null &&
        weight >= 10 &&
        weight <= 200 &&
        age != null &&
        age >= BodyScanService.minimumAge &&
        age <= 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

    // The capture step owns the whole screen: a camera preview inside a card
    // gives the user no idea what is actually in frame.
    if (_step == _Step.capture) return _buildCaptureStep(theme, l10n);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        foregroundColor: theme.textPrimary,
        title: Text(l10n.bodyScanTitle),
      ),
      body: SafeArea(
        child: switch (_step) {
          _Step.consent => _buildConsentStep(theme, l10n),
          _Step.stats => _buildStatsStep(theme, l10n),
          _Step.processing => _buildProcessingStep(theme, l10n),
          _Step.result => _buildResultStep(theme, l10n),
          _Step.capture => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildConsentStep(ThemeProvider theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text(
          l10n.bodyScanConsentTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bodyScanConsentBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 20),
        _consentPoint(
          theme,
          Icons.photo_camera_outlined,
          l10n.bodyScanConsentPhotosTitle,
          l10n.bodyScanConsentPhotosBody,
        ),
        _consentPoint(
          theme,
          Icons.cloud_upload_outlined,
          l10n.bodyScanConsentProcessingTitle,
          l10n.bodyScanConsentProcessingBody,
        ),
        _consentPoint(
          theme,
          Icons.lock_outline,
          l10n.bodyScanConsentStorageTitle,
          l10n.bodyScanConsentStorageBody,
        ),
        _consentPoint(
          theme,
          Icons.person_outline,
          l10n.bodyScanConsentAgeTitle,
          l10n.bodyScanConsentAgeBody,
        ),
        const SizedBox(height: 8),
        BodyScanSourcesCitation(theme: theme, compact: true),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: _consentGiven,
          onChanged: (v) => setState(() => _consentGiven = v ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: theme.accentOrange,
          title: Text(
            l10n.bodyScanConsentAgree,
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        _primaryButton(
          theme,
          label: l10n.bodyScanContinue,
          onPressed: _consentGiven ? () => setState(() => _step = _Step.stats) : null,
        ),
      ],
    );
  }

  Widget _consentPoint(
    ThemeProvider theme,
    IconData icon,
    String title,
    String body,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.accentOrange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: theme.accentOrange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    color: theme.textSecondary,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsStep(ThemeProvider theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text(
          l10n.bodyScanStatsTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bodyScanStatsBody,
          style: TextStyle(color: theme.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 24),
        _numberField(theme, l10n.bodyScanStatsHeight, _heightController, 'cm'),
        _numberField(theme, l10n.bodyScanStatsWeight, _weightController, 'kg'),
        _numberField(theme, l10n.bodyScanStatsAge, _ageController, ''),
        const SizedBox(height: 8),
        Text(
          l10n.bodyScanStatsSex,
          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.bodyScanStatsSexNote,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _sexChoice(theme, NutritionGender.female, l10n.bodyScanStatsFemale),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sexChoice(theme, NutritionGender.male, l10n.bodyScanStatsMale),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _primaryButton(
          theme,
          label: l10n.bodyScanContinue,
          onPressed: _statsAreValid
              ? () {
                  setState(() => _step = _Step.capture);
                  _initCamera();
                }
              : null,
        ),
        if (!_statsAreValid) ...[
          const SizedBox(height: 12),
          Text(
            l10n.bodyScanStatsInvalid,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
          ),
        ],
      ],
    );
  }

  Widget _numberField(
    ThemeProvider theme,
    String label,
    TextEditingController controller,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix.isEmpty ? null : suffix,
          labelStyle: TextStyle(color: theme.textSecondary),
          suffixStyle: TextStyle(color: theme.textSecondary),
          filled: true,
          fillColor: theme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.accentOrange, width: 1.6),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _sexChoice(ThemeProvider theme, NutritionGender value, String label) {
    final selected = _sex == value;
    return InkWell(
      onTap: () => setState(() => _sex = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.accentOrange.withValues(alpha: 0.14) : theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.accentOrange : theme.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? theme.accentOrange : theme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureStep(ThemeProvider theme, AppLocalizations l10n) {
    final camera = _camera;
    final photo = _pose == BodyScanPose.front ? _frontPhoto : _rightPhoto;
    final bothTaken = _frontPhoto != null && _rightPhoto != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (camera != null && camera.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: camera.value.previewSize?.height ?? 1080,
                height: camera.value.previewSize?.width ?? 1920,
                child: CameraPreview(camera),
              ),
            )
          else
            Center(
              child: _initializingCamera
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _cameraError ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
            ),

          if (photo == null && camera != null && camera.value.isInitialized)
            BodySilhouetteOverlay(pose: _pose, aligned: _secondsLeft > 0),

          if (_secondsLeft > 0)
            Center(
              child: Text(
                '$_secondsLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                _captureHeader(l10n),
                const Spacer(),
                if (_error != null) _captureError(l10n),
                _captureControls(theme, l10n, photo, bothTaken),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _captureHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _cancelCountdown();
              Navigator.of(context).maybePop();
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pose == BodyScanPose.front
                      ? l10n.bodyScanCaptureFrontTitle
                      : l10n.bodyScanCaptureRightTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.bodyScanCaptureHowTo,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _captureError(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Text(
        _error!,
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
      ),
    );
  }

  Widget _captureControls(
    ThemeProvider theme,
    AppLocalizations l10n,
    List<int>? photo,
    bool bothTaken,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _poseDot(l10n.bodyScanPoseFront, _frontPhoto != null, _pose == BodyScanPose.front),
              const SizedBox(width: 12),
              _poseDot(l10n.bodyScanPoseRight, _rightPhoto != null, _pose == BodyScanPose.right),
            ],
          ),
          const SizedBox(height: 16),
          if (photo == null) ...[
            Text(
              l10n.bodyScanCaptureTips,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            _primaryButton(
              theme,
              label: _secondsLeft > 0
                  ? l10n.bodyScanCancelTimer
                  : l10n.bodyScanStartTimer,
              onPressed: _camera == null
                  ? null
                  : (_secondsLeft > 0 ? _cancelCountdown : _startCountdown),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      if (_pose == BodyScanPose.front) {
                        _frontPhoto = null;
                      } else {
                        _rightPhoto = null;
                      }
                    }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(l10n.bodyScanRetake),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _primaryButton(
                    theme,
                    label: bothTaken
                        ? l10n.bodyScanGetResults
                        : l10n.bodyScanNextPose,
                    onPressed: () {
                      if (bothTaken) {
                        _submit();
                      } else {
                        setState(() => _pose = BodyScanPose.right);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _poseDot(String label, bool done, bool active) {
    final color = done
        ? const Color(0xFF4ADE80)
        : (active ? Colors.white : Colors.white38);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStep(ThemeProvider theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.accentOrange),
            const SizedBox(height: 28),
            Text(
              l10n.bodyScanProcessingTitle,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.bodyScanProcessingBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStep(ThemeProvider theme, AppLocalizations l10n) {
    final scan = _result;
    if (scan == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text(
          l10n.bodyScanResultTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.bodyScanResultSubtitle,
          style: TextStyle(color: theme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        BodyScanMetricsGrid(theme: theme, scan: scan),
        const SizedBox(height: 20),
        BodyScanSourcesCitation(theme: theme),
        if (_quota != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n.bodyScanQuotaRemaining(_quota!.remaining),
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
          ),
        ],
        const SizedBox(height: 20),
        _primaryButton(
          theme,
          label: l10n.bodyScanDone,
          onPressed: () => Navigator.of(context).pop(scan),
        ),
      ],
    );
  }

  Widget _primaryButton(
    ThemeProvider theme, {
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.accentOrange.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }
}

/// The numbers from a scan, laid out as cards.
///
/// Shared between the flow's result step and the hub so the two can never
/// disagree about units or labelling.
class BodyScanMetricsGrid extends StatelessWidget {
  const BodyScanMetricsGrid({super.key, required this.theme, required this.scan});

  final ThemeProvider theme;
  final BodyScan scan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final metrics = <({String label, String value})>[
      if (scan.bodyFatPercentage != null)
        (
          label: l10n.bodyScanBodyFat,
          value: '${scan.bodyFatPercentage!.toStringAsFixed(1)}%',
        ),
      if (scan.leanMassKg != null)
        (
          label: l10n.bodyScanLeanMass,
          value: '${scan.leanMassKg!.toStringAsFixed(1)} kg',
        ),
      if (scan.bodyFatMassKg != null)
        (
          label: l10n.bodyScanFatMass,
          value: '${scan.bodyFatMassKg!.toStringAsFixed(1)} kg',
        ),
      if (scan.waistCm != null)
        (
          label: l10n.bodyScanWaist,
          value: '${scan.waistCm!.toStringAsFixed(1)} cm',
        ),
      if (scan.hipCm != null)
        (label: l10n.bodyScanHip, value: '${scan.hipCm!.toStringAsFixed(1)} cm'),
      if (scan.bustCm != null)
        (label: l10n.bodyScanChest, value: '${scan.bustCm!.toStringAsFixed(1)} cm'),
      if (scan.waistToHipRatio != null)
        (
          label: l10n.bodyScanWaistToHip,
          value: scan.waistToHipRatio!.toStringAsFixed(2),
        ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final metric in metrics)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 60) / 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    metric.value,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
