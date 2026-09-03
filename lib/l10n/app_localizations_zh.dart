// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Celia 综合教练';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRetry => '重试';

  @override
  String get actionDone => '完成';

  @override
  String get actionClose => '关闭';

  @override
  String get actionContinue => '继续';

  @override
  String get actionSeeAll => '查看全部';

  @override
  String get actionYesDoIt => '是，就这样';

  @override
  String get actionNotNow => '暂时不要';

  @override
  String get loadingPreparing => '正在准备 Celia...';

  @override
  String get loadingGeneric => '加载中...';

  @override
  String get errorGeneric => '出了点问题。请重试。';

  @override
  String get errorCanceled => '操作已取消。';

  @override
  String get errorTooManyRequests => '尝试次数过多。请等待一分钟后重试。';

  @override
  String get errorNetwork => '请检查网络连接后重试。';

  @override
  String get errorBadCredentials => '邮箱或密码不正确。';

  @override
  String get errorEmailInUse => '该邮箱已被使用。请尝试直接登录。';

  @override
  String get errorWeakPassword => '请使用更强的密码后重试。';

  @override
  String get errorInvalidEmail => '请输入有效的邮箱地址。';

  @override
  String get errorNoPermission => '你没有执行此操作的权限。';

  @override
  String get errorNotSignedIn => '请登录后重试。';

  @override
  String get errorDeleteAccount => '无法删除您的账户，请重试。';

  @override
  String get errorNoConversation => '开始新聊天以继续。';

  @override
  String get errorNoPlayableVideos => '此训练暂时没有可播放的视频。';

  @override
  String get errorLoadRoutines => '暂时无法加载训练计划。请重试。';

  @override
  String get errorLoadSavedRoutines => '暂时无法加载已保存的训练计划。请重试。';

  @override
  String get errorGenerateRoutine => '暂时无法生成训练计划。请重试。';

  @override
  String get errorLoadChats => '暂时无法加载已保存的聊天记录。';

  @override
  String get errorCeliaUnavailable => 'Celia 当前不可用。请重试。';

  @override
  String get errorOpenConversation => '无法打开该对话。';

  @override
  String get errorDeleteConversation => '无法删除此对话。请重试。';

  @override
  String get errorSignIn => '无法登录。请重试。';

  @override
  String get errorCreateAccount => '无法创建账户。请重试。';

  @override
  String get errorSendResetEmail => '无法发送重置邮件。请重试。';

  @override
  String get errorSendVerificationEmail => '无法发送验证邮件。请重试。';

  @override
  String get errorGoogleSignIn => 'Google 登录失败。请重试。';

  @override
  String get errorAppleSignIn => 'Apple 登录失败。请重试。';

  @override
  String get errorRefreshNutrition => '无法刷新营养数据。';

  @override
  String get errorLoadNutritionProfile => '无法加载你的营养档案。';

  @override
  String get startupErrorTitle => '无法启动应用';

  @override
  String get startupErrorBody => '请关闭并重新打开应用。如果问题仍然存在，请联系支持团队。';

  @override
  String get authTagline => '你的健身伙伴';

  @override
  String get authSignUp => '注册';

  @override
  String get authLogIn => '登录';

  @override
  String authVersion(String version) {
    return '版本 $version';
  }

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authOr => '或';

  @override
  String get authContinueWithGoogle => '继续使用 Google';

  @override
  String get authContinueWithApple => '继续使用 Apple';

  @override
  String get authAuthenticating => '验证中...';

  @override
  String get authEnterYourName => '请输入你的姓名。';

  @override
  String get authNeedAccount => '还没有账户？注册';

  @override
  String get authHaveAccount => '已有账户？登录';

  @override
  String get authFieldName => '你的姓名';

  @override
  String get authFieldEmail => '邮箱';

  @override
  String get authFieldPassword => '密码';

  @override
  String get verifyEmailTitle => '验证你的邮箱';

  @override
  String get verifyEmailHeading => '查看收件箱';

  @override
  String get verifyEmailBody => '验证链接已发送到你的邮箱。';

  @override
  String get verifyEmailSent => '验证邮件已发送！';

  @override
  String get verifyEmailContinue => '我已验证，继续';

  @override
  String get verifyEmailSignOut => '退出登录';

  @override
  String get verifyEmailSending => '发送中...';

  @override
  String get verifyEmailResend => '重新发送验证邮件';

  @override
  String verifyEmailResendIn(int seconds) {
    return '$seconds秒后重新发送';
  }

  @override
  String verifyEmailAddress(String email) {
    return '邮箱：$email';
  }

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get forgotPasswordBody => '输入你的邮箱以接收密码重置链接。';

  @override
  String get forgotPasswordEmptyEmail => '请输入邮箱';

  @override
  String get forgotPasswordSent => '密码重置邮件已发送。';

  @override
  String get forgotPasswordSend => '发送重置链接';

  @override
  String get forgotPasswordSending => '发送中...';

  @override
  String get nameSetupTitle => 'Celia 应该怎么称呼你？';

  @override
  String get nameSetupBody => '我们会在应用中使用你的名字，让指导更贴心。';

  @override
  String get nameSetupSaveFailed => '无法保存你的名字。请重试。';

  @override
  String get homeGoodMorning => '早上好，';

  @override
  String get homeCeliaActive => 'CELIA 已激活';

  @override
  String get homeGenerateRoutine => '使用 AI 生成\n你的个性化\n训练计划';

  @override
  String get homeCreateRoutine => '创建训练计划';

  @override
  String get homeQuickActions => '快捷操作';

  @override
  String get homeUpNext => '接下来';

  @override
  String get homeNoUpcoming => '暂时没有即将开始的训练计划。\n创建一个或浏览训练库。';

  @override
  String get homeChatWithCelia => '与 Celia 聊天';

  @override
  String get homeChatSubtitle => '咨询动作姿势或饮食';

  @override
  String get homeScanMeal => '扫描餐食';

  @override
  String get homeScanMealSubtitle => '识别食物和热量';

  @override
  String get homeNutrition => '营养';

  @override
  String get homeNutritionSubtitle => '查看热量、宏量营养素和餐食';

  @override
  String get homeBrowseLibrary => '浏览\n训练库';

  @override
  String get homeTrackProgress => '追踪\n进度';

  @override
  String get chatTitle => 'Celia 教练';

  @override
  String get chatEmptyPrompt => '今天想怎样\n开始健身？';

  @override
  String get chatYourChats => '你的聊天';

  @override
  String get chatNoSavedChats => '暂无已保存的聊天。';

  @override
  String get chatHistory => '聊天记录';

  @override
  String get chatNew => '新聊天';

  @override
  String get chatOpening => '正在打开聊天...';

  @override
  String get chatScanAMeal => '扫描餐食';

  @override
  String get chatInputHint => '向 Celia 咨询任何训练问题...';

  @override
  String get chatMicTooltip => '按住说话';

  @override
  String get chatListening => '正在聆听…';

  @override
  String get chatMicDenied => '需要麦克风权限才能与 Celia 对话。';

  @override
  String get chatSpeechUnavailable => '此设备不支持语音识别。';

  @override
  String get avatarModeReady => '准备就绪';

  @override
  String get avatarModeThinking => '思考中…';

  @override
  String get avatarModeSpeaking => '说话中…';

  @override
  String get avatarModeHoldToTalk => '按住说话';

  @override
  String get avatarModeExit => '手动模式';

  @override
  String get avatarModeConfirmTitle => '与 Celia 确认？';

  @override
  String get avatarModeConfirmBody => 'Celia 想保存内容。允许吗？';

  @override
  String get avatarModeConfirmYes => '允许';

  @override
  String get chatCouldNotOpenRoutine => '无法打开该训练计划';

  @override
  String get chatThisRoutine => '该训练计划';

  @override
  String get chatThisMeal => '这餐';

  @override
  String get chatYourRoutine => '你的训练计划';

  @override
  String chatMoreExercises(int count) {
    return '+ $count 个';
  }

  @override
  String get chatEmptySubtitle => '咨询你的训练、饮食或进度。';

  @override
  String chatLoggedToday(int calories) {
    return '你今天已记录 $calories kcal。';
  }

  @override
  String get chatSuggestionHiit => '为我制定一个 20 分钟的 HIIT 训练计划';

  @override
  String get chatSuggestionDinner => '今晚吃什么好？';

  @override
  String get chatSuggestionProgress => '我这周表现如何？';

  @override
  String get chatSuggestionIngredients => '我有鸡肉、米饭和菠菜';

  @override
  String get chatJustNow => '刚刚';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes分钟前';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours小时前';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days天前';
  }

  @override
  String get chatRoutineAlreadySaved => '已在你的训练库中——点击打开';

  @override
  String get chatRoutineTapToOpen => '点击打开';

  @override
  String get chatToolCancelled => '已取消';

  @override
  String chatToolFailed(String label) {
    return '$label — 操作失败';
  }

  @override
  String get chatToolRoutineSaveFailed => '无法保存训练计划';

  @override
  String get chatToolRoutineSaved => '已保存到你的库中';

  @override
  String get chatToolMealLogged => '已添加到今天的记录';

  @override
  String get chatToolRoutineAdded => '已添加到你的库中';

  @override
  String get activityCheckingProgress => '正在查看你的进度';

  @override
  String get activityCheckingNutrition => '正在查看你今天吃了什么';

  @override
  String get activityReviewingMeals => '正在查看你最近的餐食';

  @override
  String get activityLookingAtRoutines => '正在查看你的训练计划';

  @override
  String get activityReadingRoutine => '正在读取该训练计划';

  @override
  String get activitySearchingLibrary => '正在搜索训练库';

  @override
  String get activityBuildingRoutine => '正在制定训练计划';

  @override
  String get activityLoggingMeal => '正在记录你的餐食';

  @override
  String get activitySavingToLibrary => '正在保存到你的库中';

  @override
  String get activityWorking => '正在处理';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Save \"$name\" with $count exercises to your library?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '要将“$name”保存到你的库中吗？';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '要记录“$name”（$calories kcal）吗？';
  }

  @override
  String approvalLogMeal(String name) {
    return '要记录“$name”吗？';
  }

  @override
  String get approvalAddRoutine => '要将此训练计划添加到你的库中吗？';

  @override
  String get approvalGeneric => '允许 Celia 执行此操作吗？';

  @override
  String get libraryTitle => '训练计划库';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个步骤',
      one: '$count 个步骤',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => '还没有训练计划';

  @override
  String get libraryEmptyBody => '在管理后台创建并发布训练计划。';

  @override
  String get libraryLoadFailed => '加载训练计划失败';

  @override
  String get routineStartWorkout => '开始训练';

  @override
  String get routineNoSteps => '没有可用步骤';

  @override
  String get routineNoVideoForStep => '此步骤没有可用视频';

  @override
  String get routineVideoProcessing => '视频仍在处理中，请稍后再试。';

  @override
  String get routineMissingPlaybackUrl => '此视频缺少播放链接';

  @override
  String get routinePreviewBanner => '预览 — 完整视频即将推出';

  @override
  String get routinePreview => '预览';

  @override
  String get routineDetails => '详情';

  @override
  String get routineNotFound => '未找到训练计划';

  @override
  String routineCompletedTimes(int count) {
    return '已完成 $count 次';
  }

  @override
  String get playerVideoUnavailable => '此视频目前不可用。';

  @override
  String get playerSteps => '步骤';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => '没有可播放的视频';

  @override
  String get playerWorkoutComplete => '训练完成！';

  @override
  String get playerSavingStreak => '正在保存到你的连续记录…';

  @override
  String get playerSavedStreak => '已保存到你的连续记录';

  @override
  String get playerRetrySave => '重试保存';

  @override
  String get playerReplay => '重播';

  @override
  String get playerNotReady => '播放器尚未准备好';

  @override
  String get playerPreviewUnavailable => '预览目前不可用。';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return '片段 $current/$total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => '加载视频时出错';

  @override
  String get playerLoadingVideo => '正在加载视频...';

  @override
  String get playerFailedToLoadVideo => '加载视频失败';

  @override
  String get playerNotInitialized => '视频播放器未初始化';

  @override
  String guidedExerciseCounter(int current, int total) {
    return '动作 $current/$total';
  }

  @override
  String get guidedGetReady => '准备开始';

  @override
  String guidedSetOf(int current, int total) {
    return '第 $current 组，共 $total 组';
  }

  @override
  String get guidedRest => '休息';

  @override
  String get guidedSkipRest => '跳过休息';

  @override
  String get guidedPaused => '已暂停';

  @override
  String get guidedResume => '继续';

  @override
  String get guidedWorkoutComplete => '训练完成';

  @override
  String get guidedEndTitle => '结束训练？';

  @override
  String get guidedEndBody => '本次训练的进度不会保存。';

  @override
  String get guidedKeepGoing => '继续';

  @override
  String get guidedEnd => '结束';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
      one: '$count 次',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => '使用 AI 生成训练计划';

  @override
  String get generateSheetPrompt => '你想进行什么类型的训练？';

  @override
  String get generateSheetHint => '例如：“唤醒身体的快速晨间拉伸”或“适合初学者的全身力量训练”';

  @override
  String get generateSheetDuration => '时长';

  @override
  String generateSheetMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String get generateSheetDifficulty => '难度';

  @override
  String get generateSheetEquipment => '可用器械';

  @override
  String get generateSheetGenerating => '生成中…';

  @override
  String get generateSheetSubmit => '生成训练计划';

  @override
  String get generateSheetDescribeFirst => '请描述你想要的训练';

  @override
  String generateSheetAlreadyExists(String title) {
    return '你已经有这个训练计划了：$title';
  }

  @override
  String generateSheetCreated(String title) {
    return '已创建：$title';
  }

  @override
  String get generateSheetFailed => '训练计划生成失败';

  @override
  String get guidedNoExercises => '此训练计划还没有训练动作。';

  @override
  String get guidedStartFailed => '暂时无法开始此训练。请重试。';

  @override
  String get guidedSaveFailed => '无法保存此训练。点击重试以更新你的连续训练记录。';

  @override
  String guidedOfReps(int count) {
    return '共 $count 次';
  }

  @override
  String get guidedHold => '保持';

  @override
  String get guidedNextSet => '下一组';

  @override
  String get guidedUpNext => '接下来';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds秒保持';
  }

  @override
  String coachGetReady(String exercise) {
    return '准备好。$exercise';
  }

  @override
  String coachStartReps(int count) {
    return '开始。$count 次。';
  }

  @override
  String coachStartHold(int seconds) {
    return '保持 $seconds 秒。';
  }

  @override
  String coachRest(String exercise) {
    return '休息。接下来：$exercise';
  }

  @override
  String get coachRestShort => '休息。';

  @override
  String get coachComplete => '做得好。训练完成。';

  @override
  String coachRep(int count) {
    return '$count';
  }

  @override
  String coachCountdown(int seconds) {
    return '$seconds';
  }

  @override
  String get playerNoVideosInRoutine => '此训练计划中没有找到可播放的视频。';

  @override
  String get playerLoadRoutineFailed => '暂时无法加载此训练计划。请重试。';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return '无法加载“$title”。跳过…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return '无法加载“$title”。';
  }

  @override
  String get playerSaveCompletionFailed => '无法保存完成状态。点击重试以更新你的连续训练记录。';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • 预览';
  }

  @override
  String get playerNoVideosReady => '此训练计划还没有可播放的视频。';

  @override
  String get playerPlaybackFailed => '暂时无法播放此视频。请重试。';

  @override
  String get libraryTabCurated => '精选';

  @override
  String get libraryTabAiGenerated => 'AI 生成';

  @override
  String get profileSavedRoutines => '已保存的训练计划';

  @override
  String get savedRoutinesNoFavorites => '还没有收藏的训练计划。';

  @override
  String get savedRoutinesEmpty => '还没有保存的训练计划。';

  @override
  String get actionFavorite => '收藏';

  @override
  String get actionUnfavorite => '取消收藏';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours小时 $minutes分钟';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours小时';
  }

  @override
  String get difficultyEasy => '简单';

  @override
  String get difficultyMedium => '中等';

  @override
  String get difficultyHard => '困难';

  @override
  String get categoryStrength => '力量';

  @override
  String get categoryCardio => '有氧';

  @override
  String get categoryFlexibility => '柔韧性';

  @override
  String get categoryMindfulness => '正念';

  @override
  String get categoryDance => '舞蹈';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => '瑜伽';

  @override
  String get categoryCustom => '自定义';

  @override
  String get navHome => '首页';

  @override
  String get navLibrary => '库';

  @override
  String get navChat => '聊天';

  @override
  String get navProfile => '个人资料';

  @override
  String get equipmentNone => '无';

  @override
  String get equipmentDumbbells => '哑铃';

  @override
  String get equipmentResistanceBands => '弹力带';

  @override
  String get equipmentYogaMat => '瑜伽垫';

  @override
  String get equipmentKettlebell => '壶铃';

  @override
  String get equipmentPullUpBar => '单杠';

  @override
  String get equipmentJumpRope => '跳绳';

  @override
  String get nutritionTitle => '营养';

  @override
  String get nutritionSubtitle => '卡路里、宏量营养素和餐食记录';

  @override
  String get nutritionSetGoalsTitle => '设置每日营养目标';

  @override
  String get nutritionSetGoalsBody =>
      '添加你的体重、身高、年龄和性别，以便 Celia 计算你每天应摄入的卡路里和营养素。';

  @override
  String get nutritionSetUpGoals => '设置目标';

  @override
  String get nutritionDailyTarget => '每日目标';

  @override
  String get nutritionDailyGoals => '每日目标';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => '今天';

  @override
  String get nutritionMealHistory => '餐食记录';

  @override
  String get nutritionCeliaInsights => 'Celia 洞察';

  @override
  String get nutritionWeeklyTrend => '每周趋势';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 餐',
      one: '$count 餐',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 餐',
      one: '$count 餐',
    );
    return '目标 $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => '一,二,三,四,五,六,日';

  @override
  String get nutritionFieldFoodName => '食物名称';

  @override
  String get nutritionFieldGrams => '克数';

  @override
  String get nutritionFieldCalories => '卡路里';

  @override
  String get scannerStatusAnalyzing => '分析中...';

  @override
  String get scannerStatusIdle => 'CELIA 扫描器';

  @override
  String get scannerFieldFoodName => '食物名称';

  @override
  String get scannerFieldGrams => '克数';

  @override
  String get scannerFieldCalories => '卡路里';

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
    return '今天还剩 $calories kcal 和 ${grams}g 蛋白质';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '超过每日目标 $calories kcal';
  }

  @override
  String get scannerButtonAnalyzing => '分析中';

  @override
  String get scannerButtonQuotaNeeded => '需要配额';

  @override
  String get scannerButtonScanNow => '立即扫描';

  @override
  String get scannerButtonLogging => '记录中';

  @override
  String get scannerButtonLogMeal => '记录餐食';

  @override
  String get scannerNoClearFood => '尚未检测到清晰的食物。请改善光线或靠近一些。';

  @override
  String get scannerErrorCameraPermission => '扫描餐食需要相机权限。';

  @override
  String get scannerErrorBackendMissing => '卡路里扫描后端尚未配置。';

  @override
  String get scannerErrorApiKeyInvalid =>
      '用于卡路里扫描的 OpenAI API 密钥无效。请在后端环境中替换密钥，重新部署后再试。';

  @override
  String get scannerErrorApiKeyMissing =>
      '卡路里扫描需要 OpenAI API 密钥。请在 Vercel 中添加密钥，重新部署后再试。';

  @override
  String get scannerErrorQuotaExhausted =>
      '用于卡路里扫描的 OpenAI 额度已用尽。请添加 API 额度或提高账单限额后再试。';

  @override
  String get scannerErrorTimeout => 'Celia 需要更多时间来分析这份餐食。请保持相机稳定，然后重新扫描。';

  @override
  String get scannerErrorNotSignedIn => '请先登录再扫描餐食。';

  @override
  String get scannerErrorMealTableMissing => '餐食记录表尚未准备就绪。扫描结果仍然可用。';

  @override
  String get scannerErrorGeneric =>
      'Celia 暂时无法分析这份餐食。请保持相机稳定，让食物位于画面中央，然后重新扫描。';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
      one: '$count 项',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => '餐食详情';

  @override
  String get nutritionFoodItems => '食物项目';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem => '一餐至少需要包含一项食物。';

  @override
  String get nutritionMealUpdated => '餐食已更新';

  @override
  String nutritionUpdateFailed(String error) {
    return '无法更新餐食：$error';
  }

  @override
  String get nutritionDeleteMealTitle => '删除餐食？';

  @override
  String get nutritionDeleteMealBody => '这将从你的营养记录中移除该餐食。';

  @override
  String get nutritionDeleteMeal => '删除餐食';

  @override
  String nutritionDeleteFailed(String error) {
    return '无法删除餐食：$error';
  }

  @override
  String get nutritionEditFood => '编辑食物';

  @override
  String get nutritionSaveFood => '保存食物';

  @override
  String get nutritionLoadFailed => '无法加载餐食';

  @override
  String get nutritionLoadFailedBody => '下拉刷新或检查后端连接。';

  @override
  String get nutritionNoMeals => '尚未记录餐食';

  @override
  String get nutritionNoMealsBody => '扫描你的第一餐，Celia 将为你建立营养记录。';

  @override
  String get progressToday => '今天';

  @override
  String get progressSetGoals => '设置营养目标以解锁卡路里和宏量营养素追踪。';

  @override
  String progressOfTarget(int target) {
    return '共 $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '超出 $calories kcal';
  }

  @override
  String progressKcalLeft(int calories) {
    return '剩余 $calories kcal';
  }

  @override
  String get progressProtein => '蛋白质';

  @override
  String get progressCarbs => '碳水化合物';

  @override
  String get progressFat => '脂肪';

  @override
  String get scannerEditItem => '编辑食物项目';

  @override
  String get scannerSaveChanges => '保存更改';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return '置信度 $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count 项食物已包含在此餐食记录中';
  }

  @override
  String get scannerIfYouLog => '如果记录这餐';

  @override
  String scannerAfterLogging(int after, int target) {
    return '今天 $after / $target kcal';
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
  String get scannerNoMealDetected => '未检测到餐食';

  @override
  String onboardingWelcome(String name) {
    return '欢迎，$name';
  }

  @override
  String get onboardingGender => '性别';

  @override
  String get onboardingCalculateGoals => '计算我的目标';

  @override
  String get onboardingScanFirstMeal => '扫描我的第一餐';

  @override
  String get onboardingExploreRoutines => '探索训练计划';

  @override
  String get onboardingGoHome => '前往主页';

  @override
  String get onboardingDailyTargets => '你的每日目标';

  @override
  String onboardingProtein(int grams) {
    return '蛋白质 ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return '蛋白质 ${protein}g • 碳水化合物 ${carbs}g • 脂肪 ${fat}g';
  }

  @override
  String get onboardingTargetsReady => '你的每日营养目标已准备就绪。选择你想要的开始方式。';

  @override
  String get onboardingWeightKg => '体重（kg）';

  @override
  String get onboardingHeightCm => '身高（cm）';

  @override
  String get onboardingAge => '年龄';

  @override
  String get onboardingInvalidWeight => '请输入有效的体重（kg）。';

  @override
  String get onboardingInvalidHeight => '请输入有效的身高（cm）。';

  @override
  String get onboardingInvalidAge => '请输入 13 至 100 岁之间的有效年龄。';

  @override
  String get onboardingSaveFailed => '无法保存你的营养档案。';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => '其他';

  @override
  String get nutritionSetupTitle => '每日营养目标';

  @override
  String get nutritionSetupBody => '告诉 Celia 你的身体信息，她会计算你的每日卡路里和宏量营养素目标。';

  @override
  String get nutritionSetupGender => '性别';

  @override
  String get nutritionSetupFootnote =>
      'Celia 会根据你的体重、身高、年龄和性别，按中等活动水平估算每日卡路里和宏量营养素目标。';

  @override
  String get nutritionSourcesTitle => '这些目标如何计算';

  @override
  String get nutritionSourcesBody =>
      '每日热量采用 Mifflin–St Jeor 静息能量公式，并乘以中等体力活动系数（约 1.55）。活跃成人的蛋白质估算约为每公斤体重 1.8 克。脂肪约占热量的 25%，其余由碳水化合物补足——均在常见膳食指导范围内。';

  @override
  String get nutritionSourcesDisclaimer =>
      '这些数字仅为一般健康估算，并非诊断、处方，也不能替代合格临床医生或注册营养师的建议。';

  @override
  String get nutritionSetupSave => '保存目标';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => '会员';

  @override
  String get profileAccount => '账户';

  @override
  String profileSignedInAs(String email) {
    return '登录账户：\n$email';
  }

  @override
  String get profileUnknownEmail => '未知';

  @override
  String get profileDarkMode => '深色模式';

  @override
  String get profileAvatarMode => '虚拟形象模式';

  @override
  String get profileAvatarModeSubtitle => '与 Celia 全屏语音对话';

  @override
  String get profileLanguage => '语言';

  @override
  String get profileLogOutTitle => '退出登录？';

  @override
  String get profileLogOutBody => '确定要退出登录吗？';

  @override
  String get profileLogOut => '退出登录';

  @override
  String get profileLogOutButton => '退出登录';

  @override
  String get profileDeleteAccount => '删除账户';

  @override
  String get profileDeleteAccountConfirmTitle => '删除您的账户？';

  @override
  String get profileDeleteAccountConfirmBody =>
      '这将永久删除您的账户及所有数据，包括已保存的训练计划、饮食记录和聊天记录。此操作无法撤销。';

  @override
  String get profileDeleteAccountPasswordPrompt => '请输入密码以确认。';

  @override
  String get profileDeleteAccountPasswordLabel => '密码';

  @override
  String get profileDeleteAccountButton => '删除我的账户';

  @override
  String get profileFavoriteRoutines => '收藏的训练计划';

  @override
  String get profileSubscription => '订阅';

  @override
  String get profileNutrition => '营养';

  @override
  String get profileHelpSupport => '帮助与支持';

  @override
  String get profileFriend => '好友';

  @override
  String get profileStatSaved => '已保存';

  @override
  String get profileStatStreak => '连续记录';

  @override
  String get profileStatWorkouts => '训练次数';

  @override
  String get streakDayOneStarted => '第 1 天已开始——明天再来，保持连续记录。';

  @override
  String get streakRebuild => '你昨天很活跃——今天记录一餐或完成一次训练，重新建立连续记录。';

  @override
  String get streakStart => '记录一餐或完成一次训练，开始你的连续记录。';

  @override
  String streakLongRun(int days) {
    return '已连续 $days 天！坚持下去——Celia 正在记录你的坚持。';
  }

  @override
  String streakBothLogged(int days) {
    return '已连续 $days 天——今天的训练和营养记录都已完成。';
  }

  @override
  String streakNeedWorkout(int days) {
    return '已连续 $days 天。完成一次快速训练，让今天更加完整。';
  }

  @override
  String streakNeedMeal(int days) {
    return '已连续 $days 天。记录一餐，追踪你的能量补给。';
  }

  @override
  String streakStayActive(int days) {
    return '已连续 $days 天——今天也要保持活跃。';
  }

  @override
  String get editProfileTitle => '编辑个人资料';

  @override
  String get editProfileName => '姓名';

  @override
  String get editProfileFootnote => '更改会保存到你的账户，并显示在首页和个人资料页。';

  @override
  String get editProfileSaveFailed => '无法更新个人资料，请重试。';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '设备语言';

  @override
  String get languageSystemSubtitle => '跟随手机当前设置的语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get insightStartFuelingTitle => '今天开始补充能量';

  @override
  String get insightStartFuelingBody => '你还有全部的热量额度。扫描或记录第一餐，保持计划进度。';

  @override
  String get insightAboveTargetTitle => '今天已超出目标';

  @override
  String insightAboveTargetBody(int calories) {
    return '你比每日目标多摄入了 $calories kcal。晚餐可以清淡一些，或增加一次短时训练。';
  }

  @override
  String get insightLowProteinTitle => '蛋白质摄入仍不足';

  @override
  String insightLowProteinBody(int grams) {
    return '今天还需要摄入约 ${grams}g 蛋白质，才能达到目标。';
  }

  @override
  String get insightAlmostThereTitle => '快达到目标了';

  @override
  String insightAlmostThereBody(int calories) {
    return '今天还剩 $calories kcal。搭配均衡的零食应该正合适。';
  }

  @override
  String get insightOnTrackTitle => '今天进展顺利';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return '还剩 $calories kcal 和 ${grams}g 蛋白质即可达到每日目标。';
  }

  @override
  String get insightWeeklyRhythmTitle => '建立每周节奏';

  @override
  String get insightWeeklyRhythmBody => '在一周中持续记录餐食，让 Celia 发现规律并更好地指导你。';

  @override
  String get insightWeeklyTrendTitle => '每周趋势';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return '过去 7 天中，你有 $days 天记录了餐食，平均摄入 $average kcal——$direction。';
  }

  @override
  String get insightTrendOnTarget => '平均值接近每日目标';

  @override
  String insightTrendAbove(int delta) {
    return '平均每天高于目标 $delta kcal';
  }

  @override
  String insightTrendBelow(int delta) {
    return '平均每天低于目标 $delta kcal';
  }

  @override
  String get insightsSectionTitle => 'Celia 洞察';

  @override
  String get bodyScanTitle => '身体扫描';

  @override
  String get bodyScanContinue => '继续';

  @override
  String get bodyScanDone => '完成';

  @override
  String get bodyScanConsentTitle => '扫描前须知';

  @override
  String get bodyScanConsentBody => '身体扫描会根据两张照片估算你的身体成分。以下是照片的具体处理方式。';

  @override
  String get bodyScanConsentPhotosTitle => '由你拍摄的两张照片';

  @override
  String get bodyScanConsentPhotosBody => '一张正面照和一张右侧面照。请穿合身的衣服，以便清晰显示身体轮廓。';

  @override
  String get bodyScanConsentProcessingTitle => '由 Bodygram 分析';

  @override
  String get bodyScanConsentProcessingBody =>
      '你的照片会发送给扫描服务提供商 Bodygram，用于估算你的身体指标。照片不会用于其他用途。';

  @override
  String get bodyScanConsentStorageTitle => '你的照片绝不会被存储';

  @override
  String get bodyScanConsentStorageBody =>
      'Celia 不会保留你的照片。只有生成的数值和 3D 模型会保存到你的账户中；删除账户后，这些内容也会被删除。';

  @override
  String get bodyScanConsentAgeTitle => '你必须年满 18 岁';

  @override
  String get bodyScanConsentAgeBody => '未满 18 岁无法使用身体扫描。';

  @override
  String get bodyScanConsentAgree => '我已了解并同意分析我的照片';

  @override
  String get bodyScanStatsTitle => '确认你的信息';

  @override
  String get bodyScanStatsBody => '这些信息会直接用于估算，因此过时的体重会影响结果。';

  @override
  String get bodyScanStatsHeight => '身高';

  @override
  String get bodyScanStatsWeight => '体重';

  @override
  String get bodyScanStatsAge => '年龄';

  @override
  String get bodyScanStatsSex => '生理性别';

  @override
  String get bodyScanStatsSexNote =>
      '扫描模型仅基于两组参考人群建立。请选择与你的身体更接近的一组；这会影响估算结果，不会影响 Celia 对待你的方式。';

  @override
  String get bodyScanStatsFemale => '女性';

  @override
  String get bodyScanStatsMale => '男性';

  @override
  String get bodyScanStatsInvalid => '请输入有效的身高、体重和年龄。你必须年满 18 岁才能进行扫描。';

  @override
  String get bodyScanCaptureFrontTitle => '面向摄像头';

  @override
  String get bodyScanCaptureRightTitle => '向右转身';

  @override
  String get bodyScanCaptureHowTo => '将手机支撑在大约 3 米外，后退到全身都能放入轮廓线内，然后开始计时。';

  @override
  String get bodyScanCaptureTips => '穿合身的衣服，选择简洁的背景，确保光线均匀充足，双臂稍微离开身体。';

  @override
  String get bodyScanPoseFront => '正面';

  @override
  String get bodyScanPoseRight => '右侧面';

  @override
  String get bodyScanStartTimer => '开始计时';

  @override
  String get bodyScanCancelTimer => '取消计时';

  @override
  String get bodyScanRetake => '重新拍摄';

  @override
  String get bodyScanNextPose => '下一张照片';

  @override
  String get bodyScanGetResults => '获取我的结果';

  @override
  String get bodyScanProcessingTitle => '正在分析你的扫描结果';

  @override
  String get bodyScanProcessingBody => '正在构建你的 3D 模型并估算你的身体指标。最多需要一分钟。';

  @override
  String get bodyScanResultTitle => '你的身体扫描结果';

  @override
  String get bodyScanResultSubtitle => '根据你的照片估算得出。最适合用于长期追踪趋势。';

  @override
  String get bodyScanBodyFat => '体脂率';

  @override
  String get bodyScanLeanMass => '瘦体重';

  @override
  String get bodyScanFatMass => '脂肪量';

  @override
  String get bodyScanWaist => '腰围';

  @override
  String get bodyScanHip => '臀围';

  @override
  String get bodyScanChest => '胸围';

  @override
  String get bodyScanWaistToHip => '腰臀比';

  @override
  String bodyScanQuotaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次扫描剩余',
      one: '本周期还剩 1 次扫描',
      zero: '本周期没有剩余扫描次数',
    );
    return '$_temp0';
  }

  @override
  String get bodyScanEmptyTitle => '了解身体的变化';

  @override
  String get bodyScanEmptyBody =>
      '两张照片即可估算您的体脂和瘦体重，并测量关键部位，还可生成一个 3D 模型，方便您长期对比。';

  @override
  String get bodyScanLatestTitle => '最近扫描';

  @override
  String get bodyScanHistoryTitle => '之前的扫描';

  @override
  String get bodyScanStartCta => '开始身体扫描';

  @override
  String get bodyScanRescanCta => '再次扫描';

  @override
  String get bodyScanRescanHint => '身体成分变化缓慢。大约每月扫描一次，最有助于进行有意义的比较。';

  @override
  String bodyScanDeltaSinceLast(String value) {
    return '与上次扫描相比变化了 $value%';
  }

  @override
  String get bodyScanNoComposition => '暂无估算结果';

  @override
  String get bodyScanSourcesTitle => '这些结果如何得出';

  @override
  String get bodyScanSourcesBody =>
      '系统会将您的照片转换为身体的 3D 轮廓，并结合您的身高、体重、年龄和性别，根据该形状估算体脂和瘦体重。瘦体重包括肌肉、水分、骨骼和器官，并不单指蛋白质。';

  @override
  String get bodyScanDisclaimer =>
      '这些是估算结果，并非医学测量值。针对这种方法的研究显示，与临床 DXA 扫描相比，体脂平均误差约为 3.5%；与单次读数相比，其跟踪变化的一致性较弱。本功能不用于诊断。如需作出健康相关决定，请咨询医疗专业人士。';

  @override
  String get bodyScanErrorCameraPermission => 'Celia 需要访问相机才能扫描您的身体。';

  @override
  String get bodyScanErrorNoCamera => '此设备上没有可用的相机。';

  @override
  String get bodyScanErrorFraming => '您的全身需要出现在画面中。请将手机拿远一些，并确保头部和脚部都清晰可见。';

  @override
  String get bodyScanErrorQuality => '照片太暗或太模糊。请寻找更明亮、均匀的光线，并在计时期间保持不动。';

  @override
  String get bodyScanErrorPose =>
      '您的姿势不太合适。请面向相机站直，双臂略微离开身体两侧，然后向右完整转身拍摄第二张照片。';

  @override
  String get bodyScanErrorClothing => '宽松的衣物会遮挡您的身体轮廓。穿着贴身衣物才能获得可用的扫描结果。';

  @override
  String get bodyScanErrorPhotoUnknown => '这些照片无法使用。请在光线良好、背景简洁的地方重试。';

  @override
  String get bodyScanErrorPhotosTooLarge => '这些照片太大，无法上传。请重试。';

  @override
  String get bodyScanErrorQuota => '您已用完本周期的扫描次数。重置后即可再次扫描。';

  @override
  String get bodyScanErrorAge => '身体扫描仅向年满 18 岁的用户开放。';

  @override
  String get bodyScanErrorStats => '请检查您的身高、体重、年龄和性别，然后重试。';

  @override
  String get bodyScanErrorSignedIn => '请重新登录后再扫描。';

  @override
  String get bodyScanErrorUnavailable => '身体扫描暂时不可用。';

  @override
  String get bodyScanErrorNetwork => '无法连接到 Celia。请检查网络连接后重试。';

  @override
  String get bodyScanErrorServer => '扫描时出了点问题。请重试。';

  @override
  String get bodyScanErrorLoadHistory => '无法加载您之前的扫描记录。';

  @override
  String get profileBodyScan => '身体扫描';

  @override
  String get homeBodyScan => '身体扫描';

  @override
  String get homeBodyScanSubtitle => '根据两张照片估算体脂';
}
