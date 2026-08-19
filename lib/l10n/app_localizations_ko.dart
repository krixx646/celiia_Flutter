// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Celia 종합 코치';

  @override
  String get actionCancel => '취소';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionEdit => '수정';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionDone => '완료';

  @override
  String get actionClose => '닫기';

  @override
  String get actionContinue => '계속';

  @override
  String get actionSeeAll => '모두 보기';

  @override
  String get actionYesDoIt => '네, 진행할게요';

  @override
  String get actionNotNow => '나중에';

  @override
  String get loadingPreparing => 'Celia 준비 중...';

  @override
  String get loadingGeneric => '불러오는 중...';

  @override
  String get errorGeneric => '문제가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorCanceled => '작업이 취소되었습니다.';

  @override
  String get errorTooManyRequests => '시도 횟수가 너무 많습니다. 1분 후 다시 시도해 주세요.';

  @override
  String get errorNetwork => '인터넷 연결을 확인한 후 다시 시도해 주세요.';

  @override
  String get errorBadCredentials => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get errorEmailInUse => '이 이메일은 이미 사용 중입니다. 대신 로그인해 보세요.';

  @override
  String get errorWeakPassword => '더 강력한 비밀번호를 사용한 후 다시 시도해 주세요.';

  @override
  String get errorInvalidEmail => '유효한 이메일 주소를 입력해 주세요.';

  @override
  String get errorNoPermission => '이 작업을 수행할 권한이 없습니다.';

  @override
  String get errorNotSignedIn => '로그인한 후 다시 시도해 주세요.';

  @override
  String get errorDeleteAccount =>
      'We couldn\'t delete your account. Please try again.';

  @override
  String get errorNoConversation => '계속하려면 새 채팅을 시작하세요.';

  @override
  String get errorNoPlayableVideos => '아직 이 루틴에 재생할 수 있는 동영상이 없습니다.';

  @override
  String get errorLoadRoutines => '지금은 루틴을 불러올 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorLoadSavedRoutines => '지금은 저장된 루틴을 불러올 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorGenerateRoutine => '지금은 루틴을 생성할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorLoadChats => '지금은 저장된 채팅을 불러올 수 없습니다.';

  @override
  String get errorCeliaUnavailable => '지금은 Celia를 사용할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorOpenConversation => '대화를 열 수 없습니다.';

  @override
  String get errorDeleteConversation => '이 대화를 삭제할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorSignIn => '로그인할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorCreateAccount => '계정을 만들 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorSendResetEmail => '비밀번호 재설정 이메일을 보낼 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorSendVerificationEmail => '인증 이메일을 보낼 수 없습니다. 다시 시도해 주세요.';

  @override
  String get errorGoogleSignIn => 'Google 로그인에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get errorAppleSignIn => 'Apple 로그인에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get errorRefreshNutrition => '영양 데이터를 새로 고칠 수 없습니다.';

  @override
  String get errorLoadNutritionProfile => '영양 프로필을 불러올 수 없습니다.';

  @override
  String get startupErrorTitle => '앱을 시작할 수 없습니다';

  @override
  String get startupErrorBody =>
      '앱을 종료한 후 다시 열어 주세요. 문제가 계속되면 고객 지원팀에 문의해 주세요.';

  @override
  String get authTagline => '나의 피트니스 친구';

  @override
  String get authSignUp => '회원가입';

  @override
  String get authLogIn => '로그인';

  @override
  String authVersion(String version) {
    return '버전 $version';
  }

  @override
  String get authForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get authOr => '또는';

  @override
  String get authContinueWithGoogle => 'Google로 계속하기';

  @override
  String get authContinueWithApple => 'Apple로 계속하기';

  @override
  String get authAuthenticating => '인증 중...';

  @override
  String get authEnterYourName => '이름을 입력해 주세요.';

  @override
  String get authNeedAccount => '계정이 없나요? 회원가입';

  @override
  String get authHaveAccount => '이미 계정이 있나요? 로그인';

  @override
  String get authFieldName => '이름';

  @override
  String get authFieldEmail => '이메일';

  @override
  String get authFieldPassword => '비밀번호';

  @override
  String get verifyEmailTitle => '이메일 인증';

  @override
  String get verifyEmailHeading => '받은편지함을 확인하세요';

  @override
  String get verifyEmailBody => '인증 링크를 이메일로 보냈습니다.';

  @override
  String get verifyEmailSent => '인증 이메일을 보냈습니다!';

  @override
  String get verifyEmailContinue => '인증을 완료했어요. 계속하기';

  @override
  String get verifyEmailSignOut => '로그아웃';

  @override
  String get verifyEmailSending => '전송 중...';

  @override
  String get verifyEmailResend => '인증 이메일 다시 보내기';

  @override
  String verifyEmailResendIn(int seconds) {
    return '$seconds초 후 다시 보내기';
  }

  @override
  String verifyEmailAddress(String email) {
    return '이메일: $email';
  }

  @override
  String get forgotPasswordTitle => '비밀번호를 잊으셨나요?';

  @override
  String get forgotPasswordBody => '비밀번호 재설정 링크를 받을 이메일을 입력하세요.';

  @override
  String get forgotPasswordEmptyEmail => '이메일을 입력하세요';

  @override
  String get forgotPasswordSent => '비밀번호 재설정 이메일을 보냈습니다.';

  @override
  String get forgotPasswordSend => '재설정 링크 보내기';

  @override
  String get forgotPasswordSending => '전송 중...';

  @override
  String get nameSetupTitle => 'Celia가 어떻게 불러드릴까요?';

  @override
  String get nameSetupBody => '코칭을 더 개인화할 수 있도록 앱 전체에서 이름을 사용합니다.';

  @override
  String get nameSetupSaveFailed => '이름을 저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get homeGoodMorning => '좋은 아침이에요,';

  @override
  String get homeCeliaActive => 'CELIA 활성화';

  @override
  String get homeGenerateRoutine => 'AI로\n맞춤\n루틴 생성';

  @override
  String get homeCreateRoutine => '루틴 만들기';

  @override
  String get homeQuickActions => '빠른 작업';

  @override
  String get homeUpNext => '다음 일정';

  @override
  String get homeNoUpcoming => '예정된 루틴이 아직 없습니다.\n루틴을 만들거나 라이브러리를 둘러보세요.';

  @override
  String get homeChatWithCelia => 'Celia와 채팅';

  @override
  String get homeChatSubtitle => '운동 자세나 식단에 대해 물어보세요';

  @override
  String get homeScanMeal => '식사 스캔';

  @override
  String get homeScanMealSubtitle => '음식 및 칼로리 확인';

  @override
  String get homeNutrition => '영양';

  @override
  String get homeNutritionSubtitle => '칼로리, 매크로 및 식사 확인';

  @override
  String get homeBrowseLibrary => '라이브러리\n둘러보기';

  @override
  String get homeTrackProgress => '진행 상황\n추적';

  @override
  String get chatTitle => '코치 Celia';

  @override
  String get chatEmptyPrompt => '오늘 어떻게 도와드릴까요?\n함께 건강해져요.';

  @override
  String get chatYourChats => '내 채팅';

  @override
  String get chatNoSavedChats => '저장된 채팅이 아직 없습니다.';

  @override
  String get chatHistory => '채팅 기록';

  @override
  String get chatNew => '새 채팅';

  @override
  String get chatOpening => '채팅 여는 중...';

  @override
  String get chatScanAMeal => '식사 스캔하기';

  @override
  String get chatInputHint => '운동에 대해 Celia에게 무엇이든 물어보세요...';

  @override
  String get chatCouldNotOpenRoutine => '해당 루틴을 열 수 없습니다';

  @override
  String get chatThisRoutine => '이 루틴';

  @override
  String get chatThisMeal => '이 식사';

  @override
  String get chatYourRoutine => '내 루틴';

  @override
  String chatMoreExercises(int count) {
    return '+ $count개 더';
  }

  @override
  String get chatEmptySubtitle => '운동, 음식 또는 진행 상황에 대해 물어보세요.';

  @override
  String chatLoggedToday(int calories) {
    return '오늘 $calories kcal를 기록했습니다.';
  }

  @override
  String get chatSuggestionHiit => '20분 HIIT 루틴을 만들어줘';

  @override
  String get chatSuggestionDinner => '오늘 저녁에는 무엇을 먹을까요?';

  @override
  String get chatSuggestionProgress => '이번 주 진행 상황은 어떤가요?';

  @override
  String get chatSuggestionIngredients => '닭고기, 쌀, 시금치가 있어요';

  @override
  String get chatJustNow => '방금 전';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days일 전';
  }

  @override
  String get chatRoutineAlreadySaved => '이미 라이브러리에 있습니다 — 탭하여 열기';

  @override
  String get chatRoutineTapToOpen => '탭하여 열기';

  @override
  String get chatToolCancelled => '취소됨';

  @override
  String chatToolFailed(String label) {
    return '$label — 작업을 완료하지 못했습니다';
  }

  @override
  String get chatToolRoutineSaveFailed => '루틴을 저장하지 못했습니다';

  @override
  String get chatToolRoutineSaved => '라이브러리에 저장했습니다';

  @override
  String get chatToolMealLogged => '오늘 기록에 추가했습니다';

  @override
  String get chatToolRoutineAdded => '라이브러리에 추가했습니다';

  @override
  String get activityCheckingProgress => '진행 상황을 확인하는 중';

  @override
  String get activityCheckingNutrition => '오늘 먹은 음식을 확인하는 중';

  @override
  String get activityReviewingMeals => '최근 식사를 검토하는 중';

  @override
  String get activityLookingAtRoutines => '루틴을 확인하는 중';

  @override
  String get activityReadingRoutine => '해당 루틴을 읽는 중';

  @override
  String get activitySearchingLibrary => '운동 라이브러리를 검색하는 중';

  @override
  String get activityBuildingRoutine => '루틴을 만드는 중';

  @override
  String get activityLoggingMeal => '식사를 기록하는 중';

  @override
  String get activitySavingToLibrary => '라이브러리에 저장하는 중';

  @override
  String get activityWorking => '처리 중';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Save \"$name\" with $count exercises to your library?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '\"$name\"을(를) 라이브러리에 저장할까요?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '\"$name\"을(를) $calories kcal로 기록할까요?';
  }

  @override
  String approvalLogMeal(String name) {
    return '\"$name\"을(를) 기록할까요?';
  }

  @override
  String get approvalAddRoutine => '이 루틴을 라이브러리에 추가할까요?';

  @override
  String get approvalGeneric => 'Celia가 이 작업을 수행하도록 허용할까요?';

  @override
  String get libraryTitle => '루틴 라이브러리';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count단계',
      one: '$count단계',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => '아직 루틴이 없습니다';

  @override
  String get libraryEmptyBody => '관리자 대시보드에서 루틴을 만들고 게시하세요.';

  @override
  String get libraryLoadFailed => '루틴을 불러오지 못했습니다';

  @override
  String get routineStartWorkout => '운동 시작';

  @override
  String get routineNoSteps => '사용 가능한 단계가 없습니다';

  @override
  String get routineNoVideoForStep => '이 단계에 사용할 수 있는 동영상이 없습니다';

  @override
  String get routineVideoProcessing => '동영상을 처리하는 중입니다. 나중에 다시 시도해 주세요.';

  @override
  String get routineMissingPlaybackUrl => '이 동영상의 재생 URL이 없습니다';

  @override
  String get routinePreviewBanner => '미리보기 — 전체 동영상은 곧 제공됩니다';

  @override
  String get routinePreview => '미리보기';

  @override
  String get routineDetails => '세부 정보';

  @override
  String get routineNotFound => '루틴을 찾을 수 없습니다';

  @override
  String routineCompletedTimes(int count) {
    return '$count회 완료';
  }

  @override
  String get playerVideoUnavailable => '이 동영상은 현재 사용할 수 없습니다.';

  @override
  String get playerSteps => '단계';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => '재생할 수 있는 동영상이 없습니다';

  @override
  String get playerWorkoutComplete => '운동 완료!';

  @override
  String get playerSavingStreak => '연속 기록에 저장하는 중…';

  @override
  String get playerSavedStreak => '연속 기록에 저장했습니다';

  @override
  String get playerRetrySave => '다시 저장';

  @override
  String get playerReplay => '다시 재생';

  @override
  String get playerNotReady => '플레이어가 준비되지 않았습니다';

  @override
  String get playerPreviewUnavailable => '미리보기를 현재 사용할 수 없습니다.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return '클립 $current/$total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => '동영상 로드 중 오류가 발생했습니다';

  @override
  String get playerLoadingVideo => '동영상 로드 중...';

  @override
  String get playerFailedToLoadVideo => '동영상을 로드하지 못했습니다';

  @override
  String get playerNotInitialized => '동영상 플레이어가 초기화되지 않았습니다';

  @override
  String guidedExerciseCounter(int current, int total) {
    return '운동 $current/$total';
  }

  @override
  String get guidedGetReady => '준비하세요';

  @override
  String guidedSetOf(int current, int total) {
    return '세트 $current/$total';
  }

  @override
  String get guidedRest => '휴식';

  @override
  String get guidedSkipRest => '휴식 건너뛰기';

  @override
  String get guidedPaused => '일시정지됨';

  @override
  String get guidedResume => '재개';

  @override
  String get guidedWorkoutComplete => '운동 완료';

  @override
  String get guidedEndTitle => '운동을 종료할까요?';

  @override
  String get guidedEndBody => '이번 세션의 진행 상황은 저장되지 않습니다.';

  @override
  String get guidedKeepGoing => '계속하기';

  @override
  String get guidedEnd => '종료';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count회',
      one: '$count회',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'AI로 루틴 생성';

  @override
  String get generateSheetPrompt => '어떤 운동을 원하시나요?';

  @override
  String get generateSheetHint =>
      '예: \"잠을 깨우는 간단한 아침 스트레칭\" 또는 \"초보자를 위한 전신 근력 운동\"';

  @override
  String get generateSheetDuration => '운동 시간';

  @override
  String generateSheetMinutes(int count) {
    return '$count분';
  }

  @override
  String get generateSheetDifficulty => '난이도';

  @override
  String get generateSheetEquipment => '사용 가능한 장비';

  @override
  String get generateSheetGenerating => '생성 중...';

  @override
  String get generateSheetSubmit => '루틴 생성';

  @override
  String get generateSheetDescribeFirst => '원하는 운동을 설명해 주세요';

  @override
  String generateSheetAlreadyExists(String title) {
    return '이미 있습니다: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return '생성됨: $title';
  }

  @override
  String get generateSheetFailed => '루틴을 생성하지 못했습니다';

  @override
  String get guidedNoExercises => '이 루틴에는 아직 운동이 없습니다.';

  @override
  String get guidedStartFailed => '지금은 이 운동을 시작할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get guidedSaveFailed => '이 운동을 저장하지 못했습니다. 연속 기록을 업데이트하려면 재시도를 탭하세요.';

  @override
  String guidedOfReps(int count) {
    return '$count회 중';
  }

  @override
  String get guidedHold => '유지';

  @override
  String get guidedNextSet => '다음 세트';

  @override
  String get guidedUpNext => '다음 운동';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds초 유지';
  }

  @override
  String coachGetReady(String exercise) {
    return '준비하세요. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return '시작합니다. $count회.';
  }

  @override
  String coachStartHold(int seconds) {
    return '$seconds초 동안 유지하세요.';
  }

  @override
  String coachRest(String exercise) {
    return '휴식하세요. 다음 운동: $exercise';
  }

  @override
  String get coachRestShort => '휴식하세요.';

  @override
  String get coachComplete => '잘했어요. 운동이 완료되었습니다.';

  @override
  String coachRep(int count) {
    return '$count';
  }

  @override
  String coachCountdown(int seconds) {
    return '$seconds';
  }

  @override
  String get playerNoVideosInRoutine => '이 루틴에서 재생할 수 있는 동영상을 찾지 못했습니다.';

  @override
  String get playerLoadRoutineFailed => '지금은 이 루틴을 불러올 수 없습니다. 다시 시도해 주세요.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return '\"$title\"을(를) 불러오지 못했습니다. 건너뜁니다…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return '\"$title\"을(를) 불러오지 못했습니다.';
  }

  @override
  String get playerSaveCompletionFailed =>
      '완료 기록을 저장하지 못했습니다. 연속 기록을 업데이트하려면 재시도를 탭하세요.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • 미리보기';
  }

  @override
  String get playerNoVideosReady => '이 루틴에는 아직 재생할 수 있는 동영상이 없습니다.';

  @override
  String get playerPlaybackFailed => '지금은 이 동영상을 재생할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get libraryTabCurated => '엄선됨';

  @override
  String get libraryTabAiGenerated => 'AI 생성';

  @override
  String get profileSavedRoutines => '저장된 루틴';

  @override
  String get savedRoutinesNoFavorites => '아직 즐겨찾기한 루틴이 없습니다.';

  @override
  String get savedRoutinesEmpty => '아직 저장된 루틴이 없습니다.';

  @override
  String get actionFavorite => '즐겨찾기';

  @override
  String get actionUnfavorite => '즐겨찾기 해제';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours시간';
  }

  @override
  String get difficultyEasy => '쉬움';

  @override
  String get difficultyMedium => '보통';

  @override
  String get difficultyHard => '어려움';

  @override
  String get categoryStrength => '근력';

  @override
  String get categoryCardio => '유산소';

  @override
  String get categoryFlexibility => '유연성';

  @override
  String get categoryMindfulness => '마음챙김';

  @override
  String get categoryDance => '댄스';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => '요가';

  @override
  String get categoryCustom => '맞춤';

  @override
  String get navHome => '홈';

  @override
  String get navLibrary => '라이브러리';

  @override
  String get navChat => '채팅';

  @override
  String get navProfile => '프로필';

  @override
  String get equipmentNone => '없음';

  @override
  String get equipmentDumbbells => '덤벨';

  @override
  String get equipmentResistanceBands => '저항 밴드';

  @override
  String get equipmentYogaMat => '요가 매트';

  @override
  String get equipmentKettlebell => '케틀벨';

  @override
  String get equipmentPullUpBar => '풀업 바';

  @override
  String get equipmentJumpRope => '줄넘기';

  @override
  String get nutritionTitle => '영양';

  @override
  String get nutritionSubtitle => '칼로리, 매크로 및 식사 기록';

  @override
  String get nutritionSetGoalsTitle => '일일 영양 목표 설정';

  @override
  String get nutritionSetGoalsBody =>
      '체중, 키, 나이, 성별을 입력하면 Celia가 매일 섭취해야 할 칼로리와 영양소를 계산해 드려요.';

  @override
  String get nutritionSetUpGoals => '목표 설정';

  @override
  String get nutritionDailyTarget => '일일 목표';

  @override
  String get nutritionDailyGoals => '일일 목표';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return '단백질 ${protein}g · 탄수화물 ${carbs}g · 지방 ${fat}g';
  }

  @override
  String get nutritionToday => '오늘';

  @override
  String get nutritionMealHistory => '식사 기록';

  @override
  String get nutritionCeliaInsights => 'Celia 인사이트';

  @override
  String get nutritionWeeklyTrend => '주간 추이';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count끼',
      one: '$count끼',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count끼',
      one: '$count끼',
    );
    return '목표 $target kcal 중 • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => '월,화,수,목,금,토,일';

  @override
  String get nutritionFieldFoodName => '음식 이름';

  @override
  String get nutritionFieldGrams => '그램';

  @override
  String get nutritionFieldCalories => '칼로리';

  @override
  String get scannerStatusAnalyzing => '분석 중...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => '음식 이름';

  @override
  String get scannerFieldGrams => '그램';

  @override
  String get scannerFieldCalories => '칼로리';

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
    return '오늘 $calories kcal 및 단백질 ${grams}g 남음';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '일일 목표보다 $calories kcal 초과';
  }

  @override
  String get scannerButtonAnalyzing => '분석 중';

  @override
  String get scannerButtonQuotaNeeded => '할당량 필요';

  @override
  String get scannerButtonScanNow => '지금 스캔';

  @override
  String get scannerButtonLogging => '기록 중';

  @override
  String get scannerButtonLogMeal => '식사 기록';

  @override
  String get scannerNoClearFood =>
      '아직 음식이 명확하게 감지되지 않았어요. 조명을 개선하거나 더 가까이 이동해 보세요.';

  @override
  String get scannerErrorCameraPermission => '식사를 스캔하려면 카메라 권한이 필요해요.';

  @override
  String get scannerErrorBackendMissing => '칼로리 스캐너 백엔드가 아직 설정되지 않았어요.';

  @override
  String get scannerErrorApiKeyInvalid =>
      '칼로리 스캔용 OpenAI API 키가 유효하지 않아요. 백엔드 환경에서 키를 교체하고 재배포한 후 다시 시도하세요.';

  @override
  String get scannerErrorApiKeyMissing =>
      '칼로리 스캔을 위해 OpenAI API 키가 필요해요. Vercel에 키를 추가하고 재배포한 후 다시 시도하세요.';

  @override
  String get scannerErrorQuotaExhausted =>
      '칼로리 스캔에 사용할 OpenAI 크레딧이 소진되었어요. API 크레딧을 추가하거나 결제 한도를 높인 후 다시 시도하세요.';

  @override
  String get scannerErrorTimeout =>
      'Celia가 이 식사를 분석하는 데 시간이 더 필요해요. 카메라를 steady하게 유지하고 다시 스캔하세요.';

  @override
  String get scannerErrorNotSignedIn => '식사를 스캔하기 전에 로그인해 주세요.';

  @override
  String get scannerErrorMealTableMissing =>
      '식사 기록 테이블이 아직 준비되지 않았어요. 스캔 결과는 계속 확인할 수 있어요.';

  @override
  String get scannerErrorGeneric =>
      'Celia가 아직 이 식사를 분석하지 못했어요. 카메라를 steady하게 유지하고 음식이 중앙에 오도록 한 뒤 다시 스캔하세요.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목',
      one: '$count개 항목',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => '식사 세부 정보';

  @override
  String get nutritionFoodItems => '음식 항목';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem => '식사에는 음식 항목이 하나 이상 필요합니다.';

  @override
  String get nutritionMealUpdated => '식사가 업데이트되었습니다';

  @override
  String nutritionUpdateFailed(String error) {
    return '식사를 업데이트할 수 없습니다: $error';
  }

  @override
  String get nutritionDeleteMealTitle => '식사를 삭제할까요?';

  @override
  String get nutritionDeleteMealBody => '영양 기록에서 이 식사가 삭제됩니다.';

  @override
  String get nutritionDeleteMeal => '식사 삭제';

  @override
  String nutritionDeleteFailed(String error) {
    return '식사를 삭제할 수 없습니다: $error';
  }

  @override
  String get nutritionEditFood => '음식 수정';

  @override
  String get nutritionSaveFood => '음식 저장';

  @override
  String get nutritionLoadFailed => '식사를 불러올 수 없습니다';

  @override
  String get nutritionLoadFailedBody => '당겨서 새로고침하거나 백엔드 연결을 확인하세요.';

  @override
  String get nutritionNoMeals => '아직 기록된 식사가 없습니다';

  @override
  String get nutritionNoMealsBody => '첫 식사를 스캔하면 Celia가 영양 기록을 만들어 드립니다.';

  @override
  String get progressToday => '오늘';

  @override
  String get progressSetGoals => '영양 목표를 설정하면 칼로리와 매크로 추적을 이용할 수 있습니다.';

  @override
  String progressOfTarget(int target) {
    return '$target kcal 중';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal 초과';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal 남음';
  }

  @override
  String get progressProtein => '단백질';

  @override
  String get progressCarbs => '탄수화물';

  @override
  String get progressFat => '지방';

  @override
  String get scannerEditItem => '음식 항목 수정';

  @override
  String get scannerSaveChanges => '변경 사항 저장';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return '신뢰도 $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count개 항목이 이 식사 기록에 포함됨';
  }

  @override
  String get scannerIfYouLog => '이 식사를 기록하면';

  @override
  String scannerAfterLogging(int after, int target) {
    return '오늘 $after / $target kcal';
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
  String get scannerNoMealDetected => '감지된 식사가 없습니다';

  @override
  String onboardingWelcome(String name) {
    return '환영합니다, $name님';
  }

  @override
  String get onboardingGender => '성별';

  @override
  String get onboardingCalculateGoals => '내 목표 계산하기';

  @override
  String get onboardingScanFirstMeal => '첫 식사 스캔하기';

  @override
  String get onboardingExploreRoutines => '루틴 둘러보기';

  @override
  String get onboardingGoHome => '홈으로 가기';

  @override
  String get onboardingDailyTargets => '일일 목표';

  @override
  String onboardingProtein(int grams) {
    return '단백질 ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return '단백질 ${protein}g • 탄수화물 ${carbs}g • 지방 ${fat}g';
  }

  @override
  String get onboardingTargetsReady => '일일 영양 목표가 준비되었습니다. 시작 방법을 선택하세요.';

  @override
  String get onboardingWeightKg => '체중 (kg)';

  @override
  String get onboardingHeightCm => '키 (cm)';

  @override
  String get onboardingAge => '나이';

  @override
  String get onboardingInvalidWeight => '유효한 체중(kg)을 입력하세요.';

  @override
  String get onboardingInvalidHeight => '유효한 키(cm)를 입력하세요.';

  @override
  String get onboardingInvalidAge => '13세에서 100세 사이의 유효한 나이를 입력하세요.';

  @override
  String get onboardingSaveFailed => '영양 프로필을 저장할 수 없습니다.';

  @override
  String get genderMale => '남성';

  @override
  String get genderFemale => '여성';

  @override
  String get genderOther => '기타';

  @override
  String get nutritionSetupTitle => '일일 영양 목표';

  @override
  String get nutritionSetupBody =>
      'Celia가 일일 칼로리와 매크로를 계산할 수 있도록 신체 정보를 알려주세요.';

  @override
  String get nutritionSetupGender => '성별';

  @override
  String get nutritionSetupFootnote =>
      'Celia는 체중, 키, 나이, 성별을 사용하고 보통 활동 수준을 기준으로 일일 칼로리와 매크로 목표를 추정합니다.';

  @override
  String get nutritionSetupSave => '목표 저장';

  @override
  String get profileTitle => '프로필';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => '멤버';

  @override
  String get profileAccount => '계정';

  @override
  String profileSignedInAs(String email) {
    return '로그인한 계정:\n$email';
  }

  @override
  String get profileUnknownEmail => '알 수 없음';

  @override
  String get profileDarkMode => '다크 모드';

  @override
  String get profileLanguage => '언어';

  @override
  String get profileLogOutTitle => '로그아웃할까요?';

  @override
  String get profileLogOutBody => '정말 로그아웃하시겠어요?';

  @override
  String get profileLogOut => '로그아웃';

  @override
  String get profileLogOutButton => '로그아웃';

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
  String get profileFavoriteRoutines => '즐겨찾는 루틴';

  @override
  String get profileSubscription => '구독';

  @override
  String get profileNutrition => '영양';

  @override
  String get profileHelpSupport => '도움말 및 지원';

  @override
  String get profileFriend => '친구';

  @override
  String get profileStatSaved => '저장됨';

  @override
  String get profileStatStreak => '연속 기록';

  @override
  String get profileStatWorkouts => '운동';

  @override
  String get streakDayOneStarted => '1일 차를 시작했어요 — 연속 기록을 이어가려면 내일 다시 방문하세요.';

  @override
  String get streakRebuild =>
      '어제 활동했어요 — 오늘 식사를 기록하거나 운동을 완료해 연속 기록을 다시 이어가세요.';

  @override
  String get streakStart => '식사를 기록하거나 운동을 완료해 활동 연속 기록을 시작하세요.';

  @override
  String streakLongRun(int days) {
    return '$days일 연속 기록! 계속 꾸준히 참여하세요 — Celia가 꾸준함을 기록하고 있어요.';
  }

  @override
  String streakBothLogged(int days) {
    return '$days일 연속 기록 — 오늘 운동과 영양을 모두 기록했어요.';
  }

  @override
  String streakNeedWorkout(int days) {
    return '$days일 연속 기록이에요. 짧은 운동으로 오늘을 완성해 보세요.';
  }

  @override
  String streakNeedMeal(int days) {
    return '$days일 연속 기록이에요. 식사를 기록해 영양 섭취를 추적하세요.';
  }

  @override
  String streakStayActive(int days) {
    return '$days일 연속 기록 — 오늘도 활동을 이어가세요.';
  }

  @override
  String get editProfileTitle => '프로필 편집';

  @override
  String get editProfileName => '이름';

  @override
  String get editProfileFootnote => '변경 사항은 계정에 저장되며 홈/프로필에 표시됩니다.';

  @override
  String get editProfileSaveFailed => '프로필을 업데이트할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystem => '기기 언어';

  @override
  String get languageSystemSubtitle => '휴대전화에 설정된 언어를 사용합니다';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get insightStartFuelingTitle => '오늘부터 영양을 채워 보세요';

  @override
  String get insightStartFuelingBody =>
      '아직 일일 칼로리 예산을 모두 사용할 수 있어요. 첫 식사를 스캔하거나 기록해 목표를 지켜 보세요.';

  @override
  String get insightAboveTargetTitle => '오늘 목표 초과';

  @override
  String insightAboveTargetBody(int calories) {
    return '일일 목표보다 $calories kcal 초과했어요. 저녁을 가볍게 먹거나 짧은 운동을 추가해 보세요.';
  }

  @override
  String get insightLowProteinTitle => '단백질이 아직 부족해요';

  @override
  String insightLowProteinBody(int grams) {
    return '오늘 목표를 달성하려면 단백질이 약 ${grams}g 더 필요해요.';
  }

  @override
  String get insightAlmostThereTitle => '목표에 거의 도달했어요';

  @override
  String insightAlmostThereBody(int calories) {
    return '오늘 $calories kcal가 남았어요. 균형 잡힌 간식이 잘 맞겠어요.';
  }

  @override
  String get insightOnTrackTitle => '오늘 목표를 잘 지키고 있어요';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return '일일 목표까지 $calories kcal와 단백질 ${grams}g이 남았어요.';
  }

  @override
  String get insightWeeklyRhythmTitle => '주간 리듬을 만들어 보세요';

  @override
  String get insightWeeklyRhythmBody =>
      '일주일 동안 식사를 기록하면 Celia가 패턴을 파악해 더 나은 코칭을 제공할 수 있어요.';

  @override
  String get insightWeeklyTrendTitle => '주간 추이';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return '지난 7일 중 $days일에 식사를 기록했으며, 평균 $average kcal를 섭취했어요 — $direction.';
  }

  @override
  String get insightTrendOnTarget => '일일 목표와 거의 같아요';

  @override
  String insightTrendAbove(int delta) {
    return '평균적으로 목표보다 $delta kcal 높아요';
  }

  @override
  String insightTrendBelow(int delta) {
    return '평균적으로 목표보다 $delta kcal 낮아요';
  }

  @override
  String get insightsSectionTitle => 'Celia 인사이트';
}
