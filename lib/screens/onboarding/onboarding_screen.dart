import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/nutrition_tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/onboarding_service.dart';
import '../tools/calorie_scanner_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  NutritionGender _gender = NutritionGender.female;
  bool _saving = false;
  bool _showGetStarted = false;
  NutritionProfile? _savedProfile;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final age = int.tryParse(_ageController.text.trim());

    if (weight == null || weight <= 0) {
      _showSnack('Enter a valid weight in kg.');
      return;
    }
    if (height == null || height <= 0) {
      _showSnack('Enter a valid height in cm.');
      return;
    }
    if (age == null || age < 13 || age > 100) {
      _showSnack('Enter a valid age between 13 and 100.');
      return;
    }

    setState(() => _saving = true);
    final profileProvider = context.read<NutritionProfileProvider>();
    final ok = await profileProvider.saveProfile(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
    );
    if (!mounted) return;

    if (!ok) {
      setState(() => _saving = false);
      _showSnack(
        profileProvider.error ?? 'Could not save your nutrition profile.',
      );
      return;
    }

    final profile = profileProvider.profile;
    context.read<NutritionTrackerProvider>().syncProfile(profile);
    setState(() {
      _saving = false;
      _savedProfile = profile;
      _showGetStarted = true;
    });
  }

  Future<void> _finish({required bool openScanner}) async {
    final uid = context.read<AuthProvider>().uiState.currentUser?.uid;
    if (uid != null) {
      await OnboardingService.markComplete(uid);
    }

    widget.onComplete();

    if (!mounted || !openScanner) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CalorieScannerScreen()));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final userName =
        context.watch<AuthProvider>().uiState.currentUser?.displayName ??
        'there';

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              'Welcome, $userName',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showGetStarted
                  ? 'Your daily nutrition targets are ready. Choose how you want to start.'
                  : 'Tell Celia about your body so she can calculate your daily calories and macros.',
              style: TextStyle(color: theme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            if (!_showGetStarted) ...[
              _buildField(theme, _weightController, 'Weight (kg)'),
              const SizedBox(height: 12),
              _buildField(theme, _heightController, 'Height (cm)'),
              const SizedBox(height: 12),
              _buildField(theme, _ageController, 'Age'),
              const SizedBox(height: 18),
              Text(
                'Gender',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: NutritionGender.values.map((gender) {
                  final selected = _gender == gender;
                  return ChoiceChip(
                    label: Text(_genderLabel(gender)),
                    selected: selected,
                    onSelected: (_) => setState(() => _gender = gender),
                    selectedColor: theme.accentOrange.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selected ? theme.accentOrange : theme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: selected ? theme.accentOrange : theme.border,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Calculate My Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ] else ...[
              _buildTargetsPreview(theme, _savedProfile!),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _finish(openScanner: true),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan My First Meal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<NavigationProvider>().setIndex(1);
                  _finish(openScanner: false);
                },
                icon: Icon(Icons.fitness_center, color: theme.textPrimary),
                label: Text(
                  'Explore Routines',
                  style: TextStyle(color: theme.textPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _finish(openScanner: false),
                child: Text(
                  'Go to Home',
                  style: TextStyle(color: theme.textSecondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTargetsPreview(ThemeProvider theme, NutritionProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFF171B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your daily targets',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${profile.dailyCalories.round()} kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Protein ${profile.dailyProteinGrams.round()}g • '
            'Carbs ${profile.dailyCarbsGrams.round()}g • '
            'Fat ${profile.dailyFatGrams.round()}g',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    ThemeProvider theme,
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.surface,
        labelStyle: TextStyle(color: theme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.accentOrange),
        ),
      ),
    );
  }

  String _genderLabel(NutritionGender gender) {
    return switch (gender) {
      NutritionGender.male => 'Male',
      NutritionGender.female => 'Female',
      NutritionGender.other => 'Other',
    };
  }
}
