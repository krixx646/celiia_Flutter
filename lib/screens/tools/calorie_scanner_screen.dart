import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/meal_analysis.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/nutrition_tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/calorie_scanner_service.dart';
import 'nutrition_profile_setup_screen.dart';
import 'nutrition_screen.dart';

class CalorieScannerScreen extends StatefulWidget {
  const CalorieScannerScreen({super.key});

  @override
  State<CalorieScannerScreen> createState() => _CalorieScannerScreenState();
}

class _CalorieScannerScreenState extends State<CalorieScannerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _scanController;
  late final AnimationController _pulseController;
  final CalorieScannerService _scannerService = CalorieScannerService();

  CameraController? _cameraController;
  Timer? _scanTimer;
  MealAnalysis? _analysis;
  String? _error;
  bool _isInitializingCamera = true;
  bool _isAnalyzing = false;
  bool _isFlashOn = false;
  bool _isLogging = false;
  bool _isQuotaBlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = context.read<NutritionProfileProvider>().profile;
      context.read<NutritionTrackerProvider>().refresh(profile: profile);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _scanTimer?.cancel();
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializingCamera = true;
      _error = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No camera found on this device.');
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _cameraController = controller;
      setState(() => _isInitializingCamera = false);
      _startScanLoop();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isInitializingCamera = false;
        _error = _friendlyError(l10n, e);
      });
    }
  }

  void _startScanLoop() {
    _scanTimer?.cancel();
  }

  Future<void> _captureAndAnalyze({bool silent = false}) async {
    final l10n = AppLocalizations.of(context);
    final controller = _cameraController;
    if (_isAnalyzing ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      if (!silent) _error = null;
    });

    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      final analysis = await _scannerService.analyzeMealImage(jpegBytes: bytes);
      if (!mounted) return;
      setState(() {
        _analysis = analysis;
        _isQuotaBlocked = false;
        _error = analysis.items.isEmpty ? l10n.scannerNoClearFood : null;
      });
    } catch (e) {
      if (!mounted) return;
      final friendlyError = _friendlyError(l10n, e);
      setState(() {
        _error = friendlyError;
        _isQuotaBlocked = _isQuotaError(e);
      });
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    final next = !_isFlashOn;
    await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    if (mounted) setState(() => _isFlashOn = next);
  }

  Future<void> _logMeal() async {
    final l10n = AppLocalizations.of(context);
    final analysis = _analysis;
    if (analysis == null || analysis.items.isEmpty) return;

    setState(() => _isLogging = true);
    try {
      final meal = await _scannerService.logMeal(analysis);
      if (!mounted) return;
      await context.read<NutritionTrackerProvider>().refresh(
        profile: context.read<NutritionProfileProvider>().profile,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => NutritionScreen(highlightMealId: meal.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(l10n, e))));
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  void _removeItem(MealFoodItem item) {
    final analysis = _analysis;
    if (analysis == null) return;

    final nextItems = analysis.items.where((value) => value != item).toList();
    setState(() => _analysis = analysis.copyWith(items: nextItems));
  }

  Future<void> _editItem(MealFoodItem item) async {
    final nameController = TextEditingController(text: item.name);
    final gramsController = TextEditingController(
      text: item.servingGrams.round().toString(),
    );
    final caloriesController = TextEditingController(
      text: item.calories.round().toString(),
    );
    final proteinController = TextEditingController(
      text: item.proteinGrams.toStringAsFixed(1),
    );
    final carbsController = TextEditingController(
      text: item.carbsGrams.toStringAsFixed(1),
    );
    final fatController = TextEditingController(
      text: item.fatGrams.toStringAsFixed(1),
    );

    final edited = await showModalBottomSheet<MealFoodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final theme = context.watch<ThemeProvider>();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.border),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.scannerEditItem,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEditField(
                    theme,
                    nameController,
                    l10n.scannerFieldFoodName,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          theme,
                          gramsController,
                          l10n.scannerFieldGrams,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEditField(
                          theme,
                          caloriesController,
                          l10n.scannerFieldCalories,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          theme,
                          proteinController,
                          l10n.scannerFieldPro,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEditField(
                          theme,
                          carbsController,
                          l10n.progressCarbs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEditField(
                          theme,
                          fatController,
                          l10n.progressFat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        item.copyWith(
                          name: nameController.text.trim().isEmpty
                              ? item.name
                              : nameController.text.trim(),
                          servingGrams:
                              double.tryParse(gramsController.text) ??
                              item.servingGrams,
                          calories:
                              double.tryParse(caloriesController.text) ??
                              item.calories,
                          proteinGrams:
                              double.tryParse(proteinController.text) ??
                              item.proteinGrams,
                          carbsGrams:
                              double.tryParse(carbsController.text) ??
                              item.carbsGrams,
                          fatGrams:
                              double.tryParse(fatController.text) ??
                              item.fatGrams,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(l10n.scannerSaveChanges),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    nameController.dispose();
    gramsController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();

    if (edited == null || !mounted) return;
    final analysis = _analysis;
    if (analysis == null) return;
    final nextItems = analysis.items
        .map((value) => value == item ? edited : value)
        .toList();
    setState(() => _analysis = analysis.copyWith(items: nextItems));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimer?.cancel();
    _cameraController?.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final analysis = _analysis;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraLayer(theme),
          _buildScanOverlay(l10n, theme, analysis),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopControls(l10n, theme),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorPill(theme, _error!),
                  ],
                  const Spacer(),
                  if (analysis != null) _buildMealCard(l10n, theme, analysis),
                  const SizedBox(height: 16),
                  _buildBottomActions(l10n, theme, analysis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLayer(ThemeProvider theme) {
    final controller = _cameraController;
    if (_isInitializingCamera) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF10121C),
        child: Center(
          child: Icon(Icons.camera_alt, color: theme.textSecondary, size: 64),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1,
        height: controller.value.previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildScanOverlay(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealAnalysis? analysis,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black.withValues(alpha: 0.22)),
        if (_isAnalyzing)
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _scanController.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.accentOrange.withValues(alpha: 0.34),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        if (analysis != null)
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: analysis.items
                    .where((item) => item.box != null)
                    .map(
                      (item) =>
                          _buildBoundingBox(l10n, theme, item, constraints),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBoundingBox(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealFoodItem item,
    BoxConstraints constraints,
  ) {
    final box = item.box!;
    final previewRect = _cameraPreviewRect(constraints);
    final left = previewRect.left + (box.x * previewRect.width);
    final top = previewRect.top + (box.y * previewRect.height);
    final width = box.width * previewRect.width;
    final height = box.height * previewRect.height;

    return Positioned(
      left: left.clamp(0, constraints.maxWidth - 56),
      top: top.clamp(0, constraints.maxHeight - 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141827).withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.accentOrange.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  l10n.scannerItemCalories(item.name, item.calories.round()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: width.clamp(56, constraints.maxWidth),
            height: height.clamp(56, constraints.maxHeight),
            decoration: BoxDecoration(
              border: Border.all(color: theme.accentOrange, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Rect _cameraPreviewRect(BoxConstraints constraints) {
    final controller = _cameraController;
    final previewSize = controller?.value.previewSize;
    if (previewSize == null) {
      return Offset.zero & Size(constraints.maxWidth, constraints.maxHeight);
    }

    final sourceSize = Size(previewSize.height, previewSize.width);
    final outputSize = Size(constraints.maxWidth, constraints.maxHeight);
    final fitted = applyBoxFit(BoxFit.cover, sourceSize, outputSize);
    final destination = fitted.destination;
    final dx = (outputSize.width - destination.width) / 2;
    final dy = (outputSize.height - destination.height) / 2;
    return Offset(dx, dy) & destination;
  }

  Future<void> _openNutritionGoals() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NutritionProfileSetupScreen()),
    );
    if (!mounted) return;
    await context.read<NutritionProfileProvider>().loadProfile();
  }

  Widget _buildTopControls(AppLocalizations l10n, ThemeProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildGlassIconButton(
          icon: Icons.close,
          onTap: () => Navigator.of(context).pop(),
        ),
        _buildStatusPill(l10n, theme),
        Row(
          children: [
            _buildGlassIconButton(
              icon: Icons.monitor_weight_outlined,
              onTap: _openNutritionGoals,
            ),
            const SizedBox(width: 8),
            _buildGlassIconButton(
              icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
              onTap: _toggleFlash,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill(AppLocalizations l10n, ThemeProvider theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF141827).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 8 + (_pulseController.value * 4),
                    height: 8 + (_pulseController.value * 4),
                    decoration: BoxDecoration(
                      color: _isAnalyzing
                          ? theme.accentOrange
                          : const Color(0xFF00E676),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                _isAnalyzing
                    ? l10n.scannerStatusAnalyzing
                    : l10n.scannerStatusIdle,
                style: TextStyle(
                  color: _isAnalyzing ? theme.accentOrange : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF141827).withValues(alpha: 0.65),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPill(ThemeProvider theme, String message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF141827).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.accentOrange.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealAnalysis analysis,
  ) {
    final tracker = context.watch<NutritionTrackerProvider>();
    final profile = tracker.profile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141827).withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.scannerConfidence(
                            (analysis.confidence * 100).round(),
                            analysis.provider,
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.64),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${analysis.totalCalories.round()}',
                    style: TextStyle(
                      color: theme.accentOrange,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
              if (profile != null) ...[
                const SizedBox(height: 14),
                _buildBudgetPreview(l10n, theme, tracker, analysis),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMacroChip(
                    l10n,
                    l10n.scannerMacroPro,
                    analysis.totalProteinGrams,
                    theme,
                  ),
                  const SizedBox(width: 10),
                  _buildMacroChip(
                    l10n,
                    l10n.scannerMacroCarb,
                    analysis.totalCarbsGrams,
                    theme,
                  ),
                  const SizedBox(width: 10),
                  _buildMacroChip(
                    l10n,
                    l10n.scannerMacroFat,
                    analysis.totalFatGrams,
                    theme,
                  ),
                ],
              ),
              if (analysis.items.isNotEmpty) ...[
                const SizedBox(height: 14),
                ...analysis.items
                    .take(6)
                    .map((item) => _buildFoodRow(l10n, theme, item)),
                if (analysis.items.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.scannerMoreItems(analysis.items.length - 6),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.64),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
              if (analysis.warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  analysis.warnings.first,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetPreview(
    AppLocalizations l10n,
    ThemeProvider theme,
    NutritionTrackerProvider tracker,
    MealAnalysis analysis,
  ) {
    final profile = tracker.profile!;
    final afterCalories = tracker.todayCalories + analysis.totalCalories;
    final afterProtein = tracker.todayProtein + analysis.totalProteinGrams;
    final remainingCalories = profile.dailyCalories - afterCalories;
    final remainingProtein = profile.dailyProteinGrams - afterProtein;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scannerIfYouLog,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.scannerAfterLogging(
              afterCalories.round(),
              profile.dailyCalories.round(),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            remainingCalories >= 0
                ? l10n.scannerRemainingAfterLogging(
                    remainingCalories.round(),
                    remainingProtein.round(),
                  )
                : l10n.scannerOverTargetAfterLogging(
                    (-remainingCalories).round(),
                  ),
            style: TextStyle(
              color: remainingCalories >= 0
                  ? theme.accentOrange
                  : Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(
    AppLocalizations l10n,
    String label,
    double value,
    ThemeProvider theme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.accentOrange,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.scannerGramsDecimal(value.toStringAsFixed(1)),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodRow(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealFoodItem item,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.scannerItemServing(item.name, item.servingGrams.round()),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _editItem(item),
            child: Text(
              l10n.actionEdit,
              style: TextStyle(color: theme.accentOrange),
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(item),
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    AppLocalizations l10n,
    ThemeProvider theme,
    MealAnalysis? analysis,
  ) {
    final canLog = analysis != null && analysis.items.isNotEmpty && !_isLogging;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing || _isQuotaBlocked
                ? null
                : () => _captureAndAnalyze(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.center_focus_strong),
            label: Text(
              _isAnalyzing
                  ? l10n.scannerButtonAnalyzing
                  : _isQuotaBlocked
                  ? l10n.scannerButtonQuotaNeeded
                  : l10n.scannerButtonScanNow,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canLog ? _logMeal : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.16),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: _isLogging
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_circle),
            label: Text(
              _isLogging
                  ? l10n.scannerButtonLogging
                  : l10n.scannerButtonLogMeal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(
    ThemeProvider theme,
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary),
        filled: true,
        fillColor: theme.background.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.border),
        ),
      ),
    );
  }

  String _friendlyError(AppLocalizations l10n, Object error) {
    final text = error.toString();
    if (text.contains('CameraAccessDenied')) {
      return l10n.scannerErrorCameraPermission;
    }
    if (text.contains('Backend not configured')) {
      return l10n.scannerErrorBackendMissing;
    }
    if (text.contains('OPENAI_API_KEY') ||
        text.contains('OpenAI vision API key') ||
        text.contains('vision is not configured')) {
      _scanTimer?.cancel();
      return text.contains('invalid')
          ? l10n.scannerErrorApiKeyInvalid
          : l10n.scannerErrorApiKeyMissing;
    }
    if (_isQuotaError(error)) {
      _scanTimer?.cancel();
      return l10n.scannerErrorQuotaExhausted;
    }
    if (text.contains('TimeoutException')) {
      return l10n.scannerErrorTimeout;
    }
    if (text.contains('Unauthorized') || text.contains('Not signed in')) {
      return l10n.scannerErrorNotSignedIn;
    }
    if (text.contains('user_meals')) {
      return l10n.scannerErrorMealTableMissing;
    }
    return l10n.scannerErrorGeneric;
  }

  bool _isQuotaError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('quota') || text.contains('insufficient_quota');
  }
}
