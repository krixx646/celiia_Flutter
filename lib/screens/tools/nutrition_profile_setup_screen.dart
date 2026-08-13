import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/nutrition_profile.dart';
import '../../providers/nutrition_profile_provider.dart';
import '../../providers/theme_provider.dart';

class NutritionProfileSetupScreen extends StatefulWidget {
  const NutritionProfileSetupScreen({
    super.key,
    this.requireCompletion = false,
  });

  final bool requireCompletion;

  @override
  State<NutritionProfileSetupScreen> createState() =>
      _NutritionProfileSetupScreenState();
}

class _NutritionProfileSetupScreenState
    extends State<NutritionProfileSetupScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  NutritionGender _gender = NutritionGender.female;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<NutritionProfileProvider>().profile;
    if (profile != null) {
      _weightController.text = profile.weightKg.toStringAsFixed(1);
      _heightController.text = profile.heightCm.round().toString();
      _ageController.text = profile.age.toString();
      _gender = profile.gender;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final age = int.tryParse(_ageController.text.trim());

    if (weight == null || weight <= 0) {
      _showError(l10n.onboardingInvalidWeight);
      return;
    }
    if (height == null || height <= 0) {
      _showError(l10n.onboardingInvalidHeight);
      return;
    }
    if (age == null || age < 13 || age > 100) {
      _showError(l10n.onboardingInvalidAge);
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<NutritionProfileProvider>();
    final ok = await provider.saveProfile(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    _showError(provider.error ?? l10n.onboardingSaveFailed);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();

    return PopScope(
      canPop: !widget.requireCompletion,
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Row(
                children: [
                  if (!widget.requireCompletion)
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back, color: theme.textPrimary),
                    ),
                  Expanded(
                    child: Text(
                      l10n.nutritionSetupTitle,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.nutritionSetupBody,
                style: TextStyle(color: theme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              _buildField(theme, _weightController, l10n.onboardingWeightKg),
              const SizedBox(height: 12),
              _buildField(theme, _heightController, l10n.onboardingHeightCm),
              const SizedBox(height: 12),
              _buildField(
                theme,
                _ageController,
                l10n.onboardingAge,
                isNumber: true,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.nutritionSetupGender,
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
                    label: Text(_genderLabel(l10n, gender)),
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
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.border),
                ),
                child: Text(
                  l10n.nutritionSetupFootnote,
                  style: TextStyle(color: theme.textSecondary, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
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
                    : Text(
                        l10n.nutritionSetupSave,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    ThemeProvider theme,
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
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

  String _genderLabel(AppLocalizations l10n, NutritionGender gender) {
    return switch (gender) {
      NutritionGender.male => l10n.genderMale,
      NutritionGender.female => l10n.genderFemale,
      NutritionGender.other => l10n.genderOther,
    };
  }
}
