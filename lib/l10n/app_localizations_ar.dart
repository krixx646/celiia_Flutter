// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Celia - المدرب الشامل';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionDone => 'تم';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionYesDoIt => 'نعم، نفّذ ذلك';

  @override
  String get actionNotNow => 'ليس الآن';

  @override
  String get loadingPreparing => 'جارٍ إعداد Celia...';

  @override
  String get loadingGeneric => 'جارٍ التحميل...';

  @override
  String get errorGeneric => 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorCanceled => 'تم إلغاء الإجراء.';

  @override
  String get errorTooManyRequests =>
      'محاولات كثيرة جدًا. يُرجى الانتظار دقيقة ثم المحاولة مرة أخرى.';

  @override
  String get errorNetwork =>
      'يُرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorBadCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorEmailInUse =>
      'هذا البريد الإلكتروني مستخدم بالفعل. حاول تسجيل الدخول بدلًا من ذلك.';

  @override
  String get errorWeakPassword => 'استخدم كلمة مرور أقوى وحاول مرة أخرى.';

  @override
  String get errorInvalidEmail => 'يُرجى إدخال عنوان بريد إلكتروني صالح.';

  @override
  String get errorNoPermission => 'ليس لديك إذن للقيام بذلك.';

  @override
  String get errorNotSignedIn => 'يُرجى تسجيل الدخول والمحاولة مرة أخرى.';

  @override
  String get errorNoConversation => 'ابدأ محادثة جديدة للمتابعة.';

  @override
  String get errorNoPlayableVideos =>
      'لا تتوفر حاليًا أي فيديوهات قابلة للتشغيل لهذا التمرين.';

  @override
  String get errorLoadRoutines =>
      'تعذّر تحميل التمارين حاليًا. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorLoadSavedRoutines =>
      'تعذّر تحميل التمارين المحفوظة حاليًا. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorGenerateRoutine =>
      'تعذّر إنشاء تمرين حاليًا. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorLoadChats => 'تعذّر تحميل المحادثات المحفوظة حاليًا.';

  @override
  String get errorCeliaUnavailable =>
      'Celia غير متاحة حاليًا. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorOpenConversation => 'تعذّر فتح هذه المحادثة.';

  @override
  String get errorDeleteConversation =>
      'تعذّر حذف هذه المحادثة. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorSignIn => 'تعذّر تسجيل الدخول. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorCreateAccount =>
      'تعذّر إنشاء حسابك. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorSendResetEmail =>
      'تعذّر إرسال رسالة إعادة تعيين كلمة المرور. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorSendVerificationEmail =>
      'تعذّر إرسال رسالة التحقق. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorGoogleSignIn =>
      'فشل تسجيل الدخول باستخدام Google. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorAppleSignIn =>
      'فشل تسجيل الدخول باستخدام Apple. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorRefreshNutrition => 'تعذّر تحديث بيانات التغذية.';

  @override
  String get errorLoadNutritionProfile => 'تعذّر تحميل ملفك الغذائي.';

  @override
  String get startupErrorTitle => 'تعذّر بدء التطبيق';

  @override
  String get startupErrorBody =>
      'يُرجى إغلاق التطبيق وإعادة فتحه. إذا استمرت المشكلة، فتواصل مع الدعم.';

  @override
  String get authTagline => 'رفيقك في اللياقة البدنية';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String authVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get authForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get authOr => 'أو';

  @override
  String get authContinueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get authContinueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get authAuthenticating => 'جارٍ التحقق...';

  @override
  String get authEnterYourName => 'يُرجى إدخال اسمك.';

  @override
  String get authNeedAccount => 'هل تحتاج إلى حساب؟ إنشاء حساب';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get authFieldName => 'اسمك';

  @override
  String get authFieldEmail => 'البريد الإلكتروني';

  @override
  String get authFieldPassword => 'كلمة المرور';

  @override
  String get verifyEmailTitle => 'تحقّق من بريدك الإلكتروني';

  @override
  String get verifyEmailHeading => 'تحقّق من صندوق الوارد';

  @override
  String get verifyEmailBody => 'تم إرسال رابط التحقق إلى بريدك الإلكتروني.';

  @override
  String get verifyEmailSent => 'تم إرسال رسالة التحقق!';

  @override
  String get verifyEmailContinue => 'تحققتُ، متابعة';

  @override
  String get verifyEmailSignOut => 'تسجيل الخروج';

  @override
  String get verifyEmailSending => 'جارٍ الإرسال...';

  @override
  String get verifyEmailResend => 'إعادة إرسال رسالة التحقق';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'إعادة الإرسال خلال $secondsث';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'البريد الإلكتروني: $email';
  }

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordBody =>
      'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordEmptyEmail => 'يرجى إدخال بريد إلكتروني';

  @override
  String get forgotPasswordSent => 'تم إرسال رسالة إعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordSend => 'إرسال رابط إعادة التعيين';

  @override
  String get forgotPasswordSending => 'جارٍ الإرسال...';

  @override
  String get nameSetupTitle => 'بماذا تناديك Celia؟';

  @override
  String get nameSetupBody =>
      'نستخدم اسمك في جميع أنحاء التطبيق لتقديم تجربة تدريب شخصية.';

  @override
  String get nameSetupSaveFailed => 'تعذر حفظ اسمك. يرجى المحاولة مرة أخرى.';

  @override
  String get homeGoodMorning => 'صباح الخير،';

  @override
  String get homeCeliaActive => 'CELIA نشطة';

  @override
  String get homeGenerateRoutine =>
      'أنشئ روتينك\nالشخصي\nباستخدام الذكاء الاصطناعي';

  @override
  String get homeCreateRoutine => 'إنشاء روتين';

  @override
  String get homeQuickActions => 'إجراءات سريعة';

  @override
  String get homeUpNext => 'التالي';

  @override
  String get homeNoUpcoming =>
      'لا توجد روتينات قادمة بعد.\nأنشئ روتينًا أو تصفح المكتبة.';

  @override
  String get homeChatWithCelia => 'تحدث مع Celia';

  @override
  String get homeChatSubtitle => 'اسأل عن أسلوب أدائك أو نظامك الغذائي';

  @override
  String get homeScanMeal => 'مسح وجبة';

  @override
  String get homeScanMealSubtitle => 'تعرّف على الطعام والسعرات الحرارية';

  @override
  String get homeNutrition => 'التغذية';

  @override
  String get homeNutritionSubtitle => 'عرض السعرات والماكرو والوجبات';

  @override
  String get homeBrowseLibrary => 'تصفح\nالمكتبة';

  @override
  String get homeTrackProgress => 'تتبع\nالتقدم';

  @override
  String get chatTitle => 'المدربة Celia';

  @override
  String get chatEmptyPrompt => 'كيف يمكنني مساعدتك\nعلى تحقيق اللياقة اليوم؟';

  @override
  String get chatYourChats => 'محادثاتك';

  @override
  String get chatNoSavedChats => 'لا توجد محادثات محفوظة بعد.';

  @override
  String get chatHistory => 'سجل المحادثات';

  @override
  String get chatNew => 'محادثة جديدة';

  @override
  String get chatOpening => 'جارٍ فتح المحادثة...';

  @override
  String get chatScanAMeal => 'مسح وجبة';

  @override
  String get chatInputHint => 'اسأل Celia عن أي شيء يتعلق بتدريبك...';

  @override
  String get chatCouldNotOpenRoutine => 'تعذر فتح ذلك الروتين';

  @override
  String get chatThisRoutine => 'هذا الروتين';

  @override
  String get chatThisMeal => 'هذه الوجبة';

  @override
  String get chatYourRoutine => 'روتينك';

  @override
  String chatMoreExercises(int count) {
    return '+ $count إضافية';
  }

  @override
  String get chatEmptySubtitle => 'اسأل عن تدريبك أو طعامك أو تقدمك.';

  @override
  String chatLoggedToday(int calories) {
    return 'سجلتَ $calories kcal اليوم.';
  }

  @override
  String get chatSuggestionHiit => 'أنشئ لي روتين HIIT مدته 20 دقيقة';

  @override
  String get chatSuggestionDinner => 'ماذا ينبغي أن آكل الليلة؟';

  @override
  String get chatSuggestionProgress => 'كيف هو أدائي هذا الأسبوع؟';

  @override
  String get chatSuggestionIngredients => 'لدي دجاج وأرز وسبانخ';

  @override
  String get chatJustNow => 'الآن';

  @override
  String chatMinutesAgo(int minutes) {
    return 'منذ $minutesد';
  }

  @override
  String chatHoursAgo(int hours) {
    return 'منذ $hoursس';
  }

  @override
  String chatDaysAgo(int days) {
    return 'منذ $daysي';
  }

  @override
  String get chatRoutineAlreadySaved => 'موجود بالفعل في مكتبتك — اضغط لفتحه';

  @override
  String get chatRoutineTapToOpen => 'اضغط للفتح';

  @override
  String get chatToolCancelled => 'أُلغيت العملية';

  @override
  String chatToolFailed(String label) {
    return '$label — تعذّر تنفيذ ذلك';
  }

  @override
  String get chatToolRoutineSaveFailed => 'تعذّر حفظ الروتين';

  @override
  String get chatToolRoutineSaved => 'تم الحفظ في مكتبتك';

  @override
  String get chatToolMealLogged => 'تمت الإضافة إلى سجل اليوم';

  @override
  String get chatToolRoutineAdded => 'تمت الإضافة إلى مكتبتك';

  @override
  String get activityCheckingProgress => 'جارٍ التحقق من تقدمك';

  @override
  String get activityCheckingNutrition => 'جارٍ التحقق مما تناولته اليوم';

  @override
  String get activityReviewingMeals => 'جارٍ مراجعة وجباتك الأخيرة';

  @override
  String get activityLookingAtRoutines => 'جارٍ الاطلاع على روتيناتك';

  @override
  String get activityReadingRoutine => 'جارٍ قراءة هذا الروتين';

  @override
  String get activitySearchingLibrary => 'جارٍ البحث في مكتبة التمارين';

  @override
  String get activityBuildingRoutine => 'جارٍ إعداد روتينك';

  @override
  String get activityLoggingMeal => 'جارٍ تسجيل وجبتك';

  @override
  String get activitySavingToLibrary => 'جارٍ الحفظ في مكتبتك';

  @override
  String get activityWorking => 'جارٍ العمل على ذلك';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'هل تريد حفظ \"$name\" مع $count من التمارين في مكتبتك؟';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'هل تريد حفظ \"$name\" في مكتبتك؟';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'هل تريد تسجيل \"$name\" بواقع $calories kcal؟';
  }

  @override
  String approvalLogMeal(String name) {
    return 'هل تريد تسجيل \"$name\"؟';
  }

  @override
  String get approvalAddRoutine => 'هل تريد إضافة هذا الروتين إلى مكتبتك؟';

  @override
  String get approvalGeneric => 'هل تسمح لـ Celia بتنفيذ هذا الإجراء؟';

  @override
  String get libraryTitle => 'مكتبة الروتينات';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطوات',
      one: '$count خطوة',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'لا توجد روتينات بعد';

  @override
  String get libraryEmptyBody => 'أنشئ روتينات وانشرها في لوحة تحكم الإدارة.';

  @override
  String get libraryLoadFailed => 'تعذّر تحميل الروتينات';

  @override
  String get routineStartWorkout => 'بدء التمرين';

  @override
  String get routineNoSteps => 'لا تتوفر خطوات';

  @override
  String get routineNoVideoForStep => 'لا يتوفر فيديو لهذه الخطوة';

  @override
  String get routineVideoProcessing =>
      'لا يزال الفيديو قيد المعالجة. يُرجى المحاولة لاحقًا.';

  @override
  String get routineMissingPlaybackUrl => 'عنوان تشغيل هذا الفيديو مفقود';

  @override
  String get routinePreviewBanner => 'معاينة — سيتوفر الفيديو الكامل قريبًا';

  @override
  String get routinePreview => 'معاينة';

  @override
  String get routineDetails => 'التفاصيل';

  @override
  String get routineNotFound => 'لم يتم العثور على الروتين';

  @override
  String routineCompletedTimes(int count) {
    return 'تم الإكمال $count مرات';
  }

  @override
  String get playerVideoUnavailable => 'هذا الفيديو غير متاح حاليًا.';

  @override
  String get playerSteps => 'الخطوات';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'لا توجد فيديوهات قابلة للتشغيل';

  @override
  String get playerWorkoutComplete => 'اكتمل التمرين!';

  @override
  String get playerSavingStreak => 'جارٍ الحفظ في سلسلة إنجازاتك…';

  @override
  String get playerSavedStreak => 'تم الحفظ في سلسلة إنجازاتك';

  @override
  String get playerRetrySave => 'إعادة محاولة الحفظ';

  @override
  String get playerReplay => 'إعادة التشغيل';

  @override
  String get playerNotReady => 'المشغّل غير جاهز';

  @override
  String get playerPreviewUnavailable => 'المعاينة غير متاحة حاليًا.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'المقطع $current من $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'حدث خطأ أثناء تحميل الفيديو';

  @override
  String get playerLoadingVideo => 'جارٍ تحميل الفيديو...';

  @override
  String get playerFailedToLoadVideo => 'تعذّر تحميل الفيديو';

  @override
  String get playerNotInitialized => 'لم تتم تهيئة مشغّل الفيديو';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'التمرين $current/$total';
  }

  @override
  String get guidedGetReady => 'استعد';

  @override
  String guidedSetOf(int current, int total) {
    return 'المجموعة $current من $total';
  }

  @override
  String get guidedRest => 'راحة';

  @override
  String get guidedSkipRest => 'تخطّي الراحة';

  @override
  String get guidedPaused => 'متوقف مؤقتًا';

  @override
  String get guidedResume => 'استئناف';

  @override
  String get guidedWorkoutComplete => 'اكتمل التمرين';

  @override
  String get guidedEndTitle => 'إنهاء التمرين؟';

  @override
  String get guidedEndBody => 'لن يتم حفظ تقدمك لهذه الجلسة.';

  @override
  String get guidedKeepGoing => 'تابع';

  @override
  String get guidedEnd => 'إنهاء';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تكرارات',
      one: '$count تكرار',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'إنشاء روتين بالذكاء الاصطناعي';

  @override
  String get generateSheetPrompt => 'ما نوع التمرين الذي تريده؟';

  @override
  String get generateSheetHint =>
      'مثال: \"تمدد صباحي سريع للاستيقاظ\" أو \"تمارين قوة لكامل الجسم للمبتدئين\"';

  @override
  String get generateSheetDuration => 'المدة';

  @override
  String generateSheetMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String get generateSheetDifficulty => 'الصعوبة';

  @override
  String get generateSheetEquipment => 'المعدات المتاحة';

  @override
  String get generateSheetGenerating => 'جارٍ الإنشاء...';

  @override
  String get generateSheetSubmit => 'إنشاء روتين';

  @override
  String get generateSheetDescribeFirst => 'يرجى وصف التمرين الذي تريده';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'لديك هذا بالفعل: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'تم الإنشاء: $title';
  }

  @override
  String get generateSheetFailed => 'تعذّر إنشاء الروتين';

  @override
  String get guidedNoExercises => 'لا يحتوي هذا الروتين على تمارين بعد.';

  @override
  String get guidedStartFailed =>
      'تعذّر بدء هذا التمرين الآن. يُرجى المحاولة مرة أخرى.';

  @override
  String get guidedSaveFailed =>
      'تعذّر حفظ هذا التمرين. اضغط على إعادة المحاولة لتحديث سلسلة إنجازاتك.';

  @override
  String guidedOfReps(int count) {
    return 'من $count تكرارات';
  }

  @override
  String get guidedHold => 'ثبات';

  @override
  String get guidedNextSet => 'المجموعة التالية';

  @override
  String get guidedUpNext => 'التالي';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds ث ثبات';
  }

  @override
  String coachGetReady(String exercise) {
    return 'استعد. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'ابدأ. $count تكرارات.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'اثبت لمدة $seconds ثانية.';
  }

  @override
  String coachRest(String exercise) {
    return 'استرح. التالي: $exercise';
  }

  @override
  String get coachRestShort => 'استرح.';

  @override
  String get coachComplete => 'أحسنت. اكتمل التمرين.';

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
      'لم يتم العثور على فيديوهات قابلة للتشغيل في هذا الروتين.';

  @override
  String get playerLoadRoutineFailed =>
      'تعذّر تحميل هذا الروتين الآن. يُرجى المحاولة مرة أخرى.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'تعذّر تحميل \"$title\". جارٍ التخطي…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'تعذّر تحميل \"$title\".';
  }

  @override
  String get playerSaveCompletionFailed =>
      'تعذّر حفظ الإكمال. اضغط على إعادة المحاولة لتحديث سلسلة إنجازاتك.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • معاينة';
  }

  @override
  String get playerNoVideosReady =>
      'لا يحتوي هذا الروتين على فيديوهات جاهزة للتشغيل بعد.';

  @override
  String get playerPlaybackFailed =>
      'تعذّر تشغيل هذا الفيديو الآن. يُرجى المحاولة مرة أخرى.';

  @override
  String get libraryTabCurated => 'منتقاة';

  @override
  String get libraryTabAiGenerated => 'منشأة بالذكاء الاصطناعي';

  @override
  String get profileSavedRoutines => 'الروتينات المحفوظة';

  @override
  String get savedRoutinesNoFavorites => 'لا توجد روتينات مفضلة بعد.';

  @override
  String get savedRoutinesEmpty => 'لا توجد روتينات محفوظة بعد.';

  @override
  String get actionFavorite => 'إضافة إلى المفضلة';

  @override
  String get actionUnfavorite => 'إزالة من المفضلة';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hoursس';
  }

  @override
  String get difficultyEasy => 'سهل';

  @override
  String get difficultyMedium => 'متوسط';

  @override
  String get difficultyHard => 'صعب';

  @override
  String get categoryStrength => 'القوة';

  @override
  String get categoryCardio => 'الكارديو';

  @override
  String get categoryFlexibility => 'المرونة';

  @override
  String get categoryMindfulness => 'اليقظة الذهنية';

  @override
  String get categoryDance => 'الرقص';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'يوغا';

  @override
  String get categoryCustom => 'مخصص';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navChat => 'الدردشة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get equipmentNone => 'لا شيء';

  @override
  String get equipmentDumbbells => 'دمبلز';

  @override
  String get equipmentResistanceBands => 'أحزمة مقاومة';

  @override
  String get equipmentYogaMat => 'حصيرة يوغا';

  @override
  String get equipmentKettlebell => 'كرة kettlebell';

  @override
  String get equipmentPullUpBar => 'عقلة';

  @override
  String get equipmentJumpRope => 'حبل القفز';

  @override
  String get nutritionTitle => 'التغذية';

  @override
  String get nutritionSubtitle => 'السعرات والماكروز وسجل الوجبات';

  @override
  String get nutritionSetGoalsTitle => 'حدّد أهدافك الغذائية اليومية';

  @override
  String get nutritionSetGoalsBody =>
      'أضف وزنك وطولك وعمرك وجنسك حتى تتمكن Celia من حساب عدد السعرات والعناصر الغذائية التي ينبغي أن تستهلكها يوميًا.';

  @override
  String get nutritionSetUpGoals => 'إعداد الأهداف';

  @override
  String get nutritionDailyTarget => 'الهدف اليومي';

  @override
  String get nutritionDailyGoals => 'الأهداف اليومية';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P $proteinغ · C $carbsغ · F $fatغ';
  }

  @override
  String get nutritionToday => 'اليوم';

  @override
  String get nutritionMealHistory => 'سجل الوجبات';

  @override
  String get nutritionCeliaInsights => 'رؤى Celia';

  @override
  String get nutritionWeeklyTrend => 'الاتجاه الأسبوعي';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وجبات',
      one: '$count وجبة',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وجبات',
      one: '$count وجبة',
    );
    return 'من أصل $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'ن,ث,ر,خ,ج,س,ح';

  @override
  String get nutritionFieldFoodName => 'اسم الطعام';

  @override
  String get nutritionFieldGrams => 'الجرامات';

  @override
  String get nutritionFieldCalories => 'السعرات';

  @override
  String get scannerStatusAnalyzing => 'جارٍ التحليل...';

  @override
  String get scannerStatusIdle => 'ماسح CELIA';

  @override
  String get scannerFieldFoodName => 'اسم الطعام';

  @override
  String get scannerFieldGrams => 'الجرامات';

  @override
  String get scannerFieldCalories => 'السعرات';

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
    return 'تبقى $calories kcal و$gramsغ من البروتين اليوم';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return 'تجاوزت هدفك اليومي بمقدار $calories kcal';
  }

  @override
  String get scannerButtonAnalyzing => 'جارٍ التحليل';

  @override
  String get scannerButtonQuotaNeeded => 'يلزم توفر حصة';

  @override
  String get scannerButtonScanNow => 'امسح الآن';

  @override
  String get scannerButtonLogging => 'جارٍ التسجيل';

  @override
  String get scannerButtonLogMeal => 'تسجيل الوجبة';

  @override
  String get scannerNoClearFood =>
      'لم يتم اكتشاف طعام واضح بعد. جرّب إضاءة أفضل أو اقترب أكثر.';

  @override
  String get scannerErrorCameraPermission =>
      'يلزم السماح باستخدام الكاميرا لمسح الوجبات.';

  @override
  String get scannerErrorBackendMissing =>
      'لم تتم تهيئة خادم ماسح السعرات بعد.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'مفتاح OpenAI API المستخدم لمسح السعرات غير صالح. استبدله في بيئة الخادم، ثم أعد النشر وحاول مرة أخرى.';

  @override
  String get scannerErrorApiKeyMissing =>
      'يلزم توفير مفتاح OpenAI API لمسح السعرات. أضفه في Vercel، ثم أعد النشر وحاول مرة أخرى.';

  @override
  String get scannerErrorQuotaExhausted =>
      'نفدت أرصدة OpenAI لمسح السعرات. أضف أرصدة API أو ارفع حد الفوترة، ثم حاول مرة أخرى.';

  @override
  String get scannerErrorTimeout =>
      'احتاجت Celia إلى مزيد من الوقت لتحليل هذه الوجبة. ثبّت الكاميرا وامسحها مرة أخرى.';

  @override
  String get scannerErrorNotSignedIn => 'يرجى تسجيل الدخول قبل مسح الوجبات.';

  @override
  String get scannerErrorMealTableMissing =>
      'جدول تسجيل الوجبات غير جاهز بعد. لا تزال نتيجة المسح متاحة.';

  @override
  String get scannerErrorGeneric =>
      'تعذّر على Celia تحليل هذه الوجبة بعد. ثبّت الكاميرا، وأبقِ الطعام في المنتصف، ثم امسح مرة أخرى.';

  @override
  String nutritionGrams(String grams) {
    return '$gramsغ';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: '$count عنصر',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'تفاصيل الوجبة';

  @override
  String get nutritionFoodItems => 'الأطعمة';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '$gramsغ · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'يجب أن تحتوي الوجبة على طعام واحد على الأقل.';

  @override
  String get nutritionMealUpdated => 'تم تحديث الوجبة';

  @override
  String nutritionUpdateFailed(String error) {
    return 'تعذر تحديث الوجبة: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'حذف الوجبة؟';

  @override
  String get nutritionDeleteMealBody =>
      'سيؤدي هذا إلى إزالة الوجبة من سجل تغذيتك.';

  @override
  String get nutritionDeleteMeal => 'حذف الوجبة';

  @override
  String nutritionDeleteFailed(String error) {
    return 'تعذر حذف الوجبة: $error';
  }

  @override
  String get nutritionEditFood => 'تعديل الطعام';

  @override
  String get nutritionSaveFood => 'حفظ الطعام';

  @override
  String get nutritionLoadFailed => 'تعذر تحميل الوجبات';

  @override
  String get nutritionLoadFailedBody =>
      'اسحب للتحديث أو تحقق من اتصال الواجهة الخلفية.';

  @override
  String get nutritionNoMeals => 'لم تُسجَّل أي وجبات بعد';

  @override
  String get nutritionNoMealsBody =>
      'امسح وجبتك الأولى ضوئيًا، وستنشئ Celia سجل تغذيتك.';

  @override
  String get progressToday => 'اليوم';

  @override
  String get progressSetGoals =>
      'حدّد أهدافك الغذائية لفتح تتبع السعرات والعناصر الغذائية الكبرى.';

  @override
  String progressOfTarget(int target) {
    return 'من أصل $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / $targetغ';
  }

  @override
  String progressKcalOver(int calories) {
    return 'تجاوزت $calories kcal';
  }

  @override
  String progressKcalLeft(int calories) {
    return 'متبقي $calories kcal';
  }

  @override
  String get progressProtein => 'البروتين';

  @override
  String get progressCarbs => 'الكربوهيدرات';

  @override
  String get progressFat => 'الدهون';

  @override
  String get scannerEditItem => 'تعديل عنصر الطعام';

  @override
  String get scannerSaveChanges => 'حفظ التغييرات';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'مستوى الثقة $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count عناصر إضافية مضمنة في سجل هذه الوجبة';
  }

  @override
  String get scannerIfYouLog => 'إذا سجّلت هذه الوجبة';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal اليوم';
  }

  @override
  String scannerGramsDecimal(String grams) {
    return '$gramsغ';
  }

  @override
  String scannerItemServing(String name, int grams) {
    return '$name · $gramsغ';
  }

  @override
  String get scannerNoMealDetected => 'لم يتم اكتشاف وجبة';

  @override
  String onboardingWelcome(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get onboardingGender => 'الجنس';

  @override
  String get onboardingCalculateGoals => 'احسب أهدافي';

  @override
  String get onboardingScanFirstMeal => 'امسح وجبتي الأولى';

  @override
  String get onboardingExploreRoutines => 'استكشف التمارين';

  @override
  String get onboardingGoHome => 'الانتقال إلى الرئيسية';

  @override
  String get onboardingDailyTargets => 'أهدافك اليومية';

  @override
  String onboardingProtein(int grams) {
    return 'البروتين $gramsغ ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'البروتين $proteinغ • الكربوهيدرات $carbsغ • الدهون $fatغ';
  }

  @override
  String get onboardingTargetsReady =>
      'أصبحت أهدافك الغذائية اليومية جاهزة. اختر الطريقة التي تريد أن تبدأ بها.';

  @override
  String get onboardingWeightKg => 'الوزن (كغ)';

  @override
  String get onboardingHeightCm => 'الطول (سم)';

  @override
  String get onboardingAge => 'العمر';

  @override
  String get onboardingInvalidWeight => 'أدخل وزنًا صالحًا بالكغ.';

  @override
  String get onboardingInvalidHeight => 'أدخل طولًا صالحًا بالسم.';

  @override
  String get onboardingInvalidAge => 'أدخل عمرًا صالحًا بين 13 و100.';

  @override
  String get onboardingSaveFailed => 'تعذر حفظ ملفك الغذائي.';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get genderOther => 'آخر';

  @override
  String get nutritionSetupTitle => 'أهداف التغذية اليومية';

  @override
  String get nutritionSetupBody =>
      'أخبر Celia عن جسمك لتتمكن من حساب سعراتك والعناصر الغذائية الكبرى اليومية.';

  @override
  String get nutritionSetupGender => 'الجنس';

  @override
  String get nutritionSetupFootnote =>
      'تستخدم Celia وزنك وطولك وعمرك وجنسك لتقدير أهداف السعرات والعناصر الغذائية الكبرى اليومية بناءً على مستوى نشاط معتدل.';

  @override
  String get nutritionSetupSave => 'حفظ الأهداف';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'عضو مميز';

  @override
  String get profileAccount => 'الحساب';

  @override
  String profileSignedInAs(String email) {
    return 'تم تسجيل الدخول باسم:\n$email';
  }

  @override
  String get profileUnknownEmail => 'غير معروف';

  @override
  String get profileDarkMode => 'الوضع الداكن';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLogOutTitle => 'تسجيل الخروج؟';

  @override
  String get profileLogOutBody => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get profileLogOut => 'تسجيل الخروج';

  @override
  String get profileLogOutButton => 'تسجيل الخروج';

  @override
  String get profileFavoriteRoutines => 'التمارين المفضلة';

  @override
  String get profileSubscription => 'الاشتراك';

  @override
  String get profileNutrition => 'التغذية';

  @override
  String get profileHelpSupport => 'المساعدة والدعم';

  @override
  String get profileFriend => 'صديق';

  @override
  String get profileStatSaved => 'المحفوظة';

  @override
  String get profileStatStreak => 'سلسلة الأيام';

  @override
  String get profileStatWorkouts => 'التمارين';

  @override
  String get streakDayOneStarted =>
      'بدأت اليوم الأول — عُد غدًا لبناء سلسلة أيامك.';

  @override
  String get streakRebuild =>
      'كنت نشطًا أمس — سجّل وجبة أو أكمل تمرينًا اليوم لإعادة بناء سلسلتك.';

  @override
  String get streakStart => 'سجّل وجبة أو أكمل تمرينًا لبدء سلسلة نشاطك.';

  @override
  String streakLongRun(int days) {
    return 'سلسلة مستمرة لمدة $days يومًا! واصل الالتزام — Celia تتابع انتظامك.';
  }

  @override
  String streakBothLogged(int days) {
    return 'سلسلة مستمرة لمدة $days يومًا — تم تسجيل التمرين والتغذية اليوم.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'سلسلة مستمرة لمدة $days يومًا. تمرين سريع سيكمل يومك.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'سلسلة مستمرة لمدة $days يومًا. سجّل وجبة لتتبع تغذيتك.';
  }

  @override
  String streakStayActive(int days) {
    return 'سلسلة مستمرة لمدة $days يومًا — حافظ على نشاطك اليوم.';
  }

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileName => 'الاسم';

  @override
  String get editProfileFootnote =>
      'سيتم حفظ التغييرات في حسابك وستظهر في الصفحة الرئيسية/الملف الشخصي.';

  @override
  String get editProfileSaveFailed =>
      'تعذر تحديث الملف الشخصي. يُرجى المحاولة مرة أخرى.';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get languageSystemSubtitle => 'استخدام اللغة المحددة لهاتفك';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get insightStartFuelingTitle => 'ابدأ تغذيتك اليوم';

  @override
  String get insightStartFuelingBody =>
      'لديك كامل ميزانية السعرات المتبقية. امسح وجبتك الأولى ضوئيًا أو سجّلها للحفاظ على مسارك.';

  @override
  String get insightAboveTargetTitle => 'أعلى من الهدف اليوم';

  @override
  String insightAboveTargetBody(int calories) {
    return 'أنت تتجاوز هدفك اليومي بمقدار $calories kcal. اجعل العشاء أخف أو أضف تمرينًا قصيرًا.';
  }

  @override
  String get insightLowProteinTitle => 'البروتين لا يزال منخفضًا';

  @override
  String insightLowProteinBody(int grams) {
    return 'ما زلت بحاجة إلى نحو $gramsغ من البروتين اليوم للوصول إلى هدفك.';
  }

  @override
  String get insightAlmostThereTitle => 'اقتربت من هدفك';

  @override
  String insightAlmostThereBody(int calories) {
    return 'تبقى لك $calories kcal اليوم. ستناسبك وجبة خفيفة متوازنة.';
  }

  @override
  String get insightOnTrackTitle => 'أنت على المسار الصحيح اليوم';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'تبقى لك $calories kcal و$gramsغ من البروتين للوصول إلى أهدافك اليومية.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'ابنِ إيقاعك الأسبوعي';

  @override
  String get insightWeeklyRhythmBody =>
      'سجّل وجباتك على مدار الأسبوع ليتمكن Celia من اكتشاف الأنماط وتقديم إرشادات أفضل لك.';

  @override
  String get insightWeeklyTrendTitle => 'الاتجاه الأسبوعي';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'سجّلت وجباتك في $days من آخر 7 أيام، بمتوسط $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'قريبًا جدًا من هدفك اليومي';

  @override
  String insightTrendAbove(int delta) {
    return 'أعلى من هدفك بمتوسط $delta kcal';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'أقل من هدفك بمتوسط $delta kcal';
  }

  @override
  String get insightsSectionTitle => 'رؤى Celia';
}
