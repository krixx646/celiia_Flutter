// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionRetry => 'Tekrar Dene';

  @override
  String get actionDone => 'Bitti';

  @override
  String get actionClose => 'Kapat';

  @override
  String get actionContinue => 'Devam Et';

  @override
  String get actionSeeAll => 'Tümünü Gör';

  @override
  String get actionYesDoIt => 'Evet, yap';

  @override
  String get actionNotNow => 'Şimdi değil';

  @override
  String get loadingPreparing => 'Celia hazırlanıyor...';

  @override
  String get loadingGeneric => 'Yükleniyor...';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get errorCanceled => 'İşlem iptal edildi.';

  @override
  String get errorTooManyRequests =>
      'Çok fazla deneme yapıldı. Lütfen bir dakika bekleyip tekrar deneyin.';

  @override
  String get errorNetwork =>
      'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorBadCredentials => 'E-posta veya şifre yanlış.';

  @override
  String get errorEmailInUse =>
      'Bu e-posta zaten kullanılıyor. Bunun yerine giriş yapmayı deneyin.';

  @override
  String get errorWeakPassword =>
      'Daha güçlü bir şifre kullanıp tekrar deneyin.';

  @override
  String get errorInvalidEmail => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get errorNoPermission => 'Bunu yapma izniniz yok.';

  @override
  String get errorNotSignedIn => 'Lütfen giriş yapıp tekrar deneyin.';

  @override
  String get errorDeleteAccount =>
      'Hesabınız silinemedi. Lütfen tekrar deneyin.';

  @override
  String get errorNoConversation =>
      'Devam etmek için yeni bir sohbet başlatın.';

  @override
  String get errorNoPlayableVideos =>
      'Bu rutin için henüz oynatılabilir video yok.';

  @override
  String get errorLoadRoutines =>
      'Rutinler şu anda yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get errorLoadSavedRoutines =>
      'Kayıtlı rutinler şu anda yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get errorGenerateRoutine =>
      'Şu anda rutin oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get errorLoadChats => 'Kayıtlı sohbetler şu anda yüklenemiyor.';

  @override
  String get errorCeliaUnavailable =>
      'Celia şu anda kullanılamıyor. Lütfen tekrar deneyin.';

  @override
  String get errorOpenConversation => 'Bu konuşma açılamadı.';

  @override
  String get errorDeleteConversation =>
      'Bu konuşma silinemedi. Lütfen tekrar deneyin.';

  @override
  String get errorSignIn => 'Giriş yapılamadı. Lütfen tekrar deneyin.';

  @override
  String get errorCreateAccount =>
      'Hesabınız oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get errorSendResetEmail =>
      'Şifre sıfırlama e-postası gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get errorSendVerificationEmail =>
      'Doğrulama e-postası gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get errorGoogleSignIn =>
      'Google ile giriş başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get errorAppleSignIn =>
      'Apple ile giriş başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get errorRefreshNutrition => 'Beslenme verileri yenilenemedi.';

  @override
  String get errorLoadNutritionProfile => 'Beslenme profiliniz yüklenemedi.';

  @override
  String get startupErrorTitle => 'Uygulama başlatılamıyor';

  @override
  String get startupErrorBody =>
      'Lütfen uygulamayı kapatıp yeniden açın. Sorun devam ederse destek ekibiyle iletişime geçin.';

  @override
  String get authTagline => 'Fitness arkadaşınız';

  @override
  String get authSignUp => 'Kayıt Ol';

  @override
  String get authLogIn => 'Giriş Yap';

  @override
  String authVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get authForgotPassword => 'Şifrenizi mi unuttunuz?';

  @override
  String get authOr => 'VEYA';

  @override
  String get authContinueWithGoogle => 'Google ile devam et';

  @override
  String get authContinueWithApple => 'Apple ile devam et';

  @override
  String get authAuthenticating => 'Kimlik doğrulanıyor...';

  @override
  String get authEnterYourName => 'Lütfen adınızı girin.';

  @override
  String get authNeedAccount => 'Hesabınız yok mu? Kayıt Ol';

  @override
  String get authHaveAccount => 'Zaten hesabınız var mı? Giriş Yap';

  @override
  String get authFieldName => 'Adınız';

  @override
  String get authFieldEmail => 'E-posta';

  @override
  String get authFieldPassword => 'Şifre';

  @override
  String get verifyEmailTitle => 'E-postanızı doğrulayın';

  @override
  String get verifyEmailHeading => 'Gelen kutunuzu kontrol edin';

  @override
  String get verifyEmailBody =>
      'E-postanıza bir doğrulama bağlantısı gönderildi.';

  @override
  String get verifyEmailSent => 'Doğrulama e-postası gönderildi!';

  @override
  String get verifyEmailContinue => 'Doğruladım, devam et';

  @override
  String get verifyEmailSignOut => 'Çıkış yap';

  @override
  String get verifyEmailSending => 'Gönderiliyor...';

  @override
  String get verifyEmailResend => 'Doğrulama e-postasını yeniden gönder';

  @override
  String verifyEmailResendIn(int seconds) {
    return '${seconds}s sonra yeniden gönder';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'E-posta: $email';
  }

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get forgotPasswordBody =>
      'Şifre sıfırlama bağlantısı almak için e-postanızı girin.';

  @override
  String get forgotPasswordEmptyEmail => 'Lütfen bir e-posta girin';

  @override
  String get forgotPasswordSent => 'Şifre sıfırlama e-postası gönderildi.';

  @override
  String get forgotPasswordSend => 'Sıfırlama bağlantısı gönder';

  @override
  String get forgotPasswordSending => 'Gönderiliyor...';

  @override
  String get nameSetupTitle => 'Celia sana nasıl hitap etsin?';

  @override
  String get nameSetupBody =>
      'Koçluk deneyimini kişiselleştirmek için adınızı uygulama genelinde kullanırız.';

  @override
  String get nameSetupSaveFailed =>
      'Adınız kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get homeGoodMorning => 'Günaydın,';

  @override
  String get homeCeliaActive => 'CELIA AKTİF';

  @override
  String get homeGenerateRoutine =>
      'Yapay zekâyla\nkişiselleştirilmiş\nrutinini oluştur';

  @override
  String get homeCreateRoutine => 'Rutin Oluştur';

  @override
  String get homeQuickActions => 'Hızlı İşlemler';

  @override
  String get homeUpNext => 'Sırada';

  @override
  String get homeNoUpcoming =>
      'Henüz yaklaşan bir rutin yok.\nBir rutin oluşturun veya kütüphaneye göz atın.';

  @override
  String get homeChatWithCelia => 'Celia ile Sohbet Et';

  @override
  String get homeChatSubtitle => 'Formun veya beslenmen hakkında sor';

  @override
  String get homeScanMeal => 'Öğün Tara';

  @override
  String get homeScanMealSubtitle => 'Yiyecekleri ve kalorileri tanımla';

  @override
  String get homeNutrition => 'Beslenme';

  @override
  String get homeNutritionSubtitle =>
      'Kalorileri, makroları ve öğünleri görüntüle';

  @override
  String get homeBrowseLibrary => 'Kütüphaneye\nGöz At';

  @override
  String get homeTrackProgress => 'İlerlemeni\nTakip Et';

  @override
  String get chatTitle => 'Koç Celia';

  @override
  String get chatEmptyPrompt =>
      'Bugün forma girmen için\nnasıl yardımcı olabilirim?';

  @override
  String get chatYourChats => 'Sohbetlerin';

  @override
  String get chatNoSavedChats => 'Henüz kayıtlı sohbet yok.';

  @override
  String get chatHistory => 'Sohbet geçmişi';

  @override
  String get chatNew => 'Yeni sohbet';

  @override
  String get chatOpening => 'Sohbet açılıyor...';

  @override
  String get chatScanAMeal => 'Bir öğün tara';

  @override
  String get chatInputHint => 'Antrenmanın hakkında Celia\'ya her şeyi sor...';

  @override
  String get chatMicTooltip => 'Konuşmak için basılı tutun';

  @override
  String get chatAvatarReady => 'Hazır';

  @override
  String get chatAvatarThinking => 'Düşünüyor…';

  @override
  String get chatAvatarSpeaking => 'Konuşuyor…';

  @override
  String chatAvatarSemantics(String status) {
    return 'Celia avatarı, $status';
  }

  @override
  String get chatListening => 'Dinliyor…';

  @override
  String get chatMicDenied =>
      'Celia ile konuşmak için mikrofon erişimi gerekir.';

  @override
  String get chatSpeechUnavailable =>
      'Bu cihazda konuşma tanıma kullanılamıyor.';

  @override
  String get chatCouldNotOpenRoutine => 'Bu rutin açılamadı';

  @override
  String get chatThisRoutine => 'bu rutin';

  @override
  String get chatThisMeal => 'bu öğün';

  @override
  String get chatYourRoutine => 'Rutinin';

  @override
  String chatMoreExercises(int count) {
    return '+ $count egzersiz daha';
  }

  @override
  String get chatEmptySubtitle =>
      'Antrenmanın, beslenmen veya ilerlemen hakkında soru sor.';

  @override
  String chatLoggedToday(int calories) {
    return 'Bugün $calories kcal kaydettin.';
  }

  @override
  String get chatSuggestionHiit => 'Bana 20 dakikalık bir HIIT rutini oluştur';

  @override
  String get chatSuggestionDinner => 'Bu akşam ne yemeliyim?';

  @override
  String get chatSuggestionProgress => 'Bu hafta nasıl gidiyorum?';

  @override
  String get chatSuggestionIngredients => 'Tavuk, pirinç ve ıspanağım var';

  @override
  String get chatJustNow => 'Az önce';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes dk önce';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours sa önce';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Kütüphanende zaten kayıtlı — açmak için dokun';

  @override
  String get chatRoutineTapToOpen => 'Açmak için dokun';

  @override
  String get chatToolCancelled => 'İptal edildi';

  @override
  String chatToolFailed(String label) {
    return '$label — işlem başarısız oldu';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Rutin kaydedilemedi';

  @override
  String get chatToolRoutineSaved => 'Kütüphanenize kaydedildi';

  @override
  String get chatToolMealLogged => 'Bugünkü günlüğe eklendi';

  @override
  String get chatToolRoutineAdded => 'Kütüphanenize eklendi';

  @override
  String get activityCheckingProgress => 'İlerlemeniz kontrol ediliyor';

  @override
  String get activityCheckingNutrition => 'Bugün ne yediğiniz kontrol ediliyor';

  @override
  String get activityReviewingMeals => 'Son öğünleriniz inceleniyor';

  @override
  String get activityLookingAtRoutines => 'Rutinleriniz görüntüleniyor';

  @override
  String get activityReadingRoutine => 'Bu rutin okunuyor';

  @override
  String get activitySearchingLibrary => 'Egzersiz kütüphanesinde aranıyor';

  @override
  String get activityBuildingRoutine => 'Rutin oluşturuluyor';

  @override
  String get activityLoggingMeal => 'Öğününüz günlüğe ekleniyor';

  @override
  String get activitySavingToLibrary => 'Kütüphanenize kaydediliyor';

  @override
  String get activityWorking => 'Üzerinde çalışılıyor';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return '\"$name\" rutini $count egzersizle kütüphanenize kaydedilsin mi?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '\"$name\" rutini kütüphanenize kaydedilsin mi?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '\"$name\" öğünü $calories kcal olarak günlüğe eklensin mi?';
  }

  @override
  String approvalLogMeal(String name) {
    return '\"$name\" günlüğe eklensin mi?';
  }

  @override
  String get approvalAddRoutine => 'Bu rutin kütüphanenize eklensin mi?';

  @override
  String get approvalGeneric => 'Celia\'nın bunu yapmasına izin verilsin mi?';

  @override
  String get libraryTitle => 'Rutin Kütüphanesi';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adım',
      one: '$count adım',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Henüz rutin yok';

  @override
  String get libraryEmptyBody =>
      'Yönetici panelinde rutinler oluşturup yayınlayın.';

  @override
  String get libraryLoadFailed => 'Rutinler yüklenemedi';

  @override
  String get routineStartWorkout => 'Antrenmanı Başlat';

  @override
  String get routineNoSteps => 'Kullanılabilir adım yok';

  @override
  String get routineNoVideoForStep => 'Bu adım için kullanılabilir video yok';

  @override
  String get routineVideoProcessing =>
      'Video hâlâ işleniyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get routineMissingPlaybackUrl => 'Bu video için oynatma URL\'si eksik';

  @override
  String get routinePreviewBanner => 'ÖNİZLEME — tam video yakında';

  @override
  String get routinePreview => 'ÖNİZLEME';

  @override
  String get routineDetails => 'Ayrıntılar';

  @override
  String get routineNotFound => 'Rutin bulunamadı';

  @override
  String routineCompletedTimes(int count) {
    return '$count kez tamamlandı';
  }

  @override
  String get playerVideoUnavailable => 'Bu video şu anda kullanılamıyor.';

  @override
  String get playerSteps => 'Adımlar';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Oynatılabilir video yok';

  @override
  String get playerWorkoutComplete => 'Antrenman tamamlandı!';

  @override
  String get playerSavingStreak => 'Serinize kaydediliyor…';

  @override
  String get playerSavedStreak => 'Serinize kaydedildi';

  @override
  String get playerRetrySave => 'Kaydetmeyi tekrar dene';

  @override
  String get playerReplay => 'Tekrar oynat';

  @override
  String get playerNotReady => 'Oynatıcı hazır değil';

  @override
  String get playerPreviewUnavailable => 'Önizleme şu anda kullanılamıyor.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Klip $current/$total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Video yüklenirken hata oluştu';

  @override
  String get playerLoadingVideo => 'Video yükleniyor...';

  @override
  String get playerFailedToLoadVideo => 'Video yüklenemedi';

  @override
  String get playerNotInitialized => 'Video oynatıcı başlatılmadı';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Egzersiz $current/$total';
  }

  @override
  String get guidedGetReady => 'HAZIR OL';

  @override
  String guidedSetOf(int current, int total) {
    return 'Set $current/$total';
  }

  @override
  String get guidedRest => 'DİNLEN';

  @override
  String get guidedSkipRest => 'Dinlenmeyi atla';

  @override
  String get guidedPaused => 'Duraklatıldı';

  @override
  String get guidedResume => 'Devam et';

  @override
  String get guidedWorkoutComplete => 'Antrenman tamamlandı';

  @override
  String get guidedEndTitle => 'Antrenman bitirilsin mi?';

  @override
  String get guidedEndBody => 'Bu oturumdaki ilerlemeniz kaydedilmeyecek.';

  @override
  String get guidedKeepGoing => 'Devam et';

  @override
  String get guidedEnd => 'Bitir';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekrar',
      one: '$count tekrar',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Yapay Zekâyla Rutin Oluştur';

  @override
  String get generateSheetPrompt => 'Ne tür bir antrenman yapmak istiyorsunuz?';

  @override
  String get generateSheetHint =>
      'ör. \"Uyanmak için hızlı bir sabah esnemesi\" veya \"Yeni başlayanlar için tüm vücut kuvvet antrenmanı\"';

  @override
  String get generateSheetDuration => 'Süre';

  @override
  String generateSheetMinutes(int count) {
    return '$count dk';
  }

  @override
  String get generateSheetDifficulty => 'Zorluk';

  @override
  String get generateSheetEquipment => 'Mevcut Ekipman';

  @override
  String get generateSheetGenerating => 'Oluşturuluyor...';

  @override
  String get generateSheetSubmit => 'Rutin Oluştur';

  @override
  String get generateSheetDescribeFirst =>
      'Lütfen istediğiniz antrenmanı açıklayın';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Buna zaten sahipsiniz: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Oluşturuldu: $title';
  }

  @override
  String get generateSheetFailed => 'Rutin oluşturulamadı';

  @override
  String get guidedNoExercises => 'Bu rutinde henüz egzersiz yok.';

  @override
  String get guidedStartFailed =>
      'Bu antrenman şu anda başlatılamıyor. Lütfen tekrar deneyin.';

  @override
  String get guidedSaveFailed =>
      'Bu antrenman kaydedilemedi. Serinizi güncellemek için yeniden dene\'ye dokunun.';

  @override
  String guidedOfReps(int count) {
    return '$count tekrardan';
  }

  @override
  String get guidedHold => 'tut';

  @override
  String get guidedNextSet => 'Sonraki set';

  @override
  String get guidedUpNext => 'Sırada';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds sn tut';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Hazır olun. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Başla. $count tekrar.';
  }

  @override
  String coachStartHold(int seconds) {
    return '$seconds saniye tutun.';
  }

  @override
  String coachRest(String exercise) {
    return 'Dinlenin. Sırada: $exercise';
  }

  @override
  String get coachRestShort => 'Dinlenin.';

  @override
  String get coachComplete => 'Harika iş. Antrenman tamamlandı.';

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
      'Bu rutinde oynatılabilir video bulunamadı.';

  @override
  String get playerLoadRoutineFailed =>
      'Bu rutin şu anda yüklenemiyor. Lütfen tekrar deneyin.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return '\"$title\" yüklenemedi. Atlanıyor…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return '\"$title\" yüklenemedi.';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Tamamlanma kaydedilemedi. Serinizi güncellemek için yeniden dene\'ye dokunun.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Önizleme';
  }

  @override
  String get playerNoVideosReady =>
      'Bu rutinde henüz oynatılmaya hazır video yok.';

  @override
  String get playerPlaybackFailed =>
      'Bu video şu anda oynatılamıyor. Lütfen tekrar deneyin.';

  @override
  String get libraryTabCurated => 'Seçkiler';

  @override
  String get libraryTabAiGenerated => 'Yapay zekâ tarafından oluşturulan';

  @override
  String get profileSavedRoutines => 'Kayıtlı Rutinler';

  @override
  String get savedRoutinesNoFavorites => 'Henüz favori rutin yok.';

  @override
  String get savedRoutinesEmpty => 'Henüz kayıtlı rutin yok.';

  @override
  String get actionFavorite => 'Favorilere ekle';

  @override
  String get actionUnfavorite => 'Favorilerden kaldır';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours sa';
  }

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get categoryStrength => 'Kuvvet';

  @override
  String get categoryCardio => 'Kardiyo';

  @override
  String get categoryFlexibility => 'Esneklik';

  @override
  String get categoryMindfulness => 'Farkındalık';

  @override
  String get categoryDance => 'Dans';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Özel';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navLibrary => 'Kütüphane';

  @override
  String get navChat => 'Sohbet';

  @override
  String get navProfile => 'Profil';

  @override
  String get equipmentNone => 'Yok';

  @override
  String get equipmentDumbbells => 'Dambıllar';

  @override
  String get equipmentResistanceBands => 'Direnç Bantları';

  @override
  String get equipmentYogaMat => 'Yoga Matı';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Barfiks Barı';

  @override
  String get equipmentJumpRope => 'İp Atlama İpi';

  @override
  String get nutritionTitle => 'Beslenme';

  @override
  String get nutritionSubtitle => 'Kaloriler, makrolar ve öğün geçmişi';

  @override
  String get nutritionSetGoalsTitle => 'Günlük beslenme hedeflerini belirle';

  @override
  String get nutritionSetGoalsBody =>
      'Celia\'nın günlük tüketmen gereken kalori ve besin miktarını hesaplayabilmesi için kilonu, boyunu, yaşını ve cinsiyetini ekle.';

  @override
  String get nutritionSetUpGoals => 'Hedefleri Belirle';

  @override
  String get nutritionDailyTarget => 'Günlük hedef';

  @override
  String get nutritionDailyGoals => 'Günlük hedefler';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Bugün';

  @override
  String get nutritionMealHistory => 'Öğün Geçmişi';

  @override
  String get nutritionCeliaInsights => 'Celia İçgörüleri';

  @override
  String get nutritionWeeklyTrend => 'Haftalık Trend';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğün',
      one: '$count öğün',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğün',
      one: '$count öğün',
    );
    return '$target kcal hedefine göre • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'P,S,Ç,P,C,C,P';

  @override
  String get nutritionFieldFoodName => 'Yiyecek adı';

  @override
  String get nutritionFieldGrams => 'Gram';

  @override
  String get nutritionFieldCalories => 'Kalori';

  @override
  String get scannerStatusAnalyzing => 'ANALİZ EDİLİYOR...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => 'Yiyecek adı';

  @override
  String get scannerFieldGrams => 'Gram';

  @override
  String get scannerFieldCalories => 'Kalori';

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
    return 'Bugün $calories kcal ve ${grams}g protein kaldı';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return 'Günlük hedefini $calories kcal aştın';
  }

  @override
  String get scannerButtonAnalyzing => 'Analiz Ediliyor';

  @override
  String get scannerButtonQuotaNeeded => 'Kota Gerekli';

  @override
  String get scannerButtonScanNow => 'Şimdi Tara';

  @override
  String get scannerButtonLogging => 'Kaydediliyor';

  @override
  String get scannerButtonLogMeal => 'Öğünü Kaydet';

  @override
  String get scannerNoClearFood =>
      'Henüz net bir yiyecek algılanmadı. Daha iyi aydınlatmayı dene veya biraz yaklaş.';

  @override
  String get scannerErrorCameraPermission =>
      'Öğünleri taramak için kamera izni gerekiyor.';

  @override
  String get scannerErrorBackendMissing =>
      'Kalori tarayıcısının arka ucu henüz yapılandırılmadı.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'Kalori taraması için kullanılan OpenAI API anahtarı geçersiz. Arka uç ortamında değiştir, yeniden dağıt ve tekrar dene.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Kalori taraması için OpenAI API anahtarı gerekiyor. Anahtarı Vercel\'e ekle, yeniden dağıt ve tekrar dene.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Kalori taraması için OpenAI kredileri tükendi. API kredisi ekle veya faturalandırma limitini yükselt, ardından tekrar dene.';

  @override
  String get scannerErrorTimeout =>
      'Celia bu öğünü analiz etmek için daha fazla zamana ihtiyaç duydu. Kamerayı sabit tut ve tekrar tara.';

  @override
  String get scannerErrorNotSignedIn =>
      'Öğünleri taramadan önce lütfen giriş yap.';

  @override
  String get scannerErrorMealTableMissing =>
      'Öğün kayıt tablosu henüz hazır değil. Tarama sonucu hâlâ kullanılabilir.';

  @override
  String get scannerErrorGeneric =>
      'Celia bu öğünü henüz analiz edemedi. Kamerayı sabit tut, yiyeceği ortada tut ve tekrar tara.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe',
      one: '$count öğe',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Öğün Ayrıntıları';

  @override
  String get nutritionFoodItems => 'Yiyecekler';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Bir öğünde en az bir yiyecek bulunmalıdır.';

  @override
  String get nutritionMealUpdated => 'Öğün güncellendi';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Öğün güncellenemedi: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Öğün silinsin mi?';

  @override
  String get nutritionDeleteMealBody =>
      'Bu işlem öğünü beslenme geçmişinizden kaldırır.';

  @override
  String get nutritionDeleteMeal => 'Öğünü sil';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Öğün silinemedi: $error';
  }

  @override
  String get nutritionEditFood => 'Yiyeceği Düzenle';

  @override
  String get nutritionSaveFood => 'Yiyeceği Kaydet';

  @override
  String get nutritionLoadFailed => 'Öğünler yüklenemedi';

  @override
  String get nutritionLoadFailedBody =>
      'Yenilemek için aşağı çekin veya backend bağlantısını kontrol edin.';

  @override
  String get nutritionNoMeals => 'Henüz kaydedilmiş öğün yok';

  @override
  String get nutritionNoMealsBody =>
      'İlk öğününüzü tarayın, Celia beslenme geçmişinizi oluştursun.';

  @override
  String get progressToday => 'Bugün';

  @override
  String get progressSetGoals =>
      'Kalori ve makro takibini etkinleştirmek için beslenme hedeflerinizi belirleyin.';

  @override
  String progressOfTarget(int target) {
    return '$target kcal değerinin';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal fazla';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal kaldı';
  }

  @override
  String get progressProtein => 'Protein';

  @override
  String get progressCarbs => 'Karbonhidrat';

  @override
  String get progressFat => 'Yağ';

  @override
  String get scannerEditItem => 'Yiyecek Öğesini Düzenle';

  @override
  String get scannerSaveChanges => 'Değişiklikleri Kaydet';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Güven %$percent · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count öğe daha bu öğün kaydına dahil edildi';
  }

  @override
  String get scannerIfYouLog => 'Bu öğünü kaydederseniz';

  @override
  String scannerAfterLogging(int after, int target) {
    return 'Bugün $after / $target kcal';
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
  String get scannerNoMealDetected => 'Öğün algılanmadı';

  @override
  String onboardingWelcome(String name) {
    return 'Hoş geldin, $name';
  }

  @override
  String get onboardingGender => 'Cinsiyet';

  @override
  String get onboardingCalculateGoals => 'Hedeflerimi Hesapla';

  @override
  String get onboardingScanFirstMeal => 'İlk Öğünümü Tara';

  @override
  String get onboardingExploreRoutines => 'Rutinleri Keşfet';

  @override
  String get onboardingGoHome => 'Ana Sayfaya Git';

  @override
  String get onboardingDailyTargets => 'Günlük hedefleriniz';

  @override
  String onboardingProtein(int grams) {
    return 'Protein ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Protein ${protein}g • Karbonhidrat ${carbs}g • Yağ ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Günlük beslenme hedefleriniz hazır. Nasıl başlamak istediğinizi seçin.';

  @override
  String get onboardingWeightKg => 'Kilo (kg)';

  @override
  String get onboardingHeightCm => 'Boy (cm)';

  @override
  String get onboardingAge => 'Yaş';

  @override
  String get onboardingInvalidWeight => 'kg cinsinden geçerli bir kilo girin.';

  @override
  String get onboardingInvalidHeight => 'cm cinsinden geçerli bir boy girin.';

  @override
  String get onboardingInvalidAge =>
      '13 ile 100 arasında geçerli bir yaş girin.';

  @override
  String get onboardingSaveFailed => 'Beslenme profiliniz kaydedilemedi.';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderFemale => 'Kadın';

  @override
  String get genderOther => 'Diğer';

  @override
  String get nutritionSetupTitle => 'Günlük Beslenme Hedefleri';

  @override
  String get nutritionSetupBody =>
      'Günlük kalori ve makrolarınızı hesaplayabilmesi için Celia\'ya vücudunuz hakkında bilgi verin.';

  @override
  String get nutritionSetupGender => 'Cinsiyet';

  @override
  String get nutritionSetupFootnote =>
      'Celia, orta düzeyde aktivite seviyesine göre günlük kalori ve makro hedeflerinizi tahmin etmek için kilonuzu, boyunuzu, yaşınızı ve cinsiyetinizi kullanır.';

  @override
  String get nutritionSourcesTitle => 'Bu hedefler nasıl hesaplanır';

  @override
  String get nutritionSourcesBody =>
      'Günlük kaloriler, orta düzey fiziksel aktivite faktörü (yaklaşık 1,55) ile Mifflin–St Jeor dinlenme enerjisi denklemini kullanır. Protein, aktif yetişkinler için vücut ağırlığının kg\'ı başına yaklaşık 1,8 g olarak tahmin edilir. Yağ kalorilerin yaklaşık %25\'ine ayarlanır, kalanını karbonhidratlar doldurur — yaygın beslenme rehberliği aralıkları içinde.';

  @override
  String get nutritionSourcesDisclaimer =>
      'Bu rakamlar yalnızca genel sağlıklı yaşam tahminleridir. Teşhis, reçete veya nitelikli bir klinisyen ya da diyetisyenin tavsiyesinin yerine geçmez.';

  @override
  String get nutritionSetupSave => 'Hedefleri Kaydet';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Üye';

  @override
  String get profileAccount => 'Hesap';

  @override
  String profileSignedInAs(String email) {
    return 'Şu hesapla giriş yapıldı:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Bilinmiyor';

  @override
  String get profileDarkMode => 'Koyu Mod';

  @override
  String get profileLanguage => 'Dil';

  @override
  String get profileLogOutTitle => 'Çıkış yapılsın mı?';

  @override
  String get profileLogOutBody => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get profileLogOut => 'Çıkış yap';

  @override
  String get profileLogOutButton => 'Çıkış Yap';

  @override
  String get profileDeleteAccount => 'Hesabı sil';

  @override
  String get profileDeleteAccountConfirmTitle => 'Hesabınız silinsin mi?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Bu işlem hesabınızı ve kayıtlı rutinler, öğün kayıtları ve sohbet geçmişi dahil tüm verilerinizi kalıcı olarak siler. Geri alınamaz.';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'Onaylamak için şifrenizi girin.';

  @override
  String get profileDeleteAccountPasswordLabel => 'Şifre';

  @override
  String get profileDeleteAccountButton => 'Hesabımı sil';

  @override
  String get profileFavoriteRoutines => 'Favori Rutinler';

  @override
  String get profileSubscription => 'Abonelik';

  @override
  String get profileNutrition => 'Beslenme';

  @override
  String get profileHelpSupport => 'Yardım ve Destek';

  @override
  String get profileFriend => 'Arkadaş';

  @override
  String get profileStatSaved => 'Kaydedilenler';

  @override
  String get profileStatStreak => 'Seri';

  @override
  String get profileStatWorkouts => 'Antrenmanlar';

  @override
  String get streakDayOneStarted =>
      '1. gün başladı — serinizi oluşturmak için yarın tekrar gelin.';

  @override
  String get streakRebuild =>
      'Dün aktiftiniz — serinizi yeniden oluşturmak için bugün bir öğün kaydedin veya antrenmanı tamamlayın.';

  @override
  String get streakStart =>
      'Aktif serinizi başlatmak için bir öğün kaydedin veya antrenmanı tamamlayın.';

  @override
  String streakLongRun(int days) {
    return '$days günlük seri! Devam edin — Celia istikrarınızı takip ediyor.';
  }

  @override
  String streakBothLogged(int days) {
    return '$days günlük seri — bugün hem antrenman hem de beslenme kaydedildi.';
  }

  @override
  String streakNeedWorkout(int days) {
    return '$days günlük seri. Kısa bir antrenman bugününü tamamlar.';
  }

  @override
  String streakNeedMeal(int days) {
    return '$days günlük seri. Beslenmenizi takip etmek için bir öğün kaydedin.';
  }

  @override
  String streakStayActive(int days) {
    return '$days günlük seri — bugün aktif kalın.';
  }

  @override
  String get editProfileTitle => 'Profili Düzenle';

  @override
  String get editProfileName => 'Ad';

  @override
  String get editProfileFootnote =>
      'Değişiklikler hesabınıza kaydedilir ve Ana Sayfa/Profil bölümlerinde görünür.';

  @override
  String get editProfileSaveFailed =>
      'Profil güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSystem => 'Cihaz dili';

  @override
  String get languageSystemSubtitle => 'Telefonunuzda ayarlanan dili kullanın';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageSpanish => 'İspanyolca';

  @override
  String get insightStartFuelingTitle => 'Bugün beslenmeye başlayın';

  @override
  String get insightStartFuelingBody =>
      'Günlük kalori bütçenizin tamamı duruyor. Yolunda kalmak için ilk öğününüzü tarayın veya kaydedin.';

  @override
  String get insightAboveTargetTitle => 'Bugün hedefin üzerinde';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Günlük hedefinizin $calories kcal üzerindesiniz. Akşam yemeğini daha hafif tutun veya kısa bir antrenman ekleyin.';
  }

  @override
  String get insightLowProteinTitle => 'Protein hâlâ düşük';

  @override
  String insightLowProteinBody(int grams) {
    return 'Hedefinize ulaşmak için bugün yaklaşık ${grams}g daha protein almanız gerekiyor.';
  }

  @override
  String get insightAlmostThereTitle => 'Hedefinize neredeyse ulaştınız';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Bugün $calories kcal hakkınız kaldı. Dengeli bir atıştırmalık iyi uyacaktır.';
  }

  @override
  String get insightOnTrackTitle => 'Bugün yolundasınız';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Günlük hedeflerinize ulaşmak için $calories kcal ve ${grams}g protein hakkınız kaldı.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Haftalık ritminizi oluşturun';

  @override
  String get insightWeeklyRhythmBody =>
      'Celia\'nın alışkanlıkları fark edip size daha iyi rehberlik edebilmesi için hafta boyunca öğünlerinizi kaydedin.';

  @override
  String get insightWeeklyTrendTitle => 'Haftalık trend';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Son 7 günün $days gününde öğün kaydettiniz; ortalama $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget =>
      'günlük hedefinizin hemen hemen çevresinde';

  @override
  String insightTrendAbove(int delta) {
    return 'ortalama olarak hedefinizin $delta kcal üzerinde';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'ortalama olarak hedefinizin $delta kcal altında';
  }

  @override
  String get insightsSectionTitle => 'Celia İçgörüleri';
}
