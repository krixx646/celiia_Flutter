// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Celia — ваш фитнес-тренер';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionSeeAll => 'Посмотреть все';

  @override
  String get actionYesDoIt => 'Да, сделать';

  @override
  String get actionNotNow => 'Не сейчас';

  @override
  String get loadingPreparing => 'Celia готовится...';

  @override
  String get loadingGeneric => 'Загрузка...';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorCanceled => 'Действие отменено.';

  @override
  String get errorTooManyRequests =>
      'Слишком много попыток. Подождите минуту и попробуйте ещё раз.';

  @override
  String get errorNetwork =>
      'Проверьте подключение к интернету и попробуйте ещё раз.';

  @override
  String get errorBadCredentials =>
      'Неверный адрес электронной почты или пароль.';

  @override
  String get errorEmailInUse =>
      'Этот адрес электронной почты уже используется. Попробуйте войти.';

  @override
  String get errorWeakPassword =>
      'Используйте более надёжный пароль и попробуйте ещё раз.';

  @override
  String get errorInvalidEmail =>
      'Введите действительный адрес электронной почты.';

  @override
  String get errorNoPermission => 'У вас нет разрешения на это действие.';

  @override
  String get errorNotSignedIn => 'Войдите в аккаунт и попробуйте ещё раз.';

  @override
  String get errorNoConversation => 'Начните новый чат, чтобы продолжить.';

  @override
  String get errorNoPlayableVideos =>
      'Для этой тренировки пока нет доступных видео для воспроизведения.';

  @override
  String get errorLoadRoutines =>
      'Не удалось загрузить тренировки. Попробуйте ещё раз.';

  @override
  String get errorLoadSavedRoutines =>
      'Не удалось загрузить сохранённые тренировки. Попробуйте ещё раз.';

  @override
  String get errorGenerateRoutine =>
      'Не удалось создать тренировку. Попробуйте ещё раз.';

  @override
  String get errorLoadChats => 'Не удалось загрузить сохранённые чаты.';

  @override
  String get errorCeliaUnavailable =>
      'Celia сейчас недоступна. Попробуйте ещё раз.';

  @override
  String get errorOpenConversation => 'Не удалось открыть этот разговор.';

  @override
  String get errorDeleteConversation =>
      'Не удалось удалить этот разговор. Попробуйте ещё раз.';

  @override
  String get errorSignIn => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get errorCreateAccount =>
      'Не удалось создать аккаунт. Попробуйте ещё раз.';

  @override
  String get errorSendResetEmail =>
      'Не удалось отправить письмо для сброса пароля. Попробуйте ещё раз.';

  @override
  String get errorSendVerificationEmail =>
      'Не удалось отправить письмо с подтверждением. Попробуйте ещё раз.';

  @override
  String get errorGoogleSignIn =>
      'Не удалось войти через Google. Попробуйте ещё раз.';

  @override
  String get errorAppleSignIn =>
      'Не удалось войти через Apple. Попробуйте ещё раз.';

  @override
  String get errorRefreshNutrition => 'Не удалось обновить данные о питании.';

  @override
  String get errorLoadNutritionProfile =>
      'Не удалось загрузить ваш профиль питания.';

  @override
  String get startupErrorTitle => 'Не удалось запустить приложение';

  @override
  String get startupErrorBody =>
      'Закройте и снова откройте приложение. Если проблема не исчезнет, обратитесь в службу поддержки.';

  @override
  String get authTagline => 'Ваш фитнес-помощник';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authLogIn => 'Войти';

  @override
  String authVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authOr => 'ИЛИ';

  @override
  String get authContinueWithGoogle => 'Продолжить через Google';

  @override
  String get authContinueWithApple => 'Продолжить через Apple';

  @override
  String get authAuthenticating => 'Выполняется вход...';

  @override
  String get authEnterYourName => 'Введите своё имя.';

  @override
  String get authNeedAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get authFieldName => 'Ваше имя';

  @override
  String get authFieldEmail => 'Электронная почта';

  @override
  String get authFieldPassword => 'Пароль';

  @override
  String get verifyEmailTitle => 'Подтвердите адрес электронной почты';

  @override
  String get verifyEmailHeading => 'Проверьте входящие сообщения';

  @override
  String get verifyEmailBody =>
      'Ссылка для подтверждения отправлена на вашу электронную почту.';

  @override
  String get verifyEmailSent => 'Письмо с подтверждением отправлено!';

  @override
  String get verifyEmailContinue => 'Я подтвердил(а), продолжить';

  @override
  String get verifyEmailSignOut => 'Выйти';

  @override
  String get verifyEmailSending => 'Отправка...';

  @override
  String get verifyEmailResend => 'Отправить письмо с подтверждением повторно';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Повторная отправка через $seconds с';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'Электронная почта: $email';
  }

  @override
  String get forgotPasswordTitle => 'Забыли пароль';

  @override
  String get forgotPasswordBody =>
      'Введите электронную почту, чтобы получить ссылку для сброса пароля.';

  @override
  String get forgotPasswordEmptyEmail => 'Введите электронную почту';

  @override
  String get forgotPasswordSent => 'Письмо для сброса пароля отправлено.';

  @override
  String get forgotPasswordSend => 'Отправить ссылку для сброса';

  @override
  String get forgotPasswordSending => 'Отправка...';

  @override
  String get nameSetupTitle => 'Как Celia должна к вам обращаться?';

  @override
  String get nameSetupBody =>
      'Мы используем ваше имя в приложении, чтобы тренировки были более персональными.';

  @override
  String get nameSetupSaveFailed =>
      'Не удалось сохранить имя. Попробуйте ещё раз.';

  @override
  String get homeGoodMorning => 'Доброе утро,';

  @override
  String get homeCeliaActive => 'CELIA АКТИВНА';

  @override
  String get homeGenerateRoutine =>
      'Создайте свою\nперсональную\nпрограмму с ИИ';

  @override
  String get homeCreateRoutine => 'Создать программу';

  @override
  String get homeQuickActions => 'Быстрые действия';

  @override
  String get homeUpNext => 'Далее';

  @override
  String get homeNoUpcoming =>
      'Предстоящих программ пока нет.\nСоздайте программу или откройте библиотеку.';

  @override
  String get homeChatWithCelia => 'Чат с Celia';

  @override
  String get homeChatSubtitle => 'Спросите о технике или питании';

  @override
  String get homeScanMeal => 'Сканировать блюдо';

  @override
  String get homeScanMealSubtitle => 'Определить продукты и калории';

  @override
  String get homeNutrition => 'Питание';

  @override
  String get homeNutritionSubtitle =>
      'Просмотр калорий, макронутриентов и блюд';

  @override
  String get homeBrowseLibrary => 'Открыть\nбиблиотеку';

  @override
  String get homeTrackProgress => 'Отслеживать\nпрогресс';

  @override
  String get chatTitle => 'Тренер Celia';

  @override
  String get chatEmptyPrompt =>
      'Как я могу помочь вам\nсегодня прийти в форму?';

  @override
  String get chatYourChats => 'Ваши чаты';

  @override
  String get chatNoSavedChats => 'Сохранённых чатов пока нет.';

  @override
  String get chatHistory => 'История чатов';

  @override
  String get chatNew => 'Новый чат';

  @override
  String get chatOpening => 'Открытие чата...';

  @override
  String get chatScanAMeal => 'Сканировать блюдо';

  @override
  String get chatInputHint => 'Спросите Celia о своих тренировках...';

  @override
  String get chatCouldNotOpenRoutine => 'Не удалось открыть эту программу';

  @override
  String get chatThisRoutine => 'эту программу';

  @override
  String get chatThisMeal => 'это блюдо';

  @override
  String get chatYourRoutine => 'Ваша программа';

  @override
  String chatMoreExercises(int count) {
    return '+ $count ещё';
  }

  @override
  String get chatEmptySubtitle =>
      'Спросите о тренировках, питании или прогрессе.';

  @override
  String chatLoggedToday(int calories) {
    return 'Сегодня вы записали $calories kcal.';
  }

  @override
  String get chatSuggestionHiit =>
      'Составь для меня 20-минутную HIIT-тренировку';

  @override
  String get chatSuggestionDinner => 'Что мне съесть сегодня вечером?';

  @override
  String get chatSuggestionProgress => 'Каковы мои результаты на этой неделе?';

  @override
  String get chatSuggestionIngredients => 'У меня есть курица, рис и шпинат';

  @override
  String get chatJustNow => 'Только что';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days д назад';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Уже в вашей библиотеке — нажмите, чтобы открыть';

  @override
  String get chatRoutineTapToOpen => 'Нажмите, чтобы открыть';

  @override
  String get chatToolCancelled => 'Отменено';

  @override
  String chatToolFailed(String label) {
    return '$label — не удалось выполнить';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Не удалось сохранить программу';

  @override
  String get chatToolRoutineSaved => 'Сохранено в вашей библиотеке';

  @override
  String get chatToolMealLogged => 'Добавлено в сегодняшний журнал';

  @override
  String get chatToolRoutineAdded => 'Добавлено в вашу библиотеку';

  @override
  String get activityCheckingProgress => 'Проверяем ваш прогресс';

  @override
  String get activityCheckingNutrition => 'Проверяем, что вы сегодня съели';

  @override
  String get activityReviewingMeals =>
      'Просматриваем ваши недавние приёмы пищи';

  @override
  String get activityLookingAtRoutines => 'Просматриваем ваши программы';

  @override
  String get activityReadingRoutine => 'Изучаем эту программу';

  @override
  String get activitySearchingLibrary => 'Ищем в библиотеке упражнений';

  @override
  String get activityBuildingRoutine => 'Составляем вашу программу';

  @override
  String get activityLoggingMeal => 'Добавляем приём пищи в журнал';

  @override
  String get activitySavingToLibrary => 'Сохраняем в библиотеку';

  @override
  String get activityWorking => 'Работаем над этим';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Сохранить «$name» с $count упражнениями в библиотеку?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Сохранить «$name» в библиотеку?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Добавить «$name» — $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Добавить «$name»?';
  }

  @override
  String get approvalAddRoutine => 'Добавить эту программу в библиотеку?';

  @override
  String get approvalGeneric => 'Разрешить Celia это сделать?';

  @override
  String get libraryTitle => 'Библиотека программ';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шагов',
      one: '$count шаг',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Программ пока нет';

  @override
  String get libraryEmptyBody =>
      'Создавайте и публикуйте программы в панели администратора.';

  @override
  String get libraryLoadFailed => 'Не удалось загрузить программы';

  @override
  String get routineStartWorkout => 'Начать тренировку';

  @override
  String get routineNoSteps => 'Нет доступных шагов';

  @override
  String get routineNoVideoForStep => 'Для этого шага нет видео';

  @override
  String get routineVideoProcessing =>
      'Видео ещё обрабатывается. Повторите попытку позже.';

  @override
  String get routineMissingPlaybackUrl =>
      'Для этого видео отсутствует URL воспроизведения';

  @override
  String get routinePreviewBanner =>
      'ПРЕДПРОСМОТР — полное видео скоро будет доступно';

  @override
  String get routinePreview => 'ПРЕДПРОСМОТР';

  @override
  String get routineDetails => 'Подробнее';

  @override
  String get routineNotFound => 'Программа не найдена';

  @override
  String routineCompletedTimes(int count) {
    return 'Выполнено: $count раз';
  }

  @override
  String get playerVideoUnavailable => 'Это видео сейчас недоступно.';

  @override
  String get playerSteps => 'Шаги';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos =>
      'Нет доступных для воспроизведения видео';

  @override
  String get playerWorkoutComplete => 'Тренировка завершена!';

  @override
  String get playerSavingStreak => 'Сохраняем в вашу серию…';

  @override
  String get playerSavedStreak => 'Сохранено в вашу серию';

  @override
  String get playerRetrySave => 'Повторить сохранение';

  @override
  String get playerReplay => 'Воспроизвести снова';

  @override
  String get playerNotReady => 'Плеер не готов';

  @override
  String get playerPreviewUnavailable => 'Предпросмотр сейчас недоступен.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Клип $current из $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Ошибка загрузки видео';

  @override
  String get playerLoadingVideo => 'Загрузка видео...';

  @override
  String get playerFailedToLoadVideo => 'Не удалось загрузить видео';

  @override
  String get playerNotInitialized => 'Видеоплеер не инициализирован';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Упражнение $current/$total';
  }

  @override
  String get guidedGetReady => 'ПРИГОТОВЬТЕСЬ';

  @override
  String guidedSetOf(int current, int total) {
    return 'Подход $current из $total';
  }

  @override
  String get guidedRest => 'ОТДЫХ';

  @override
  String get guidedSkipRest => 'Пропустить отдых';

  @override
  String get guidedPaused => 'Пауза';

  @override
  String get guidedResume => 'Продолжить';

  @override
  String get guidedWorkoutComplete => 'Тренировка завершена';

  @override
  String get guidedEndTitle => 'Завершить тренировку?';

  @override
  String get guidedEndBody =>
      'Ваш прогресс за эту тренировку не будет сохранён.';

  @override
  String get guidedKeepGoing => 'Продолжить';

  @override
  String get guidedEnd => 'Завершить';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count повторов',
      one: '$count повтор',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Создать план с помощью ИИ';

  @override
  String get generateSheetPrompt => 'Какую тренировку вы хотите?';

  @override
  String get generateSheetHint =>
      'например, «Короткая утренняя растяжка, чтобы проснуться» или «Силовая тренировка для всего тела для начинающих»';

  @override
  String get generateSheetDuration => 'Продолжительность';

  @override
  String generateSheetMinutes(int count) {
    return '$count мин';
  }

  @override
  String get generateSheetDifficulty => 'Сложность';

  @override
  String get generateSheetEquipment => 'Доступное оборудование';

  @override
  String get generateSheetGenerating => 'Создание…';

  @override
  String get generateSheetSubmit => 'Создать план';

  @override
  String get generateSheetDescribeFirst => 'Опишите желаемую тренировку';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'У вас уже есть такая: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Создано: $title';
  }

  @override
  String get generateSheetFailed => 'Не удалось создать план';

  @override
  String get guidedNoExercises => 'В этом плане пока нет упражнений.';

  @override
  String get guidedStartFailed =>
      'Не удалось начать тренировку. Попробуйте ещё раз.';

  @override
  String get guidedSaveFailed =>
      'Не удалось сохранить тренировку. Нажмите «Повторить», чтобы обновить серию.';

  @override
  String guidedOfReps(int count) {
    return 'из $count повторов';
  }

  @override
  String get guidedHold => 'удержание';

  @override
  String get guidedNextSet => 'Следующий подход';

  @override
  String get guidedUpNext => 'Далее';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds с удержания';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Приготовьтесь. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Начали. $count повторов.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Удерживайте $seconds секунд.';
  }

  @override
  String coachRest(String exercise) {
    return 'Отдых. Далее: $exercise';
  }

  @override
  String get coachRestShort => 'Отдых.';

  @override
  String get coachComplete => 'Отличная работа. Тренировка завершена.';

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
      'В этом плане нет доступных для воспроизведения видео.';

  @override
  String get playerLoadRoutineFailed =>
      'Не удалось загрузить план. Попробуйте ещё раз.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Не удалось загрузить «$title». Пропускаем…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Не удалось загрузить «$title».';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Не удалось сохранить завершение тренировки. Нажмите «Повторить», чтобы обновить серию.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Предпросмотр';
  }

  @override
  String get playerNoVideosReady =>
      'В этом плане пока нет готовых к воспроизведению видео.';

  @override
  String get playerPlaybackFailed =>
      'Не удалось воспроизвести видео. Попробуйте ещё раз.';

  @override
  String get libraryTabCurated => 'Подборки';

  @override
  String get libraryTabAiGenerated => 'Создано ИИ';

  @override
  String get profileSavedRoutines => 'Сохранённые планы';

  @override
  String get savedRoutinesNoFavorites => 'Избранных планов пока нет.';

  @override
  String get savedRoutinesEmpty => 'Сохранённых планов пока нет.';

  @override
  String get actionFavorite => 'В избранное';

  @override
  String get actionUnfavorite => 'Убрать из избранного';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours ч';
  }

  @override
  String get difficultyEasy => 'Лёгкая';

  @override
  String get difficultyMedium => 'Средняя';

  @override
  String get difficultyHard => 'Сложная';

  @override
  String get categoryStrength => 'Сила';

  @override
  String get categoryCardio => 'Кардио';

  @override
  String get categoryFlexibility => 'Гибкость';

  @override
  String get categoryMindfulness => 'Осознанность';

  @override
  String get categoryDance => 'Танцы';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Йога';

  @override
  String get categoryCustom => 'Пользовательская';

  @override
  String get navHome => 'Главная';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navChat => 'Чат';

  @override
  String get navProfile => 'Профиль';

  @override
  String get equipmentNone => 'Нет';

  @override
  String get equipmentDumbbells => 'Гантели';

  @override
  String get equipmentResistanceBands => 'Эспандеры';

  @override
  String get equipmentYogaMat => 'Коврик для йоги';

  @override
  String get equipmentKettlebell => 'Гиря';

  @override
  String get equipmentPullUpBar => 'Турник';

  @override
  String get equipmentJumpRope => 'Скакалка';

  @override
  String get nutritionTitle => 'Питание';

  @override
  String get nutritionSubtitle =>
      'Калории, макронутриенты и история приёмов пищи';

  @override
  String get nutritionSetGoalsTitle => 'Установите ежедневные цели питания';

  @override
  String get nutritionSetGoalsBody =>
      'Укажите вес, рост, возраст и пол, чтобы Celia могла рассчитать, сколько калорий и питательных веществ вам нужно потреблять каждый день.';

  @override
  String get nutritionSetUpGoals => 'Настроить цели';

  @override
  String get nutritionDailyTarget => 'Дневная норма';

  @override
  String get nutritionDailyGoals => 'Дневные цели';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'Б $protein г · У $carbs г · Ж $fat г';
  }

  @override
  String get nutritionToday => 'Сегодня';

  @override
  String get nutritionMealHistory => 'История приёмов пищи';

  @override
  String get nutritionCeliaInsights => 'Аналитика Celia';

  @override
  String get nutritionWeeklyTrend => 'Недельная динамика';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count приёма пищи',
      one: '$count приём пищи',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count приёма пищи',
      one: '$count приём пищи',
    );
    return 'из $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'П,В,С,Ч,П,С,В';

  @override
  String get nutritionFieldFoodName => 'Название продукта';

  @override
  String get nutritionFieldGrams => 'Граммы';

  @override
  String get nutritionFieldCalories => 'Калории';

  @override
  String get scannerStatusAnalyzing => 'АНАЛИЗ...';

  @override
  String get scannerStatusIdle => 'СКАНЕР CELIA';

  @override
  String get scannerFieldFoodName => 'Название продукта';

  @override
  String get scannerFieldGrams => 'Граммы';

  @override
  String get scannerFieldCalories => 'Калории';

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
    return 'Сегодня осталось $calories kcal и $grams г белка';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return 'Превышение дневной нормы на $calories kcal';
  }

  @override
  String get scannerButtonAnalyzing => 'Анализ';

  @override
  String get scannerButtonQuotaNeeded => 'Нужна квота';

  @override
  String get scannerButtonScanNow => 'Сканировать';

  @override
  String get scannerButtonLogging => 'Запись';

  @override
  String get scannerButtonLogMeal => 'Записать приём пищи';

  @override
  String get scannerNoClearFood =>
      'Продукт пока не распознан. Попробуйте улучшить освещение или поднесите камеру ближе.';

  @override
  String get scannerErrorCameraPermission =>
      'Для сканирования приёмов пищи нужен доступ к камере.';

  @override
  String get scannerErrorBackendMissing =>
      'Серверная часть сканера калорий ещё не настроена.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'Ключ OpenAI API для сканирования калорий недействителен. Замените его в окружении серверной части, разверните приложение заново и повторите попытку.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Для сканирования калорий требуется ключ OpenAI API. Добавьте его в Vercel, разверните приложение заново и повторите попытку.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Кредиты OpenAI для сканирования калорий исчерпаны. Пополните кредиты API или увеличьте лимит оплаты, затем повторите попытку.';

  @override
  String get scannerErrorTimeout =>
      'Celia потребовалось больше времени для анализа этого блюда. Держите камеру неподвижно и отсканируйте его снова.';

  @override
  String get scannerErrorNotSignedIn =>
      'Перед сканированием приёмов пищи войдите в аккаунт.';

  @override
  String get scannerErrorMealTableMissing =>
      'Таблица для записи приёмов пищи ещё не готова. Результат сканирования всё ещё доступен.';

  @override
  String get scannerErrorGeneric =>
      'Celia пока не смогла проанализировать это блюдо. Держите камеру неподвижно, расположите еду по центру и отсканируйте снова.';

  @override
  String nutritionGrams(String grams) {
    return '$grams г';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продукта',
      one: '$count продукт',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Детали приёма пищи';

  @override
  String get nutritionFoodItems => 'Продукты';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Приём пищи должен содержать хотя бы один продукт.';

  @override
  String get nutritionMealUpdated => 'Приём пищи обновлён';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Не удалось обновить приём пищи: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Удалить приём пищи?';

  @override
  String get nutritionDeleteMealBody =>
      'Приём пищи будет удалён из истории питания.';

  @override
  String get nutritionDeleteMeal => 'Удалить приём пищи';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Не удалось удалить приём пищи: $error';
  }

  @override
  String get nutritionEditFood => 'Редактировать продукт';

  @override
  String get nutritionSaveFood => 'Сохранить продукт';

  @override
  String get nutritionLoadFailed => 'Не удалось загрузить приёмы пищи';

  @override
  String get nutritionLoadFailedBody =>
      'Потяните вниз, чтобы обновить, или проверьте подключение к серверу.';

  @override
  String get nutritionNoMeals => 'Приёмы пищи ещё не добавлены';

  @override
  String get nutritionNoMealsBody =>
      'Отсканируйте свой первый приём пищи, и Celia начнёт вести историю питания.';

  @override
  String get progressToday => 'Сегодня';

  @override
  String get progressSetGoals =>
      'Установите цели питания, чтобы отслеживать калории и макронутриенты.';

  @override
  String progressOfTarget(int target) {
    return 'из $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return 'Превышение на $calories kcal';
  }

  @override
  String progressKcalLeft(int calories) {
    return 'Осталось $calories kcal';
  }

  @override
  String get progressProtein => 'Белки';

  @override
  String get progressCarbs => 'Углеводы';

  @override
  String get progressFat => 'Жиры';

  @override
  String get scannerEditItem => 'Редактировать продукт';

  @override
  String get scannerSaveChanges => 'Сохранить изменения';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Уверенность $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count дополнительных продуктов включено в этот приём пищи';
  }

  @override
  String get scannerIfYouLog => 'Если добавить этот приём пищи';

  @override
  String scannerAfterLogging(int after, int target) {
    return 'Сегодня: $after / $target kcal';
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
  String get scannerNoMealDetected => 'Приём пищи не обнаружен';

  @override
  String onboardingWelcome(String name) {
    return 'Добро пожаловать, $name';
  }

  @override
  String get onboardingGender => 'Пол';

  @override
  String get onboardingCalculateGoals => 'Рассчитать мои цели';

  @override
  String get onboardingScanFirstMeal => 'Отсканировать первый приём пищи';

  @override
  String get onboardingExploreRoutines => 'Посмотреть тренировки';

  @override
  String get onboardingGoHome => 'На главную';

  @override
  String get onboardingDailyTargets => 'Ваши ежедневные цели';

  @override
  String onboardingProtein(int grams) {
    return 'Белки ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Белки ${protein}g • Углеводы ${carbs}g • Жиры ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Ваши ежедневные цели по питанию готовы. Выберите, с чего хотите начать.';

  @override
  String get onboardingWeightKg => 'Вес (кг)';

  @override
  String get onboardingHeightCm => 'Рост (см)';

  @override
  String get onboardingAge => 'Возраст';

  @override
  String get onboardingInvalidWeight => 'Введите корректный вес в кг.';

  @override
  String get onboardingInvalidHeight => 'Введите корректный рост в см.';

  @override
  String get onboardingInvalidAge =>
      'Введите корректный возраст от 13 до 100 лет.';

  @override
  String get onboardingSaveFailed => 'Не удалось сохранить профиль питания.';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get genderOther => 'Другой';

  @override
  String get nutritionSetupTitle => 'Ежедневные цели питания';

  @override
  String get nutritionSetupBody =>
      'Расскажите Celia о своём теле, чтобы она могла рассчитать вашу ежедневную норму калорий и макронутриентов.';

  @override
  String get nutritionSetupGender => 'Пол';

  @override
  String get nutritionSetupFootnote =>
      'Celia использует ваш вес, рост, возраст и пол, чтобы оценить ежедневные цели по калориям и макронутриентам при умеренном уровне активности.';

  @override
  String get nutritionSetupSave => 'Сохранить цели';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Элитный участник';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String profileSignedInAs(String email) {
    return 'Выполнен вход как:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Неизвестно';

  @override
  String get profileDarkMode => 'Тёмная тема';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileLogOutTitle => 'Выйти?';

  @override
  String get profileLogOutBody => 'Вы уверены, что хотите выйти?';

  @override
  String get profileLogOut => 'Выйти';

  @override
  String get profileLogOutButton => 'Выйти';

  @override
  String get profileFavoriteRoutines => 'Избранные тренировки';

  @override
  String get profileSubscription => 'Подписка';

  @override
  String get profileNutrition => 'Питание';

  @override
  String get profileHelpSupport => 'Помощь и поддержка';

  @override
  String get profileFriend => 'Друг';

  @override
  String get profileStatSaved => 'Сохранено';

  @override
  String get profileStatStreak => 'Серия';

  @override
  String get profileStatWorkouts => 'Тренировки';

  @override
  String get streakDayOneStarted =>
      'День 1 начался — возвращайтесь завтра, чтобы продолжить серию.';

  @override
  String get streakRebuild =>
      'Вчера вы были активны — сегодня запишите приём пищи или завершите тренировку, чтобы восстановить серию.';

  @override
  String get streakStart =>
      'Запишите приём пищи или завершите тренировку, чтобы начать серию активности.';

  @override
  String streakLongRun(int days) {
    return 'Серия из $days дней! Продолжайте в том же духе — Celia отслеживает вашу регулярность.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Серия из $days дней — сегодня отмечены и тренировка, и питание.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Серия из $days дней. Короткая тренировка поможет завершить сегодняшний день.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Серия из $days дней. Запишите приём пищи, чтобы отслеживать питание.';
  }

  @override
  String streakStayActive(int days) {
    return 'Серия из $days дней — оставайтесь активными сегодня.';
  }

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get editProfileName => 'Имя';

  @override
  String get editProfileFootnote =>
      'Изменения сохраняются в вашем аккаунте и отображаются на главном экране и в профиле.';

  @override
  String get editProfileSaveFailed =>
      'Не удалось обновить профиль. Попробуйте ещё раз.';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystem => 'Язык устройства';

  @override
  String get languageSystemSubtitle =>
      'Использовать язык, установленный на телефоне';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get insightStartFuelingTitle => 'Начните питаться уже сегодня';

  @override
  String get insightStartFuelingBody =>
      'Ваш дневной лимит калорий ещё полностью доступен. Отсканируйте или запишите первый приём пищи, чтобы не сбиться с цели.';

  @override
  String get insightAboveTargetTitle => 'Сегодня вы превысили цель';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Сегодня вы превысили дневную цель на $calories kcal. Сделайте ужин легче или добавьте короткую тренировку.';
  }

  @override
  String get insightLowProteinTitle => 'Белка пока недостаточно';

  @override
  String insightLowProteinBody(int grams) {
    return 'Сегодня вам нужно ещё около $grams г белка, чтобы достичь цели.';
  }

  @override
  String get insightAlmostThereTitle => 'Вы почти у цели';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Сегодня осталось $calories kcal. Сбалансированный перекус отлично впишется в ваш план.';
  }

  @override
  String get insightOnTrackTitle => 'Сегодня всё по плану';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'До дневных целей осталось $calories kcal и $grams г белка.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Выработайте ритм на неделю';

  @override
  String get insightWeeklyRhythmBody =>
      'Записывайте приёмы пищи в течение недели, чтобы Celia могла выявлять закономерности и лучше вас консультировать.';

  @override
  String get insightWeeklyTrendTitle => 'Тенденция за неделю';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Вы записывали приёмы пищи $days из последних 7 дней, в среднем по $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget =>
      'примерно соответствует вашей дневной цели';

  @override
  String insightTrendAbove(int delta) {
    return 'в среднем на $delta kcal выше вашей цели';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'в среднем на $delta kcal ниже вашей цели';
  }

  @override
  String get insightsSectionTitle => 'Советы Celia';
}
