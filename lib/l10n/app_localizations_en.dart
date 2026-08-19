// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionClose => 'Close';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSeeAll => 'See All';

  @override
  String get actionYesDoIt => 'Yes, do it';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get loadingPreparing => 'Preparing Celia...';

  @override
  String get loadingGeneric => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorCanceled => 'Action canceled.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get errorNetwork =>
      'Please check your internet connection and try again.';

  @override
  String get errorBadCredentials => 'Incorrect email or password.';

  @override
  String get errorEmailInUse =>
      'This email is already in use. Try logging in instead.';

  @override
  String get errorWeakPassword => 'Use a stronger password and try again.';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorNoPermission => 'You do not have permission to do that.';

  @override
  String get errorNotSignedIn => 'Please sign in and try again.';

  @override
  String get errorDeleteAccount =>
      'We couldn\'t delete your account. Please try again.';

  @override
  String get errorNoConversation => 'Start a new chat to continue.';

  @override
  String get errorNoPlayableVideos =>
      'No playable videos are available for this routine yet.';

  @override
  String get errorLoadRoutines =>
      'Could not load routines right now. Please try again.';

  @override
  String get errorLoadSavedRoutines =>
      'Could not load saved routines right now. Please try again.';

  @override
  String get errorGenerateRoutine =>
      'Could not generate a routine right now. Please try again.';

  @override
  String get errorLoadChats => 'Unable to load saved chats right now.';

  @override
  String get errorCeliaUnavailable =>
      'Celia is unavailable right now. Please try again.';

  @override
  String get errorOpenConversation => 'Could not open that conversation.';

  @override
  String get errorDeleteConversation =>
      'Could not delete this conversation. Please try again.';

  @override
  String get errorSignIn => 'Could not sign in. Please try again.';

  @override
  String get errorCreateAccount =>
      'Could not create your account. Please try again.';

  @override
  String get errorSendResetEmail =>
      'Could not send reset email. Please try again.';

  @override
  String get errorSendVerificationEmail =>
      'Could not send verification email. Please try again.';

  @override
  String get errorGoogleSignIn => 'Google sign-in failed. Please try again.';

  @override
  String get errorAppleSignIn => 'Apple sign-in failed. Please try again.';

  @override
  String get errorRefreshNutrition => 'Could not refresh nutrition data.';

  @override
  String get errorLoadNutritionProfile =>
      'Could not load your nutrition profile.';

  @override
  String get startupErrorTitle => 'Unable to start the app';

  @override
  String get startupErrorBody =>
      'Please close and reopen the app. If this continues, contact support.';

  @override
  String get authTagline => 'Your fitness buddy';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authLogIn => 'Log In';

  @override
  String authVersion(String version) {
    return 'Version $version';
  }

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authOr => 'OR';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authAuthenticating => 'Authenticating...';

  @override
  String get authEnterYourName => 'Please enter your name.';

  @override
  String get authNeedAccount => 'Need an account? Sign Up';

  @override
  String get authHaveAccount => 'Already have an account? Log In';

  @override
  String get authFieldName => 'Your name';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String get verifyEmailHeading => 'Check your inbox';

  @override
  String get verifyEmailBody =>
      'A verification link has been sent to your email.';

  @override
  String get verifyEmailSent => 'Verification email sent!';

  @override
  String get verifyEmailContinue => 'I have verified, continue';

  @override
  String get verifyEmailSignOut => 'Sign out';

  @override
  String get verifyEmailSending => 'Sending...';

  @override
  String get verifyEmailResend => 'Resend verification email';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'Email: $email';
  }

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordBody =>
      'Enter your email to receive a password reset link.';

  @override
  String get forgotPasswordEmptyEmail => 'Please enter an email';

  @override
  String get forgotPasswordSent => 'Password reset email sent.';

  @override
  String get forgotPasswordSend => 'Send reset link';

  @override
  String get forgotPasswordSending => 'Sending...';

  @override
  String get nameSetupTitle => 'What should Celia call you?';

  @override
  String get nameSetupBody =>
      'We use your name across the app so coaching feels personal.';

  @override
  String get nameSetupSaveFailed =>
      'Could not save your name. Please try again.';

  @override
  String get homeGoodMorning => 'Good Morning,';

  @override
  String get homeCeliaActive => 'CELIA ACTIVE';

  @override
  String get homeGenerateRoutine =>
      'Generate your\npersonalized\nroutine with AI';

  @override
  String get homeCreateRoutine => 'Create Routine';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeUpNext => 'Up Next';

  @override
  String get homeNoUpcoming =>
      'No upcoming routines yet.\nCreate one or browse the library.';

  @override
  String get homeChatWithCelia => 'Chat with Celia';

  @override
  String get homeChatSubtitle => 'Ask about your form or diet';

  @override
  String get homeScanMeal => 'Scan Meal';

  @override
  String get homeScanMealSubtitle => 'Identify food & calories';

  @override
  String get homeNutrition => 'Nutrition';

  @override
  String get homeNutritionSubtitle => 'View calories, macros & meals';

  @override
  String get homeBrowseLibrary => 'Browse\nLibrary';

  @override
  String get homeTrackProgress => 'Track\nProgress';

  @override
  String get chatTitle => 'Coach Celia';

  @override
  String get chatEmptyPrompt => 'How can I help you\nget fit today?';

  @override
  String get chatYourChats => 'Your chats';

  @override
  String get chatNoSavedChats => 'No saved chats yet.';

  @override
  String get chatHistory => 'Chat history';

  @override
  String get chatNew => 'New chat';

  @override
  String get chatOpening => 'Opening chat...';

  @override
  String get chatScanAMeal => 'Scan a meal';

  @override
  String get chatInputHint => 'Ask Celia anything about your training...';

  @override
  String get chatCouldNotOpenRoutine => 'Could not open that routine';

  @override
  String get chatThisRoutine => 'this routine';

  @override
  String get chatThisMeal => 'this meal';

  @override
  String get chatYourRoutine => 'Your routine';

  @override
  String chatMoreExercises(int count) {
    return '+ $count more';
  }

  @override
  String get chatEmptySubtitle =>
      'Ask about your training, your food, or your progress.';

  @override
  String chatLoggedToday(int calories) {
    return 'You\'ve logged $calories kcal today.';
  }

  @override
  String get chatSuggestionHiit => 'Build me a 20-minute HIIT routine';

  @override
  String get chatSuggestionDinner => 'What should I eat tonight?';

  @override
  String get chatSuggestionProgress => 'How am I doing this week?';

  @override
  String get chatSuggestionIngredients => 'I have chicken, rice and spinach';

  @override
  String get chatJustNow => 'Just now';

  @override
  String chatMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String chatHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String chatDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get chatRoutineAlreadySaved => 'Already in your library — tap to open';

  @override
  String get chatRoutineTapToOpen => 'Tap to open';

  @override
  String get chatToolCancelled => 'Cancelled';

  @override
  String chatToolFailed(String label) {
    return '$label — that did not work';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Could not save the routine';

  @override
  String get chatToolRoutineSaved => 'Saved to your library';

  @override
  String get chatToolMealLogged => 'Added to today\'s log';

  @override
  String get chatToolRoutineAdded => 'Added to your library';

  @override
  String get activityCheckingProgress => 'Checking your progress';

  @override
  String get activityCheckingNutrition => 'Checking what you ate today';

  @override
  String get activityReviewingMeals => 'Reviewing your recent meals';

  @override
  String get activityLookingAtRoutines => 'Looking at your routines';

  @override
  String get activityReadingRoutine => 'Reading that routine';

  @override
  String get activitySearchingLibrary => 'Searching the exercise library';

  @override
  String get activityBuildingRoutine => 'Building your routine';

  @override
  String get activityLoggingMeal => 'Logging your meal';

  @override
  String get activitySavingToLibrary => 'Saving to your library';

  @override
  String get activityWorking => 'Working on it';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Save \"$name\" with $count exercises to your library?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Save \"$name\" to your library?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Log \"$name\" at $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Log \"$name\"?';
  }

  @override
  String get approvalAddRoutine => 'Add this routine to your library?';

  @override
  String get approvalGeneric => 'Allow Celia to do this?';

  @override
  String get libraryTitle => 'Routine Library';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'No routines yet';

  @override
  String get libraryEmptyBody =>
      'Create and publish routines in the admin dashboard.';

  @override
  String get libraryLoadFailed => 'Failed to load routines';

  @override
  String get routineStartWorkout => 'Start Workout';

  @override
  String get routineNoSteps => 'No steps available';

  @override
  String get routineNoVideoForStep => 'No video available for this step';

  @override
  String get routineVideoProcessing =>
      'Video is still processing. Please try again later.';

  @override
  String get routineMissingPlaybackUrl =>
      'Playback URL is missing for this video';

  @override
  String get routinePreviewBanner => 'PREVIEW — full video coming soon';

  @override
  String get routinePreview => 'PREVIEW';

  @override
  String get routineDetails => 'Details';

  @override
  String get routineNotFound => 'Routine not found';

  @override
  String routineCompletedTimes(int count) {
    return 'Completed ${count}x';
  }

  @override
  String get playerVideoUnavailable => 'This video is not available right now.';

  @override
  String get playerSteps => 'Steps';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'No playable videos';

  @override
  String get playerWorkoutComplete => 'Workout complete!';

  @override
  String get playerSavingStreak => 'Saving to your streak…';

  @override
  String get playerSavedStreak => 'Saved to your streak';

  @override
  String get playerRetrySave => 'Retry save';

  @override
  String get playerReplay => 'Replay';

  @override
  String get playerNotReady => 'Player not ready';

  @override
  String get playerPreviewUnavailable => 'Preview not available right now.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current of $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Error loading video';

  @override
  String get playerLoadingVideo => 'Loading video...';

  @override
  String get playerFailedToLoadVideo => 'Failed to load video';

  @override
  String get playerNotInitialized => 'Video player not initialized';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Exercise $current/$total';
  }

  @override
  String get guidedGetReady => 'GET READY';

  @override
  String guidedSetOf(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String get guidedRest => 'REST';

  @override
  String get guidedSkipRest => 'Skip rest';

  @override
  String get guidedPaused => 'Paused';

  @override
  String get guidedResume => 'Resume';

  @override
  String get guidedWorkoutComplete => 'Workout complete';

  @override
  String get guidedEndTitle => 'End workout?';

  @override
  String get guidedEndBody =>
      'Your progress for this session will not be saved.';

  @override
  String get guidedKeepGoing => 'Keep going';

  @override
  String get guidedEnd => 'End';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reps',
      one: '$count rep',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Generate Routine with AI';

  @override
  String get generateSheetPrompt => 'What kind of workout do you want?';

  @override
  String get generateSheetHint =>
      'e.g., \"A quick morning stretch to wake up\" or \"Full body strength training for beginners\"';

  @override
  String get generateSheetDuration => 'Duration';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Difficulty';

  @override
  String get generateSheetEquipment => 'Available Equipment';

  @override
  String get generateSheetGenerating => 'Generating...';

  @override
  String get generateSheetSubmit => 'Generate Routine';

  @override
  String get generateSheetDescribeFirst =>
      'Please describe the workout you want';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'You already have this one: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Created: $title';
  }

  @override
  String get generateSheetFailed => 'Failed to generate routine';

  @override
  String get guidedNoExercises => 'This routine has no exercises yet.';

  @override
  String get guidedStartFailed =>
      'Unable to start this workout right now. Please try again.';

  @override
  String get guidedSaveFailed =>
      'Could not save this workout. Tap retry to update your streak.';

  @override
  String guidedOfReps(int count) {
    return 'of $count reps';
  }

  @override
  String get guidedHold => 'hold';

  @override
  String get guidedNextSet => 'Next set';

  @override
  String get guidedUpNext => 'Up next';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s hold';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Get ready. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Go. $count reps.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Hold for $seconds seconds.';
  }

  @override
  String coachRest(String exercise) {
    return 'Rest. Next up: $exercise';
  }

  @override
  String get coachRestShort => 'Rest.';

  @override
  String get coachComplete => 'Great work. Workout complete.';

  @override
  String coachRep(int count) {
    return '$count';
  }

  @override
  String coachCountdown(int seconds) {
    return '$seconds';
  }

  @override
  String get playerNoVideosInRoutine =>
      'No playable videos found in this routine.';

  @override
  String get playerLoadRoutineFailed =>
      'Unable to load this routine right now. Please try again.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Failed to load \"$title\". Skipping…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Failed to load \"$title\".';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Could not save completion. Tap retry to update your streak.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Preview';
  }

  @override
  String get playerNoVideosReady =>
      'This routine has no videos ready to play yet.';

  @override
  String get playerPlaybackFailed =>
      'Unable to play this video right now. Please try again.';

  @override
  String get libraryTabCurated => 'Curated';

  @override
  String get libraryTabAiGenerated => 'AI-Generated';

  @override
  String get profileSavedRoutines => 'Saved Routines';

  @override
  String get savedRoutinesNoFavorites => 'No favorite routines yet.';

  @override
  String get savedRoutinesEmpty => 'No saved routines yet.';

  @override
  String get actionFavorite => 'Favorite';

  @override
  String get actionUnfavorite => 'Unfavorite';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String routineDurationHours(int hours) {
    return '${hours}h';
  }

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get categoryStrength => 'Strength';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Flexibility';

  @override
  String get categoryMindfulness => 'Mindfulness';

  @override
  String get categoryDance => 'Dance';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Custom';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get equipmentNone => 'None';

  @override
  String get equipmentDumbbells => 'Dumbbells';

  @override
  String get equipmentResistanceBands => 'Resistance Bands';

  @override
  String get equipmentYogaMat => 'Yoga Mat';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Pull-up Bar';

  @override
  String get equipmentJumpRope => 'Jump Rope';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionSubtitle => 'Calories, macros, and meal history';

  @override
  String get nutritionSetGoalsTitle => 'Set your daily nutrition goals';

  @override
  String get nutritionSetGoalsBody =>
      'Add your weight, height, age, and gender so Celia can calculate how many calories and nutrients you should consume each day.';

  @override
  String get nutritionSetUpGoals => 'Set Up Goals';

  @override
  String get nutritionDailyTarget => 'Daily target';

  @override
  String get nutritionDailyGoals => 'Daily goals';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Today';

  @override
  String get nutritionMealHistory => 'Meal History';

  @override
  String get nutritionCeliaInsights => 'Celia Insights';

  @override
  String get nutritionWeeklyTrend => 'Weekly Trend';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '$count meal',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '$count meal',
    );
    return 'of $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'M,T,W,T,F,S,S';

  @override
  String get nutritionFieldFoodName => 'Food name';

  @override
  String get nutritionFieldGrams => 'Grams';

  @override
  String get nutritionFieldCalories => 'Calories';

  @override
  String get scannerStatusAnalyzing => 'ANALYZING...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => 'Food name';

  @override
  String get scannerFieldGrams => 'Grams';

  @override
  String get scannerFieldCalories => 'Calories';

  @override
  String get scannerFieldPro => 'Pro';

  @override
  String get scannerMacroPro => 'PRO';

  @override
  String get scannerMacroCarb => 'CARB';

  @override
  String get scannerMacroFat => 'FAT';

  @override
  String scannerRemainingAfterLogging(int calories, int grams) {
    return '$calories kcal and ${grams}g protein left today';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal over your daily target';
  }

  @override
  String get scannerButtonAnalyzing => 'Analyzing';

  @override
  String get scannerButtonQuotaNeeded => 'Quota Needed';

  @override
  String get scannerButtonScanNow => 'Scan Now';

  @override
  String get scannerButtonLogging => 'Logging';

  @override
  String get scannerButtonLogMeal => 'Log Meal';

  @override
  String get scannerNoClearFood =>
      'No clear food detected yet. Try better lighting or move closer.';

  @override
  String get scannerErrorCameraPermission =>
      'Camera permission is needed to scan meals.';

  @override
  String get scannerErrorBackendMissing =>
      'Calorie scanner backend is not configured yet.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'The OpenAI API key for calorie scanning is invalid. Replace it in the backend environment, redeploy, then try again.';

  @override
  String get scannerErrorApiKeyMissing =>
      'OpenAI API key is required for calorie scanning. Add it in Vercel, redeploy, then try again.';

  @override
  String get scannerErrorQuotaExhausted =>
      'OpenAI credits are exhausted for calorie scanning. Add API credits or raise the billing limit, then try again.';

  @override
  String get scannerErrorTimeout =>
      'Celia needed more time to analyze this meal. Hold the camera steady and scan again.';

  @override
  String get scannerErrorNotSignedIn => 'Please sign in before scanning meals.';

  @override
  String get scannerErrorMealTableMissing =>
      'Meal logging table is not ready yet. The scan result is still available.';

  @override
  String get scannerErrorGeneric =>
      'Celia could not analyze this meal yet. Hold the camera steady, keep the food centered, and scan again.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Meal Details';

  @override
  String get nutritionFoodItems => 'Food Items';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem => 'A meal needs at least one food item.';

  @override
  String get nutritionMealUpdated => 'Meal updated';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Could not update meal: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Delete meal?';

  @override
  String get nutritionDeleteMealBody =>
      'This removes the meal from your nutrition history.';

  @override
  String get nutritionDeleteMeal => 'Delete meal';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Could not delete meal: $error';
  }

  @override
  String get nutritionEditFood => 'Edit Food';

  @override
  String get nutritionSaveFood => 'Save Food';

  @override
  String get nutritionLoadFailed => 'Could not load meals';

  @override
  String get nutritionLoadFailedBody =>
      'Pull to refresh or check the backend connection.';

  @override
  String get nutritionNoMeals => 'No meals logged yet';

  @override
  String get nutritionNoMealsBody =>
      'Scan your first meal and Celia will build your nutrition history.';

  @override
  String get progressToday => 'Today';

  @override
  String get progressSetGoals =>
      'Set your nutrition goals to unlock calorie and macro tracking.';

  @override
  String progressOfTarget(int target) {
    return 'of $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal over';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal left';
  }

  @override
  String get progressProtein => 'Protein';

  @override
  String get progressCarbs => 'Carbs';

  @override
  String get progressFat => 'Fat';

  @override
  String get scannerEditItem => 'Edit Food Item';

  @override
  String get scannerSaveChanges => 'Save Changes';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Confidence $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count more items included in this meal log';
  }

  @override
  String get scannerIfYouLog => 'If you log this meal';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal today';
  }

  @override
  String scannerGramsDecimal(String grams) {
    return '${grams}g';
  }

  @override
  String scannerItemServing(String name, int grams) {
    return '$name · ${grams}g';
  }

  @override
  String get scannerNoMealDetected => 'No meal detected';

  @override
  String onboardingWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get onboardingGender => 'Gender';

  @override
  String get onboardingCalculateGoals => 'Calculate My Goals';

  @override
  String get onboardingScanFirstMeal => 'Scan My First Meal';

  @override
  String get onboardingExploreRoutines => 'Explore Routines';

  @override
  String get onboardingGoHome => 'Go to Home';

  @override
  String get onboardingDailyTargets => 'Your daily targets';

  @override
  String onboardingProtein(int grams) {
    return 'Protein ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Protein ${protein}g • Carbs ${carbs}g • Fat ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Your daily nutrition targets are ready. Choose how you want to start.';

  @override
  String get onboardingWeightKg => 'Weight (kg)';

  @override
  String get onboardingHeightCm => 'Height (cm)';

  @override
  String get onboardingAge => 'Age';

  @override
  String get onboardingInvalidWeight => 'Enter a valid weight in kg.';

  @override
  String get onboardingInvalidHeight => 'Enter a valid height in cm.';

  @override
  String get onboardingInvalidAge => 'Enter a valid age between 13 and 100.';

  @override
  String get onboardingSaveFailed => 'Could not save your nutrition profile.';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get nutritionSetupTitle => 'Daily Nutrition Goals';

  @override
  String get nutritionSetupBody =>
      'Tell Celia about your body so she can calculate your daily calories and macros.';

  @override
  String get nutritionSetupGender => 'Gender';

  @override
  String get nutritionSetupFootnote =>
      'Celia uses your weight, height, age, and gender to estimate daily calorie and macro targets using a moderate activity level.';

  @override
  String get nutritionSetupSave => 'Save Goals';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Member';

  @override
  String get profileAccount => 'Account';

  @override
  String profileSignedInAs(String email) {
    return 'Signed in as:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Unknown';

  @override
  String get profileDarkMode => 'Dark Mode';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLogOutTitle => 'Log out?';

  @override
  String get profileLogOutBody => 'Are you sure you want to log out?';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileLogOutButton => 'Log Out';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'This permanently deletes your account and all of your data, including saved routines, meal logs, and chat history. This can\'t be undone.';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'Enter your password to confirm.';

  @override
  String get profileDeleteAccountPasswordLabel => 'Password';

  @override
  String get profileDeleteAccountButton => 'Delete My Account';

  @override
  String get profileFavoriteRoutines => 'Favorite Routines';

  @override
  String get profileSubscription => 'Subscription';

  @override
  String get profileNutrition => 'Nutrition';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileFriend => 'Friend';

  @override
  String get profileStatSaved => 'Saved';

  @override
  String get profileStatStreak => 'Streak';

  @override
  String get profileStatWorkouts => 'Workouts';

  @override
  String get streakDayOneStarted =>
      'Day 1 started — come back tomorrow to build your streak.';

  @override
  String get streakRebuild =>
      'You were active yesterday — log a meal or finish a workout today to rebuild your streak.';

  @override
  String get streakStart =>
      'Log a meal or finish a workout to start your active streak.';

  @override
  String streakLongRun(int days) {
    return '$days-day streak! Keep showing up — Celia is tracking your consistency.';
  }

  @override
  String streakBothLogged(int days) {
    return '$days-day streak — workout and nutrition both logged today.';
  }

  @override
  String streakNeedWorkout(int days) {
    return '$days-day streak. A quick workout would round out today.';
  }

  @override
  String streakNeedMeal(int days) {
    return '$days-day streak. Log a meal to track your fueling.';
  }

  @override
  String streakStayActive(int days) {
    return '$days-day streak — stay active today.';
  }

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileName => 'Name';

  @override
  String get editProfileFootnote =>
      'Changes are saved to your account and will show on Home/Profile.';

  @override
  String get editProfileSaveFailed =>
      'Could not update profile. Please try again.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageSystemSubtitle =>
      'Follow the language your phone is set to';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get insightStartFuelingTitle => 'Start fueling today';

  @override
  String get insightStartFuelingBody =>
      'You have your full calorie budget left. Scan or log your first meal to stay on track.';

  @override
  String get insightAboveTargetTitle => 'Above target today';

  @override
  String insightAboveTargetBody(int calories) {
    return 'You are $calories kcal above your daily target. Keep dinner lighter or add a short workout.';
  }

  @override
  String get insightLowProteinTitle => 'Protein is still low';

  @override
  String insightLowProteinBody(int grams) {
    return 'You still need about ${grams}g protein today to hit your target.';
  }

  @override
  String get insightAlmostThereTitle => 'Almost at your goal';

  @override
  String insightAlmostThereBody(int calories) {
    return 'You have $calories kcal left today. A balanced snack should fit nicely.';
  }

  @override
  String get insightOnTrackTitle => 'On track today';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return '$calories kcal and ${grams}g protein left to reach your daily targets.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Build your weekly rhythm';

  @override
  String get insightWeeklyRhythmBody =>
      'Log meals across the week so Celia can spot patterns and coach you better.';

  @override
  String get insightWeeklyTrendTitle => 'Weekly trend';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'You logged meals on $days of the last 7 days, averaging $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'right around your daily target';

  @override
  String insightTrendAbove(int delta) {
    return '$delta kcal above your target on average';
  }

  @override
  String insightTrendBelow(int delta) {
    return '$delta kcal below your target on average';
  }

  @override
  String get insightsSectionTitle => 'Celia Insights';
}
