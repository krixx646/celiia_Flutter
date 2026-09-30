import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/routine.dart';
import '../providers/routine_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/routine_text.dart';

/// Bottom sheet for generating AI routines.
class GenerateRoutineSheet extends StatefulWidget {
  const GenerateRoutineSheet({super.key});

  @override
  State<GenerateRoutineSheet> createState() => _GenerateRoutineSheetState();
}

class _GenerateRoutineSheetState extends State<GenerateRoutineSheet> {
  final _requestController = TextEditingController();
  int _selectedDuration = 15;
  RoutineDifficulty _selectedDifficulty = RoutineDifficulty.medium;

  final List<int> _durations = [10, 15, 20, 30, 45, 60];

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
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
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.generateSheetTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.generateSheetPrompt,
              style: TextStyle(color: theme.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _requestController,
              maxLines: 3,
              style: TextStyle(color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.generateSheetHint,
                hintStyle: TextStyle(color: theme.textSecondary),
                filled: true,
                fillColor: theme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.accentOrange),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
              children: _durations.map((minutes) {
                final selected = _selectedDuration == minutes;
                return ChoiceChip(
                  label: Text('$minutes'),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedDuration = minutes),
                  selectedColor: theme.accentOrange,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
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
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
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
    HapticFeedback.lightImpact();
    final provider = context.read<RoutineProvider>();
    final result = await provider.generateRoutine(
      request: request,
      durationMinutes: _selectedDuration,
      difficulty: _selectedDifficulty,
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
