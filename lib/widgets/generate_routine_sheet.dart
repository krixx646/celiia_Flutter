import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/routine_text.dart';

/// Bottom sheet for generating AI routines
class GenerateRoutineSheet extends StatefulWidget {
  const GenerateRoutineSheet({super.key});

  @override
  State<GenerateRoutineSheet> createState() => _GenerateRoutineSheetState();
}

class _GenerateRoutineSheetState extends State<GenerateRoutineSheet> {
  final _requestController = TextEditingController();
  int _selectedDuration = 15;
  RoutineDifficulty _selectedDifficulty = RoutineDifficulty.medium;
  final List<String> _selectedEquipment = [];

  final List<int> _durations = [10, 15, 20, 30, 45, 60];
  final List<String> _equipmentOptions = [
    'None',
    'Dumbbells',
    'Resistance Bands',
    'Yoga Mat',
    'Kettlebell',
    'Pull-up Bar',
    'Jump Rope',
  ];

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  /// The equipment values above are what the backend matches on, so they stay
  /// English; only the chip text follows the app language.
  String _equipmentLabel(AppLocalizations l10n, String equipment) {
    switch (equipment) {
      case 'None':
        return l10n.equipmentNone;
      case 'Dumbbells':
        return l10n.equipmentDumbbells;
      case 'Resistance Bands':
        return l10n.equipmentResistanceBands;
      case 'Yoga Mat':
        return l10n.equipmentYogaMat;
      case 'Kettlebell':
        return l10n.equipmentKettlebell;
      case 'Pull-up Bar':
        return l10n.equipmentPullUpBar;
      case 'Jump Rope':
        return l10n.equipmentJumpRope;
      default:
        return equipment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final routineProvider = context.watch<RoutineProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.generateSheetTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Request input
            Text(
              l10n.generateSheetPrompt,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _requestController,
              maxLines: 3,
              style: TextStyle(color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.generateSheetHint,
                hintStyle: TextStyle(
                  color: theme.textSecondary.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: theme.isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.accentOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Duration selector
            Text(
              l10n.generateSheetDuration,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _durations.map((duration) {
                final isSelected = _selectedDuration == duration;
                return ChoiceChip(
                  label: Text(l10n.generateSheetMinutes(duration)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDuration = duration);
                    }
                  },
                  selectedColor: theme.accentOrange,
                  backgroundColor: theme.isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Difficulty selector
            Text(
              l10n.generateSheetDifficulty,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: RoutineDifficulty.values.map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                final label = localizedRoutineDifficulty(l10n, difficulty);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedDifficulty = difficulty);
                        }
                      },
                      selectedColor: theme.accentOrange,
                      backgroundColor: theme.isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Equipment selector
            Text(
              l10n.generateSheetEquipment,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _equipmentOptions.map((equipment) {
                final isSelected = _selectedEquipment.contains(equipment);
                return FilterChip(
                  label: Text(_equipmentLabel(l10n, equipment)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (equipment == 'None') {
                          _selectedEquipment.clear();
                        } else {
                          _selectedEquipment.remove('None');
                        }
                        _selectedEquipment.add(equipment);
                      } else {
                        _selectedEquipment.remove(equipment);
                      }
                    });
                  },
                  selectedColor: theme.accentOrange.withValues(alpha: 0.3),
                  checkmarkColor: theme.accentOrange,
                  backgroundColor: theme.isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? theme.accentOrange : theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: routineProvider.isGenerating
                    ? null
                    : () => _generateRoutine(l10n, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: routineProvider.isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.generateSheetGenerating,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.generateSheetSubmit,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _generateRoutine(
    AppLocalizations l10n,
    BuildContext context,
  ) async {
    final request = _requestController.text.trim();
    if (request.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generateSheetDescribeFirst)),
      );
      return;
    }

    final provider = context.read<RoutineProvider>();
    final result = await provider.generateRoutine(
      request: request,
      durationMinutes: _selectedDuration,
      difficulty: _selectedDifficulty,
      equipment: _selectedEquipment.isEmpty ? ['None'] : _selectedEquipment,
    );

    if (!context.mounted) return;

    if (result != null) {
      Navigator.of(context).pop(result.routine);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyExisted
                ? l10n.generateSheetAlreadyExists(result.routine.title)
                : l10n.generateSheetCreated(result.routine.title),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.generateSheetFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Show the generate routine bottom sheet
Future<Routine?> showGenerateRoutineSheet(BuildContext context) {
  return showModalBottomSheet<Routine>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (context) => const GenerateRoutineSheet(),
  );
}
