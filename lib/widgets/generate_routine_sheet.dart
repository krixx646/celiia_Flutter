import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';
import '../providers/theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  'Generate Routine with AI',
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
              'What kind of workout do you want?',
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
                hintText:
                    'e.g., "A quick morning stretch to wake up" or "Full body strength training for beginners"',
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
              'Duration',
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
                  label: Text('$duration min'),
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
              'Difficulty',
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
                final label =
                    difficulty.name[0].toUpperCase() +
                    difficulty.name.substring(1);
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
              'Available Equipment',
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
                  label: Text(equipment),
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
                    : () => _generateRoutine(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: routineProvider.isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Generating...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Generate Routine',
                            style: TextStyle(
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

  Future<void> _generateRoutine(BuildContext context) async {
    final request = _requestController.text.trim();
    if (request.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the workout you want')),
      );
      return;
    }

    final provider = context.read<RoutineProvider>();
    final routine = await provider.generateRoutine(
      request: request,
      durationMinutes: _selectedDuration,
      difficulty: _selectedDifficulty,
      equipment: _selectedEquipment.isEmpty ? ['None'] : _selectedEquipment,
    );

    if (!context.mounted) return;

    if (routine != null) {
      Navigator.of(context).pop(routine);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created: ${routine.title}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to generate routine'),
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
