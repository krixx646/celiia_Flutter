// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionSeeAll => 'Ver todo';

  @override
  String get actionYesDoIt => 'Sí, adelante';

  @override
  String get actionNotNow => 'Ahora no';

  @override
  String get loadingPreparing => 'Preparando a Celia...';

  @override
  String get loadingGeneric => 'Cargando...';

  @override
  String get errorGeneric => 'Algo ha salido mal. Inténtalo de nuevo.';

  @override
  String get errorCanceled => 'Acción cancelada.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Espera un minuto e inténtalo de nuevo.';

  @override
  String get errorNetwork =>
      'Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errorBadCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get errorEmailInUse =>
      'Este correo ya está en uso. Prueba a iniciar sesión.';

  @override
  String get errorWeakPassword =>
      'Usa una contraseña más segura e inténtalo de nuevo.';

  @override
  String get errorInvalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get errorNoPermission => 'No tienes permiso para hacer eso.';

  @override
  String get errorNotSignedIn => 'Inicia sesión e inténtalo de nuevo.';

  @override
  String get errorDeleteAccount =>
      'We couldn\'t delete your account. Please try again.';

  @override
  String get errorNoConversation =>
      'Empieza una conversación nueva para continuar.';

  @override
  String get errorNoPlayableVideos =>
      'Aún no hay vídeos reproducibles para esta rutina.';

  @override
  String get errorLoadRoutines =>
      'No se pudieron cargar las rutinas ahora mismo. Inténtalo de nuevo.';

  @override
  String get errorLoadSavedRoutines =>
      'No se pudieron cargar las rutinas guardadas ahora mismo. Inténtalo de nuevo.';

  @override
  String get errorGenerateRoutine =>
      'No se pudo generar una rutina ahora mismo. Inténtalo de nuevo.';

  @override
  String get errorLoadChats =>
      'No se pueden cargar los chats guardados ahora mismo.';

  @override
  String get errorCeliaUnavailable =>
      'Celia no está disponible ahora mismo. Inténtalo de nuevo.';

  @override
  String get errorOpenConversation => 'No se pudo abrir esa conversación.';

  @override
  String get errorDeleteConversation =>
      'No se pudo eliminar esta conversación. Inténtalo de nuevo.';

  @override
  String get errorSignIn => 'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get errorCreateAccount =>
      'No se pudo crear tu cuenta. Inténtalo de nuevo.';

  @override
  String get errorSendResetEmail =>
      'No se pudo enviar el correo de restablecimiento. Inténtalo de nuevo.';

  @override
  String get errorSendVerificationEmail =>
      'No se pudo enviar el correo de verificación. Inténtalo de nuevo.';

  @override
  String get errorGoogleSignIn =>
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get errorAppleSignIn =>
      'No se pudo iniciar sesión con Apple. Inténtalo de nuevo.';

  @override
  String get errorRefreshNutrition =>
      'No se pudieron actualizar los datos de nutrición.';

  @override
  String get errorLoadNutritionProfile =>
      'No se pudo cargar tu perfil nutricional.';

  @override
  String get startupErrorTitle => 'No se puede iniciar la aplicación';

  @override
  String get startupErrorBody =>
      'Cierra la aplicación y vuelve a abrirla. Si el problema continúa, contacta con soporte.';

  @override
  String get authTagline => 'Tu compañera de entrenamiento';

  @override
  String get authSignUp => 'Crear cuenta';

  @override
  String get authLogIn => 'Iniciar sesión';

  @override
  String authVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authOr => 'O';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authContinueWithApple => 'Continuar con Apple';

  @override
  String get authAuthenticating => 'Autenticando...';

  @override
  String get authEnterYourName => 'Introduce tu nombre.';

  @override
  String get authNeedAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get authFieldName => 'Tu nombre';

  @override
  String get authFieldEmail => 'Correo electrónico';

  @override
  String get authFieldPassword => 'Contraseña';

  @override
  String get verifyEmailTitle => 'Verifica tu correo';

  @override
  String get verifyEmailHeading => 'Revisa tu bandeja de entrada';

  @override
  String get verifyEmailBody =>
      'Hemos enviado un enlace de verificación a tu correo.';

  @override
  String get verifyEmailSent => '¡Correo de verificación enviado!';

  @override
  String get verifyEmailContinue => 'Ya lo verifiqué, continuar';

  @override
  String get verifyEmailSignOut => 'Cerrar sesión';

  @override
  String get verifyEmailSending => 'Enviando...';

  @override
  String get verifyEmailResend => 'Reenviar correo de verificación';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'Correo: $email';
  }

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordBody =>
      'Introduce tu correo para recibir un enlace de restablecimiento.';

  @override
  String get forgotPasswordEmptyEmail => 'Introduce un correo electrónico';

  @override
  String get forgotPasswordSent => 'Correo de restablecimiento enviado.';

  @override
  String get forgotPasswordSend => 'Enviar enlace';

  @override
  String get forgotPasswordSending => 'Enviando...';

  @override
  String get nameSetupTitle => '¿Cómo quieres que Celia te llame?';

  @override
  String get nameSetupBody =>
      'Usamos tu nombre en toda la aplicación para que el entrenamiento sea más cercano.';

  @override
  String get nameSetupSaveFailed =>
      'No se pudo guardar tu nombre. Inténtalo de nuevo.';

  @override
  String get homeGoodMorning => 'Buenos días,';

  @override
  String get homeCeliaActive => 'CELIA ACTIVA';

  @override
  String get homeGenerateRoutine => 'Crea tu rutina\npersonalizada\ncon IA';

  @override
  String get homeCreateRoutine => 'Crear rutina';

  @override
  String get homeQuickActions => 'Acciones rápidas';

  @override
  String get homeUpNext => 'A continuación';

  @override
  String get homeNoUpcoming =>
      'Aún no tienes rutinas pendientes.\nCrea una o explora la biblioteca.';

  @override
  String get homeChatWithCelia => 'Habla con Celia';

  @override
  String get homeChatSubtitle => 'Pregunta sobre tu técnica o dieta';

  @override
  String get homeScanMeal => 'Escanear comida';

  @override
  String get homeScanMealSubtitle => 'Identifica alimentos y calorías';

  @override
  String get homeNutrition => 'Nutrición';

  @override
  String get homeNutritionSubtitle => 'Consulta calorías, macros y comidas';

  @override
  String get homeBrowseLibrary => 'Explorar\nbiblioteca';

  @override
  String get homeTrackProgress => 'Seguir\nprogreso';

  @override
  String get chatTitle => 'Entrenadora Celia';

  @override
  String get chatEmptyPrompt =>
      '¿En qué puedo ayudarte\nhoy con tu entrenamiento?';

  @override
  String get chatYourChats => 'Tus conversaciones';

  @override
  String get chatNoSavedChats => 'Aún no tienes conversaciones guardadas.';

  @override
  String get chatHistory => 'Historial de chats';

  @override
  String get chatNew => 'Nueva conversación';

  @override
  String get chatOpening => 'Abriendo conversación...';

  @override
  String get chatScanAMeal => 'Escanear una comida';

  @override
  String get chatInputHint =>
      'Pregúntale a Celia lo que quieras sobre tu entrenamiento...';

  @override
  String get chatMicTooltip => 'Hold to talk';

  @override
  String get chatListening => 'Listening…';

  @override
  String get chatMicDenied => 'Microphone access is needed to talk to Celia.';

  @override
  String get chatSpeechUnavailable =>
      'Speech recognition isn\'t available on this device.';

  @override
  String get chatCouldNotOpenRoutine => 'No se pudo abrir esa rutina';

  @override
  String get chatThisRoutine => 'esta rutina';

  @override
  String get chatThisMeal => 'esta comida';

  @override
  String get chatYourRoutine => 'Tu rutina';

  @override
  String chatMoreExercises(int count) {
    return '+ $count más';
  }

  @override
  String get chatEmptySubtitle =>
      'Pregúntame por tu entrenamiento, tu comida o tu progreso.';

  @override
  String chatLoggedToday(int calories) {
    return 'Hoy has registrado $calories kcal.';
  }

  @override
  String get chatSuggestionHiit => 'Créame una rutina HIIT de 20 minutos';

  @override
  String get chatSuggestionDinner => '¿Qué debería cenar hoy?';

  @override
  String get chatSuggestionProgress => '¿Cómo voy esta semana?';

  @override
  String get chatSuggestionIngredients => 'Tengo pollo, arroz y espinacas';

  @override
  String get chatJustNow => 'Ahora mismo';

  @override
  String chatMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String chatHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String chatDaysAgo(int days) {
    return 'hace $days d';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Ya está en tu biblioteca: toca para abrir';

  @override
  String get chatRoutineTapToOpen => 'Toca para abrir';

  @override
  String get chatToolCancelled => 'Cancelado';

  @override
  String chatToolFailed(String label) {
    return '$label: no funcionó';
  }

  @override
  String get chatToolRoutineSaveFailed => 'No se pudo guardar la rutina';

  @override
  String get chatToolRoutineSaved => 'Guardado en tu biblioteca';

  @override
  String get chatToolMealLogged => 'Añadido al registro de hoy';

  @override
  String get chatToolRoutineAdded => 'Añadido a tu biblioteca';

  @override
  String get activityCheckingProgress => 'Revisando tu progreso';

  @override
  String get activityCheckingNutrition => 'Revisando lo que has comido hoy';

  @override
  String get activityReviewingMeals => 'Revisando tus comidas recientes';

  @override
  String get activityLookingAtRoutines => 'Consultando tus rutinas';

  @override
  String get activityReadingRoutine => 'Leyendo esa rutina';

  @override
  String get activitySearchingLibrary =>
      'Buscando en la biblioteca de ejercicios';

  @override
  String get activityBuildingRoutine => 'Creando tu rutina';

  @override
  String get activityLoggingMeal => 'Registrando tu comida';

  @override
  String get activitySavingToLibrary => 'Guardando en tu biblioteca';

  @override
  String get activityWorking => 'Trabajando en ello';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return '¿Guardar «$name» con $count ejercicios en tu biblioteca?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '¿Guardar «$name» en tu biblioteca?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '¿Registrar «$name» con $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return '¿Registrar «$name»?';
  }

  @override
  String get approvalAddRoutine => '¿Añadir esta rutina a tu biblioteca?';

  @override
  String get approvalGeneric => '¿Permitir que Celia haga esto?';

  @override
  String get libraryTitle => 'Biblioteca de rutinas';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '$count ejercicio',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Aún no hay rutinas';

  @override
  String get libraryEmptyBody =>
      'Crea y publica rutinas desde el panel de administración.';

  @override
  String get libraryLoadFailed => 'No se pudieron cargar las rutinas';

  @override
  String get routineStartWorkout => 'Empezar entrenamiento';

  @override
  String get routineNoSteps => 'No hay ejercicios disponibles';

  @override
  String get routineNoVideoForStep =>
      'No hay vídeo disponible para este ejercicio';

  @override
  String get routineVideoProcessing =>
      'El vídeo se está procesando. Inténtalo de nuevo más tarde.';

  @override
  String get routineMissingPlaybackUrl =>
      'Falta la URL de reproducción de este vídeo';

  @override
  String get routinePreviewBanner => 'VISTA PREVIA — vídeo completo muy pronto';

  @override
  String get routinePreview => 'VISTA PREVIA';

  @override
  String get routineDetails => 'Detalles';

  @override
  String get routineNotFound => 'Rutina no encontrada';

  @override
  String routineCompletedTimes(int count) {
    return 'Completada $count veces';
  }

  @override
  String get playerVideoUnavailable =>
      'Este vídeo no está disponible en este momento.';

  @override
  String get playerSteps => 'Ejercicios';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'No hay vídeos reproducibles';

  @override
  String get playerWorkoutComplete => '¡Entrenamiento completado!';

  @override
  String get playerSavingStreak => 'Guardando en tu racha…';

  @override
  String get playerSavedStreak => 'Guardado en tu racha';

  @override
  String get playerRetrySave => 'Reintentar guardado';

  @override
  String get playerReplay => 'Repetir';

  @override
  String get playerNotReady => 'El reproductor no está listo';

  @override
  String get playerPreviewUnavailable =>
      'La vista previa no está disponible ahora mismo.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current de $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Error al cargar el vídeo';

  @override
  String get playerLoadingVideo => 'Cargando vídeo...';

  @override
  String get playerFailedToLoadVideo => 'No se pudo cargar el vídeo';

  @override
  String get playerNotInitialized =>
      'El reproductor de vídeo no se ha inicializado';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Ejercicio $current/$total';
  }

  @override
  String get guidedGetReady => 'PREPÁRATE';

  @override
  String guidedSetOf(int current, int total) {
    return 'Serie $current de $total';
  }

  @override
  String get guidedRest => 'DESCANSO';

  @override
  String get guidedSkipRest => 'Saltar descanso';

  @override
  String get guidedPaused => 'En pausa';

  @override
  String get guidedResume => 'Reanudar';

  @override
  String get guidedWorkoutComplete => 'Entrenamiento completado';

  @override
  String get guidedEndTitle => '¿Terminar el entrenamiento?';

  @override
  String get guidedEndBody => 'No se guardará tu progreso de esta sesión.';

  @override
  String get guidedKeepGoing => 'Seguir';

  @override
  String get guidedEnd => 'Terminar';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeticiones',
      one: '$count repetición',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Crear rutina con IA';

  @override
  String get generateSheetPrompt => '¿Qué tipo de entrenamiento quieres?';

  @override
  String get generateSheetHint =>
      'Por ejemplo: «Estiramientos rápidos para despertarme» o «Fuerza de cuerpo completo para principiantes»';

  @override
  String get generateSheetDuration => 'Duración';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Dificultad';

  @override
  String get generateSheetEquipment => 'Material disponible';

  @override
  String get generateSheetGenerating => 'Creando...';

  @override
  String get generateSheetSubmit => 'Crear rutina';

  @override
  String get generateSheetDescribeFirst =>
      'Describe el entrenamiento que quieres';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Ya tienes esta: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Creada: $title';
  }

  @override
  String get generateSheetFailed => 'No se pudo generar la rutina';

  @override
  String get guidedNoExercises => 'Esta rutina aún no tiene ejercicios.';

  @override
  String get guidedStartFailed =>
      'No se puede iniciar este entrenamiento ahora mismo. Inténtalo de nuevo.';

  @override
  String get guidedSaveFailed =>
      'No se pudo guardar este entrenamiento. Toca reintentar para actualizar tu racha.';

  @override
  String guidedOfReps(int count) {
    return 'de $count repeticiones';
  }

  @override
  String get guidedHold => 'mantén';

  @override
  String get guidedNextSet => 'Siguiente serie';

  @override
  String get guidedUpNext => 'A continuación';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s de mantenimiento';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Prepárate. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Vamos. $count repeticiones.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Mantén durante $seconds segundos.';
  }

  @override
  String coachRest(String exercise) {
    return 'Descanso. Siguiente: $exercise';
  }

  @override
  String get coachRestShort => 'Descanso.';

  @override
  String get coachComplete => 'Buen trabajo. Entrenamiento terminado.';

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
      'No se encontraron vídeos reproducibles en esta rutina.';

  @override
  String get playerLoadRoutineFailed =>
      'No se puede cargar esta rutina ahora mismo. Inténtalo de nuevo.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'No se pudo cargar «$title». Saltando…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'No se pudo cargar «$title».';
  }

  @override
  String get playerSaveCompletionFailed =>
      'No se pudo guardar la finalización. Toca reintentar para actualizar tu racha.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Vista previa';
  }

  @override
  String get playerNoVideosReady =>
      'Esta rutina todavía no tiene vídeos listos para reproducir.';

  @override
  String get playerPlaybackFailed =>
      'No se puede reproducir este vídeo ahora mismo. Inténtalo de nuevo.';

  @override
  String get libraryTabCurated => 'Seleccionadas';

  @override
  String get libraryTabAiGenerated => 'Generadas con IA';

  @override
  String get profileSavedRoutines => 'Rutinas guardadas';

  @override
  String get savedRoutinesNoFavorites => 'Aún no tienes rutinas favoritas.';

  @override
  String get savedRoutinesEmpty => 'Aún no tienes rutinas guardadas.';

  @override
  String get actionFavorite => 'Añadir a favoritos';

  @override
  String get actionUnfavorite => 'Quitar de favoritos';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours h';
  }

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get categoryStrength => 'Fuerza';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Flexibilidad';

  @override
  String get categoryMindfulness => 'Mindfulness';

  @override
  String get categoryDance => 'Baile';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Personalizada';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get equipmentNone => 'Ninguno';

  @override
  String get equipmentDumbbells => 'Mancuernas';

  @override
  String get equipmentResistanceBands => 'Bandas elásticas';

  @override
  String get equipmentYogaMat => 'Esterilla';

  @override
  String get equipmentKettlebell => 'Pesa rusa';

  @override
  String get equipmentPullUpBar => 'Barra de dominadas';

  @override
  String get equipmentJumpRope => 'Comba';

  @override
  String get nutritionTitle => 'Nutrición';

  @override
  String get nutritionSubtitle => 'Calorías, macros e historial de comidas';

  @override
  String get nutritionSetGoalsTitle => 'Define tus objetivos diarios';

  @override
  String get nutritionSetGoalsBody =>
      'Añade tu peso, altura, edad y sexo para que Celia calcule cuántas calorías y nutrientes necesitas cada día.';

  @override
  String get nutritionSetUpGoals => 'Definir objetivos';

  @override
  String get nutritionDailyTarget => 'Objetivo diario';

  @override
  String get nutritionDailyGoals => 'Objetivos diarios';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P $protein g · C $carbs g · G $fat g';
  }

  @override
  String get nutritionToday => 'Hoy';

  @override
  String get nutritionMealHistory => 'Historial de comidas';

  @override
  String get nutritionCeliaInsights => 'Consejos de Celia';

  @override
  String get nutritionWeeklyTrend => 'Tendencia semanal';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comidas',
      one: '$count comida',
    );
    return 'kcal · $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comidas',
      one: '$count comida',
    );
    return 'de $target kcal · $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'L,M,X,J,V,S,D';

  @override
  String get nutritionFieldFoodName => 'Nombre del alimento';

  @override
  String get nutritionFieldGrams => 'Gramos';

  @override
  String get nutritionFieldCalories => 'Calorías';

  @override
  String get scannerStatusAnalyzing => 'ANALIZANDO...';

  @override
  String get scannerStatusIdle => 'ESCÁNER CELIA';

  @override
  String get scannerFieldFoodName => 'Nombre del alimento';

  @override
  String get scannerFieldGrams => 'Gramos';

  @override
  String get scannerFieldCalories => 'Calorías';

  @override
  String get scannerFieldPro => 'Pro';

  @override
  String get scannerMacroPro => 'PRO';

  @override
  String get scannerMacroCarb => 'CARB';

  @override
  String get scannerMacroFat => 'GRASA';

  @override
  String scannerRemainingAfterLogging(int calories, int grams) {
    return 'Te quedan $calories kcal y $grams g de proteína hoy';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal por encima de tu objetivo diario';
  }

  @override
  String get scannerButtonAnalyzing => 'Analizando';

  @override
  String get scannerButtonQuotaNeeded => 'Falta cuota';

  @override
  String get scannerButtonScanNow => 'Escanear ahora';

  @override
  String get scannerButtonLogging => 'Guardando';

  @override
  String get scannerButtonLogMeal => 'Registrar comida';

  @override
  String get scannerNoClearFood =>
      'Aún no se detecta comida con claridad. Prueba con más luz o acércate.';

  @override
  String get scannerErrorCameraPermission =>
      'Se necesita permiso de cámara para escanear comidas.';

  @override
  String get scannerErrorBackendMissing =>
      'El servidor del escáner de calorías aún no está configurado.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'La clave de API de OpenAI para el escaneo de calorías no es válida. Reemplázala en el entorno del servidor, vuelve a desplegar e inténtalo de nuevo.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Se requiere una clave de API de OpenAI para el escaneo de calorías. Añádela en Vercel, vuelve a desplegar e inténtalo de nuevo.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Se han agotado los créditos de OpenAI para el escaneo de calorías. Añade créditos o sube el límite de facturación e inténtalo de nuevo.';

  @override
  String get scannerErrorTimeout =>
      'Celia necesitaba más tiempo para analizar esta comida. Mantén la cámara firme y escanea de nuevo.';

  @override
  String get scannerErrorNotSignedIn =>
      'Inicia sesión antes de escanear comidas.';

  @override
  String get scannerErrorMealTableMissing =>
      'La tabla de registro de comidas aún no está lista. El resultado del escaneo sigue disponible.';

  @override
  String get scannerErrorGeneric =>
      'Celia aún no ha podido analizar esta comida. Mantén la cámara firme, centra la comida y escanea de nuevo.';

  @override
  String nutritionGrams(String grams) {
    return '$grams g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimentos',
      one: '$count alimento',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Detalles de la comida';

  @override
  String get nutritionFoodItems => 'Alimentos';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '$grams g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Una comida necesita al menos un alimento.';

  @override
  String get nutritionMealUpdated => 'Comida actualizada';

  @override
  String nutritionUpdateFailed(String error) {
    return 'No se pudo actualizar la comida: $error';
  }

  @override
  String get nutritionDeleteMealTitle => '¿Eliminar la comida?';

  @override
  String get nutritionDeleteMealBody =>
      'Esto la quitará de tu historial de nutrición.';

  @override
  String get nutritionDeleteMeal => 'Eliminar comida';

  @override
  String nutritionDeleteFailed(String error) {
    return 'No se pudo eliminar la comida: $error';
  }

  @override
  String get nutritionEditFood => 'Editar alimento';

  @override
  String get nutritionSaveFood => 'Guardar alimento';

  @override
  String get nutritionLoadFailed => 'No se pudieron cargar las comidas';

  @override
  String get nutritionLoadFailedBody =>
      'Desliza para actualizar o comprueba la conexión con el servidor.';

  @override
  String get nutritionNoMeals => 'Aún no has registrado comidas';

  @override
  String get nutritionNoMealsBody =>
      'Escanea tu primera comida y Celia empezará tu historial de nutrición.';

  @override
  String get progressToday => 'Hoy';

  @override
  String get progressSetGoals =>
      'Define tus objetivos de nutrición para activar el seguimiento de calorías y macros.';

  @override
  String progressOfTarget(int target) {
    return 'de $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / $target g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal de más';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal restantes';
  }

  @override
  String get progressProtein => 'Proteína';

  @override
  String get progressCarbs => 'Carbohidratos';

  @override
  String get progressFat => 'Grasa';

  @override
  String get scannerEditItem => 'Editar alimento';

  @override
  String get scannerSaveChanges => 'Guardar cambios';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Confianza $percent % · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count alimentos más incluidos en este registro';
  }

  @override
  String get scannerIfYouLog => 'Si registras esta comida';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal hoy';
  }

  @override
  String scannerGramsDecimal(String grams) {
    return '$grams g';
  }

  @override
  String scannerItemServing(String name, int grams) {
    return '$name · $grams g';
  }

  @override
  String get scannerNoMealDetected => 'No se detectó ninguna comida';

  @override
  String onboardingWelcome(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String get onboardingGender => 'Sexo';

  @override
  String get onboardingCalculateGoals => 'Calcular mis objetivos';

  @override
  String get onboardingScanFirstMeal => 'Escanear mi primera comida';

  @override
  String get onboardingExploreRoutines => 'Explorar rutinas';

  @override
  String get onboardingGoHome => 'Ir al inicio';

  @override
  String get onboardingDailyTargets => 'Tus objetivos diarios';

  @override
  String onboardingProtein(int grams) {
    return 'Proteína $grams g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Proteínas $protein g • Carbohidratos $carbs g • Grasas $fat g';
  }

  @override
  String get onboardingTargetsReady =>
      'Tus objetivos nutricionales diarios están listos. Elige cómo quieres empezar.';

  @override
  String get onboardingWeightKg => 'Peso (kg)';

  @override
  String get onboardingHeightCm => 'Altura (cm)';

  @override
  String get onboardingAge => 'Edad';

  @override
  String get onboardingInvalidWeight => 'Introduce un peso válido en kg.';

  @override
  String get onboardingInvalidHeight => 'Introduce una altura válida en cm.';

  @override
  String get onboardingInvalidAge =>
      'Introduce una edad válida entre 13 y 100.';

  @override
  String get onboardingSaveFailed =>
      'No se pudo guardar tu perfil nutricional.';

  @override
  String get genderMale => 'Hombre';

  @override
  String get genderFemale => 'Mujer';

  @override
  String get genderOther => 'Otro';

  @override
  String get nutritionSetupTitle => 'Objetivos diarios de nutrición';

  @override
  String get nutritionSetupBody =>
      'Cuéntale a Celia cómo es tu cuerpo para que calcule tus calorías y macros diarios.';

  @override
  String get nutritionSetupGender => 'Sexo';

  @override
  String get nutritionSetupFootnote =>
      'Celia usa tu peso, altura, edad y sexo para estimar tus objetivos diarios de calorías y macros con un nivel de actividad moderado.';

  @override
  String get nutritionSourcesTitle => 'How these targets are calculated';

  @override
  String get nutritionSourcesBody =>
      'Daily calories use the Mifflin–St Jeor resting energy equation with a moderate physical activity factor (about 1.55). Protein is estimated near 1.8 g per kg body weight for active adults. Fat is set near 25% of calories, with carbs filling the remainder — within common dietary guidance ranges.';

  @override
  String get nutritionSourcesDisclaimer =>
      'These figures are general wellness estimates only. They are not a diagnosis, prescription, or substitute for advice from a qualified clinician or registered dietitian.';

  @override
  String get nutritionSetupSave => 'Guardar objetivos';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileCeliaAi => 'Celia IA';

  @override
  String get profileEliteMember => 'Miembro';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String profileSignedInAs(String email) {
    return 'Sesión iniciada como:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Desconocido';

  @override
  String get profileDarkMode => 'Modo oscuro';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLogOutTitle => '¿Cerrar sesión?';

  @override
  String get profileLogOutBody => '¿Seguro que quieres cerrar sesión?';

  @override
  String get profileLogOut => 'Cerrar sesión';

  @override
  String get profileLogOutButton => 'Cerrar sesión';

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
  String get profileFavoriteRoutines => 'Rutinas favoritas';

  @override
  String get profileSubscription => 'Suscripción';

  @override
  String get profileNutrition => 'Nutrición';

  @override
  String get profileHelpSupport => 'Ayuda y soporte';

  @override
  String get profileFriend => 'Amigo';

  @override
  String get profileStatSaved => 'Guardadas';

  @override
  String get profileStatStreak => 'Racha';

  @override
  String get profileStatWorkouts => 'Entrenos';

  @override
  String get streakDayOneStarted =>
      'Día 1 empezado — vuelve mañana para construir tu racha.';

  @override
  String get streakRebuild =>
      'Ayer estuviste activo — registra una comida o completa un entrenamiento hoy para recuperar tu racha.';

  @override
  String get streakStart =>
      'Registra una comida o completa un entrenamiento para empezar tu racha.';

  @override
  String streakLongRun(int days) {
    return '¡Racha de $days días! Sigue así — Celia está siguiendo tu constancia.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Racha de $days días — hoy has registrado entrenamiento y nutrición.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Racha de $days días. Un entrenamiento corto redondearía el día.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Racha de $days días. Registra una comida para seguir tu alimentación.';
  }

  @override
  String streakStayActive(int days) {
    return 'Racha de $days días — mantente activo hoy.';
  }

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get editProfileName => 'Nombre';

  @override
  String get editProfileFootnote =>
      'Los cambios se guardan en tu cuenta y aparecerán en Inicio y Perfil.';

  @override
  String get editProfileSaveFailed =>
      'No se pudo actualizar el perfil. Inténtalo de nuevo.';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma del dispositivo';

  @override
  String get languageSystemSubtitle =>
      'Usar el idioma configurado en tu teléfono';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get insightStartFuelingTitle => 'Empieza a alimentarte hoy';

  @override
  String get insightStartFuelingBody =>
      'Tienes todo tu presupuesto de calorías disponible. Escanea o registra tu primera comida para no perder el ritmo.';

  @override
  String get insightAboveTargetTitle => 'Por encima del objetivo';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Estás $calories kcal por encima de tu objetivo diario. Cena algo más ligero o añade un entrenamiento corto.';
  }

  @override
  String get insightLowProteinTitle => 'Te falta proteína';

  @override
  String insightLowProteinBody(int grams) {
    return 'Aún necesitas unos $grams g de proteína hoy para llegar a tu objetivo.';
  }

  @override
  String get insightAlmostThereTitle => 'Casi en tu objetivo';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Te quedan $calories kcal hoy. Un tentempié equilibrado encaja perfectamente.';
  }

  @override
  String get insightOnTrackTitle => 'Vas bien hoy';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Te quedan $calories kcal y $grams g de proteína para alcanzar tus objetivos diarios.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Crea tu rutina semanal';

  @override
  String get insightWeeklyRhythmBody =>
      'Registra tus comidas durante la semana para que Celia detecte patrones y te entrene mejor.';

  @override
  String get insightWeeklyTrendTitle => 'Tendencia semanal';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Registraste comidas $days de los últimos 7 días, con una media de $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'justo en tu objetivo diario';

  @override
  String insightTrendAbove(int delta) {
    return '$delta kcal por encima de tu objetivo de media';
  }

  @override
  String insightTrendBelow(int delta) {
    return '$delta kcal por debajo de tu objetivo de media';
  }

  @override
  String get insightsSectionTitle => 'Consejos de Celia';
}
