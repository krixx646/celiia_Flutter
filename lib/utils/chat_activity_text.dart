import '../l10n/app_localizations.dart';
import '../models/celia_chat_message.dart';

/// Puts the words on Celia's tool activity.
///
/// The message model carries what the tool is and what it was asked to do;
/// this turns that into the line the user reads while it runs, and into the
/// question they answer before a write goes through.
extension ChatToolCallText on ChatToolCall {
  /// Present-tense status shown while the tool runs.
  String activityLabel(AppLocalizations l10n) {
    switch (toolName) {
      case 'get_my_progress':
        return l10n.activityCheckingProgress;
      case 'get_today_nutrition':
        return l10n.activityCheckingNutrition;
      case 'list_my_meals':
        return l10n.activityReviewingMeals;
      case 'list_my_routines':
        return l10n.activityLookingAtRoutines;
      case 'get_routine_details':
        return l10n.activityReadingRoutine;
      case 'search_exercises':
        return l10n.activitySearchingLibrary;
      case 'create_routine':
        return l10n.activityBuildingRoutine;
      case 'log_meal':
        return l10n.activityLoggingMeal;
      case 'save_routine':
        return l10n.activitySavingToLibrary;
      default:
        return l10n.activityWorking;
    }
  }

  /// The question to put to the user before a write runs.
  String approvalPrompt(AppLocalizations l10n) {
    switch (toolName) {
      case 'create_routine':
        final title = input?['title'];
        final steps = input?['steps'];
        final count = steps is List ? steps.length : 0;
        final name = title is String && title.isNotEmpty
            ? title
            : l10n.chatThisRoutine;
        return count > 0
            ? l10n.approvalSaveRoutineWithCount(name, count)
            : l10n.approvalSaveRoutine(name);
      case 'log_meal':
        final title = input?['title'];
        final calories = input?['calories'];
        final name = title is String && title.isNotEmpty
            ? title
            : l10n.chatThisMeal;
        return calories is num
            ? l10n.approvalLogMealWithCalories(name, calories.round())
            : l10n.approvalLogMeal(name);
      case 'save_routine':
        return l10n.approvalAddRoutine;
      default:
        return l10n.approvalGeneric;
    }
  }
}
