// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionDone => 'Fatto';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionContinue => 'Continua';

  @override
  String get actionSeeAll => 'Vedi tutto';

  @override
  String get actionYesDoIt => 'Sì, fallo';

  @override
  String get actionNotNow => 'Non ora';

  @override
  String get loadingPreparing => 'Celia si sta preparando...';

  @override
  String get loadingGeneric => 'Caricamento...';

  @override
  String get errorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorCanceled => 'Azione annullata.';

  @override
  String get errorTooManyRequests =>
      'Troppi tentativi. Attendi un minuto e riprova.';

  @override
  String get errorNetwork => 'Controlla la connessione a internet e riprova.';

  @override
  String get errorBadCredentials => 'Email o password errata.';

  @override
  String get errorEmailInUse =>
      'Questa email è già in uso. Prova invece ad accedere.';

  @override
  String get errorWeakPassword => 'Usa una password più sicura e riprova.';

  @override
  String get errorInvalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get errorNoPermission => 'Non hai l\'autorizzazione per farlo.';

  @override
  String get errorNotSignedIn => 'Accedi e riprova.';

  @override
  String get errorDeleteAccount =>
      'Non siamo riusciti a eliminare il tuo account. Riprova.';

  @override
  String get errorNoConversation => 'Avvia una nuova chat per continuare.';

  @override
  String get errorNoPlayableVideos =>
      'Non sono ancora disponibili video riproducibili per questa routine.';

  @override
  String get errorLoadRoutines =>
      'Non è stato possibile caricare le routine. Riprova.';

  @override
  String get errorLoadSavedRoutines =>
      'Non è stato possibile caricare le routine salvate. Riprova.';

  @override
  String get errorGenerateRoutine =>
      'Non è stato possibile generare una routine. Riprova.';

  @override
  String get errorLoadChats =>
      'Non è stato possibile caricare le chat salvate.';

  @override
  String get errorCeliaUnavailable =>
      'Celia non è al momento disponibile. Riprova.';

  @override
  String get errorOpenConversation =>
      'Non è stato possibile aprire la conversazione.';

  @override
  String get errorDeleteConversation =>
      'Non è stato possibile eliminare questa conversazione. Riprova.';

  @override
  String get errorSignIn => 'Non è stato possibile accedere. Riprova.';

  @override
  String get errorCreateAccount =>
      'Non è stato possibile creare il tuo account. Riprova.';

  @override
  String get errorSendResetEmail =>
      'Non è stato possibile inviare l\'email di reimpostazione. Riprova.';

  @override
  String get errorSendVerificationEmail =>
      'Non è stato possibile inviare l\'email di verifica. Riprova.';

  @override
  String get errorGoogleSignIn => 'Accesso con Google non riuscito. Riprova.';

  @override
  String get errorAppleSignIn => 'Accesso con Apple non riuscito. Riprova.';

  @override
  String get errorRefreshNutrition =>
      'Non è stato possibile aggiornare i dati nutrizionali.';

  @override
  String get errorLoadNutritionProfile =>
      'Non è stato possibile caricare il tuo profilo nutrizionale.';

  @override
  String get startupErrorTitle => 'Impossibile avviare l\'app';

  @override
  String get startupErrorBody =>
      'Chiudi e riapri l\'app. Se il problema persiste, contatta l\'assistenza.';

  @override
  String get authTagline => 'Il tuo compagno di fitness';

  @override
  String get authSignUp => 'Registrati';

  @override
  String get authLogIn => 'Accedi';

  @override
  String authVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get authForgotPassword => 'Hai dimenticato la password?';

  @override
  String get authOr => 'OPPURE';

  @override
  String get authContinueWithGoogle => 'Continua con Google';

  @override
  String get authContinueWithApple => 'Continua con Apple';

  @override
  String get authAuthenticating => 'Autenticazione...';

  @override
  String get authEnterYourName => 'Inserisci il tuo nome.';

  @override
  String get authNeedAccount => 'Non hai un account? Registrati';

  @override
  String get authHaveAccount => 'Hai già un account? Accedi';

  @override
  String get authFieldName => 'Il tuo nome';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get verifyEmailTitle => 'Verifica la tua email';

  @override
  String get verifyEmailHeading => 'Controlla la posta in arrivo';

  @override
  String get verifyEmailBody =>
      'Un link di verifica è stato inviato alla tua email.';

  @override
  String get verifyEmailSent => 'Email di verifica inviata!';

  @override
  String get verifyEmailContinue => 'Ho verificato, continua';

  @override
  String get verifyEmailSignOut => 'Esci';

  @override
  String get verifyEmailSending => 'Invio...';

  @override
  String get verifyEmailResend => 'Invia di nuovo l\'email di verifica';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Invia di nuovo tra ${seconds}s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'Email: $email';
  }

  @override
  String get forgotPasswordTitle => 'Password dimenticata';

  @override
  String get forgotPasswordBody =>
      'Inserisci la tua email per ricevere un link per reimpostare la password.';

  @override
  String get forgotPasswordEmptyEmail => 'Inserisci un\'email';

  @override
  String get forgotPasswordSent => 'Email per reimpostare la password inviata.';

  @override
  String get forgotPasswordSend => 'Invia link di reimpostazione';

  @override
  String get forgotPasswordSending => 'Invio...';

  @override
  String get nameSetupTitle => 'Come vuoi che Celia ti chiami?';

  @override
  String get nameSetupBody =>
      'Usiamo il tuo nome in tutta l\'app per rendere il coaching più personale.';

  @override
  String get nameSetupSaveFailed => 'Impossibile salvare il tuo nome. Riprova.';

  @override
  String get homeGoodMorning => 'Buongiorno,';

  @override
  String get homeCeliaActive => 'CELIA ATTIVA';

  @override
  String get homeGenerateRoutine =>
      'Genera la tua\nroutine\npersonalizzata con l\'IA';

  @override
  String get homeCreateRoutine => 'Crea routine';

  @override
  String get homeQuickActions => 'Azioni rapide';

  @override
  String get homeUpNext => 'In arrivo';

  @override
  String get homeNoUpcoming =>
      'Ancora nessuna routine in programma.\nCreane una o esplora la libreria.';

  @override
  String get homeChatWithCelia => 'Chatta con Celia';

  @override
  String get homeChatSubtitle => 'Chiedi della tua tecnica o della tua dieta';

  @override
  String get homeScanMeal => 'Scansiona pasto';

  @override
  String get homeScanMealSubtitle => 'Identifica cibi e calorie';

  @override
  String get homeNutrition => 'Nutrizione';

  @override
  String get homeNutritionSubtitle => 'Visualizza calorie, macro e pasti';

  @override
  String get homeBrowseLibrary => 'Esplora\nlibreria';

  @override
  String get homeTrackProgress => 'Monitora\ni progressi';

  @override
  String get chatTitle => 'Coach Celia';

  @override
  String get chatEmptyPrompt =>
      'Come posso aiutarti\na rimetterti in forma oggi?';

  @override
  String get chatYourChats => 'Le tue chat';

  @override
  String get chatNoSavedChats => 'Nessuna chat salvata.';

  @override
  String get chatHistory => 'Cronologia chat';

  @override
  String get chatNew => 'Nuova chat';

  @override
  String get chatOpening => 'Apertura chat...';

  @override
  String get chatScanAMeal => 'Scansiona un pasto';

  @override
  String get chatInputHint =>
      'Chiedi a Celia qualsiasi cosa sul tuo allenamento...';

  @override
  String get chatMicTooltip => 'Tieni premuto per parlare';

  @override
  String get chatListening => 'In ascolto…';

  @override
  String get chatMicDenied =>
      'Serve l\'accesso al microfono per parlare con Celia.';

  @override
  String get chatSpeechUnavailable =>
      'Il riconoscimento vocale non è disponibile su questo dispositivo.';

  @override
  String get avatarModeReady => 'Pronta';

  @override
  String get avatarModeThinking => 'Sta pensando…';

  @override
  String get avatarModeSpeaking => 'Sta parlando…';

  @override
  String get avatarModeHoldToTalk => 'Tieni premuto per parlare';

  @override
  String get avatarModeExit => 'Modalità manuale';

  @override
  String get avatarModeConfirmTitle => 'Confermare con Celia?';

  @override
  String get avatarModeConfirmBody =>
      'Celia vuole salvare qualcosa. Consentire?';

  @override
  String get avatarModeConfirmYes => 'Consenti';

  @override
  String get chatCouldNotOpenRoutine => 'Impossibile aprire questa routine';

  @override
  String get chatThisRoutine => 'questa routine';

  @override
  String get chatThisMeal => 'questo pasto';

  @override
  String get chatYourRoutine => 'La tua routine';

  @override
  String chatMoreExercises(int count) {
    return '+ $count altri';
  }

  @override
  String get chatEmptySubtitle =>
      'Chiedi del tuo allenamento, della tua alimentazione o dei tuoi progressi.';

  @override
  String chatLoggedToday(int calories) {
    return 'Oggi hai registrato $calories kcal.';
  }

  @override
  String get chatSuggestionHiit => 'Crea una routine HIIT di 20 minuti';

  @override
  String get chatSuggestionDinner => 'Cosa dovrei mangiare stasera?';

  @override
  String get chatSuggestionProgress => 'Come sto andando questa settimana?';

  @override
  String get chatSuggestionIngredients => 'Ho pollo, riso e spinaci';

  @override
  String get chatJustNow => 'Proprio ora';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes min fa';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours ore fa';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days giorni fa';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Già nella tua libreria — tocca per aprire';

  @override
  String get chatRoutineTapToOpen => 'Tocca per aprire';

  @override
  String get chatToolCancelled => 'Annullato';

  @override
  String chatToolFailed(String label) {
    return '$label — operazione non riuscita';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Impossibile salvare la routine';

  @override
  String get chatToolRoutineSaved => 'Salvata nella tua libreria';

  @override
  String get chatToolMealLogged => 'Aggiunto al registro di oggi';

  @override
  String get chatToolRoutineAdded => 'Aggiunta alla tua libreria';

  @override
  String get activityCheckingProgress => 'Controllo i tuoi progressi';

  @override
  String get activityCheckingNutrition => 'Controllo cosa hai mangiato oggi';

  @override
  String get activityReviewingMeals => 'Controllo i tuoi pasti recenti';

  @override
  String get activityLookingAtRoutines => 'Guardo le tue routine';

  @override
  String get activityReadingRoutine => 'Leggo quella routine';

  @override
  String get activitySearchingLibrary => 'Cerco nella libreria degli esercizi';

  @override
  String get activityBuildingRoutine => 'Creo la tua routine';

  @override
  String get activityLoggingMeal => 'Registro il tuo pasto';

  @override
  String get activitySavingToLibrary => 'Salvo nella tua libreria';

  @override
  String get activityWorking => 'Ci sto lavorando';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Salvare \"$name\" con $count esercizi nella tua libreria?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Salvare \"$name\" nella tua libreria?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Registrare \"$name\" con $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Registrare \"$name\"?';
  }

  @override
  String get approvalAddRoutine =>
      'Aggiungere questa routine alla tua libreria?';

  @override
  String get approvalGeneric => 'Consentire a Celia di farlo?';

  @override
  String get libraryTitle => 'Libreria delle routine';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passaggi',
      one: '$count passaggio',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Nessuna routine';

  @override
  String get libraryEmptyBody =>
      'Crea e pubblica routine nella dashboard di amministrazione.';

  @override
  String get libraryLoadFailed => 'Impossibile caricare le routine';

  @override
  String get routineStartWorkout => 'Inizia allenamento';

  @override
  String get routineNoSteps => 'Nessun passaggio disponibile';

  @override
  String get routineNoVideoForStep =>
      'Nessun video disponibile per questo passaggio';

  @override
  String get routineVideoProcessing =>
      'Il video è ancora in elaborazione. Riprova più tardi.';

  @override
  String get routineMissingPlaybackUrl =>
      'URL di riproduzione mancante per questo video';

  @override
  String get routinePreviewBanner => 'ANTEPRIMA — video completo in arrivo';

  @override
  String get routinePreview => 'ANTEPRIMA';

  @override
  String get routineDetails => 'Dettagli';

  @override
  String get routineNotFound => 'Routine non trovata';

  @override
  String routineCompletedTimes(int count) {
    return 'Completata $count volte';
  }

  @override
  String get playerVideoUnavailable =>
      'Questo video non è disponibile al momento.';

  @override
  String get playerSteps => 'Passaggi';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Nessun video riproducibile';

  @override
  String get playerWorkoutComplete => 'Allenamento completato!';

  @override
  String get playerSavingStreak => 'Salvataggio nella tua serie…';

  @override
  String get playerSavedStreak => 'Salvato nella tua serie';

  @override
  String get playerRetrySave => 'Riprova a salvare';

  @override
  String get playerReplay => 'Riproduci di nuovo';

  @override
  String get playerNotReady => 'Player non pronto';

  @override
  String get playerPreviewUnavailable =>
      'L\'anteprima non è disponibile al momento.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current di $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo =>
      'Errore durante il caricamento del video';

  @override
  String get playerLoadingVideo => 'Caricamento del video...';

  @override
  String get playerFailedToLoadVideo => 'Impossibile caricare il video';

  @override
  String get playerNotInitialized => 'Player video non inizializzato';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Esercizio $current/$total';
  }

  @override
  String get guidedGetReady => 'PREPARATI';

  @override
  String guidedSetOf(int current, int total) {
    return 'Serie $current di $total';
  }

  @override
  String get guidedRest => 'RIPOSO';

  @override
  String get guidedSkipRest => 'Salta il riposo';

  @override
  String get guidedPaused => 'In pausa';

  @override
  String get guidedResume => 'Riprendi';

  @override
  String get guidedWorkoutComplete => 'Allenamento completato';

  @override
  String get guidedEndTitle => 'Terminare l\'allenamento?';

  @override
  String get guidedEndBody =>
      'I tuoi progressi per questa sessione non verranno salvati.';

  @override
  String get guidedKeepGoing => 'Continua così';

  @override
  String get guidedEnd => 'Termina';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ripetizioni',
      one: '$count ripetizione',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Genera una routine con l\'AI';

  @override
  String get generateSheetPrompt => 'Che tipo di allenamento vuoi?';

  @override
  String get generateSheetHint =>
      'es. \"Un rapido stretching mattutino per svegliarmi\" oppure \"Allenamento di forza per tutto il corpo per principianti\"';

  @override
  String get generateSheetDuration => 'Durata';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Difficoltà';

  @override
  String get generateSheetEquipment => 'Attrezzatura disponibile';

  @override
  String get generateSheetGenerating => 'Generazione in corso...';

  @override
  String get generateSheetSubmit => 'Genera routine';

  @override
  String get generateSheetDescribeFirst => 'Descrivi l\'allenamento che vuoi';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Hai già questa routine: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Creata: $title';
  }

  @override
  String get generateSheetFailed => 'Impossibile generare la routine';

  @override
  String get guidedNoExercises =>
      'Questa routine non contiene ancora esercizi.';

  @override
  String get guidedStartFailed =>
      'Impossibile iniziare questo allenamento al momento. Riprova.';

  @override
  String get guidedSaveFailed =>
      'Impossibile salvare questo allenamento. Tocca Riprova per aggiornare la tua serie.';

  @override
  String guidedOfReps(int count) {
    return 'di $count ripetizioni';
  }

  @override
  String get guidedHold => 'mantieni';

  @override
  String get guidedNextSet => 'Serie successiva';

  @override
  String get guidedUpNext => 'Segue';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s di mantenimento';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Preparati. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Via. $count ripetizioni.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Mantieni per $seconds secondi.';
  }

  @override
  String coachRest(String exercise) {
    return 'Riposa. Prossimo: $exercise';
  }

  @override
  String get coachRestShort => 'Riposa.';

  @override
  String get coachComplete => 'Ottimo lavoro. Allenamento completato.';

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
      'Non sono stati trovati video riproducibili in questa routine.';

  @override
  String get playerLoadRoutineFailed =>
      'Impossibile caricare questa routine al momento. Riprova.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Impossibile caricare \"$title\". Salto…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Impossibile caricare \"$title\".';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Impossibile salvare il completamento. Tocca Riprova per aggiornare la tua serie.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Anteprima';
  }

  @override
  String get playerNoVideosReady =>
      'Questa routine non contiene ancora video pronti per la riproduzione.';

  @override
  String get playerPlaybackFailed =>
      'Impossibile riprodurre questo video al momento. Riprova.';

  @override
  String get libraryTabCurated => 'Selezionate';

  @override
  String get libraryTabAiGenerated => 'Generate dall\'AI';

  @override
  String get profileSavedRoutines => 'Routine salvate';

  @override
  String get savedRoutinesNoFavorites => 'Non hai ancora routine preferite.';

  @override
  String get savedRoutinesEmpty => 'Non hai ancora routine salvate.';

  @override
  String get actionFavorite => 'Aggiungi ai preferiti';

  @override
  String get actionUnfavorite => 'Rimuovi dai preferiti';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String routineDurationHours(int hours) {
    return '${hours}h';
  }

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get categoryStrength => 'Forza';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Flessibilità';

  @override
  String get categoryMindfulness => 'Mindfulness';

  @override
  String get categoryDance => 'Danza';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Personalizzato';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profilo';

  @override
  String get equipmentNone => 'Nessuno';

  @override
  String get equipmentDumbbells => 'Manubri';

  @override
  String get equipmentResistanceBands => 'Bande elastiche';

  @override
  String get equipmentYogaMat => 'Tappetino da yoga';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Sbarra per trazioni';

  @override
  String get equipmentJumpRope => 'Corda per saltare';

  @override
  String get nutritionTitle => 'Nutrizione';

  @override
  String get nutritionSubtitle => 'Calorie, macro e cronologia dei pasti';

  @override
  String get nutritionSetGoalsTitle =>
      'Imposta i tuoi obiettivi nutrizionali giornalieri';

  @override
  String get nutritionSetGoalsBody =>
      'Aggiungi peso, altezza, età e genere per permettere a Celia di calcolare quante calorie e quali nutrienti dovresti assumere ogni giorno.';

  @override
  String get nutritionSetUpGoals => 'Imposta obiettivi';

  @override
  String get nutritionDailyTarget => 'Obiettivo giornaliero';

  @override
  String get nutritionDailyGoals => 'Obiettivi giornalieri';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · G ${fat}g';
  }

  @override
  String get nutritionToday => 'Oggi';

  @override
  String get nutritionMealHistory => 'Cronologia dei pasti';

  @override
  String get nutritionCeliaInsights => 'Insights di Celia';

  @override
  String get nutritionWeeklyTrend => 'Andamento settimanale';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasti',
      one: '$count pasto',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasti',
      one: '$count pasto',
    );
    return 'su $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'L,M,M,G,V,S,D';

  @override
  String get nutritionFieldFoodName => 'Nome dell\'alimento';

  @override
  String get nutritionFieldGrams => 'Grammi';

  @override
  String get nutritionFieldCalories => 'Calorie';

  @override
  String get scannerStatusAnalyzing => 'ANALISI IN CORSO...';

  @override
  String get scannerStatusIdle => 'SCANNER CELIA';

  @override
  String get scannerFieldFoodName => 'Nome dell\'alimento';

  @override
  String get scannerFieldGrams => 'Grammi';

  @override
  String get scannerFieldCalories => 'Calorie';

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
    return 'Ti restano $calories kcal e ${grams}g di proteine per oggi';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal oltre il tuo obiettivo giornaliero';
  }

  @override
  String get scannerButtonAnalyzing => 'Analisi in corso';

  @override
  String get scannerButtonQuotaNeeded => 'Quota necessaria';

  @override
  String get scannerButtonScanNow => 'Scansiona ora';

  @override
  String get scannerButtonLogging => 'Registrazione in corso';

  @override
  String get scannerButtonLogMeal => 'Registra pasto';

  @override
  String get scannerNoClearFood =>
      'Non è stato ancora rilevato alcun alimento chiaramente. Prova a migliorare l\'illuminazione o ad avvicinarti.';

  @override
  String get scannerErrorCameraPermission =>
      'È necessaria l\'autorizzazione della fotocamera per scansionare i pasti.';

  @override
  String get scannerErrorBackendMissing =>
      'Il backend dello scanner delle calorie non è ancora configurato.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'La chiave API OpenAI per la scansione delle calorie non è valida. Sostituiscila nell\'ambiente del backend, esegui nuovamente il deploy e riprova.';

  @override
  String get scannerErrorApiKeyMissing =>
      'La chiave API OpenAI è necessaria per la scansione delle calorie. Aggiungila in Vercel, esegui nuovamente il deploy e riprova.';

  @override
  String get scannerErrorQuotaExhausted =>
      'I crediti OpenAI per la scansione delle calorie sono esauriti. Aggiungi crediti API o aumenta il limite di fatturazione, quindi riprova.';

  @override
  String get scannerErrorTimeout =>
      'Celia ha bisogno di più tempo per analizzare questo pasto. Tieni ferma la fotocamera e scansiona di nuovo.';

  @override
  String get scannerErrorNotSignedIn => 'Accedi prima di scansionare i pasti.';

  @override
  String get scannerErrorMealTableMissing =>
      'La tabella per la registrazione dei pasti non è ancora pronta. Il risultato della scansione è comunque disponibile.';

  @override
  String get scannerErrorGeneric =>
      'Celia non ha ancora potuto analizzare questo pasto. Tieni ferma la fotocamera, mantieni il cibo al centro e scansiona di nuovo.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '$count elemento',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Dettagli del pasto';

  @override
  String get nutritionFoodItems => 'Alimenti';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Un pasto deve contenere almeno un alimento.';

  @override
  String get nutritionMealUpdated => 'Pasto aggiornato';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Impossibile aggiornare il pasto: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Eliminare il pasto?';

  @override
  String get nutritionDeleteMealBody =>
      'Il pasto verrà rimosso dalla cronologia nutrizionale.';

  @override
  String get nutritionDeleteMeal => 'Elimina pasto';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Impossibile eliminare il pasto: $error';
  }

  @override
  String get nutritionEditFood => 'Modifica alimento';

  @override
  String get nutritionSaveFood => 'Salva alimento';

  @override
  String get nutritionLoadFailed => 'Impossibile caricare i pasti';

  @override
  String get nutritionLoadFailedBody =>
      'Trascina per aggiornare o controlla la connessione al backend.';

  @override
  String get nutritionNoMeals => 'Nessun pasto registrato';

  @override
  String get nutritionNoMealsBody =>
      'Scansiona il tuo primo pasto e Celia creerà la tua cronologia nutrizionale.';

  @override
  String get progressToday => 'Oggi';

  @override
  String get progressSetGoals =>
      'Imposta i tuoi obiettivi nutrizionali per attivare il monitoraggio delle calorie e dei macronutrienti.';

  @override
  String progressOfTarget(int target) {
    return 'su $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal oltre';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal rimanenti';
  }

  @override
  String get progressProtein => 'Proteine';

  @override
  String get progressCarbs => 'Carboidrati';

  @override
  String get progressFat => 'Grassi';

  @override
  String get scannerEditItem => 'Modifica alimento';

  @override
  String get scannerSaveChanges => 'Salva modifiche';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Affidabilità $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ altri $count alimenti inclusi nel registro del pasto';
  }

  @override
  String get scannerIfYouLog => 'Se registri questo pasto';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal oggi';
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
  String get scannerNoMealDetected => 'Nessun pasto rilevato';

  @override
  String onboardingWelcome(String name) {
    return 'Benvenuto, $name';
  }

  @override
  String get onboardingGender => 'Genere';

  @override
  String get onboardingCalculateGoals => 'Calcola i miei obiettivi';

  @override
  String get onboardingScanFirstMeal => 'Scansiona il mio primo pasto';

  @override
  String get onboardingExploreRoutines => 'Esplora le routine';

  @override
  String get onboardingGoHome => 'Vai alla home';

  @override
  String get onboardingDailyTargets => 'I tuoi obiettivi giornalieri';

  @override
  String onboardingProtein(int grams) {
    return 'Proteine ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Proteine ${protein}g • Carboidrati ${carbs}g • Grassi ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'I tuoi obiettivi nutrizionali giornalieri sono pronti. Scegli come iniziare.';

  @override
  String get onboardingWeightKg => 'Peso (kg)';

  @override
  String get onboardingHeightCm => 'Altezza (cm)';

  @override
  String get onboardingAge => 'Età';

  @override
  String get onboardingInvalidWeight => 'Inserisci un peso valido in kg.';

  @override
  String get onboardingInvalidHeight => 'Inserisci un\'altezza valida in cm.';

  @override
  String get onboardingInvalidAge =>
      'Inserisci un\'età valida tra 13 e 100 anni.';

  @override
  String get onboardingSaveFailed =>
      'Impossibile salvare il tuo profilo nutrizionale.';

  @override
  String get genderMale => 'Uomo';

  @override
  String get genderFemale => 'Donna';

  @override
  String get genderOther => 'Altro';

  @override
  String get nutritionSetupTitle => 'Obiettivi nutrizionali giornalieri';

  @override
  String get nutritionSetupBody =>
      'Parla a Celia del tuo corpo per consentirle di calcolare le calorie e i macronutrienti giornalieri.';

  @override
  String get nutritionSetupGender => 'Genere';

  @override
  String get nutritionSetupFootnote =>
      'Celia usa il tuo peso, la tua altezza, la tua età e il tuo genere per stimare gli obiettivi giornalieri di calorie e macronutrienti, utilizzando un livello di attività moderato.';

  @override
  String get nutritionSourcesTitle => 'Come vengono calcolati questi obiettivi';

  @override
  String get nutritionSourcesBody =>
      'Le calorie giornaliere usano l\'equazione di energia a riposo Mifflin–St Jeor con un fattore di attività fisica moderata (circa 1,55). Le proteine sono stimate vicino a 1,8 g per kg di peso corporeo per adulti attivi. I grassi sono impostati vicino al 25% delle calorie, con i carboidrati a riempire il resto — entro intervalli comuni delle linee guida alimentari.';

  @override
  String get nutritionSourcesDisclaimer =>
      'Queste cifre sono solo stime generali di benessere. Non sono una diagnosi, una prescrizione né un sostituto del consiglio di un clinico o di un dietista qualificati.';

  @override
  String get nutritionSetupSave => 'Salva obiettivi';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Membro';

  @override
  String get profileAccount => 'Account';

  @override
  String profileSignedInAs(String email) {
    return 'Accesso effettuato come:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Sconosciuta';

  @override
  String get profileDarkMode => 'Modalità scura';

  @override
  String get profileAvatarMode => 'Modalità avatar';

  @override
  String get profileAvatarModeSubtitle => 'Parla con Celia a schermo intero';

  @override
  String get profileLanguage => 'Lingua';

  @override
  String get profileLogOutTitle => 'Disconnettersi?';

  @override
  String get profileLogOutBody => 'Sei sicuro di voler uscire?';

  @override
  String get profileLogOut => 'Esci';

  @override
  String get profileLogOutButton => 'Esci';

  @override
  String get profileDeleteAccount => 'Elimina account';

  @override
  String get profileDeleteAccountConfirmTitle => 'Eliminare il tuo account?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Questo elimina definitivamente il tuo account e tutti i tuoi dati, incluse le routine salvate, i diari dei pasti e la cronologia chat. L\'operazione non può essere annullata.';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'Inserisci la password per confermare.';

  @override
  String get profileDeleteAccountPasswordLabel => 'Password';

  @override
  String get profileDeleteAccountButton => 'Elimina il mio account';

  @override
  String get profileFavoriteRoutines => 'Routine preferite';

  @override
  String get profileSubscription => 'Abbonamento';

  @override
  String get profileNutrition => 'Nutrizione';

  @override
  String get profileHelpSupport => 'Aiuto e supporto';

  @override
  String get profileFriend => 'Amico';

  @override
  String get profileStatSaved => 'Salvati';

  @override
  String get profileStatStreak => 'Serie';

  @override
  String get profileStatWorkouts => 'Allenamenti';

  @override
  String get streakDayOneStarted =>
      'Giorno 1 iniziato: torna domani per continuare la tua serie.';

  @override
  String get streakRebuild =>
      'Ieri sei stato attivo: registra un pasto o completa un allenamento oggi per ricostruire la tua serie.';

  @override
  String get streakStart =>
      'Registra un pasto o completa un allenamento per iniziare la tua serie attiva.';

  @override
  String streakLongRun(int days) {
    return 'Serie di $days giorni! Continua a esserci: Celia sta monitorando la tua costanza.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Serie di $days giorni: oggi hai registrato sia l\'allenamento sia la nutrizione.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Serie di $days giorni. Un allenamento veloce completerebbe la giornata.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Serie di $days giorni. Registra un pasto per monitorare il tuo apporto nutrizionale.';
  }

  @override
  String streakStayActive(int days) {
    return 'Serie di $days giorni: resta attivo oggi.';
  }

  @override
  String get editProfileTitle => 'Modifica profilo';

  @override
  String get editProfileName => 'Nome';

  @override
  String get editProfileFootnote =>
      'Le modifiche vengono salvate nel tuo account e saranno visibili in Home/Profilo.';

  @override
  String get editProfileSaveFailed =>
      'Impossibile aggiornare il profilo. Riprova.';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSystem => 'Lingua del dispositivo';

  @override
  String get languageSystemSubtitle =>
      'Segui la lingua impostata sul tuo telefono';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get insightStartFuelingTitle => 'Inizia a nutrirti oggi';

  @override
  String get insightStartFuelingBody =>
      'Hai ancora a disposizione tutto il tuo budget calorico. Scansiona o registra il primo pasto per restare in linea.';

  @override
  String get insightAboveTargetTitle => 'Oltre l\'obiettivo di oggi';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Sei a $calories kcal oltre il tuo obiettivo giornaliero. Scegli una cena più leggera o aggiungi un breve allenamento.';
  }

  @override
  String get insightLowProteinTitle => 'Le proteine sono ancora basse';

  @override
  String insightLowProteinBody(int grams) {
    return 'Oggi ti servono ancora circa ${grams}g di proteine per raggiungere il tuo obiettivo.';
  }

  @override
  String get insightAlmostThereTitle => 'Quasi al tuo obiettivo';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Oggi ti restano $calories kcal. Uno spuntino equilibrato ci sta alla perfezione.';
  }

  @override
  String get insightOnTrackTitle => 'In linea oggi';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Ti restano $calories kcal e ${grams}g di proteine per raggiungere i tuoi obiettivi giornalieri.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Crea il tuo ritmo settimanale';

  @override
  String get insightWeeklyRhythmBody =>
      'Registra i pasti durante la settimana, così Celia potrà individuare gli schemi e aiutarti meglio.';

  @override
  String get insightWeeklyTrendTitle => 'Tendenza settimanale';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Hai registrato i pasti per $days degli ultimi 7 giorni, con una media di $average kcal: $direction.';
  }

  @override
  String get insightTrendOnTarget =>
      'in linea con il tuo obiettivo giornaliero';

  @override
  String insightTrendAbove(int delta) {
    return '$delta kcal sopra il tuo obiettivo in media';
  }

  @override
  String insightTrendBelow(int delta) {
    return '$delta kcal sotto il tuo obiettivo in media';
  }

  @override
  String get insightsSectionTitle => 'Insights di Celia';
}
