// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Celia - Huấn luyện viên toàn diện';

  @override
  String get actionCancel => 'Hủy';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionDelete => 'Xóa';

  @override
  String get actionEdit => 'Chỉnh sửa';

  @override
  String get actionRetry => 'Thử lại';

  @override
  String get actionDone => 'Xong';

  @override
  String get actionClose => 'Đóng';

  @override
  String get actionContinue => 'Tiếp tục';

  @override
  String get actionSeeAll => 'Xem tất cả';

  @override
  String get actionYesDoIt => 'Có, thực hiện';

  @override
  String get actionNotNow => 'Để sau';

  @override
  String get loadingPreparing => 'Đang chuẩn bị Celia...';

  @override
  String get loadingGeneric => 'Đang tải...';

  @override
  String get errorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get errorCanceled => 'Đã hủy thao tác.';

  @override
  String get errorTooManyRequests =>
      'Quá nhiều lần thử. Vui lòng đợi một phút rồi thử lại.';

  @override
  String get errorNetwork => 'Vui lòng kiểm tra kết nối internet và thử lại.';

  @override
  String get errorBadCredentials => 'Email hoặc mật khẩu không đúng.';

  @override
  String get errorEmailInUse => 'Email này đã được sử dụng. Hãy thử đăng nhập.';

  @override
  String get errorWeakPassword => 'Hãy dùng mật khẩu mạnh hơn rồi thử lại.';

  @override
  String get errorInvalidEmail => 'Vui lòng nhập địa chỉ email hợp lệ.';

  @override
  String get errorNoPermission => 'Bạn không có quyền thực hiện việc này.';

  @override
  String get errorNotSignedIn => 'Vui lòng đăng nhập rồi thử lại.';

  @override
  String get errorNoConversation => 'Bắt đầu cuộc trò chuyện mới để tiếp tục.';

  @override
  String get errorNoPlayableVideos =>
      'Hiện chưa có video nào có thể phát cho bài tập này.';

  @override
  String get errorLoadRoutines =>
      'Không thể tải bài tập lúc này. Vui lòng thử lại.';

  @override
  String get errorLoadSavedRoutines =>
      'Không thể tải các bài tập đã lưu lúc này. Vui lòng thử lại.';

  @override
  String get errorGenerateRoutine =>
      'Không thể tạo bài tập lúc này. Vui lòng thử lại.';

  @override
  String get errorLoadChats => 'Hiện không thể tải các cuộc trò chuyện đã lưu.';

  @override
  String get errorCeliaUnavailable =>
      'Celia hiện không khả dụng. Vui lòng thử lại.';

  @override
  String get errorOpenConversation => 'Không thể mở cuộc trò chuyện đó.';

  @override
  String get errorDeleteConversation =>
      'Không thể xóa cuộc trò chuyện này. Vui lòng thử lại.';

  @override
  String get errorSignIn => 'Không thể đăng nhập. Vui lòng thử lại.';

  @override
  String get errorCreateAccount => 'Không thể tạo tài khoản. Vui lòng thử lại.';

  @override
  String get errorSendResetEmail =>
      'Không thể gửi email đặt lại mật khẩu. Vui lòng thử lại.';

  @override
  String get errorSendVerificationEmail =>
      'Không thể gửi email xác minh. Vui lòng thử lại.';

  @override
  String get errorGoogleSignIn =>
      'Đăng nhập bằng Google không thành công. Vui lòng thử lại.';

  @override
  String get errorAppleSignIn =>
      'Đăng nhập bằng Apple không thành công. Vui lòng thử lại.';

  @override
  String get errorRefreshNutrition => 'Không thể làm mới dữ liệu dinh dưỡng.';

  @override
  String get errorLoadNutritionProfile =>
      'Không thể tải hồ sơ dinh dưỡng của bạn.';

  @override
  String get startupErrorTitle => 'Không thể khởi động ứng dụng';

  @override
  String get startupErrorBody =>
      'Vui lòng đóng rồi mở lại ứng dụng. Nếu sự cố vẫn tiếp diễn, hãy liên hệ bộ phận hỗ trợ.';

  @override
  String get authTagline => 'Người bạn đồng hành thể hình của bạn';

  @override
  String get authSignUp => 'Đăng ký';

  @override
  String get authLogIn => 'Đăng nhập';

  @override
  String authVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authOr => 'HOẶC';

  @override
  String get authContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get authContinueWithApple => 'Tiếp tục với Apple';

  @override
  String get authAuthenticating => 'Đang xác thực...';

  @override
  String get authEnterYourName => 'Vui lòng nhập tên của bạn.';

  @override
  String get authNeedAccount => 'Chưa có tài khoản? Đăng ký';

  @override
  String get authHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get authFieldName => 'Tên của bạn';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Mật khẩu';

  @override
  String get verifyEmailTitle => 'Xác minh email của bạn';

  @override
  String get verifyEmailHeading => 'Kiểm tra hộp thư đến';

  @override
  String get verifyEmailBody =>
      'Một liên kết xác minh đã được gửi đến email của bạn.';

  @override
  String get verifyEmailSent => 'Đã gửi email xác minh!';

  @override
  String get verifyEmailContinue => 'Tôi đã xác minh, tiếp tục';

  @override
  String get verifyEmailSignOut => 'Đăng xuất';

  @override
  String get verifyEmailSending => 'Đang gửi...';

  @override
  String get verifyEmailResend => 'Gửi lại email xác minh';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Gửi lại sau $seconds giây';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'Email: $email';
  }

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordBody =>
      'Nhập email của bạn để nhận liên kết đặt lại mật khẩu.';

  @override
  String get forgotPasswordEmptyEmail => 'Vui lòng nhập email';

  @override
  String get forgotPasswordSent => 'Đã gửi email đặt lại mật khẩu.';

  @override
  String get forgotPasswordSend => 'Gửi liên kết đặt lại';

  @override
  String get forgotPasswordSending => 'Đang gửi...';

  @override
  String get nameSetupTitle => 'Bạn muốn Celia gọi bạn là gì?';

  @override
  String get nameSetupBody =>
      'Chúng tôi sử dụng tên của bạn trong ứng dụng để việc huấn luyện trở nên thân thiện hơn.';

  @override
  String get nameSetupSaveFailed =>
      'Không thể lưu tên của bạn. Vui lòng thử lại.';

  @override
  String get homeGoodMorning => 'Chào buổi sáng,';

  @override
  String get homeCeliaActive => 'CELIA ACTIVE';

  @override
  String get homeGenerateRoutine => 'Tạo\nlịch tập\ncá nhân hóa bằng AI';

  @override
  String get homeCreateRoutine => 'Tạo lịch tập';

  @override
  String get homeQuickActions => 'Tác vụ nhanh';

  @override
  String get homeUpNext => 'Sắp tới';

  @override
  String get homeNoUpcoming =>
      'Chưa có lịch tập nào sắp tới.\nHãy tạo một lịch tập hoặc duyệt thư viện.';

  @override
  String get homeChatWithCelia => 'Trò chuyện với Celia';

  @override
  String get homeChatSubtitle => 'Hỏi về kỹ thuật hoặc chế độ ăn';

  @override
  String get homeScanMeal => 'Quét món ăn';

  @override
  String get homeScanMealSubtitle => 'Nhận diện thực phẩm & calo';

  @override
  String get homeNutrition => 'Dinh dưỡng';

  @override
  String get homeNutritionSubtitle => 'Xem calo, macro & bữa ăn';

  @override
  String get homeBrowseLibrary => 'Duyệt\nthư viện';

  @override
  String get homeTrackProgress => 'Theo dõi\ntiến độ';

  @override
  String get chatTitle => 'Huấn luyện viên Celia';

  @override
  String get chatEmptyPrompt =>
      'Hôm nay tôi có thể giúp bạn\nrèn luyện sức khỏe thế nào?';

  @override
  String get chatYourChats => 'Các cuộc trò chuyện';

  @override
  String get chatNoSavedChats => 'Chưa có cuộc trò chuyện nào được lưu.';

  @override
  String get chatHistory => 'Lịch sử trò chuyện';

  @override
  String get chatNew => 'Cuộc trò chuyện mới';

  @override
  String get chatOpening => 'Đang mở cuộc trò chuyện...';

  @override
  String get chatScanAMeal => 'Quét món ăn';

  @override
  String get chatInputHint =>
      'Hỏi Celia bất cứ điều gì về việc tập luyện của bạn...';

  @override
  String get chatCouldNotOpenRoutine => 'Không thể mở lịch tập đó';

  @override
  String get chatThisRoutine => 'lịch tập này';

  @override
  String get chatThisMeal => 'bữa ăn này';

  @override
  String get chatYourRoutine => 'Lịch tập của bạn';

  @override
  String chatMoreExercises(int count) {
    return '+ $count bài tập nữa';
  }

  @override
  String get chatEmptySubtitle =>
      'Hỏi về việc tập luyện, chế độ ăn hoặc tiến độ của bạn.';

  @override
  String chatLoggedToday(int calories) {
    return 'Hôm nay bạn đã ghi nhận $calories kcal.';
  }

  @override
  String get chatSuggestionHiit => 'Tạo cho tôi một lịch HIIT 20 phút';

  @override
  String get chatSuggestionDinner => 'Tối nay tôi nên ăn gì?';

  @override
  String get chatSuggestionProgress => 'Tuần này tôi tiến bộ thế nào?';

  @override
  String get chatSuggestionIngredients => 'Tôi có thịt gà, cơm và rau bina';

  @override
  String get chatJustNow => 'Vừa xong';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get chatRoutineAlreadySaved => 'Đã có trong thư viện — chạm để mở';

  @override
  String get chatRoutineTapToOpen => 'Chạm để mở';

  @override
  String get chatToolCancelled => 'Đã hủy';

  @override
  String chatToolFailed(String label) {
    return '$label — thao tác không thành công';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Không thể lưu bài tập';

  @override
  String get chatToolRoutineSaved => 'Đã lưu vào thư viện';

  @override
  String get chatToolMealLogged => 'Đã thêm vào nhật ký hôm nay';

  @override
  String get chatToolRoutineAdded => 'Đã thêm vào thư viện';

  @override
  String get activityCheckingProgress => 'Đang kiểm tra tiến độ của bạn';

  @override
  String get activityCheckingNutrition =>
      'Đang kiểm tra những gì bạn đã ăn hôm nay';

  @override
  String get activityReviewingMeals => 'Đang xem lại các bữa ăn gần đây';

  @override
  String get activityLookingAtRoutines => 'Đang xem các bài tập của bạn';

  @override
  String get activityReadingRoutine => 'Đang đọc bài tập đó';

  @override
  String get activitySearchingLibrary => 'Đang tìm kiếm trong thư viện bài tập';

  @override
  String get activityBuildingRoutine => 'Đang tạo bài tập cho bạn';

  @override
  String get activityLoggingMeal => 'Đang ghi lại bữa ăn của bạn';

  @override
  String get activitySavingToLibrary => 'Đang lưu vào thư viện';

  @override
  String get activityWorking => 'Đang xử lý';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Lưu \"$name\" với $count bài tập vào thư viện?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Lưu \"$name\" vào thư viện?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Ghi \"$name\" với $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Ghi \"$name\"?';
  }

  @override
  String get approvalAddRoutine => 'Thêm bài tập này vào thư viện?';

  @override
  String get approvalGeneric => 'Cho phép Celia thực hiện việc này?';

  @override
  String get libraryTitle => 'Thư viện bài tập';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bước',
      one: '$count bước',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Chưa có bài tập nào';

  @override
  String get libraryEmptyBody => 'Tạo và đăng bài tập trong trang quản trị.';

  @override
  String get libraryLoadFailed => 'Không thể tải các bài tập';

  @override
  String get routineStartWorkout => 'Bắt đầu tập';

  @override
  String get routineNoSteps => 'Không có bước nào';

  @override
  String get routineNoVideoForStep => 'Không có video cho bước này';

  @override
  String get routineVideoProcessing =>
      'Video vẫn đang được xử lý. Vui lòng thử lại sau.';

  @override
  String get routineMissingPlaybackUrl => 'Thiếu URL phát cho video này';

  @override
  String get routinePreviewBanner => 'BẢN XEM TRƯỚC — video đầy đủ sắp có';

  @override
  String get routinePreview => 'BẢN XEM TRƯỚC';

  @override
  String get routineDetails => 'Chi tiết';

  @override
  String get routineNotFound => 'Không tìm thấy bài tập';

  @override
  String routineCompletedTimes(int count) {
    return 'Đã hoàn thành $count lần';
  }

  @override
  String get playerVideoUnavailable => 'Video này hiện không khả dụng.';

  @override
  String get playerSteps => 'Các bước';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Không có video có thể phát';

  @override
  String get playerWorkoutComplete => 'Đã hoàn thành buổi tập!';

  @override
  String get playerSavingStreak => 'Đang lưu vào chuỗi ngày tập…';

  @override
  String get playerSavedStreak => 'Đã lưu vào chuỗi ngày tập';

  @override
  String get playerRetrySave => 'Thử lưu lại';

  @override
  String get playerReplay => 'Phát lại';

  @override
  String get playerNotReady => 'Trình phát chưa sẵn sàng';

  @override
  String get playerPreviewUnavailable => 'Bản xem trước hiện không khả dụng.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Đoạn $current trên $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Lỗi khi tải video';

  @override
  String get playerLoadingVideo => 'Đang tải video...';

  @override
  String get playerFailedToLoadVideo => 'Không thể tải video';

  @override
  String get playerNotInitialized => 'Trình phát video chưa được khởi tạo';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Bài tập $current/$total';
  }

  @override
  String get guidedGetReady => 'CHUẨN BỊ';

  @override
  String guidedSetOf(int current, int total) {
    return 'Hiệp $current trên $total';
  }

  @override
  String get guidedRest => 'NGHỈ';

  @override
  String get guidedSkipRest => 'Bỏ qua thời gian nghỉ';

  @override
  String get guidedPaused => 'Đã tạm dừng';

  @override
  String get guidedResume => 'Tiếp tục';

  @override
  String get guidedWorkoutComplete => 'Đã hoàn thành buổi tập';

  @override
  String get guidedEndTitle => 'Kết thúc buổi tập?';

  @override
  String get guidedEndBody =>
      'Tiến trình của bạn trong buổi tập này sẽ không được lưu.';

  @override
  String get guidedKeepGoing => 'Tiếp tục';

  @override
  String get guidedEnd => 'Kết thúc';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lần',
      one: '$count lần',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Tạo giáo án bằng AI';

  @override
  String get generateSheetPrompt => 'Bạn muốn tập luyện như thế nào?';

  @override
  String get generateSheetHint =>
      'ví dụ: \"Bài giãn cơ buổi sáng nhanh để tỉnh táo\" hoặc \"Tập sức mạnh toàn thân cho người mới bắt đầu\"';

  @override
  String get generateSheetDuration => 'Thời lượng';

  @override
  String generateSheetMinutes(int count) {
    return '$count phút';
  }

  @override
  String get generateSheetDifficulty => 'Độ khó';

  @override
  String get generateSheetEquipment => 'Thiết bị sẵn có';

  @override
  String get generateSheetGenerating => 'Đang tạo...';

  @override
  String get generateSheetSubmit => 'Tạo giáo án';

  @override
  String get generateSheetDescribeFirst => 'Vui lòng mô tả bài tập bạn muốn';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Bạn đã có bài này: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Đã tạo: $title';
  }

  @override
  String get generateSheetFailed => 'Không thể tạo giáo án';

  @override
  String get guidedNoExercises => 'Giáo án này chưa có bài tập nào.';

  @override
  String get guidedStartFailed =>
      'Hiện không thể bắt đầu buổi tập này. Vui lòng thử lại.';

  @override
  String get guidedSaveFailed =>
      'Không thể lưu buổi tập này. Nhấn thử lại để cập nhật chuỗi ngày tập.';

  @override
  String guidedOfReps(int count) {
    return 'trên tổng số $count lần';
  }

  @override
  String get guidedHold => 'giữ';

  @override
  String get guidedNextSet => 'Hiệp tiếp theo';

  @override
  String get guidedUpNext => 'Tiếp theo';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × giữ $seconds giây';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Sẵn sàng. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Bắt đầu. $count lần.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Giữ trong $seconds giây.';
  }

  @override
  String coachRest(String exercise) {
    return 'Nghỉ. Tiếp theo: $exercise';
  }

  @override
  String get coachRestShort => 'Nghỉ.';

  @override
  String get coachComplete => 'Tuyệt vời. Đã hoàn thành buổi tập.';

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
      'Không tìm thấy video có thể phát trong giáo án này.';

  @override
  String get playerLoadRoutineFailed =>
      'Hiện không thể tải giáo án này. Vui lòng thử lại.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Không thể tải \"$title\". Đang bỏ qua…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Không thể tải \"$title\".';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Không thể lưu trạng thái hoàn thành. Nhấn thử lại để cập nhật chuỗi ngày tập.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Xem trước';
  }

  @override
  String get playerNoVideosReady =>
      'Giáo án này chưa có video sẵn sàng để phát.';

  @override
  String get playerPlaybackFailed =>
      'Hiện không thể phát video này. Vui lòng thử lại.';

  @override
  String get libraryTabCurated => 'Tuyển chọn';

  @override
  String get libraryTabAiGenerated => 'Được tạo bằng AI';

  @override
  String get profileSavedRoutines => 'Giáo án đã lưu';

  @override
  String get savedRoutinesNoFavorites => 'Chưa có giáo án yêu thích nào.';

  @override
  String get savedRoutinesEmpty => 'Chưa có giáo án nào được lưu.';

  @override
  String get actionFavorite => 'Thêm vào yêu thích';

  @override
  String get actionUnfavorite => 'Bỏ khỏi yêu thích';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours giờ';
  }

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyMedium => 'Trung bình';

  @override
  String get difficultyHard => 'Khó';

  @override
  String get categoryStrength => 'Sức mạnh';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Độ dẻo';

  @override
  String get categoryMindfulness => 'Chánh niệm';

  @override
  String get categoryDance => 'Khiêu vũ';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Tùy chỉnh';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navLibrary => 'Thư viện';

  @override
  String get navChat => 'Trò chuyện';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get equipmentNone => 'Không có';

  @override
  String get equipmentDumbbells => 'Tạ tay';

  @override
  String get equipmentResistanceBands => 'Dây kháng lực';

  @override
  String get equipmentYogaMat => 'Thảm Yoga';

  @override
  String get equipmentKettlebell => 'Tạ ấm';

  @override
  String get equipmentPullUpBar => 'Xà đơn';

  @override
  String get equipmentJumpRope => 'Dây nhảy';

  @override
  String get nutritionTitle => 'Dinh dưỡng';

  @override
  String get nutritionSubtitle => 'Calo, macro và lịch sử bữa ăn';

  @override
  String get nutritionSetGoalsTitle => 'Đặt mục tiêu dinh dưỡng hằng ngày';

  @override
  String get nutritionSetGoalsBody =>
      'Thêm cân nặng, chiều cao, tuổi và giới tính để Celia tính toán lượng calo và dưỡng chất bạn nên tiêu thụ mỗi ngày.';

  @override
  String get nutritionSetUpGoals => 'Thiết lập mục tiêu';

  @override
  String get nutritionDailyTarget => 'Mục tiêu hằng ngày';

  @override
  String get nutritionDailyGoals => 'Mục tiêu hằng ngày';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Hôm nay';

  @override
  String get nutritionMealHistory => 'Lịch sử bữa ăn';

  @override
  String get nutritionCeliaInsights => 'Thông tin từ Celia';

  @override
  String get nutritionWeeklyTrend => 'Xu hướng theo tuần';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bữa ăn',
      one: '$count bữa ăn',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bữa ăn',
      one: '$count bữa ăn',
    );
    return 'trên $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'T,H,B,T,S,S,C';

  @override
  String get nutritionFieldFoodName => 'Tên món ăn';

  @override
  String get nutritionFieldGrams => 'Số gram';

  @override
  String get nutritionFieldCalories => 'Calo';

  @override
  String get scannerStatusAnalyzing => 'ĐANG PHÂN TÍCH...';

  @override
  String get scannerStatusIdle => 'BỘ QUÉT CELIA';

  @override
  String get scannerFieldFoodName => 'Tên món ăn';

  @override
  String get scannerFieldGrams => 'Số gram';

  @override
  String get scannerFieldCalories => 'Calo';

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
    return 'Còn lại $calories kcal và ${grams}g protein cho hôm nay';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return 'Vượt $calories kcal so với mục tiêu hằng ngày';
  }

  @override
  String get scannerButtonAnalyzing => 'Đang phân tích';

  @override
  String get scannerButtonQuotaNeeded => 'Cần hạn mức';

  @override
  String get scannerButtonScanNow => 'Quét ngay';

  @override
  String get scannerButtonLogging => 'Đang ghi nhận';

  @override
  String get scannerButtonLogMeal => 'Ghi nhận bữa ăn';

  @override
  String get scannerNoClearFood =>
      'Chưa phát hiện rõ món ăn. Hãy thử nơi có ánh sáng tốt hơn hoặc đưa máy ảnh lại gần.';

  @override
  String get scannerErrorCameraPermission =>
      'Cần cấp quyền máy ảnh để quét bữa ăn.';

  @override
  String get scannerErrorBackendMissing =>
      'Backend quét calo chưa được cấu hình.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'Khóa API OpenAI dùng để quét calo không hợp lệ. Hãy thay khóa trong môi trường backend, triển khai lại rồi thử lại.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Cần có khóa API OpenAI để quét calo. Hãy thêm khóa trong Vercel, triển khai lại rồi thử lại.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Tín dụng OpenAI cho việc quét calo đã hết. Hãy thêm tín dụng API hoặc tăng giới hạn thanh toán rồi thử lại.';

  @override
  String get scannerErrorTimeout =>
      'Celia cần thêm thời gian để phân tích bữa ăn này. Giữ máy ảnh ổn định và quét lại.';

  @override
  String get scannerErrorNotSignedIn =>
      'Vui lòng đăng nhập trước khi quét bữa ăn.';

  @override
  String get scannerErrorMealTableMissing =>
      'Bảng ghi nhận bữa ăn chưa sẵn sàng. Kết quả quét vẫn khả dụng.';

  @override
  String get scannerErrorGeneric =>
      'Celia chưa thể phân tích bữa ăn này. Giữ máy ảnh ổn định, đặt món ăn ở giữa khung hình và quét lại.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món',
      one: '$count món',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Chi tiết bữa ăn';

  @override
  String get nutritionFoodItems => 'Món ăn';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem => 'Bữa ăn cần ít nhất một món ăn.';

  @override
  String get nutritionMealUpdated => 'Đã cập nhật bữa ăn';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Không thể cập nhật bữa ăn: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Xóa bữa ăn?';

  @override
  String get nutritionDeleteMealBody =>
      'Thao tác này sẽ xóa bữa ăn khỏi lịch sử dinh dưỡng của bạn.';

  @override
  String get nutritionDeleteMeal => 'Xóa bữa ăn';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Không thể xóa bữa ăn: $error';
  }

  @override
  String get nutritionEditFood => 'Chỉnh sửa món ăn';

  @override
  String get nutritionSaveFood => 'Lưu món ăn';

  @override
  String get nutritionLoadFailed => 'Không thể tải các bữa ăn';

  @override
  String get nutritionLoadFailedBody =>
      'Kéo xuống để làm mới hoặc kiểm tra kết nối đến máy chủ.';

  @override
  String get nutritionNoMeals => 'Chưa có bữa ăn nào được ghi lại';

  @override
  String get nutritionNoMealsBody =>
      'Quét bữa ăn đầu tiên và Celia sẽ xây dựng lịch sử dinh dưỡng cho bạn.';

  @override
  String get progressToday => 'Hôm nay';

  @override
  String get progressSetGoals =>
      'Đặt mục tiêu dinh dưỡng để theo dõi calo và các chất dinh dưỡng đa lượng.';

  @override
  String progressOfTarget(int target) {
    return 'trên $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return 'Vượt $calories kcal';
  }

  @override
  String progressKcalLeft(int calories) {
    return 'Còn lại $calories kcal';
  }

  @override
  String get progressProtein => 'Chất đạm';

  @override
  String get progressCarbs => 'Tinh bột';

  @override
  String get progressFat => 'Chất béo';

  @override
  String get scannerEditItem => 'Chỉnh sửa món ăn';

  @override
  String get scannerSaveChanges => 'Lưu thay đổi';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Độ tin cậy $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count món khác trong nhật ký bữa ăn này';
  }

  @override
  String get scannerIfYouLog => 'Nếu bạn ghi lại bữa ăn này';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal hôm nay';
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
  String get scannerNoMealDetected => 'Không phát hiện bữa ăn';

  @override
  String onboardingWelcome(String name) {
    return 'Chào mừng, $name';
  }

  @override
  String get onboardingGender => 'Giới tính';

  @override
  String get onboardingCalculateGoals => 'Tính mục tiêu của tôi';

  @override
  String get onboardingScanFirstMeal => 'Quét bữa ăn đầu tiên';

  @override
  String get onboardingExploreRoutines => 'Khám phá bài tập';

  @override
  String get onboardingGoHome => 'Về trang chủ';

  @override
  String get onboardingDailyTargets => 'Mục tiêu hằng ngày của bạn';

  @override
  String onboardingProtein(int grams) {
    return 'Chất đạm ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Chất đạm ${protein}g • Tinh bột ${carbs}g • Chất béo ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Mục tiêu dinh dưỡng hằng ngày của bạn đã sẵn sàng. Hãy chọn cách bạn muốn bắt đầu.';

  @override
  String get onboardingWeightKg => 'Cân nặng (kg)';

  @override
  String get onboardingHeightCm => 'Chiều cao (cm)';

  @override
  String get onboardingAge => 'Tuổi';

  @override
  String get onboardingInvalidWeight => 'Nhập cân nặng hợp lệ tính bằng kg.';

  @override
  String get onboardingInvalidHeight => 'Nhập chiều cao hợp lệ tính bằng cm.';

  @override
  String get onboardingInvalidAge => 'Nhập độ tuổi hợp lệ từ 13 đến 100.';

  @override
  String get onboardingSaveFailed => 'Không thể lưu hồ sơ dinh dưỡng của bạn.';

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get genderOther => 'Khác';

  @override
  String get nutritionSetupTitle => 'Mục tiêu dinh dưỡng hằng ngày';

  @override
  String get nutritionSetupBody =>
      'Cho Celia biết thông tin cơ thể của bạn để tính lượng calo và các chất dinh dưỡng đa lượng hằng ngày.';

  @override
  String get nutritionSetupGender => 'Giới tính';

  @override
  String get nutritionSetupFootnote =>
      'Celia sử dụng cân nặng, chiều cao, tuổi và giới tính của bạn để ước tính mục tiêu calo và các chất dinh dưỡng đa lượng hằng ngày dựa trên mức độ vận động vừa phải.';

  @override
  String get nutritionSetupSave => 'Lưu mục tiêu';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Thành viên';

  @override
  String get profileAccount => 'Tài khoản';

  @override
  String profileSignedInAs(String email) {
    return 'Đã đăng nhập bằng:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Không rõ';

  @override
  String get profileDarkMode => 'Chế độ tối';

  @override
  String get profileLanguage => 'Ngôn ngữ';

  @override
  String get profileLogOutTitle => 'Đăng xuất?';

  @override
  String get profileLogOutBody => 'Bạn có chắc muốn đăng xuất không?';

  @override
  String get profileLogOut => 'Đăng xuất';

  @override
  String get profileLogOutButton => 'Đăng xuất';

  @override
  String get profileFavoriteRoutines => 'Bài tập yêu thích';

  @override
  String get profileSubscription => 'Gói đăng ký';

  @override
  String get profileNutrition => 'Dinh dưỡng';

  @override
  String get profileHelpSupport => 'Trợ giúp & Hỗ trợ';

  @override
  String get profileFriend => 'Bạn bè';

  @override
  String get profileStatSaved => 'Đã lưu';

  @override
  String get profileStatStreak => 'Chuỗi ngày';

  @override
  String get profileStatWorkouts => 'Bài tập';

  @override
  String get streakDayOneStarted =>
      'Ngày 1 đã bắt đầu — hãy quay lại vào ngày mai để xây dựng chuỗi ngày của bạn.';

  @override
  String get streakRebuild =>
      'Bạn đã hoạt động hôm qua — hãy ghi lại một bữa ăn hoặc hoàn thành bài tập hôm nay để khôi phục chuỗi ngày.';

  @override
  String get streakStart =>
      'Ghi lại một bữa ăn hoặc hoàn thành bài tập để bắt đầu chuỗi ngày hoạt động.';

  @override
  String streakLongRun(int days) {
    return 'Chuỗi $days ngày! Hãy tiếp tục duy trì — Celia đang theo dõi sự đều đặn của bạn.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Chuỗi $days ngày — hôm nay bạn đã ghi lại cả bài tập và dinh dưỡng.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Chuỗi $days ngày. Một bài tập nhanh sẽ giúp bạn hoàn thiện ngày hôm nay.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Chuỗi $days ngày. Hãy ghi lại một bữa ăn để theo dõi việc nạp năng lượng.';
  }

  @override
  String streakStayActive(int days) {
    return 'Chuỗi $days ngày — hãy duy trì hoạt động hôm nay.';
  }

  @override
  String get editProfileTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get editProfileName => 'Tên';

  @override
  String get editProfileFootnote =>
      'Các thay đổi sẽ được lưu vào tài khoản và hiển thị trên Trang chủ/Hồ sơ.';

  @override
  String get editProfileSaveFailed =>
      'Không thể cập nhật hồ sơ. Vui lòng thử lại.';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Ngôn ngữ thiết bị';

  @override
  String get languageSystemSubtitle =>
      'Sử dụng ngôn ngữ được cài đặt trên điện thoại của bạn';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get languageSpanish => 'Tiếng Tây Ban Nha';

  @override
  String get insightStartFuelingTitle => 'Bắt đầu nạp năng lượng hôm nay';

  @override
  String get insightStartFuelingBody =>
      'Bạn vẫn còn toàn bộ ngân sách calo. Hãy quét hoặc ghi lại bữa ăn đầu tiên để duy trì đúng kế hoạch.';

  @override
  String get insightAboveTargetTitle => 'Vượt mục tiêu hôm nay';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Bạn đã vượt $calories kcal so với mục tiêu hằng ngày. Hãy ăn tối nhẹ hơn hoặc thêm một bài tập ngắn.';
  }

  @override
  String get insightLowProteinTitle => 'Lượng protein vẫn còn thấp';

  @override
  String insightLowProteinBody(int grams) {
    return 'Hôm nay bạn vẫn cần khoảng ${grams}g protein để đạt mục tiêu.';
  }

  @override
  String get insightAlmostThereTitle => 'Sắp đạt mục tiêu';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Hôm nay bạn còn $calories kcal. Một bữa ăn nhẹ cân bằng sẽ rất phù hợp.';
  }

  @override
  String get insightOnTrackTitle => 'Đang đi đúng hướng hôm nay';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Còn $calories kcal và ${grams}g protein để đạt mục tiêu hằng ngày.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Xây dựng nhịp độ hằng tuần';

  @override
  String get insightWeeklyRhythmBody =>
      'Hãy ghi lại các bữa ăn trong suốt tuần để Celia nhận ra các xu hướng và hướng dẫn bạn tốt hơn.';

  @override
  String get insightWeeklyTrendTitle => 'Xu hướng hằng tuần';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Bạn đã ghi lại bữa ăn trong $days trên 7 ngày qua, trung bình $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'gần đúng với mục tiêu hằng ngày';

  @override
  String insightTrendAbove(int delta) {
    return 'trung bình cao hơn mục tiêu $delta kcal';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'trung bình thấp hơn mục tiêu $delta kcal';
  }

  @override
  String get insightsSectionTitle => 'Thông tin chuyên sâu từ Celia';
}
