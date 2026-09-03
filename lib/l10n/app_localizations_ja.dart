// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionDone => '完了';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionSeeAll => 'すべて見る';

  @override
  String get actionYesDoIt => 'はい、実行する';

  @override
  String get actionNotNow => '今はしない';

  @override
  String get loadingPreparing => 'Celiaを準備中…';

  @override
  String get loadingGeneric => '読み込み中…';

  @override
  String get errorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get errorCanceled => '操作がキャンセルされました。';

  @override
  String get errorTooManyRequests => '試行回数が多すぎます。1分ほど待ってから、もう一度お試しください。';

  @override
  String get errorNetwork => 'インターネット接続を確認して、もう一度お試しください。';

  @override
  String get errorBadCredentials => 'メールアドレスまたはパスワードが正しくありません。';

  @override
  String get errorEmailInUse => 'このメールアドレスはすでに使用されています。代わりにログインしてください。';

  @override
  String get errorWeakPassword => 'より強力なパスワードを入力して、もう一度お試しください。';

  @override
  String get errorInvalidEmail => '有効なメールアドレスを入力してください。';

  @override
  String get errorNoPermission => 'この操作を行う権限がありません。';

  @override
  String get errorNotSignedIn => 'サインインしてから、もう一度お試しください。';

  @override
  String get errorDeleteAccount => 'アカウントを削除できませんでした。もう一度お試しください。';

  @override
  String get errorNoConversation => '続けるには新しいチャットを開始してください。';

  @override
  String get errorNoPlayableVideos => 'このルーティンで再生できる動画はまだありません。';

  @override
  String get errorLoadRoutines => '現在ルーティンを読み込めません。もう一度お試しください。';

  @override
  String get errorLoadSavedRoutines => '現在保存済みのルーティンを読み込めません。もう一度お試しください。';

  @override
  String get errorGenerateRoutine => '現在ルーティンを作成できません。もう一度お試しください。';

  @override
  String get errorLoadChats => '現在保存済みのチャットを読み込めません。';

  @override
  String get errorCeliaUnavailable => '現在Celiaを利用できません。もう一度お試しください。';

  @override
  String get errorOpenConversation => 'その会話を開けませんでした。';

  @override
  String get errorDeleteConversation => 'この会話を削除できませんでした。もう一度お試しください。';

  @override
  String get errorSignIn => 'サインインできませんでした。もう一度お試しください。';

  @override
  String get errorCreateAccount => 'アカウントを作成できませんでした。もう一度お試しください。';

  @override
  String get errorSendResetEmail => 'パスワードリセットメールを送信できませんでした。もう一度お試しください。';

  @override
  String get errorSendVerificationEmail => '確認メールを送信できませんでした。もう一度お試しください。';

  @override
  String get errorGoogleSignIn => 'Googleでのサインインに失敗しました。もう一度お試しください。';

  @override
  String get errorAppleSignIn => 'Appleでのサインインに失敗しました。もう一度お試しください。';

  @override
  String get errorRefreshNutrition => '栄養データを更新できませんでした。';

  @override
  String get errorLoadNutritionProfile => '栄養プロフィールを読み込めませんでした。';

  @override
  String get startupErrorTitle => 'アプリを起動できません';

  @override
  String get startupErrorBody =>
      'アプリを閉じて、もう一度開いてください。問題が続く場合は、サポートにお問い合わせください。';

  @override
  String get authTagline => 'あなたのフィットネス仲間';

  @override
  String get authSignUp => 'アカウント登録';

  @override
  String get authLogIn => 'ログイン';

  @override
  String authVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get authForgotPassword => 'パスワードをお忘れですか？';

  @override
  String get authOr => 'または';

  @override
  String get authContinueWithGoogle => 'Googleで続ける';

  @override
  String get authContinueWithApple => 'Appleで続ける';

  @override
  String get authAuthenticating => '認証中…';

  @override
  String get authEnterYourName => '名前を入力してください。';

  @override
  String get authNeedAccount => 'アカウントをお持ちでない方：アカウント登録';

  @override
  String get authHaveAccount => 'すでにアカウントをお持ちですか？ログイン';

  @override
  String get authFieldName => '名前';

  @override
  String get authFieldEmail => 'メールアドレス';

  @override
  String get authFieldPassword => 'パスワード';

  @override
  String get verifyEmailTitle => 'メールアドレスを確認';

  @override
  String get verifyEmailHeading => '受信トレイを確認してください';

  @override
  String get verifyEmailBody => '確認リンクをメールで送信しました。';

  @override
  String get verifyEmailSent => '確認メールを送信しました！';

  @override
  String get verifyEmailContinue => '確認しました。続行';

  @override
  String get verifyEmailSignOut => 'ログアウト';

  @override
  String get verifyEmailSending => '送信中…';

  @override
  String get verifyEmailResend => '確認メールを再送信';

  @override
  String verifyEmailResendIn(int seconds) {
    return '$seconds秒後に再送信';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'メール：$email';
  }

  @override
  String get forgotPasswordTitle => 'パスワードをお忘れですか？';

  @override
  String get forgotPasswordBody => 'パスワード再設定リンクを受け取るメールアドレスを入力してください。';

  @override
  String get forgotPasswordEmptyEmail => 'メールアドレスを入力してください';

  @override
  String get forgotPasswordSent => 'パスワード再設定メールを送信しました。';

  @override
  String get forgotPasswordSend => '再設定リンクを送信';

  @override
  String get forgotPasswordSending => '送信中…';

  @override
  String get nameSetupTitle => 'Celiaには何と呼ばせますか？';

  @override
  String get nameSetupBody => 'コーチングをあなたに合わせるため、アプリ全体で名前を使用します。';

  @override
  String get nameSetupSaveFailed => '名前を保存できませんでした。もう一度お試しください。';

  @override
  String get homeGoodMorning => 'おはようございます。';

  @override
  String get homeCeliaActive => 'CELIA ACTIVE';

  @override
  String get homeGenerateRoutine => 'AIで\nあなた専用の\nルーティンを作成';

  @override
  String get homeCreateRoutine => 'ルーティンを作成';

  @override
  String get homeQuickActions => 'クイックアクション';

  @override
  String get homeUpNext => '次の予定';

  @override
  String get homeNoUpcoming => '予定されているルーティンはまだありません。\n作成するか、ライブラリを見てみましょう。';

  @override
  String get homeChatWithCelia => 'Celiaに相談';

  @override
  String get homeChatSubtitle => 'フォームや食事について質問';

  @override
  String get homeScanMeal => '食事をスキャン';

  @override
  String get homeScanMealSubtitle => '食べ物とカロリーを識別';

  @override
  String get homeNutrition => '栄養';

  @override
  String get homeNutritionSubtitle => 'カロリー、マクロ、食事を確認';

  @override
  String get homeBrowseLibrary => 'ライブラリを\n見る';

  @override
  String get homeTrackProgress => '進捗を\n記録';

  @override
  String get chatTitle => 'コーチCelia';

  @override
  String get chatEmptyPrompt => '今日はどのように\nフィットネスをサポートしましょうか？';

  @override
  String get chatYourChats => 'あなたのチャット';

  @override
  String get chatNoSavedChats => '保存されたチャットはまだありません。';

  @override
  String get chatHistory => 'チャット履歴';

  @override
  String get chatNew => '新しいチャット';

  @override
  String get chatOpening => 'チャットを開いています…';

  @override
  String get chatScanAMeal => '食事をスキャン';

  @override
  String get chatInputHint => 'トレーニングについてCeliaに何でも聞いてください…';

  @override
  String get chatMicTooltip => '長押しで話す';

  @override
  String get chatListening => '聞いています…';

  @override
  String get chatMicDenied => 'Celia と話すにはマイクへのアクセスが必要です。';

  @override
  String get chatSpeechUnavailable => 'この端末では音声認識を利用できません。';

  @override
  String get avatarModeReady => '待機中';

  @override
  String get avatarModeThinking => '考え中…';

  @override
  String get avatarModeSpeaking => '話しています…';

  @override
  String get avatarModeHoldToTalk => '長押しで話す';

  @override
  String get avatarModeExit => '手動モード';

  @override
  String get avatarModeConfirmTitle => 'Celiaに確認しますか？';

  @override
  String get avatarModeConfirmBody => 'Celiaが保存しようとしています。許可しますか？';

  @override
  String get avatarModeConfirmYes => '許可';

  @override
  String get chatCouldNotOpenRoutine => 'そのルーティンを開けませんでした';

  @override
  String get chatThisRoutine => 'このルーティン';

  @override
  String get chatThisMeal => 'この食事';

  @override
  String get chatYourRoutine => 'あなたのルーティン';

  @override
  String chatMoreExercises(int count) {
    return 'あと$count件';
  }

  @override
  String get chatEmptySubtitle => 'トレーニング、食事、進捗について質問してください。';

  @override
  String chatLoggedToday(int calories) {
    return '今日は$calories kcalを記録しています。';
  }

  @override
  String get chatSuggestionHiit => '20分間のHIITルーティンを作って';

  @override
  String get chatSuggestionDinner => '今夜は何を食べればいい？';

  @override
  String get chatSuggestionProgress => '今週の調子はどう？';

  @override
  String get chatSuggestionIngredients => '鶏肉、米、ほうれん草があります';

  @override
  String get chatJustNow => 'たった今';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes分前';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours時間前';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days日前';
  }

  @override
  String get chatRoutineAlreadySaved => 'すでにライブラリにあります — タップして開く';

  @override
  String get chatRoutineTapToOpen => 'タップして開く';

  @override
  String get chatToolCancelled => 'キャンセルしました';

  @override
  String chatToolFailed(String label) {
    return '$label — うまくいきませんでした';
  }

  @override
  String get chatToolRoutineSaveFailed => 'ルーティンを保存できませんでした';

  @override
  String get chatToolRoutineSaved => 'ライブラリに保存しました';

  @override
  String get chatToolMealLogged => '今日の記録に追加しました';

  @override
  String get chatToolRoutineAdded => 'ライブラリに追加しました';

  @override
  String get activityCheckingProgress => '進捗を確認しています';

  @override
  String get activityCheckingNutrition => '今日食べたものを確認しています';

  @override
  String get activityReviewingMeals => '最近の食事を確認しています';

  @override
  String get activityLookingAtRoutines => 'ルーティンを確認しています';

  @override
  String get activityReadingRoutine => 'そのルーティンを読み込んでいます';

  @override
  String get activitySearchingLibrary => 'エクササイズライブラリを検索しています';

  @override
  String get activityBuildingRoutine => 'ルーティンを作成しています';

  @override
  String get activityLoggingMeal => '食事を記録しています';

  @override
  String get activitySavingToLibrary => 'ライブラリに保存しています';

  @override
  String get activityWorking => '処理しています';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return '「$name」を$count個のエクササイズ付きでライブラリに保存しますか？';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '「$name」をライブラリに保存しますか？';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '「$name」を$calories kcalとして記録しますか？';
  }

  @override
  String approvalLogMeal(String name) {
    return '「$name」を記録しますか？';
  }

  @override
  String get approvalAddRoutine => 'このルーティンをライブラリに追加しますか？';

  @override
  String get approvalGeneric => 'Celiaに実行を許可しますか？';

  @override
  String get libraryTitle => 'ルーティンライブラリ';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countステップ',
      one: '$countステップ',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'ルーティンはまだありません';

  @override
  String get libraryEmptyBody => '管理ダッシュボードでルーティンを作成して公開してください。';

  @override
  String get libraryLoadFailed => 'ルーティンを読み込めませんでした';

  @override
  String get routineStartWorkout => 'ワークアウトを開始';

  @override
  String get routineNoSteps => '利用できるステップはありません';

  @override
  String get routineNoVideoForStep => 'このステップの動画はありません';

  @override
  String get routineVideoProcessing => '動画を処理中です。後でもう一度お試しください。';

  @override
  String get routineMissingPlaybackUrl => 'この動画の再生URLがありません';

  @override
  String get routinePreviewBanner => 'プレビュー — フル動画は近日公開';

  @override
  String get routinePreview => 'プレビュー';

  @override
  String get routineDetails => '詳細';

  @override
  String get routineNotFound => 'ルーティンが見つかりません';

  @override
  String routineCompletedTimes(int count) {
    return '$count回完了';
  }

  @override
  String get playerVideoUnavailable => 'この動画は現在利用できません。';

  @override
  String get playerSteps => 'ステップ';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => '再生できる動画はありません';

  @override
  String get playerWorkoutComplete => 'ワークアウト完了！';

  @override
  String get playerSavingStreak => '連続記録に保存しています…';

  @override
  String get playerSavedStreak => '連続記録に保存しました';

  @override
  String get playerRetrySave => '再保存';

  @override
  String get playerReplay => '再生';

  @override
  String get playerNotReady => 'プレーヤーの準備ができていません';

  @override
  String get playerPreviewUnavailable => 'プレビューは現在利用できません。';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current of $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => '動画の読み込み中にエラーが発生しました';

  @override
  String get playerLoadingVideo => '動画を読み込んでいます…';

  @override
  String get playerFailedToLoadVideo => '動画を読み込めませんでした';

  @override
  String get playerNotInitialized => '動画プレーヤーが初期化されていません';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'エクササイズ $current/$total';
  }

  @override
  String get guidedGetReady => '準備してください';

  @override
  String guidedSetOf(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String get guidedRest => '休憩';

  @override
  String get guidedSkipRest => '休憩をスキップ';

  @override
  String get guidedPaused => '一時停止中';

  @override
  String get guidedResume => '再開';

  @override
  String get guidedWorkoutComplete => 'ワークアウト完了';

  @override
  String get guidedEndTitle => 'ワークアウトを終了しますか？';

  @override
  String get guidedEndBody => 'このセッションの進捗は保存されません。';

  @override
  String get guidedKeepGoing => '続ける';

  @override
  String get guidedEnd => '終了';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回',
      one: '$count回',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'AIでルーティンを生成';

  @override
  String get generateSheetPrompt => 'どんなワークアウトをしたいですか？';

  @override
  String get generateSheetHint => '例：「目を覚ますための朝の短いストレッチ」または「初心者向けの全身筋力トレーニング」';

  @override
  String get generateSheetDuration => '時間';

  @override
  String generateSheetMinutes(int count) {
    return '$count分';
  }

  @override
  String get generateSheetDifficulty => '難易度';

  @override
  String get generateSheetEquipment => '利用可能な器具';

  @override
  String get generateSheetGenerating => '生成中…';

  @override
  String get generateSheetSubmit => 'ルーティンを生成';

  @override
  String get generateSheetDescribeFirst => '希望するワークアウトを入力してください';

  @override
  String generateSheetAlreadyExists(String title) {
    return '同じものがすでにあります：$title';
  }

  @override
  String generateSheetCreated(String title) {
    return '作成しました：$title';
  }

  @override
  String get generateSheetFailed => 'ルーティンの生成に失敗しました';

  @override
  String get guidedNoExercises => 'このルーティンにはまだエクササイズがありません。';

  @override
  String get guidedStartFailed => '現在このワークアウトを開始できません。もう一度お試しください。';

  @override
  String get guidedSaveFailed =>
      'このワークアウトを保存できませんでした。連続記録を更新するには、再試行をタップしてください。';

  @override
  String guidedOfReps(int count) {
    return '全$count回中';
  }

  @override
  String get guidedHold => 'キープ';

  @override
  String get guidedNextSet => '次のセット';

  @override
  String get guidedUpNext => '次はこれ';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds秒キープ';
  }

  @override
  String coachGetReady(String exercise) {
    return '準備してください。$exercise';
  }

  @override
  String coachStartReps(int count) {
    return '開始。$count回。';
  }

  @override
  String coachStartHold(int seconds) {
    return '$seconds秒キープ。';
  }

  @override
  String coachRest(String exercise) {
    return '休憩。次は$exerciseです';
  }

  @override
  String get coachRestShort => '休憩。';

  @override
  String get coachComplete => 'よくできました。ワークアウト完了です。';

  @override
  String coachRep(int count) {
    return '$count';
  }

  @override
  String coachCountdown(int seconds) {
    return '$seconds';
  }

  @override
  String get playerNoVideosInRoutine => 'このルーティンに再生可能な動画が見つかりません。';

  @override
  String get playerLoadRoutineFailed => '現在このルーティンを読み込めません。もう一度お試しください。';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return '「$title」を読み込めませんでした。スキップします…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return '「$title」を読み込めませんでした。';
  }

  @override
  String get playerSaveCompletionFailed =>
      '完了を保存できませんでした。連続記録を更新するには、再試行をタップしてください。';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • プレビュー';
  }

  @override
  String get playerNoVideosReady => 'このルーティンにはまだ再生できる動画がありません。';

  @override
  String get playerPlaybackFailed => '現在この動画を再生できません。もう一度お試しください。';

  @override
  String get libraryTabCurated => '厳選';

  @override
  String get libraryTabAiGenerated => 'AI生成';

  @override
  String get profileSavedRoutines => '保存済みルーティン';

  @override
  String get savedRoutinesNoFavorites => 'お気に入りのルーティンはまだありません。';

  @override
  String get savedRoutinesEmpty => '保存済みのルーティンはまだありません。';

  @override
  String get actionFavorite => 'お気に入りに追加';

  @override
  String get actionUnfavorite => 'お気に入りから削除';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours時間';
  }

  @override
  String get difficultyEasy => '初級';

  @override
  String get difficultyMedium => '中級';

  @override
  String get difficultyHard => '上級';

  @override
  String get categoryStrength => '筋力';

  @override
  String get categoryCardio => '有酸素運動';

  @override
  String get categoryFlexibility => '柔軟性';

  @override
  String get categoryMindfulness => 'マインドフルネス';

  @override
  String get categoryDance => 'ダンス';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'ヨガ';

  @override
  String get categoryCustom => 'カスタム';

  @override
  String get navHome => 'ホーム';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navChat => 'チャット';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get equipmentNone => 'なし';

  @override
  String get equipmentDumbbells => 'ダンベル';

  @override
  String get equipmentResistanceBands => 'レジスタンスバンド';

  @override
  String get equipmentYogaMat => 'ヨガマット';

  @override
  String get equipmentKettlebell => 'ケトルベル';

  @override
  String get equipmentPullUpBar => '懸垂バー';

  @override
  String get equipmentJumpRope => '縄跳び';

  @override
  String get nutritionTitle => '栄養';

  @override
  String get nutritionSubtitle => 'カロリー、マクロ栄養素、食事履歴';

  @override
  String get nutritionSetGoalsTitle => '1日の栄養目標を設定';

  @override
  String get nutritionSetGoalsBody =>
      '体重、身長、年齢、性別を入力すると、Celiaが毎日摂取すべきカロリーと栄養素を計算します。';

  @override
  String get nutritionSetUpGoals => '目標を設定';

  @override
  String get nutritionDailyTarget => '1日の目標';

  @override
  String get nutritionDailyGoals => '1日の目標';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => '今日';

  @override
  String get nutritionMealHistory => '食事履歴';

  @override
  String get nutritionCeliaInsights => 'Celiaのインサイト';

  @override
  String get nutritionWeeklyTrend => '週間の推移';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count食',
      one: '$count食',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count食',
      one: '$count食',
    );
    return '$target kcal中 • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => '月,火,水,木,金,土,日';

  @override
  String get nutritionFieldFoodName => '食品名';

  @override
  String get nutritionFieldGrams => 'グラム数';

  @override
  String get nutritionFieldCalories => 'カロリー';

  @override
  String get scannerStatusAnalyzing => '分析中...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => '食品名';

  @override
  String get scannerFieldGrams => 'グラム数';

  @override
  String get scannerFieldCalories => 'カロリー';

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
    return '今日は残り$calories kcal、たんぱく質${grams}gです';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '1日の目標を$calories kcal超えています';
  }

  @override
  String get scannerButtonAnalyzing => '分析中';

  @override
  String get scannerButtonQuotaNeeded => 'クォータが必要';

  @override
  String get scannerButtonScanNow => '今すぐスキャン';

  @override
  String get scannerButtonLogging => '記録中';

  @override
  String get scannerButtonLogMeal => '食事を記録';

  @override
  String get scannerNoClearFood => '食品をまだはっきり検出できません。明るい場所で試すか、カメラを近づけてください。';

  @override
  String get scannerErrorCameraPermission => '食事をスキャンするにはカメラの許可が必要です。';

  @override
  String get scannerErrorBackendMissing => 'カロリースキャナーのバックエンドがまだ設定されていません。';

  @override
  String get scannerErrorApiKeyInvalid =>
      'カロリースキャン用のOpenAI APIキーが無効です。バックエンド環境のキーを置き換えて再デプロイし、もう一度お試しください。';

  @override
  String get scannerErrorApiKeyMissing =>
      'カロリースキャンにはOpenAI APIキーが必要です。Vercelに追加して再デプロイし、もう一度お試しください。';

  @override
  String get scannerErrorQuotaExhausted =>
      'カロリースキャン用のOpenAIクレジットを使い切りました。APIクレジットを追加するか請求上限を引き上げて、もう一度お試しください。';

  @override
  String get scannerErrorTimeout =>
      'Celiaによる食事の分析に時間がかかっています。カメラを固定して、もう一度スキャンしてください。';

  @override
  String get scannerErrorNotSignedIn => '食事をスキャンする前にサインインしてください。';

  @override
  String get scannerErrorMealTableMissing =>
      '食事記録テーブルの準備がまだできていません。スキャン結果は引き続き利用できます。';

  @override
  String get scannerErrorGeneric =>
      'Celiaはまだこの食事を分析できません。カメラを固定し、食品を中央に収めて、もう一度スキャンしてください。';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count品',
      one: '$count品',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => '食事の詳細';

  @override
  String get nutritionFoodItems => '食品項目';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem => '食事には少なくとも1つの食品項目が必要です。';

  @override
  String get nutritionMealUpdated => '食事を更新しました';

  @override
  String nutritionUpdateFailed(String error) {
    return '食事を更新できませんでした：$error';
  }

  @override
  String get nutritionDeleteMealTitle => '食事を削除しますか？';

  @override
  String get nutritionDeleteMealBody => '栄養履歴からこの食事を削除します。';

  @override
  String get nutritionDeleteMeal => '食事を削除';

  @override
  String nutritionDeleteFailed(String error) {
    return '食事を削除できませんでした：$error';
  }

  @override
  String get nutritionEditFood => '食品を編集';

  @override
  String get nutritionSaveFood => '食品を保存';

  @override
  String get nutritionLoadFailed => '食事を読み込めませんでした';

  @override
  String get nutritionLoadFailedBody => '下にスワイプして更新するか、バックエンド接続を確認してください。';

  @override
  String get nutritionNoMeals => 'まだ食事が記録されていません';

  @override
  String get nutritionNoMealsBody => '最初の食事をスキャンすると、Celiaが栄養履歴を作成します。';

  @override
  String get progressToday => '今日';

  @override
  String get progressSetGoals => '栄養目標を設定して、カロリーとマクロのトラッキングを利用しましょう。';

  @override
  String progressOfTarget(int target) {
    return '$target kcal中';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcalオーバー';
  }

  @override
  String progressKcalLeft(int calories) {
    return '残り$calories kcal';
  }

  @override
  String get progressProtein => 'タンパク質';

  @override
  String get progressCarbs => '炭水化物';

  @override
  String get progressFat => '脂質';

  @override
  String get scannerEditItem => '食品項目を編集';

  @override
  String get scannerSaveChanges => '変更を保存';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return '信頼度 $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count個の項目をこの食事記録に追加';
  }

  @override
  String get scannerIfYouLog => 'この食事を記録すると';

  @override
  String scannerAfterLogging(int after, int target) {
    return '今日の$after / $target kcal';
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
  String get scannerNoMealDetected => '食事を検出できませんでした';

  @override
  String onboardingWelcome(String name) {
    return 'ようこそ、$nameさん';
  }

  @override
  String get onboardingGender => '性別';

  @override
  String get onboardingCalculateGoals => '目標を計算';

  @override
  String get onboardingScanFirstMeal => '最初の食事をスキャン';

  @override
  String get onboardingExploreRoutines => 'ルーティンを見る';

  @override
  String get onboardingGoHome => 'ホームへ';

  @override
  String get onboardingDailyTargets => '1日の目標';

  @override
  String onboardingProtein(int grams) {
    return 'タンパク質 ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'タンパク質 ${protein}g • 炭水化物 ${carbs}g • 脂質 ${fat}g';
  }

  @override
  String get onboardingTargetsReady => '1日の栄養目標が準備できました。始め方を選択してください。';

  @override
  String get onboardingWeightKg => '体重（kg）';

  @override
  String get onboardingHeightCm => '身長（cm）';

  @override
  String get onboardingAge => '年齢';

  @override
  String get onboardingInvalidWeight => '有効な体重をkg単位で入力してください。';

  @override
  String get onboardingInvalidHeight => '有効な身長をcm単位で入力してください。';

  @override
  String get onboardingInvalidAge => '13～100歳の有効な年齢を入力してください。';

  @override
  String get onboardingSaveFailed => '栄養プロフィールを保存できませんでした。';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => 'その他';

  @override
  String get nutritionSetupTitle => '1日の栄養目標';

  @override
  String get nutritionSetupBody => 'Celiaが1日のカロリーとマクロを計算できるよう、体について教えてください。';

  @override
  String get nutritionSetupGender => '性別';

  @override
  String get nutritionSetupFootnote =>
      'Celiaは体重、身長、年齢、性別をもとに、適度な活動レベルで1日のカロリーとマクロの目標を推定します。';

  @override
  String get nutritionSourcesTitle => 'これらの目標の計算方法';

  @override
  String get nutritionSourcesBody =>
      '1日のカロリーは、Mifflin–St Jeorの安静時エネルギー式に中程度の身体活動係数（約1.55）を用いて算出します。タンパク質は活動的な成人向けに体重1kgあたり約1.8gで推定します。脂質はカロリーの約25%とし、残りを炭水化物が埋めます——一般的な食事指導の範囲内です。';

  @override
  String get nutritionSourcesDisclaimer =>
      'これらの数値は一般的なウェルネスの目安にすぎません。診断や処方がなく、資格を持つ臨床医や管理栄養士の助言の代わりにもなりません。';

  @override
  String get nutritionSetupSave => '目標を保存';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'メンバー';

  @override
  String get profileAccount => 'アカウント';

  @override
  String profileSignedInAs(String email) {
    return 'ログイン中のアカウント：\n$email';
  }

  @override
  String get profileUnknownEmail => '不明';

  @override
  String get profileDarkMode => 'ダークモード';

  @override
  String get profileAvatarMode => 'アバターモード';

  @override
  String get profileAvatarModeSubtitle => 'Celiaと全画面で話す';

  @override
  String get profileLanguage => '言語';

  @override
  String get profileLogOutTitle => 'ログアウトしますか？';

  @override
  String get profileLogOutBody => '本当にログアウトしますか？';

  @override
  String get profileLogOut => 'ログアウト';

  @override
  String get profileLogOutButton => 'ログアウト';

  @override
  String get profileDeleteAccount => 'アカウントを削除';

  @override
  String get profileDeleteAccountConfirmTitle => 'アカウントを削除しますか？';

  @override
  String get profileDeleteAccountConfirmBody =>
      'これにより、アカウントと保存済みルーティン、食事ログ、チャット履歴を含むすべてのデータが完全に削除されます。元に戻すことはできません。';

  @override
  String get profileDeleteAccountPasswordPrompt => '確認のためパスワードを入力してください。';

  @override
  String get profileDeleteAccountPasswordLabel => 'パスワード';

  @override
  String get profileDeleteAccountButton => 'アカウントを削除する';

  @override
  String get profileFavoriteRoutines => 'お気に入りのルーティン';

  @override
  String get profileSubscription => 'サブスクリプション';

  @override
  String get profileNutrition => '栄養';

  @override
  String get profileHelpSupport => 'ヘルプとサポート';

  @override
  String get profileFriend => 'フレンド';

  @override
  String get profileStatSaved => '保存済み';

  @override
  String get profileStatStreak => '連続記録';

  @override
  String get profileStatWorkouts => 'ワークアウト';

  @override
  String get streakDayOneStarted => '1日目がスタートしました — 明日も戻ってきて、連続記録を伸ばしましょう。';

  @override
  String get streakRebuild =>
      '昨日はアクティブでした — 今日、食事を記録するかワークアウトを完了して、連続記録を再開しましょう。';

  @override
  String get streakStart => '食事を記録するかワークアウトを完了して、連続記録を始めましょう。';

  @override
  String streakLongRun(int days) {
    return '$days日連続！続けていきましょう — Celiaがあなたの継続状況を記録しています。';
  }

  @override
  String streakBothLogged(int days) {
    return '$days日連続 — 今日はワークアウトと食事の両方を記録しました。';
  }

  @override
  String streakNeedWorkout(int days) {
    return '$days日連続。短いワークアウトを追加すれば、今日の記録がさらに充実します。';
  }

  @override
  String streakNeedMeal(int days) {
    return '$days日連続。食事を記録して、栄養補給を管理しましょう。';
  }

  @override
  String streakStayActive(int days) {
    return '$days日連続 — 今日もアクティブに過ごしましょう。';
  }

  @override
  String get editProfileTitle => 'プロフィールを編集';

  @override
  String get editProfileName => '名前';

  @override
  String get editProfileFootnote => '変更内容はアカウントに保存され、ホームとプロフィールに反映されます。';

  @override
  String get editProfileSaveFailed => 'プロフィールを更新できませんでした。もう一度お試しください。';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => '端末の言語';

  @override
  String get languageSystemSubtitle => 'スマートフォンの設定言語に合わせる';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get insightStartFuelingTitle => '今日の栄養補給を始めましょう';

  @override
  String get insightStartFuelingBody =>
      '1日のカロリー予算がすべて残っています。最初の食事をスキャンまたは記録して、目標どおりに進めましょう。';

  @override
  String get insightAboveTargetTitle => '今日は目標を超えています';

  @override
  String insightAboveTargetBody(int calories) {
    return '1日の目標を$calories kcal上回っています。夕食を軽めにするか、短いワークアウトを追加しましょう。';
  }

  @override
  String get insightLowProteinTitle => 'まだタンパク質が不足しています';

  @override
  String insightLowProteinBody(int grams) {
    return '目標達成まで、今日はあと約${grams}gのタンパク質が必要です。';
  }

  @override
  String get insightAlmostThereTitle => '目標まであと少し';

  @override
  String insightAlmostThereBody(int calories) {
    return '今日はあと$calories kcalです。バランスのよいスナックなら無理なく収まります。';
  }

  @override
  String get insightOnTrackTitle => '今日は順調です';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return '1日の目標達成まで、あと$calories kcalと${grams}gのタンパク質です。';
  }

  @override
  String get insightWeeklyRhythmTitle => '1週間のリズムを作りましょう';

  @override
  String get insightWeeklyRhythmBody =>
      '1週間を通して食事を記録すると、Celiaがパターンを見つけて、より適切にサポートできます。';

  @override
  String get insightWeeklyTrendTitle => '週間トレンド';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return '過去7日間のうち$days日で食事を記録し、平均$average kcalでした — $direction。';
  }

  @override
  String get insightTrendOnTarget => '1日の目標付近';

  @override
  String insightTrendAbove(int delta) {
    return '平均で目標を$delta kcal上回っています';
  }

  @override
  String insightTrendBelow(int delta) {
    return '平均で目標を$delta kcal下回っています';
  }

  @override
  String get insightsSectionTitle => 'Celiaのインサイト';
}
