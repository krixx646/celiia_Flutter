// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Pelatih Integral Celia';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionSave => 'Simpan';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get actionDone => 'Selesai';

  @override
  String get actionClose => 'Tutup';

  @override
  String get actionContinue => 'Lanjutkan';

  @override
  String get actionSeeAll => 'Lihat Semua';

  @override
  String get actionYesDoIt => 'Ya, lakukan';

  @override
  String get actionNotNow => 'Jangan sekarang';

  @override
  String get loadingPreparing => 'Menyiapkan Celia...';

  @override
  String get loadingGeneric => 'Memuat...';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get errorCanceled => 'Tindakan dibatalkan.';

  @override
  String get errorTooManyRequests =>
      'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';

  @override
  String get errorNetwork => 'Periksa koneksi internet Anda lalu coba lagi.';

  @override
  String get errorBadCredentials => 'Email atau kata sandi salah.';

  @override
  String get errorEmailInUse =>
      'Email ini sudah digunakan. Coba masuk sebagai gantinya.';

  @override
  String get errorWeakPassword =>
      'Gunakan kata sandi yang lebih kuat lalu coba lagi.';

  @override
  String get errorInvalidEmail => 'Masukkan alamat email yang valid.';

  @override
  String get errorNoPermission =>
      'Anda tidak memiliki izin untuk melakukan itu.';

  @override
  String get errorNotSignedIn => 'Silakan masuk lalu coba lagi.';

  @override
  String get errorDeleteAccount =>
      'Kami tidak dapat menghapus akun Anda. Silakan coba lagi.';

  @override
  String get errorNoConversation => 'Mulai chat baru untuk melanjutkan.';

  @override
  String get errorNoPlayableVideos =>
      'Belum ada video yang dapat diputar untuk rutinitas ini.';

  @override
  String get errorLoadRoutines =>
      'Rutinitas tidak dapat dimuat saat ini. Silakan coba lagi.';

  @override
  String get errorLoadSavedRoutines =>
      'Rutinitas tersimpan tidak dapat dimuat saat ini. Silakan coba lagi.';

  @override
  String get errorGenerateRoutine =>
      'Rutinitas tidak dapat dibuat saat ini. Silakan coba lagi.';

  @override
  String get errorLoadChats => 'Chat tersimpan tidak dapat dimuat saat ini.';

  @override
  String get errorCeliaUnavailable =>
      'Celia tidak tersedia saat ini. Silakan coba lagi.';

  @override
  String get errorOpenConversation => 'Percakapan tersebut tidak dapat dibuka.';

  @override
  String get errorDeleteConversation =>
      'Percakapan ini tidak dapat dihapus. Silakan coba lagi.';

  @override
  String get errorSignIn => 'Gagal masuk. Silakan coba lagi.';

  @override
  String get errorCreateAccount =>
      'Akun Anda tidak dapat dibuat. Silakan coba lagi.';

  @override
  String get errorSendResetEmail =>
      'Email pengaturan ulang tidak dapat dikirim. Silakan coba lagi.';

  @override
  String get errorSendVerificationEmail =>
      'Email verifikasi tidak dapat dikirim. Silakan coba lagi.';

  @override
  String get errorGoogleSignIn =>
      'Gagal masuk dengan Google. Silakan coba lagi.';

  @override
  String get errorAppleSignIn => 'Gagal masuk dengan Apple. Silakan coba lagi.';

  @override
  String get errorRefreshNutrition => 'Data nutrisi tidak dapat diperbarui.';

  @override
  String get errorLoadNutritionProfile =>
      'Profil nutrisi Anda tidak dapat dimuat.';

  @override
  String get startupErrorTitle => 'Aplikasi tidak dapat dimulai';

  @override
  String get startupErrorBody =>
      'Tutup dan buka kembali aplikasi. Jika masalah berlanjut, hubungi dukungan.';

  @override
  String get authTagline => 'Teman kebugaran Anda';

  @override
  String get authSignUp => 'Daftar';

  @override
  String get authLogIn => 'Masuk';

  @override
  String authVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get authForgotPassword => 'Lupa Kata Sandi?';

  @override
  String get authOr => 'ATAU';

  @override
  String get authContinueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get authContinueWithApple => 'Lanjutkan dengan Apple';

  @override
  String get authAuthenticating => 'Mengautentikasi...';

  @override
  String get authEnterYourName => 'Silakan masukkan nama Anda.';

  @override
  String get authNeedAccount => 'Belum punya akun? Daftar';

  @override
  String get authHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get authFieldName => 'Nama Anda';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Kata Sandi';

  @override
  String get verifyEmailTitle => 'Verifikasi email Anda';

  @override
  String get verifyEmailHeading => 'Periksa kotak masuk Anda';

  @override
  String get verifyEmailBody =>
      'Tautan verifikasi telah dikirim ke email Anda.';

  @override
  String get verifyEmailSent => 'Email verifikasi telah dikirim!';

  @override
  String get verifyEmailContinue => 'Saya sudah memverifikasi, lanjutkan';

  @override
  String get verifyEmailSignOut => 'Keluar';

  @override
  String get verifyEmailSending => 'Mengirim...';

  @override
  String get verifyEmailResend => 'Kirim ulang email verifikasi';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Kirim ulang dalam $seconds dtk';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'Email: $email';
  }

  @override
  String get forgotPasswordTitle => 'Lupa Kata Sandi';

  @override
  String get forgotPasswordBody =>
      'Masukkan email Anda untuk menerima tautan pengaturan ulang kata sandi.';

  @override
  String get forgotPasswordEmptyEmail => 'Masukkan email';

  @override
  String get forgotPasswordSent =>
      'Email pengaturan ulang kata sandi telah dikirim.';

  @override
  String get forgotPasswordSend => 'Kirim tautan pengaturan ulang';

  @override
  String get forgotPasswordSending => 'Mengirim...';

  @override
  String get nameSetupTitle => 'Celia harus memanggil Anda siapa?';

  @override
  String get nameSetupBody =>
      'Kami menggunakan nama Anda di seluruh aplikasi agar panduan terasa lebih personal.';

  @override
  String get nameSetupSaveFailed =>
      'Nama Anda tidak dapat disimpan. Silakan coba lagi.';

  @override
  String get homeGoodMorning => 'Selamat Pagi,';

  @override
  String get homeCeliaActive => 'CELIA AKTIF';

  @override
  String get homeGenerateRoutine => 'Buat rutinitas\npersonal\nAnda dengan AI';

  @override
  String get homeCreateRoutine => 'Buat Rutinitas';

  @override
  String get homeQuickActions => 'Aksi Cepat';

  @override
  String get homeUpNext => 'Berikutnya';

  @override
  String get homeNoUpcoming =>
      'Belum ada rutinitas mendatang.\nBuat rutinitas atau jelajahi pustaka.';

  @override
  String get homeChatWithCelia => 'Chat dengan Celia';

  @override
  String get homeChatSubtitle => 'Tanyakan tentang teknik atau pola makan Anda';

  @override
  String get homeScanMeal => 'Pindai Makanan';

  @override
  String get homeScanMealSubtitle => 'Identifikasi makanan & kalori';

  @override
  String get homeNutrition => 'Nutrisi';

  @override
  String get homeNutritionSubtitle => 'Lihat kalori, makro & makanan';

  @override
  String get homeBrowseLibrary => 'Jelajahi\nPustaka';

  @override
  String get homeTrackProgress => 'Lacak\nProgres';

  @override
  String get chatTitle => 'Pelatih Celia';

  @override
  String get chatEmptyPrompt =>
      'Bagaimana saya bisa membantu Anda\nmenjadi bugar hari ini?';

  @override
  String get chatYourChats => 'Chat Anda';

  @override
  String get chatNoSavedChats => 'Belum ada chat tersimpan.';

  @override
  String get chatHistory => 'Riwayat chat';

  @override
  String get chatNew => 'Chat baru';

  @override
  String get chatOpening => 'Membuka chat...';

  @override
  String get chatScanAMeal => 'Pindai makanan';

  @override
  String get chatInputHint =>
      'Tanyakan apa saja kepada Celia tentang latihan Anda...';

  @override
  String get chatMicTooltip => 'Tahan untuk berbicara';

  @override
  String get chatListening => 'Mendengarkan…';

  @override
  String get chatMicDenied =>
      'Akses mikrofon diperlukan untuk berbicara dengan Celia.';

  @override
  String get chatSpeechUnavailable =>
      'Pengenalan suara tidak tersedia di perangkat ini.';

  @override
  String get avatarModeReady => 'Siap';

  @override
  String get avatarModeThinking => 'Berpikir…';

  @override
  String get avatarModeSpeaking => 'Berbicara…';

  @override
  String get avatarModeHoldToTalk => 'Tahan untuk berbicara';

  @override
  String get avatarModeExit => 'Mode manual';

  @override
  String get avatarModeConfirmTitle => 'Konfirmasi dengan Celia?';

  @override
  String get avatarModeConfirmBody => 'Celia ingin menyimpan sesuatu. Izinkan?';

  @override
  String get avatarModeConfirmYes => 'Izinkan';

  @override
  String get chatCouldNotOpenRoutine => 'Rutinitas tersebut tidak dapat dibuka';

  @override
  String get chatThisRoutine => 'rutinitas ini';

  @override
  String get chatThisMeal => 'makanan ini';

  @override
  String get chatYourRoutine => 'Rutinitas Anda';

  @override
  String chatMoreExercises(int count) {
    return '+ $count lagi';
  }

  @override
  String get chatEmptySubtitle =>
      'Tanyakan tentang latihan, makanan, atau progres Anda.';

  @override
  String chatLoggedToday(int calories) {
    return 'Anda telah mencatat $calories kcal hari ini.';
  }

  @override
  String get chatSuggestionHiit => 'Buatkan rutinitas HIIT 20 menit';

  @override
  String get chatSuggestionDinner => 'Apa yang sebaiknya saya makan malam ini?';

  @override
  String get chatSuggestionProgress => 'Bagaimana progres saya minggu ini?';

  @override
  String get chatSuggestionIngredients => 'Saya punya ayam, nasi, dan bayam';

  @override
  String get chatJustNow => 'Baru saja';

  @override
  String chatMinutesAgo(int minutes) {
    return '${minutes}m yang lalu';
  }

  @override
  String chatHoursAgo(int hours) {
    return '${hours}j yang lalu';
  }

  @override
  String chatDaysAgo(int days) {
    return '${days}h yang lalu';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Sudah ada di pustaka Anda — ketuk untuk membuka';

  @override
  String get chatRoutineTapToOpen => 'Ketuk untuk membuka';

  @override
  String get chatToolCancelled => 'Dibatalkan';

  @override
  String chatToolFailed(String label) {
    return '$label — tindakan tersebut gagal';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Gagal menyimpan rutinitas';

  @override
  String get chatToolRoutineSaved => 'Disimpan ke pustaka Anda';

  @override
  String get chatToolMealLogged => 'Ditambahkan ke catatan hari ini';

  @override
  String get chatToolRoutineAdded => 'Ditambahkan ke pustaka Anda';

  @override
  String get activityCheckingProgress => 'Memeriksa progres Anda';

  @override
  String get activityCheckingNutrition =>
      'Memeriksa makanan yang Anda konsumsi hari ini';

  @override
  String get activityReviewingMeals => 'Meninjau makanan terbaru Anda';

  @override
  String get activityLookingAtRoutines => 'Melihat rutinitas Anda';

  @override
  String get activityReadingRoutine => 'Membaca rutinitas tersebut';

  @override
  String get activitySearchingLibrary => 'Mencari di pustaka latihan';

  @override
  String get activityBuildingRoutine => 'Menyusun rutinitas Anda';

  @override
  String get activityLoggingMeal => 'Mencatat makanan Anda';

  @override
  String get activitySavingToLibrary => 'Menyimpan ke pustaka Anda';

  @override
  String get activityWorking => 'Sedang memproses';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Simpan \"$name\" dengan $count latihan ke pustaka Anda?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Simpan \"$name\" ke pustaka Anda?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Catat \"$name\" sebesar $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Catat \"$name\"?';
  }

  @override
  String get approvalAddRoutine => 'Tambahkan rutinitas ini ke pustaka Anda?';

  @override
  String get approvalGeneric => 'Izinkan Celia melakukan ini?';

  @override
  String get libraryTitle => 'Pustaka Rutinitas';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count langkah',
      one: '$count langkah',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Belum ada rutinitas';

  @override
  String get libraryEmptyBody =>
      'Buat dan publikasikan rutinitas di dasbor admin.';

  @override
  String get libraryLoadFailed => 'Gagal memuat rutinitas';

  @override
  String get routineStartWorkout => 'Mulai Latihan';

  @override
  String get routineNoSteps => 'Tidak ada langkah yang tersedia';

  @override
  String get routineNoVideoForStep => 'Tidak ada video untuk langkah ini';

  @override
  String get routineVideoProcessing =>
      'Video masih diproses. Silakan coba lagi nanti.';

  @override
  String get routineMissingPlaybackUrl =>
      'URL pemutaran tidak tersedia untuk video ini';

  @override
  String get routinePreviewBanner => 'PRATINJAU — video lengkap segera hadir';

  @override
  String get routinePreview => 'PRATINJAU';

  @override
  String get routineDetails => 'Detail';

  @override
  String get routineNotFound => 'Rutinitas tidak ditemukan';

  @override
  String routineCompletedTimes(int count) {
    return 'Selesai ${count}x';
  }

  @override
  String get playerVideoUnavailable => 'Video ini sedang tidak tersedia.';

  @override
  String get playerSteps => 'Langkah';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Tidak ada video yang dapat diputar';

  @override
  String get playerWorkoutComplete => 'Latihan selesai!';

  @override
  String get playerSavingStreak => 'Menyimpan ke streak Anda…';

  @override
  String get playerSavedStreak => 'Disimpan ke streak Anda';

  @override
  String get playerRetrySave => 'Coba simpan lagi';

  @override
  String get playerReplay => 'Putar ulang';

  @override
  String get playerNotReady => 'Pemutar belum siap';

  @override
  String get playerPreviewUnavailable => 'Pratinjau sedang tidak tersedia.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Klip $current dari $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Terjadi kesalahan saat memuat video';

  @override
  String get playerLoadingVideo => 'Memuat video...';

  @override
  String get playerFailedToLoadVideo => 'Gagal memuat video';

  @override
  String get playerNotInitialized => 'Pemutar video belum diinisialisasi';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Latihan $current/$total';
  }

  @override
  String get guidedGetReady => 'BERSIAP';

  @override
  String guidedSetOf(int current, int total) {
    return 'Set $current dari $total';
  }

  @override
  String get guidedRest => 'ISTIRAHAT';

  @override
  String get guidedSkipRest => 'Lewati istirahat';

  @override
  String get guidedPaused => 'Dijeda';

  @override
  String get guidedResume => 'Lanjutkan';

  @override
  String get guidedWorkoutComplete => 'Latihan selesai';

  @override
  String get guidedEndTitle => 'Akhiri latihan?';

  @override
  String get guidedEndBody =>
      'Progres Anda untuk sesi ini tidak akan disimpan.';

  @override
  String get guidedKeepGoing => 'Lanjutkan';

  @override
  String get guidedEnd => 'Selesai';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repetisi',
      one: '$count repetisi',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Buat Rutinitas dengan AI';

  @override
  String get generateSheetPrompt => 'Jenis latihan apa yang Anda inginkan?';

  @override
  String get generateSheetHint =>
      'misalnya, \"Peregangan pagi singkat untuk membangunkan tubuh\" atau \"Latihan kekuatan seluruh tubuh untuk pemula\"';

  @override
  String get generateSheetDuration => 'Durasi';

  @override
  String generateSheetMinutes(int count) {
    return '$count mnt';
  }

  @override
  String get generateSheetDifficulty => 'Tingkat Kesulitan';

  @override
  String get generateSheetEquipment => 'Peralatan yang Tersedia';

  @override
  String get generateSheetGenerating => 'Membuat...';

  @override
  String get generateSheetSubmit => 'Buat Rutinitas';

  @override
  String get generateSheetDescribeFirst =>
      'Deskripsikan latihan yang Anda inginkan';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Anda sudah memiliki ini: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Dibuat: $title';
  }

  @override
  String get generateSheetFailed => 'Gagal membuat rutinitas';

  @override
  String get guidedNoExercises => 'Rutinitas ini belum memiliki latihan.';

  @override
  String get guidedStartFailed =>
      'Tidak dapat memulai latihan ini sekarang. Silakan coba lagi.';

  @override
  String get guidedSaveFailed =>
      'Tidak dapat menyimpan latihan ini. Ketuk coba lagi untuk memperbarui streak Anda.';

  @override
  String guidedOfReps(int count) {
    return 'dari $count repetisi';
  }

  @override
  String get guidedHold => 'tahan';

  @override
  String get guidedNextSet => 'Set berikutnya';

  @override
  String get guidedUpNext => 'Selanjutnya';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds d tahan';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Bersiap. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Mulai. $count repetisi.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Tahan selama $seconds detik.';
  }

  @override
  String coachRest(String exercise) {
    return 'Istirahat. Selanjutnya: $exercise';
  }

  @override
  String get coachRestShort => 'Istirahat.';

  @override
  String get coachComplete => 'Kerja bagus. Latihan selesai.';

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
      'Tidak ditemukan video yang dapat diputar dalam rutinitas ini.';

  @override
  String get playerLoadRoutineFailed =>
      'Tidak dapat memuat rutinitas ini sekarang. Silakan coba lagi.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Gagal memuat \"$title\". Melewati…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Gagal memuat \"$title\".';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Tidak dapat menyimpan penyelesaian. Ketuk coba lagi untuk memperbarui streak Anda.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Pratinjau';
  }

  @override
  String get playerNoVideosReady =>
      'Rutinitas ini belum memiliki video yang siap diputar.';

  @override
  String get playerPlaybackFailed =>
      'Tidak dapat memutar video ini sekarang. Silakan coba lagi.';

  @override
  String get libraryTabCurated => 'Pilihan';

  @override
  String get libraryTabAiGenerated => 'Dibuat oleh AI';

  @override
  String get profileSavedRoutines => 'Rutinitas Tersimpan';

  @override
  String get savedRoutinesNoFavorites => 'Belum ada rutinitas favorit.';

  @override
  String get savedRoutinesEmpty => 'Belum ada rutinitas tersimpan.';

  @override
  String get actionFavorite => 'Tambahkan ke Favorit';

  @override
  String get actionUnfavorite => 'Hapus dari Favorit';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String routineDurationHours(int hours) {
    return '${hours}j';
  }

  @override
  String get difficultyEasy => 'Mudah';

  @override
  String get difficultyMedium => 'Sedang';

  @override
  String get difficultyHard => 'Sulit';

  @override
  String get categoryStrength => 'Kekuatan';

  @override
  String get categoryCardio => 'Kardio';

  @override
  String get categoryFlexibility => 'Fleksibilitas';

  @override
  String get categoryMindfulness => 'Kesadaran Penuh';

  @override
  String get categoryDance => 'Tari';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Khusus';

  @override
  String get navHome => 'Beranda';

  @override
  String get navLibrary => 'Pustaka';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get equipmentNone => 'Tidak ada';

  @override
  String get equipmentDumbbells => 'Dumbbell';

  @override
  String get equipmentResistanceBands => 'Resistance band';

  @override
  String get equipmentYogaMat => 'Matras yoga';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Palang pull-up';

  @override
  String get equipmentJumpRope => 'Tali lompat';

  @override
  String get nutritionTitle => 'Nutrisi';

  @override
  String get nutritionSubtitle => 'Kalori, makro, dan riwayat makanan';

  @override
  String get nutritionSetGoalsTitle => 'Tetapkan sasaran nutrisi harian';

  @override
  String get nutritionSetGoalsBody =>
      'Tambahkan berat badan, tinggi badan, usia, dan jenis kelamin agar Celia dapat menghitung jumlah kalori dan nutrisi yang perlu Anda konsumsi setiap hari.';

  @override
  String get nutritionSetUpGoals => 'Atur Sasaran';

  @override
  String get nutritionDailyTarget => 'Target harian';

  @override
  String get nutritionDailyGoals => 'Sasaran harian';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Hari ini';

  @override
  String get nutritionMealHistory => 'Riwayat Makanan';

  @override
  String get nutritionCeliaInsights => 'Insight Celia';

  @override
  String get nutritionWeeklyTrend => 'Tren Mingguan';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali makan',
      one: '$count kali makan',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali makan',
      one: '$count kali makan',
    );
    return 'dari $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'S,S,R,K,J,S,M';

  @override
  String get nutritionFieldFoodName => 'Nama makanan';

  @override
  String get nutritionFieldGrams => 'Gram';

  @override
  String get nutritionFieldCalories => 'Kalori';

  @override
  String get scannerStatusAnalyzing => 'MENGANALISIS...';

  @override
  String get scannerStatusIdle => 'PEMINDAI CELIA';

  @override
  String get scannerFieldFoodName => 'Nama makanan';

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
    return 'Sisa $calories kcal dan ${grams}g protein hari ini';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal melebihi target harian Anda';
  }

  @override
  String get scannerButtonAnalyzing => 'Menganalisis';

  @override
  String get scannerButtonQuotaNeeded => 'Kuota Diperlukan';

  @override
  String get scannerButtonScanNow => 'Pindai Sekarang';

  @override
  String get scannerButtonLogging => 'Mencatat';

  @override
  String get scannerButtonLogMeal => 'Catat Makanan';

  @override
  String get scannerNoClearFood =>
      'Belum ada makanan yang terdeteksi dengan jelas. Coba gunakan pencahayaan yang lebih baik atau mendekat.';

  @override
  String get scannerErrorCameraPermission =>
      'Izin kamera diperlukan untuk memindai makanan.';

  @override
  String get scannerErrorBackendMissing =>
      'Backend pemindai kalori belum dikonfigurasi.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'Kunci API OpenAI untuk pemindaian kalori tidak valid. Ganti di lingkungan backend, lakukan deploy ulang, lalu coba lagi.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Kunci API OpenAI diperlukan untuk pemindaian kalori. Tambahkan di Vercel, lakukan deploy ulang, lalu coba lagi.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Kredit OpenAI untuk pemindaian kalori telah habis. Tambahkan kredit API atau naikkan batas penagihan, lalu coba lagi.';

  @override
  String get scannerErrorTimeout =>
      'Celia memerlukan waktu lebih lama untuk menganalisis makanan ini. Pegang kamera tetap stabil dan pindai lagi.';

  @override
  String get scannerErrorNotSignedIn =>
      'Silakan masuk sebelum memindai makanan.';

  @override
  String get scannerErrorMealTableMissing =>
      'Tabel pencatatan makanan belum siap. Hasil pemindaian tetap tersedia.';

  @override
  String get scannerErrorGeneric =>
      'Celia belum dapat menganalisis makanan ini. Pegang kamera tetap stabil, posisikan makanan di tengah, lalu pindai lagi.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
      one: '$count item',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Detail Makanan';

  @override
  String get nutritionFoodItems => 'Item Makanan';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Makanan harus memiliki setidaknya satu item makanan.';

  @override
  String get nutritionMealUpdated => 'Makanan diperbarui';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Tidak dapat memperbarui makanan: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Hapus makanan?';

  @override
  String get nutritionDeleteMealBody =>
      'Ini akan menghapus makanan dari riwayat nutrisi Anda.';

  @override
  String get nutritionDeleteMeal => 'Hapus makanan';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Tidak dapat menghapus makanan: $error';
  }

  @override
  String get nutritionEditFood => 'Edit Makanan';

  @override
  String get nutritionSaveFood => 'Simpan Makanan';

  @override
  String get nutritionLoadFailed => 'Tidak dapat memuat makanan';

  @override
  String get nutritionLoadFailedBody =>
      'Tarik untuk menyegarkan atau periksa koneksi backend.';

  @override
  String get nutritionNoMeals => 'Belum ada makanan yang dicatat';

  @override
  String get nutritionNoMealsBody =>
      'Pindai makanan pertama Anda dan Celia akan membuat riwayat nutrisi Anda.';

  @override
  String get progressToday => 'Hari ini';

  @override
  String get progressSetGoals =>
      'Tetapkan sasaran nutrisi untuk membuka pelacakan kalori dan makro.';

  @override
  String progressOfTarget(int target) {
    return 'dari $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal berlebih';
  }

  @override
  String progressKcalLeft(int calories) {
    return 'tersisa $calories kcal';
  }

  @override
  String get progressProtein => 'Protein';

  @override
  String get progressCarbs => 'Karbohidrat';

  @override
  String get progressFat => 'Lemak';

  @override
  String get scannerEditItem => 'Edit Item Makanan';

  @override
  String get scannerSaveChanges => 'Simpan Perubahan';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Keyakinan $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count item lainnya termasuk dalam catatan makanan ini';
  }

  @override
  String get scannerIfYouLog => 'Jika Anda mencatat makanan ini';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal hari ini';
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
  String get scannerNoMealDetected => 'Makanan tidak terdeteksi';

  @override
  String onboardingWelcome(String name) {
    return 'Selamat datang, $name';
  }

  @override
  String get onboardingGender => 'Jenis Kelamin';

  @override
  String get onboardingCalculateGoals => 'Hitung Sasaran Saya';

  @override
  String get onboardingScanFirstMeal => 'Pindai Makanan Pertama Saya';

  @override
  String get onboardingExploreRoutines => 'Jelajahi Rutinitas';

  @override
  String get onboardingGoHome => 'Ke Beranda';

  @override
  String get onboardingDailyTargets => 'Target harian Anda';

  @override
  String onboardingProtein(int grams) {
    return 'Protein ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Protein ${protein}g • Karbohidrat ${carbs}g • Lemak ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Target nutrisi harian Anda siap. Pilih cara untuk memulai.';

  @override
  String get onboardingWeightKg => 'Berat (kg)';

  @override
  String get onboardingHeightCm => 'Tinggi (cm)';

  @override
  String get onboardingAge => 'Usia';

  @override
  String get onboardingInvalidWeight => 'Masukkan berat yang valid dalam kg.';

  @override
  String get onboardingInvalidHeight => 'Masukkan tinggi yang valid dalam cm.';

  @override
  String get onboardingInvalidAge =>
      'Masukkan usia yang valid antara 13 dan 100.';

  @override
  String get onboardingSaveFailed =>
      'Tidak dapat menyimpan profil nutrisi Anda.';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get genderOther => 'Lainnya';

  @override
  String get nutritionSetupTitle => 'Sasaran Nutrisi Harian';

  @override
  String get nutritionSetupBody =>
      'Beri tahu Celia tentang tubuh Anda agar ia dapat menghitung kalori dan makro harian Anda.';

  @override
  String get nutritionSetupGender => 'Jenis Kelamin';

  @override
  String get nutritionSetupFootnote =>
      'Celia menggunakan berat, tinggi, usia, dan jenis kelamin Anda untuk memperkirakan target kalori dan makro harian dengan tingkat aktivitas sedang.';

  @override
  String get nutritionSourcesTitle => 'Bagaimana target ini dihitung';

  @override
  String get nutritionSourcesBody =>
      'Kalori harian menggunakan persamaan energi istirahat Mifflin–St Jeor dengan faktor aktivitas fisik sedang (sekitar 1,55). Protein diperkirakan mendekati 1,8 g per kg berat badan untuk orang dewasa aktif. Lemak ditetapkan mendekati 25% kalori, dengan karbohidrat mengisi sisanya — dalam rentang panduan diet yang umum.';

  @override
  String get nutritionSourcesDisclaimer =>
      'Angka-angka ini hanya perkiraan kesejahteraan umum. Bukan diagnosis, resep, atau pengganti saran dari dokter atau ahli gizi yang berkualifikasi.';

  @override
  String get nutritionSetupSave => 'Simpan Sasaran';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Anggota';

  @override
  String get profileAccount => 'Akun';

  @override
  String profileSignedInAs(String email) {
    return 'Masuk sebagai:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Tidak diketahui';

  @override
  String get profileDarkMode => 'Mode Gelap';

  @override
  String get profileAvatarMode => 'Mode avatar';

  @override
  String get profileAvatarModeSubtitle => 'Bicara dengan Celia layar penuh';

  @override
  String get profileLanguage => 'Bahasa';

  @override
  String get profileLogOutTitle => 'Keluar?';

  @override
  String get profileLogOutBody => 'Apakah Anda yakin ingin keluar?';

  @override
  String get profileLogOut => 'Keluar';

  @override
  String get profileLogOutButton => 'Keluar';

  @override
  String get profileDeleteAccount => 'Hapus akun';

  @override
  String get profileDeleteAccountConfirmTitle => 'Hapus akun Anda?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Ini menghapus secara permanen akun dan semua data Anda, termasuk rutinitas tersimpan, catatan makanan, dan riwayat chat. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'Masukkan kata sandi Anda untuk mengonfirmasi.';

  @override
  String get profileDeleteAccountPasswordLabel => 'Kata sandi';

  @override
  String get profileDeleteAccountButton => 'Hapus akun saya';

  @override
  String get profileFavoriteRoutines => 'Rutinitas Favorit';

  @override
  String get profileSubscription => 'Langganan';

  @override
  String get profileNutrition => 'Nutrisi';

  @override
  String get profileHelpSupport => 'Bantuan & Dukungan';

  @override
  String get profileFriend => 'Teman';

  @override
  String get profileStatSaved => 'Tersimpan';

  @override
  String get profileStatStreak => 'Rangkaian';

  @override
  String get profileStatWorkouts => 'Latihan';

  @override
  String get streakDayOneStarted =>
      'Hari pertama dimulai — kembali besok untuk membangun rangkaian Anda.';

  @override
  String get streakRebuild =>
      'Anda aktif kemarin — catat makanan atau selesaikan latihan hari ini untuk membangun kembali rangkaian Anda.';

  @override
  String get streakStart =>
      'Catat makanan atau selesaikan latihan untuk memulai rangkaian aktif Anda.';

  @override
  String streakLongRun(int days) {
    return 'Rangkaian $days hari! Terus konsisten — Celia memantau kemajuan Anda.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Rangkaian $days hari — latihan dan nutrisi hari ini sudah dicatat.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Rangkaian $days hari. Latihan singkat akan melengkapi hari ini.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Rangkaian $days hari. Catat makanan untuk melacak asupan Anda.';
  }

  @override
  String streakStayActive(int days) {
    return 'Rangkaian $days hari — tetap aktif hari ini.';
  }

  @override
  String get editProfileTitle => 'Edit Profil';

  @override
  String get editProfileName => 'Nama';

  @override
  String get editProfileFootnote =>
      'Perubahan disimpan ke akun Anda dan akan ditampilkan di Beranda/Profil.';

  @override
  String get editProfileSaveFailed =>
      'Profil tidak dapat diperbarui. Silakan coba lagi.';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSystem => 'Bahasa perangkat';

  @override
  String get languageSystemSubtitle =>
      'Ikuti bahasa yang digunakan di ponsel Anda';

  @override
  String get languageEnglish => 'Bahasa Inggris';

  @override
  String get languageSpanish => 'Bahasa Spanyol';

  @override
  String get insightStartFuelingTitle => 'Mulai penuhi asupan hari ini';

  @override
  String get insightStartFuelingBody =>
      'Anda masih memiliki seluruh anggaran kalori. Pindai atau catat makanan pertama Anda agar tetap sesuai target.';

  @override
  String get insightAboveTargetTitle => 'Di atas target hari ini';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Anda mengonsumsi $calories kcal di atas target harian. Kurangi porsi makan malam atau tambahkan latihan singkat.';
  }

  @override
  String get insightLowProteinTitle => 'Protein masih kurang';

  @override
  String insightLowProteinBody(int grams) {
    return 'Anda masih membutuhkan sekitar ${grams}g protein hari ini untuk mencapai target.';
  }

  @override
  String get insightAlmostThereTitle => 'Hampir mencapai tujuan';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Anda memiliki sisa $calories kcal hari ini. Camilan seimbang akan cocok untuk Anda.';
  }

  @override
  String get insightOnTrackTitle => 'Sesuai target hari ini';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Tersisa $calories kcal dan ${grams}g protein untuk mencapai target harian Anda.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Bangun ritme mingguan';

  @override
  String get insightWeeklyRhythmBody =>
      'Catat makanan sepanjang minggu agar Celia dapat menemukan pola dan membimbing Anda dengan lebih baik.';

  @override
  String get insightWeeklyTrendTitle => 'Tren mingguan';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Anda mencatat makanan pada $days dari 7 hari terakhir, dengan rata-rata $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'tepat di sekitar target harian Anda';

  @override
  String insightTrendAbove(int delta) {
    return 'rata-rata $delta kcal di atas target Anda';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'rata-rata $delta kcal di bawah target Anda';
  }

  @override
  String get insightsSectionTitle => 'Wawasan Celia';
}
