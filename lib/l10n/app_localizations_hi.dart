// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionDelete => 'हटाएँ';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionRetry => 'फिर कोशिश करें';

  @override
  String get actionDone => 'हो गया';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get actionSeeAll => 'सभी देखें';

  @override
  String get actionYesDoIt => 'हाँ, करें';

  @override
  String get actionNotNow => 'अभी नहीं';

  @override
  String get loadingPreparing => 'Celia तैयार हो रही है...';

  @override
  String get loadingGeneric => 'लोड हो रहा है...';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया फिर कोशिश करें।';

  @override
  String get errorCanceled => 'कार्रवाई रद्द कर दी गई।';

  @override
  String get errorTooManyRequests =>
      'बहुत अधिक प्रयास किए गए। कृपया एक मिनट प्रतीक्षा करें और फिर कोशिश करें।';

  @override
  String get errorNetwork =>
      'कृपया अपना इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get errorBadCredentials => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get errorEmailInUse =>
      'यह ईमेल पहले से उपयोग में है। इसके बजाय लॉग इन करने की कोशिश करें।';

  @override
  String get errorWeakPassword =>
      'ज़्यादा मज़बूत पासवर्ड इस्तेमाल करें और फिर कोशिश करें।';

  @override
  String get errorInvalidEmail => 'कृपया मान्य ईमेल पता दर्ज करें।';

  @override
  String get errorNoPermission => 'आपको ऐसा करने की अनुमति नहीं है।';

  @override
  String get errorNotSignedIn => 'कृपया साइन इन करें और फिर कोशिश करें।';

  @override
  String get errorDeleteAccount =>
      'हम आपका खाता नहीं हटा सके। कृपया फिर से कोशिश करें।';

  @override
  String get errorNoConversation => 'जारी रखने के लिए नई चैट शुरू करें।';

  @override
  String get errorNoPlayableVideos =>
      'इस रूटीन के लिए अभी कोई चलने योग्य वीडियो उपलब्ध नहीं है।';

  @override
  String get errorLoadRoutines =>
      'अभी रूटीन लोड नहीं हो सकीं। कृपया फिर कोशिश करें।';

  @override
  String get errorLoadSavedRoutines =>
      'अभी सेव की गई रूटीन लोड नहीं हो सकीं। कृपया फिर कोशिश करें।';

  @override
  String get errorGenerateRoutine =>
      'अभी रूटीन बनाई नहीं जा सकी। कृपया फिर कोशिश करें।';

  @override
  String get errorLoadChats => 'अभी सेव की गई चैट लोड नहीं हो सकीं।';

  @override
  String get errorCeliaUnavailable =>
      'Celia अभी उपलब्ध नहीं है। कृपया फिर कोशिश करें।';

  @override
  String get errorOpenConversation => 'यह बातचीत खोली नहीं जा सकी।';

  @override
  String get errorDeleteConversation =>
      'यह बातचीत हटाई नहीं जा सकी। कृपया फिर कोशिश करें।';

  @override
  String get errorSignIn => 'साइन इन नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get errorCreateAccount =>
      'आपका खाता नहीं बनाया जा सका। कृपया फिर कोशिश करें।';

  @override
  String get errorSendResetEmail =>
      'पासवर्ड रीसेट ईमेल नहीं भेजा जा सका। कृपया फिर कोशिश करें।';

  @override
  String get errorSendVerificationEmail =>
      'सत्यापन ईमेल नहीं भेजा जा सका। कृपया फिर कोशिश करें।';

  @override
  String get errorGoogleSignIn =>
      'Google से साइन इन विफल रहा। कृपया फिर कोशिश करें।';

  @override
  String get errorAppleSignIn =>
      'Apple से साइन इन विफल रहा। कृपया फिर कोशिश करें।';

  @override
  String get errorRefreshNutrition => 'पोषण डेटा रीफ़्रेश नहीं किया जा सका।';

  @override
  String get errorLoadNutritionProfile =>
      'आपकी पोषण प्रोफ़ाइल लोड नहीं की जा सकी।';

  @override
  String get startupErrorTitle => 'ऐप शुरू नहीं हो सका';

  @override
  String get startupErrorBody =>
      'कृपया ऐप बंद करके फिर खोलें। अगर समस्या बनी रहती है, तो सहायता टीम से संपर्क करें।';

  @override
  String get authTagline => 'आपका फिटनेस साथी';

  @override
  String get authSignUp => 'साइन अप करें';

  @override
  String get authLogIn => 'लॉग इन करें';

  @override
  String authVersion(String version) {
    return 'वर्ज़न $version';
  }

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get authOr => 'या';

  @override
  String get authContinueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get authContinueWithApple => 'Apple के साथ जारी रखें';

  @override
  String get authAuthenticating => 'प्रमाणीकरण हो रहा है...';

  @override
  String get authEnterYourName => 'कृपया अपना नाम दर्ज करें।';

  @override
  String get authNeedAccount => 'खाता चाहिए? साइन अप करें';

  @override
  String get authHaveAccount => 'पहले से खाता है? लॉग इन करें';

  @override
  String get authFieldName => 'आपका नाम';

  @override
  String get authFieldEmail => 'ईमेल';

  @override
  String get authFieldPassword => 'पासवर्ड';

  @override
  String get verifyEmailTitle => 'अपना ईमेल सत्यापित करें';

  @override
  String get verifyEmailHeading => 'अपना इनबॉक्स देखें';

  @override
  String get verifyEmailBody => 'आपके ईमेल पर सत्यापन लिंक भेजा गया है।';

  @override
  String get verifyEmailSent => 'सत्यापन ईमेल भेज दिया गया!';

  @override
  String get verifyEmailContinue => 'मैंने सत्यापित कर लिया, आगे बढ़ें';

  @override
  String get verifyEmailSignOut => 'साइन आउट करें';

  @override
  String get verifyEmailSending => 'भेजा जा रहा है...';

  @override
  String get verifyEmailResend => 'सत्यापन ईमेल फिर से भेजें';

  @override
  String verifyEmailResendIn(int seconds) {
    return '$seconds सेकंड में फिर से भेजें';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'ईमेल: $email';
  }

  @override
  String get forgotPasswordTitle => 'पासवर्ड भूल गए?';

  @override
  String get forgotPasswordBody =>
      'पासवर्ड रीसेट लिंक पाने के लिए अपना ईमेल दर्ज करें।';

  @override
  String get forgotPasswordEmptyEmail => 'कृपया ईमेल दर्ज करें';

  @override
  String get forgotPasswordSent => 'पासवर्ड रीसेट ईमेल भेज दिया गया।';

  @override
  String get forgotPasswordSend => 'रीसेट लिंक भेजें';

  @override
  String get forgotPasswordSending => 'भेजा जा रहा है...';

  @override
  String get nameSetupTitle => 'Celia आपको किस नाम से बुलाए?';

  @override
  String get nameSetupBody =>
      'कोचिंग को व्यक्तिगत बनाने के लिए हम पूरे ऐप में आपके नाम का उपयोग करते हैं।';

  @override
  String get nameSetupSaveFailed =>
      'आपका नाम सेव नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get homeGoodMorning => 'सुप्रभात,';

  @override
  String get homeCeliaActive => 'CELIA सक्रिय';

  @override
  String get homeGenerateRoutine => 'AI की मदद से अपनी\nव्यक्तिगत\nरूटीन बनाएं';

  @override
  String get homeCreateRoutine => 'रूटीन बनाएं';

  @override
  String get homeQuickActions => 'त्वरित कार्रवाइयां';

  @override
  String get homeUpNext => 'आगे';

  @override
  String get homeNoUpcoming =>
      'अभी कोई आगामी रूटीन नहीं है।\nएक बनाएं या लाइब्रेरी देखें।';

  @override
  String get homeChatWithCelia => 'Celia से चैट करें';

  @override
  String get homeChatSubtitle => 'अपने फॉर्म या डाइट के बारे में पूछें';

  @override
  String get homeScanMeal => 'मील स्कैन करें';

  @override
  String get homeScanMealSubtitle => 'खाने और कैलोरी की पहचान करें';

  @override
  String get homeNutrition => 'पोषण';

  @override
  String get homeNutritionSubtitle => 'कैलोरी, मैक्रोज़ और मील देखें';

  @override
  String get homeBrowseLibrary => 'लाइब्रेरी\nदेखें';

  @override
  String get homeTrackProgress => 'प्रगति\nट्रैक करें';

  @override
  String get chatTitle => 'कोच Celia';

  @override
  String get chatEmptyPrompt =>
      'आज फिट होने के लिए\nमैं आपकी कैसे मदद कर सकती हूं?';

  @override
  String get chatYourChats => 'आपकी चैट';

  @override
  String get chatNoSavedChats => 'अभी कोई सेव की गई चैट नहीं है।';

  @override
  String get chatHistory => 'चैट इतिहास';

  @override
  String get chatNew => 'नई चैट';

  @override
  String get chatOpening => 'चैट खोली जा रही है...';

  @override
  String get chatScanAMeal => 'मील स्कैन करें';

  @override
  String get chatInputHint =>
      'अपनी ट्रेनिंग के बारे में Celia से कुछ भी पूछें...';

  @override
  String get chatMicTooltip => 'बोलने के लिए दबाए रखें';

  @override
  String get chatListening => 'सुन रही है…';

  @override
  String get chatMicDenied =>
      'सीलिया से बात करने के लिए माइक्रोफ़ोन की अनुमति चाहिए।';

  @override
  String get chatSpeechUnavailable => 'इस डिवाइस पर वाक् पहचान उपलब्ध नहीं है।';

  @override
  String get avatarModeReady => 'तैयार';

  @override
  String get avatarModeThinking => 'सोच रही है…';

  @override
  String get avatarModeSpeaking => 'बोल रही है…';

  @override
  String get avatarModeHoldToTalk => 'बोलने के लिए दबाकर रखें';

  @override
  String get avatarModeExit => 'मैनुअल मोड';

  @override
  String get avatarModeConfirmTitle => 'सीलिया से पुष्टि करें?';

  @override
  String get avatarModeConfirmBody =>
      'सीलिया कुछ सेव करना चाहती है। अनुमति दें?';

  @override
  String get avatarModeConfirmYes => 'अनुमति दें';

  @override
  String get chatCouldNotOpenRoutine => 'वह रूटीन खोली नहीं जा सकी';

  @override
  String get chatThisRoutine => 'यह रूटीन';

  @override
  String get chatThisMeal => 'यह मील';

  @override
  String get chatYourRoutine => 'आपकी रूटीन';

  @override
  String chatMoreExercises(int count) {
    return '+ $count और';
  }

  @override
  String get chatEmptySubtitle =>
      'अपनी ट्रेनिंग, खाने या प्रगति के बारे में पूछें।';

  @override
  String chatLoggedToday(int calories) {
    return 'आज आपने $calories kcal लॉग की हैं।';
  }

  @override
  String get chatSuggestionHiit => 'मेरे लिए 20 मिनट की HIIT रूटीन बनाएं';

  @override
  String get chatSuggestionDinner => 'आज रात मुझे क्या खाना चाहिए?';

  @override
  String get chatSuggestionProgress => 'इस हफ्ते मेरी प्रगति कैसी रही?';

  @override
  String get chatSuggestionIngredients => 'मेरे पास चिकन, चावल और पालक हैं';

  @override
  String get chatJustNow => 'अभी-अभी';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'आपकी लाइब्रेरी में पहले से है — खोलने के लिए टैप करें';

  @override
  String get chatRoutineTapToOpen => 'खोलने के लिए टैप करें';

  @override
  String get chatToolCancelled => 'रद्द किया गया';

  @override
  String chatToolFailed(String label) {
    return '$label — यह काम नहीं कर पाया';
  }

  @override
  String get chatToolRoutineSaveFailed => 'रूटीन सेव नहीं हो सकी';

  @override
  String get chatToolRoutineSaved => 'आपकी लाइब्रेरी में सेव की गई';

  @override
  String get chatToolMealLogged => 'आज के लॉग में जोड़ा गया';

  @override
  String get chatToolRoutineAdded => 'आपकी लाइब्रेरी में जोड़ा गया';

  @override
  String get activityCheckingProgress => 'आपकी प्रगति देखी जा रही है';

  @override
  String get activityCheckingNutrition =>
      'आज आपने क्या खाया, यह देखा जा रहा है';

  @override
  String get activityReviewingMeals =>
      'आपके हाल के भोजन की समीक्षा की जा रही है';

  @override
  String get activityLookingAtRoutines => 'आपकी रूटीन देखी जा रही हैं';

  @override
  String get activityReadingRoutine => 'उस रूटीन को पढ़ा जा रहा है';

  @override
  String get activitySearchingLibrary =>
      'एक्सरसाइज़ लाइब्रेरी में खोजा जा रहा है';

  @override
  String get activityBuildingRoutine => 'आपकी रूटीन बनाई जा रही है';

  @override
  String get activityLoggingMeal => 'आपका भोजन लॉग किया जा रहा है';

  @override
  String get activitySavingToLibrary => 'आपकी लाइब्रेरी में सेव किया जा रहा है';

  @override
  String get activityWorking => 'इस पर काम हो रहा है';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return '\"$name\" को $count एक्सरसाइज़ के साथ अपनी लाइब्रेरी में सेव करें?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '\"$name\" को अपनी लाइब्रेरी में सेव करें?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '\"$name\" को $calories kcal के रूप में लॉग करें?';
  }

  @override
  String approvalLogMeal(String name) {
    return '\"$name\" को लॉग करें?';
  }

  @override
  String get approvalAddRoutine => 'इस रूटीन को अपनी लाइब्रेरी में जोड़ें?';

  @override
  String get approvalGeneric => 'क्या Celia को यह करने की अनुमति दें?';

  @override
  String get libraryTitle => 'रूटीन लाइब्रेरी';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्टेप',
      one: '$count स्टेप',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'अभी कोई रूटीन नहीं है';

  @override
  String get libraryEmptyBody =>
      'एडमिन डैशबोर्ड में रूटीन बनाएँ और प्रकाशित करें।';

  @override
  String get libraryLoadFailed => 'रूटीन लोड नहीं हो सकीं';

  @override
  String get routineStartWorkout => 'वर्कआउट शुरू करें';

  @override
  String get routineNoSteps => 'कोई स्टेप उपलब्ध नहीं है';

  @override
  String get routineNoVideoForStep =>
      'इस स्टेप के लिए कोई वीडियो उपलब्ध नहीं है';

  @override
  String get routineVideoProcessing =>
      'वीडियो अभी प्रोसेस हो रहा है। कृपया बाद में फिर कोशिश करें।';

  @override
  String get routineMissingPlaybackUrl =>
      'इस वीडियो का प्लेबैक URL मौजूद नहीं है';

  @override
  String get routinePreviewBanner => 'प्रीव्यू — पूरा वीडियो जल्द आ रहा है';

  @override
  String get routinePreview => 'प्रीव्यू';

  @override
  String get routineDetails => 'विवरण';

  @override
  String get routineNotFound => 'रूटीन नहीं मिली';

  @override
  String routineCompletedTimes(int count) {
    return '$count बार पूरा किया गया';
  }

  @override
  String get playerVideoUnavailable => 'यह वीडियो अभी उपलब्ध नहीं है।';

  @override
  String get playerSteps => 'स्टेप्स';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'चलाने योग्य कोई वीडियो नहीं है';

  @override
  String get playerWorkoutComplete => 'वर्कआउट पूरा हुआ!';

  @override
  String get playerSavingStreak => 'आपकी स्ट्रीक में सेव किया जा रहा है…';

  @override
  String get playerSavedStreak => 'आपकी स्ट्रीक में सेव किया गया';

  @override
  String get playerRetrySave => 'फिर से सेव करें';

  @override
  String get playerReplay => 'दोबारा चलाएँ';

  @override
  String get playerNotReady => 'प्लेयर तैयार नहीं है';

  @override
  String get playerPreviewUnavailable => 'प्रीव्यू अभी उपलब्ध नहीं है।';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current of $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'वीडियो लोड करने में त्रुटि';

  @override
  String get playerLoadingVideo => 'वीडियो लोड हो रहा है...';

  @override
  String get playerFailedToLoadVideo => 'वीडियो लोड नहीं हो सका';

  @override
  String get playerNotInitialized => 'वीडियो प्लेयर शुरू नहीं किया गया है';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'एक्सरसाइज़ $current/$total';
  }

  @override
  String get guidedGetReady => 'तैयार हो जाएँ';

  @override
  String guidedSetOf(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String get guidedRest => 'आराम';

  @override
  String get guidedSkipRest => 'आराम छोड़ें';

  @override
  String get guidedPaused => 'रुका हुआ';

  @override
  String get guidedResume => 'फिर शुरू करें';

  @override
  String get guidedWorkoutComplete => 'वर्कआउट पूरा हुआ';

  @override
  String get guidedEndTitle => 'वर्कआउट समाप्त करें?';

  @override
  String get guidedEndBody => 'इस सत्र की आपकी प्रगति सहेजी नहीं जाएगी।';

  @override
  String get guidedKeepGoing => 'जारी रखें';

  @override
  String get guidedEnd => 'समाप्त करें';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रतिनिधि',
      one: '$count प्रतिनिधि',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'AI से रूटीन बनाएं';

  @override
  String get generateSheetPrompt => 'आप किस तरह की वर्कआउट चाहते हैं?';

  @override
  String get generateSheetHint =>
      'जैसे, \"जागने के लिए सुबह की एक त्वरित स्ट्रेचिंग\" या \"शुरुआती लोगों के लिए पूरे शरीर की स्ट्रेंथ ट्रेनिंग\"';

  @override
  String get generateSheetDuration => 'अवधि';

  @override
  String generateSheetMinutes(int count) {
    return '$count मिनट';
  }

  @override
  String get generateSheetDifficulty => 'कठिनाई';

  @override
  String get generateSheetEquipment => 'उपलब्ध उपकरण';

  @override
  String get generateSheetGenerating => 'बनाया जा रहा है...';

  @override
  String get generateSheetSubmit => 'रूटीन बनाएं';

  @override
  String get generateSheetDescribeFirst =>
      'कृपया अपनी इच्छित वर्कआउट का वर्णन करें';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'आपके पास यह पहले से है: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'बनाया गया: $title';
  }

  @override
  String get generateSheetFailed => 'रूटीन बनाने में विफल';

  @override
  String get guidedNoExercises => 'इस रूटीन में अभी कोई एक्सरसाइज़ नहीं है।';

  @override
  String get guidedStartFailed =>
      'अभी यह वर्कआउट शुरू नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get guidedSaveFailed =>
      'यह वर्कआउट सहेजा नहीं जा सका। अपनी स्ट्रीक अपडेट करने के लिए पुनः प्रयास करें।';

  @override
  String guidedOfReps(int count) {
    return '$count प्रतिनिधियों में से';
  }

  @override
  String get guidedHold => 'रोकें';

  @override
  String get guidedNextSet => 'अगला सेट';

  @override
  String get guidedUpNext => 'आगे';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds सेकंड रोकें';
  }

  @override
  String coachGetReady(String exercise) {
    return 'तैयार हो जाएं। $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'शुरू करें। $count प्रतिनिधि।';
  }

  @override
  String coachStartHold(int seconds) {
    return '$seconds सेकंड तक रोकें।';
  }

  @override
  String coachRest(String exercise) {
    return 'आराम करें। आगे: $exercise';
  }

  @override
  String get coachRestShort => 'आराम करें।';

  @override
  String get coachComplete => 'बहुत बढ़िया। वर्कआउट पूरा हुआ।';

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
      'इस रूटीन में चलाने योग्य कोई वीडियो नहीं मिला।';

  @override
  String get playerLoadRoutineFailed =>
      'अभी यह रूटीन लोड नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return '\"$title\" लोड नहीं हो सका। छोड़ा जा रहा है…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return '\"$title\" लोड नहीं हो सका।';
  }

  @override
  String get playerSaveCompletionFailed =>
      'पूरा होने की जानकारी सहेजी नहीं जा सकी। अपनी स्ट्रीक अपडेट करने के लिए पुनः प्रयास करें।';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • पूर्वावलोकन';
  }

  @override
  String get playerNoVideosReady =>
      'इस रूटीन में अभी चलाने के लिए कोई वीडियो तैयार नहीं है।';

  @override
  String get playerPlaybackFailed =>
      'अभी यह वीडियो चल नहीं सका। कृपया फिर कोशिश करें।';

  @override
  String get libraryTabCurated => 'चयनित';

  @override
  String get libraryTabAiGenerated => 'AI से बनाए गए';

  @override
  String get profileSavedRoutines => 'सहेजी गई रूटीनें';

  @override
  String get savedRoutinesNoFavorites => 'अभी कोई पसंदीदा रूटीन नहीं है।';

  @override
  String get savedRoutinesEmpty => 'अभी कोई सहेजी गई रूटीन नहीं है।';

  @override
  String get actionFavorite => 'पसंदीदा में जोड़ें';

  @override
  String get actionUnfavorite => 'पसंदीदा से हटाएं';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours घंटे $minutes मिनट';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours घंटे';
  }

  @override
  String get difficultyEasy => 'आसान';

  @override
  String get difficultyMedium => 'मध्यम';

  @override
  String get difficultyHard => 'कठिन';

  @override
  String get categoryStrength => 'स्ट्रेंथ';

  @override
  String get categoryCardio => 'कार्डियो';

  @override
  String get categoryFlexibility => 'लचीलापन';

  @override
  String get categoryMindfulness => 'माइंडफुलनेस';

  @override
  String get categoryDance => 'डांस';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'योग';

  @override
  String get categoryCustom => 'कस्टम';

  @override
  String get navHome => 'होम';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navChat => 'चैट';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get equipmentNone => 'कोई नहीं';

  @override
  String get equipmentDumbbells => 'डंबल';

  @override
  String get equipmentResistanceBands => 'रेज़िस्टेंस बैंड';

  @override
  String get equipmentYogaMat => 'योगा मैट';

  @override
  String get equipmentKettlebell => 'केटलबेल';

  @override
  String get equipmentPullUpBar => 'पुल-अप बार';

  @override
  String get equipmentJumpRope => 'रस्सी कूदने की रज्जु';

  @override
  String get nutritionTitle => 'पोषण';

  @override
  String get nutritionSubtitle => 'कैलोरी, मैक्रोज़ और भोजन का इतिहास';

  @override
  String get nutritionSetGoalsTitle => 'अपने दैनिक पोषण लक्ष्य तय करें';

  @override
  String get nutritionSetGoalsBody =>
      'अपना वज़न, लंबाई, उम्र और लिंग जोड़ें, ताकि Celia हर दिन आपके लिए आवश्यक कैलोरी और पोषक तत्वों की गणना कर सके।';

  @override
  String get nutritionSetUpGoals => 'लक्ष्य तय करें';

  @override
  String get nutritionDailyTarget => 'दैनिक लक्ष्य';

  @override
  String get nutritionDailyGoals => 'दैनिक लक्ष्य';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'आज';

  @override
  String get nutritionMealHistory => 'भोजन का इतिहास';

  @override
  String get nutritionCeliaInsights => 'Celia इनसाइट्स';

  @override
  String get nutritionWeeklyTrend => 'साप्ताहिक रुझान';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भोजन',
      one: '$count भोजन',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count भोजन',
      one: '$count भोजन',
    );
    return '$target kcal में से • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'सो,मं,मं,बु,गु,शु,र';

  @override
  String get nutritionFieldFoodName => 'भोजन का नाम';

  @override
  String get nutritionFieldGrams => 'ग्राम';

  @override
  String get nutritionFieldCalories => 'कैलोरी';

  @override
  String get scannerStatusAnalyzing => 'विश्लेषण हो रहा है...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => 'भोजन का नाम';

  @override
  String get scannerFieldGrams => 'ग्राम';

  @override
  String get scannerFieldCalories => 'कैलोरी';

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
    return 'आज $calories kcal और ${grams}g प्रोटीन बाकी है';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return 'आपके दैनिक लक्ष्य से $calories kcal अधिक';
  }

  @override
  String get scannerButtonAnalyzing => 'विश्लेषण हो रहा है';

  @override
  String get scannerButtonQuotaNeeded => 'कोटा चाहिए';

  @override
  String get scannerButtonScanNow => 'अभी स्कैन करें';

  @override
  String get scannerButtonLogging => 'दर्ज हो रहा है';

  @override
  String get scannerButtonLogMeal => 'भोजन दर्ज करें';

  @override
  String get scannerNoClearFood =>
      'अभी कोई स्पष्ट भोजन नहीं मिला। बेहतर रोशनी में कोशिश करें या पास जाएँ।';

  @override
  String get scannerErrorCameraPermission =>
      'भोजन स्कैन करने के लिए कैमरा अनुमति आवश्यक है।';

  @override
  String get scannerErrorBackendMissing =>
      'कैलोरी स्कैनर का बैकएंड अभी कॉन्फ़िगर नहीं है।';

  @override
  String get scannerErrorApiKeyInvalid =>
      'कैलोरी स्कैनिंग के लिए OpenAI API कुंजी अमान्य है। इसे बैकएंड एनवायरनमेंट में बदलें, फिर से डिप्लॉय करें और दोबारा कोशिश करें।';

  @override
  String get scannerErrorApiKeyMissing =>
      'कैलोरी स्कैनिंग के लिए OpenAI API कुंजी आवश्यक है। इसे Vercel में जोड़ें, फिर से डिप्लॉय करें और दोबारा कोशिश करें।';

  @override
  String get scannerErrorQuotaExhausted =>
      'कैलोरी स्कैनिंग के लिए OpenAI क्रेडिट समाप्त हो गए हैं। API क्रेडिट जोड़ें या बिलिंग सीमा बढ़ाएँ, फिर दोबारा कोशिश करें।';

  @override
  String get scannerErrorTimeout =>
      'Celia को इस भोजन का विश्लेषण करने में अधिक समय चाहिए। कैमरा स्थिर रखें और फिर से स्कैन करें।';

  @override
  String get scannerErrorNotSignedIn =>
      'भोजन स्कैन करने से पहले कृपया साइन इन करें।';

  @override
  String get scannerErrorMealTableMissing =>
      'भोजन दर्ज करने वाली तालिका अभी तैयार नहीं है। स्कैन का परिणाम अभी भी उपलब्ध है।';

  @override
  String get scannerErrorGeneric =>
      'Celia अभी इस भोजन का विश्लेषण नहीं कर सकी। कैमरा स्थिर रखें, भोजन को बीच में रखें और फिर से स्कैन करें।';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '$count आइटम',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'भोजन का विवरण';

  @override
  String get nutritionFoodItems => 'खाद्य पदार्थ';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'भोजन में कम से कम एक खाद्य पदार्थ होना चाहिए।';

  @override
  String get nutritionMealUpdated => 'भोजन अपडेट हो गया';

  @override
  String nutritionUpdateFailed(String error) {
    return 'भोजन अपडेट नहीं किया जा सका: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'भोजन हटाएँ?';

  @override
  String get nutritionDeleteMealBody =>
      'इससे आपका पोषण इतिहास से यह भोजन हट जाएगा।';

  @override
  String get nutritionDeleteMeal => 'भोजन हटाएँ';

  @override
  String nutritionDeleteFailed(String error) {
    return 'भोजन हटाया नहीं जा सका: $error';
  }

  @override
  String get nutritionEditFood => 'खाद्य पदार्थ संपादित करें';

  @override
  String get nutritionSaveFood => 'खाद्य पदार्थ सेव करें';

  @override
  String get nutritionLoadFailed => 'भोजन लोड नहीं हो सके';

  @override
  String get nutritionLoadFailedBody =>
      'रिफ्रेश करने के लिए नीचे खींचें या बैकएंड कनेक्शन जाँचें।';

  @override
  String get nutritionNoMeals => 'अभी तक कोई भोजन लॉग नहीं किया गया';

  @override
  String get nutritionNoMealsBody =>
      'अपना पहला भोजन स्कैन करें और Celia आपका पोषण इतिहास तैयार करेगी।';

  @override
  String get progressToday => 'आज';

  @override
  String get progressSetGoals =>
      'कैलोरी और मैक्रो ट्रैकिंग अनलॉक करने के लिए अपने पोषण लक्ष्य सेट करें।';

  @override
  String progressOfTarget(int target) {
    return '$target kcal में से';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal अधिक';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal शेष';
  }

  @override
  String get progressProtein => 'प्रोटीन';

  @override
  String get progressCarbs => 'कार्ब्स';

  @override
  String get progressFat => 'फैट';

  @override
  String get scannerEditItem => 'खाद्य पदार्थ संपादित करें';

  @override
  String get scannerSaveChanges => 'बदलाव सेव करें';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'विश्वसनीयता $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count और खाद्य पदार्थ इस भोजन लॉग में शामिल हैं';
  }

  @override
  String get scannerIfYouLog => 'अगर आप यह भोजन लॉग करते हैं';

  @override
  String scannerAfterLogging(int after, int target) {
    return 'आज $after / $target kcal';
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
  String get scannerNoMealDetected => 'कोई भोजन नहीं मिला';

  @override
  String onboardingWelcome(String name) {
    return 'स्वागत है, $name';
  }

  @override
  String get onboardingGender => 'लिंग';

  @override
  String get onboardingCalculateGoals => 'मेरे लक्ष्य कैलकुलेट करें';

  @override
  String get onboardingScanFirstMeal => 'अपना पहला भोजन स्कैन करें';

  @override
  String get onboardingExploreRoutines => 'रूटीन देखें';

  @override
  String get onboardingGoHome => 'होम पर जाएँ';

  @override
  String get onboardingDailyTargets => 'आपके दैनिक लक्ष्य';

  @override
  String onboardingProtein(int grams) {
    return 'प्रोटीन ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'प्रोटीन ${protein}g • कार्ब्स ${carbs}g • फैट ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'आपके दैनिक पोषण लक्ष्य तैयार हैं। चुनें कि आप कैसे शुरुआत करना चाहते हैं।';

  @override
  String get onboardingWeightKg => 'वज़न (kg)';

  @override
  String get onboardingHeightCm => 'लंबाई (cm)';

  @override
  String get onboardingAge => 'उम्र';

  @override
  String get onboardingInvalidWeight => 'kg में मान्य वज़न दर्ज करें।';

  @override
  String get onboardingInvalidHeight => 'cm में मान्य लंबाई दर्ज करें।';

  @override
  String get onboardingInvalidAge => '13 से 100 के बीच मान्य उम्र दर्ज करें।';

  @override
  String get onboardingSaveFailed => 'आपकी पोषण प्रोफ़ाइल सेव नहीं की जा सकी।';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderFemale => 'महिला';

  @override
  String get genderOther => 'अन्य';

  @override
  String get nutritionSetupTitle => 'दैनिक पोषण लक्ष्य';

  @override
  String get nutritionSetupBody =>
      'Celia को अपने शरीर के बारे में बताएं, ताकि वह आपकी दैनिक कैलोरी और मैक्रो की गणना कर सके।';

  @override
  String get nutritionSetupGender => 'लिंग';

  @override
  String get nutritionSetupFootnote =>
      'Celia मध्यम गतिविधि स्तर के आधार पर दैनिक कैलोरी और मैक्रो लक्ष्यों का अनुमान लगाने के लिए आपके वज़न, लंबाई, उम्र और लिंग का उपयोग करती है।';

  @override
  String get nutritionSourcesTitle => 'ये लक्ष्य कैसे गणना किए जाते हैं';

  @override
  String get nutritionSourcesBody =>
      'दैनिक कैलोरी मध्यम शारीरिक गतिविधि कारक (लगभग 1.55) के साथ Mifflin–St Jeor विश्राम ऊर्जा समीकरण का उपयोग करती हैं। सक्रिय वयस्कों के लिए प्रोटीन शरीर के वजन के प्रति किग्रा लगभग 1.8 ग्रा अनुमानित है। वसा कैलोरी का लगभग 25% निर्धारित है, और बाकी कार्ब्स भरते हैं — सामान्य आहार मार्गदर्शन सीमाओं के भीतर।';

  @override
  String get nutritionSourcesDisclaimer =>
      'ये आँकड़े केवल सामान्य वेलनेस अनुमान हैं। ये निदान, नुस्खा, या किसी योग्य चिकित्सक या पंजीकृत आहार विशेषज्ञ की सलाह का विकल्प नहीं हैं।';

  @override
  String get nutritionSetupSave => 'लक्ष्य सेव करें';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'सदस्य';

  @override
  String get profileAccount => 'खाता';

  @override
  String profileSignedInAs(String email) {
    return 'इस रूप में साइन इन हैं:\n$email';
  }

  @override
  String get profileUnknownEmail => 'अज्ञात';

  @override
  String get profileDarkMode => 'डार्क मोड';

  @override
  String get profileAvatarMode => 'अवतार मोड';

  @override
  String get profileAvatarModeSubtitle => 'सीलिया से फुल स्क्रीन पर बात करें';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLogOutTitle => 'लॉग आउट करें?';

  @override
  String get profileLogOutBody => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get profileLogOut => 'लॉग आउट';

  @override
  String get profileLogOutButton => 'लॉग आउट';

  @override
  String get profileDeleteAccount => 'खाता हटाएँ';

  @override
  String get profileDeleteAccountConfirmTitle => 'अपना खाता हटाएँ?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'यह आपके खाते और आपके सभी डेटा को स्थायी रूप से हटा देता है, जिसमें सहेजी गई दिनचर्या, भोजन लॉग और चैट इतिहास शामिल हैं। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'पुष्टि के लिए अपना पासवर्ड दर्ज करें।';

  @override
  String get profileDeleteAccountPasswordLabel => 'पासवर्ड';

  @override
  String get profileDeleteAccountButton => 'मेरा खाता हटाएँ';

  @override
  String get profileFavoriteRoutines => 'पसंदीदा रूटीन';

  @override
  String get profileSubscription => 'सब्सक्रिप्शन';

  @override
  String get profileNutrition => 'पोषण';

  @override
  String get profileHelpSupport => 'सहायता और सपोर्ट';

  @override
  String get profileFriend => 'मित्र';

  @override
  String get profileStatSaved => 'सेव किए गए';

  @override
  String get profileStatStreak => 'स्ट्रीक';

  @override
  String get profileStatWorkouts => 'वर्कआउट';

  @override
  String get streakDayOneStarted =>
      'दिन 1 शुरू हो गया है — अपनी स्ट्रीक बनाने के लिए कल फिर आएँ।';

  @override
  String get streakRebuild =>
      'आप कल सक्रिय थे — अपनी स्ट्रीक फिर से बनाने के लिए आज कोई भोजन लॉग करें या वर्कआउट पूरा करें।';

  @override
  String get streakStart =>
      'अपनी सक्रिय स्ट्रीक शुरू करने के लिए कोई भोजन लॉग करें या वर्कआउट पूरा करें।';

  @override
  String streakLongRun(int days) {
    return '$days दिनों की स्ट्रीक! लगातार आते रहें — Celia आपकी निरंतरता पर नज़र रख रही है।';
  }

  @override
  String streakBothLogged(int days) {
    return '$days दिनों की स्ट्रीक — आज वर्कआउट और पोषण, दोनों लॉग किए गए।';
  }

  @override
  String streakNeedWorkout(int days) {
    return '$days दिनों की स्ट्रीक। आज एक छोटा वर्कआउट आपकी दिनचर्या पूरी कर देगा।';
  }

  @override
  String streakNeedMeal(int days) {
    return '$days दिनों की स्ट्रीक। अपने पोषण पर नज़र रखने के लिए कोई भोजन लॉग करें।';
  }

  @override
  String streakStayActive(int days) {
    return '$days दिनों की स्ट्रीक — आज सक्रिय रहें।';
  }

  @override
  String get editProfileTitle => 'प्रोफ़ाइल संपादित करें';

  @override
  String get editProfileName => 'नाम';

  @override
  String get editProfileFootnote =>
      'बदलाव आपके खाते में सेव हो जाएँगे और होम/प्रोफ़ाइल पर दिखाई देंगे।';

  @override
  String get editProfileSaveFailed =>
      'प्रोफ़ाइल अपडेट नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSystem => 'डिवाइस की भाषा';

  @override
  String get languageSystemSubtitle => 'आपके फ़ोन पर सेट भाषा का उपयोग करें';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageSpanish => 'स्पैनिश';

  @override
  String get insightStartFuelingTitle => 'आज से पोषण शुरू करें';

  @override
  String get insightStartFuelingBody =>
      'आपका पूरा कैलोरी बजट अभी बाकी है। सही राह पर बने रहने के लिए अपना पहला भोजन स्कैन या लॉग करें।';

  @override
  String get insightAboveTargetTitle => 'आज लक्ष्य से अधिक';

  @override
  String insightAboveTargetBody(int calories) {
    return 'आप अपने दैनिक लक्ष्य से $calories kcal अधिक हैं। रात का खाना हल्का रखें या छोटा वर्कआउट करें।';
  }

  @override
  String get insightLowProteinTitle => 'प्रोटीन अभी भी कम है';

  @override
  String insightLowProteinBody(int grams) {
    return 'अपने लक्ष्य तक पहुँचने के लिए आज आपको अभी लगभग ${grams}g प्रोटीन चाहिए।';
  }

  @override
  String get insightAlmostThereTitle => 'आप अपने लक्ष्य के करीब हैं';

  @override
  String insightAlmostThereBody(int calories) {
    return 'आज आपके पास $calories kcal बाकी हैं। एक संतुलित स्नैक अच्छी तरह फिट हो जाएगा।';
  }

  @override
  String get insightOnTrackTitle => 'आज सही राह पर';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'अपने दैनिक लक्ष्यों तक पहुँचने के लिए $calories kcal और ${grams}g प्रोटीन बाकी है।';
  }

  @override
  String get insightWeeklyRhythmTitle => 'अपनी साप्ताहिक लय बनाएँ';

  @override
  String get insightWeeklyRhythmBody =>
      'पूरे सप्ताह भोजन लॉग करें, ताकि Celia पैटर्न पहचानकर आपको बेहतर मार्गदर्शन दे सके।';

  @override
  String get insightWeeklyTrendTitle => 'साप्ताहिक रुझान';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'आपने पिछले 7 में से $days दिनों में भोजन लॉग किया, औसतन $average kcal — $direction।';
  }

  @override
  String get insightTrendOnTarget => 'आपके दैनिक लक्ष्य के लगभग बराबर';

  @override
  String insightTrendAbove(int delta) {
    return 'औसतन आपके लक्ष्य से $delta kcal अधिक';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'औसतन आपके लक्ष्य से $delta kcal कम';
  }

  @override
  String get insightsSectionTitle => 'Celia की जानकारियाँ';
}
