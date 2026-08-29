// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionSeeAll => 'Alle anzeigen';

  @override
  String get actionYesDoIt => 'Ja, los geht’s';

  @override
  String get actionNotNow => 'Nicht jetzt';

  @override
  String get loadingPreparing => 'Celia wird vorbereitet ...';

  @override
  String get loadingGeneric => 'Wird geladen ...';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get errorCanceled => 'Aktion abgebrochen.';

  @override
  String get errorTooManyRequests =>
      'Zu viele Versuche. Bitte warte eine Minute und versuche es erneut.';

  @override
  String get errorNetwork =>
      'Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorBadCredentials => 'E-Mail-Adresse oder Passwort ist falsch.';

  @override
  String get errorEmailInUse =>
      'Diese E-Mail-Adresse wird bereits verwendet. Versuche stattdessen, dich anzumelden.';

  @override
  String get errorWeakPassword =>
      'Verwende ein stärkeres Passwort und versuche es erneut.';

  @override
  String get errorInvalidEmail => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get errorNoPermission => 'Du hast keine Berechtigung dafür.';

  @override
  String get errorNotSignedIn => 'Bitte melde dich an und versuche es erneut.';

  @override
  String get errorDeleteAccount =>
      'We couldn\'t delete your account. Please try again.';

  @override
  String get errorNoConversation => 'Starte einen neuen Chat, um fortzufahren.';

  @override
  String get errorNoPlayableVideos =>
      'Für diese Routine sind noch keine abspielbaren Videos verfügbar.';

  @override
  String get errorLoadRoutines =>
      'Routinen konnten momentan nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get errorLoadSavedRoutines =>
      'Gespeicherte Routinen konnten momentan nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get errorGenerateRoutine =>
      'Eine Routine konnte momentan nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get errorLoadChats =>
      'Gespeicherte Chats konnten momentan nicht geladen werden.';

  @override
  String get errorCeliaUnavailable =>
      'Celia ist momentan nicht verfügbar. Bitte versuche es erneut.';

  @override
  String get errorOpenConversation =>
      'Diese Unterhaltung konnte nicht geöffnet werden.';

  @override
  String get errorDeleteConversation =>
      'Diese Unterhaltung konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String get errorSignIn =>
      'Anmeldung nicht möglich. Bitte versuche es erneut.';

  @override
  String get errorCreateAccount =>
      'Dein Konto konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get errorSendResetEmail =>
      'E-Mail zum Zurücksetzen konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get errorSendVerificationEmail =>
      'Bestätigungs-E-Mail konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get errorGoogleSignIn =>
      'Die Anmeldung mit Google ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get errorAppleSignIn =>
      'Die Anmeldung mit Apple ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get errorRefreshNutrition =>
      'Nährwertdaten konnten nicht aktualisiert werden.';

  @override
  String get errorLoadNutritionProfile =>
      'Dein Ernährungsprofil konnte nicht geladen werden.';

  @override
  String get startupErrorTitle => 'App konnte nicht gestartet werden';

  @override
  String get startupErrorBody =>
      'Bitte schließe die App und öffne sie erneut. Wenn das Problem weiterhin besteht, wende dich an den Support.';

  @override
  String get authTagline => 'Dein Fitness-Buddy';

  @override
  String get authSignUp => 'Registrieren';

  @override
  String get authLogIn => 'Anmelden';

  @override
  String authVersion(String version) {
    return 'Version $version';
  }

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authOr => 'ODER';

  @override
  String get authContinueWithGoogle => 'Mit Google fortfahren';

  @override
  String get authContinueWithApple => 'Mit Apple fortfahren';

  @override
  String get authAuthenticating => 'Anmeldung läuft ...';

  @override
  String get authEnterYourName => 'Bitte gib deinen Namen ein.';

  @override
  String get authNeedAccount => 'Noch kein Konto? Registrieren';

  @override
  String get authHaveAccount => 'Du hast bereits ein Konto? Anmelden';

  @override
  String get authFieldName => 'Dein Name';

  @override
  String get authFieldEmail => 'E-Mail';

  @override
  String get authFieldPassword => 'Passwort';

  @override
  String get verifyEmailTitle => 'E-Mail-Adresse bestätigen';

  @override
  String get verifyEmailHeading => 'Überprüfe deinen Posteingang';

  @override
  String get verifyEmailBody =>
      'Ein Bestätigungslink wurde an deine E-Mail-Adresse gesendet.';

  @override
  String get verifyEmailSent => 'Bestätigungs-E-Mail gesendet!';

  @override
  String get verifyEmailContinue => 'Ich habe bestätigt, weiter';

  @override
  String get verifyEmailSignOut => 'Abmelden';

  @override
  String get verifyEmailSending => 'Wird gesendet …';

  @override
  String get verifyEmailResend => 'Bestätigungs-E-Mail erneut senden';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Erneut senden in $seconds Sek.';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'E-Mail: $email';
  }

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get forgotPasswordBody =>
      'Gib deine E-Mail-Adresse ein, um einen Link zum Zurücksetzen deines Passworts zu erhalten.';

  @override
  String get forgotPasswordEmptyEmail => 'Bitte gib eine E-Mail-Adresse ein';

  @override
  String get forgotPasswordSent =>
      'E-Mail zum Zurücksetzen des Passworts gesendet.';

  @override
  String get forgotPasswordSend => 'Link zum Zurücksetzen senden';

  @override
  String get forgotPasswordSending => 'Wird gesendet …';

  @override
  String get nameSetupTitle => 'Wie soll Celia dich nennen?';

  @override
  String get nameSetupBody =>
      'Wir verwenden deinen Namen in der gesamten App, damit sich das Coaching persönlich anfühlt.';

  @override
  String get nameSetupSaveFailed =>
      'Dein Name konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get homeGoodMorning => 'Guten Morgen,';

  @override
  String get homeCeliaActive => 'CELIA AKTIV';

  @override
  String get homeGenerateRoutine =>
      'Erstelle deine\npersonalisierte\nRoutine mit KI';

  @override
  String get homeCreateRoutine => 'Routine erstellen';

  @override
  String get homeQuickActions => 'Schnellaktionen';

  @override
  String get homeUpNext => 'Als Nächstes';

  @override
  String get homeNoUpcoming =>
      'Noch keine anstehenden Routinen.\nErstelle eine oder durchsuche die Bibliothek.';

  @override
  String get homeChatWithCelia => 'Mit Celia chatten';

  @override
  String get homeChatSubtitle => 'Frage nach deiner Form oder Ernährung';

  @override
  String get homeScanMeal => 'Mahlzeit scannen';

  @override
  String get homeScanMealSubtitle => 'Lebensmittel & Kalorien erkennen';

  @override
  String get homeNutrition => 'Ernährung';

  @override
  String get homeNutritionSubtitle => 'Kalorien, Makros & Mahlzeiten ansehen';

  @override
  String get homeBrowseLibrary => 'Bibliothek\ndurchsuchen';

  @override
  String get homeTrackProgress => 'Fortschritt\nverfolgen';

  @override
  String get chatTitle => 'Coach Celia';

  @override
  String get chatEmptyPrompt =>
      'Wie kann ich dir heute\nhelfen, fit zu werden?';

  @override
  String get chatYourChats => 'Deine Chats';

  @override
  String get chatNoSavedChats => 'Noch keine gespeicherten Chats.';

  @override
  String get chatHistory => 'Chatverlauf';

  @override
  String get chatNew => 'Neuer Chat';

  @override
  String get chatOpening => 'Chat wird geöffnet …';

  @override
  String get chatScanAMeal => 'Mahlzeit scannen';

  @override
  String get chatInputHint => 'Frage Celia alles über dein Training …';

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
  String get chatCouldNotOpenRoutine =>
      'Diese Routine konnte nicht geöffnet werden';

  @override
  String get chatThisRoutine => 'diese Routine';

  @override
  String get chatThisMeal => 'diese Mahlzeit';

  @override
  String get chatYourRoutine => 'Deine Routine';

  @override
  String chatMoreExercises(int count) {
    return '+ $count weitere';
  }

  @override
  String get chatEmptySubtitle =>
      'Frage nach deinem Training, deiner Ernährung oder deinem Fortschritt.';

  @override
  String chatLoggedToday(int calories) {
    return 'Du hast heute $calories kcal erfasst.';
  }

  @override
  String get chatSuggestionHiit => 'Erstelle mir eine 20-minütige HIIT-Routine';

  @override
  String get chatSuggestionDinner => 'Was soll ich heute Abend essen?';

  @override
  String get chatSuggestionProgress => 'Wie läuft es diese Woche bei mir?';

  @override
  String get chatSuggestionIngredients => 'Ich habe Hähnchen, Reis und Spinat';

  @override
  String get chatJustNow => 'Gerade eben';

  @override
  String chatMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String chatHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String chatDaysAgo(int days) {
    return 'vor $days Tg.';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Bereits in deiner Bibliothek – tippe zum Öffnen';

  @override
  String get chatRoutineTapToOpen => 'Zum Öffnen tippen';

  @override
  String get chatToolCancelled => 'Abgebrochen';

  @override
  String chatToolFailed(String label) {
    return '$label – das hat nicht funktioniert';
  }

  @override
  String get chatToolRoutineSaveFailed =>
      'Routine konnte nicht gespeichert werden';

  @override
  String get chatToolRoutineSaved => 'In deiner Bibliothek gespeichert';

  @override
  String get chatToolMealLogged => 'Zum heutigen Protokoll hinzugefügt';

  @override
  String get chatToolRoutineAdded => 'Zu deiner Bibliothek hinzugefügt';

  @override
  String get activityCheckingProgress => 'Deinen Fortschritt wird überprüft';

  @override
  String get activityCheckingNutrition =>
      'Deine heutige Ernährung wird überprüft';

  @override
  String get activityReviewingMeals =>
      'Deine letzten Mahlzeiten werden überprüft';

  @override
  String get activityLookingAtRoutines => 'Deine Routinen werden angesehen';

  @override
  String get activityReadingRoutine => 'Diese Routine wird gelesen';

  @override
  String get activitySearchingLibrary => 'Übungsbibliothek wird durchsucht';

  @override
  String get activityBuildingRoutine => 'Deine Routine wird erstellt';

  @override
  String get activityLoggingMeal => 'Deine Mahlzeit wird protokolliert';

  @override
  String get activitySavingToLibrary => 'Wird in deiner Bibliothek gespeichert';

  @override
  String get activityWorking => 'Einen Moment bitte';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return '„$name“ mit $count Übungen in deiner Bibliothek speichern?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '„$name“ in deiner Bibliothek speichern?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '„$name“ mit $calories kcal protokollieren?';
  }

  @override
  String approvalLogMeal(String name) {
    return '„$name“ protokollieren?';
  }

  @override
  String get approvalAddRoutine =>
      'Diese Routine zu deiner Bibliothek hinzufügen?';

  @override
  String get approvalGeneric => 'Celia dies erlauben?';

  @override
  String get libraryTitle => 'Routinenbibliothek';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '$count Schritt',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Noch keine Routinen';

  @override
  String get libraryEmptyBody =>
      'Erstelle und veröffentliche Routinen im Admin-Dashboard.';

  @override
  String get libraryLoadFailed => 'Routinen konnten nicht geladen werden';

  @override
  String get routineStartWorkout => 'Training starten';

  @override
  String get routineNoSteps => 'Keine Schritte verfügbar';

  @override
  String get routineNoVideoForStep =>
      'Für diesen Schritt ist kein Video verfügbar';

  @override
  String get routineVideoProcessing =>
      'Das Video wird noch verarbeitet. Bitte später erneut versuchen.';

  @override
  String get routineMissingPlaybackUrl =>
      'Die Wiedergabe-URL für dieses Video fehlt';

  @override
  String get routinePreviewBanner =>
      'VORSCHAU — vollständiges Video folgt bald';

  @override
  String get routinePreview => 'VORSCHAU';

  @override
  String get routineDetails => 'Details';

  @override
  String get routineNotFound => 'Routine nicht gefunden';

  @override
  String routineCompletedTimes(int count) {
    return '$count× absolviert';
  }

  @override
  String get playerVideoUnavailable =>
      'Dieses Video ist momentan nicht verfügbar.';

  @override
  String get playerSteps => 'Schritte';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Keine abspielbaren Videos';

  @override
  String get playerWorkoutComplete => 'Training abgeschlossen!';

  @override
  String get playerSavingStreak => 'Wird in deiner Serie gespeichert…';

  @override
  String get playerSavedStreak => 'In deiner Serie gespeichert';

  @override
  String get playerRetrySave => 'Erneut speichern';

  @override
  String get playerReplay => 'Erneut abspielen';

  @override
  String get playerNotReady => 'Player nicht bereit';

  @override
  String get playerPreviewUnavailable => 'Vorschau momentan nicht verfügbar.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current von $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Fehler beim Laden des Videos';

  @override
  String get playerLoadingVideo => 'Video wird geladen...';

  @override
  String get playerFailedToLoadVideo => 'Video konnte nicht geladen werden';

  @override
  String get playerNotInitialized => 'Videoplayer nicht initialisiert';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Übung $current/$total';
  }

  @override
  String get guidedGetReady => 'BEREIT MACHEN';

  @override
  String guidedSetOf(int current, int total) {
    return 'Satz $current von $total';
  }

  @override
  String get guidedRest => 'PAUSE';

  @override
  String get guidedSkipRest => 'Pause überspringen';

  @override
  String get guidedPaused => 'Pausiert';

  @override
  String get guidedResume => 'Fortsetzen';

  @override
  String get guidedWorkoutComplete => 'Training abgeschlossen';

  @override
  String get guidedEndTitle => 'Training beenden?';

  @override
  String get guidedEndBody =>
      'Dein Fortschritt für diese Einheit wird nicht gespeichert.';

  @override
  String get guidedKeepGoing => 'Weiter';

  @override
  String get guidedEnd => 'Beenden';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wiederholungen',
      one: '$count Wiederholung',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Routine mit KI erstellen';

  @override
  String get generateSheetPrompt =>
      'Welche Art von Training möchtest du machen?';

  @override
  String get generateSheetHint =>
      'z. B. „Eine kurze morgendliche Dehnung zum Aufwachen“ oder „Ganzkörper-Krafttraining für Anfänger“';

  @override
  String get generateSheetDuration => 'Dauer';

  @override
  String generateSheetMinutes(int count) {
    return '$count Min.';
  }

  @override
  String get generateSheetDifficulty => 'Schwierigkeitsgrad';

  @override
  String get generateSheetEquipment => 'Verfügbare Ausrüstung';

  @override
  String get generateSheetGenerating => 'Wird erstellt …';

  @override
  String get generateSheetSubmit => 'Routine erstellen';

  @override
  String get generateSheetDescribeFirst =>
      'Bitte beschreibe das gewünschte Training';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Diese Routine hast du bereits: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Erstellt: $title';
  }

  @override
  String get generateSheetFailed => 'Routine konnte nicht erstellt werden';

  @override
  String get guidedNoExercises => 'Diese Routine enthält noch keine Übungen.';

  @override
  String get guidedStartFailed =>
      'Dieses Training kann gerade nicht gestartet werden. Bitte versuche es erneut.';

  @override
  String get guidedSaveFailed =>
      'Dieses Training konnte nicht gespeichert werden. Tippe auf „Erneut versuchen“, um deine Serie zu aktualisieren.';

  @override
  String guidedOfReps(int count) {
    return 'von $count Wiederholungen';
  }

  @override
  String get guidedHold => 'halten';

  @override
  String get guidedNextSet => 'Nächster Satz';

  @override
  String get guidedUpNext => 'Als Nächstes';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × $seconds Sek. halten';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Mach dich bereit. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Los. $count Wiederholungen.';
  }

  @override
  String coachStartHold(int seconds) {
    return '$seconds Sekunden halten.';
  }

  @override
  String coachRest(String exercise) {
    return 'Pause. Als Nächstes: $exercise';
  }

  @override
  String get coachRestShort => 'Pause.';

  @override
  String get coachComplete => 'Großartige Leistung. Training abgeschlossen.';

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
      'In dieser Routine wurden keine abspielbaren Videos gefunden.';

  @override
  String get playerLoadRoutineFailed =>
      'Diese Routine kann gerade nicht geladen werden. Bitte versuche es erneut.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return '„$title“ konnte nicht geladen werden. Wird übersprungen …';
  }

  @override
  String playerStepLoadFailed(String title) {
    return '„$title“ konnte nicht geladen werden.';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Der Abschluss konnte nicht gespeichert werden. Tippe auf „Erneut versuchen“, um deine Serie zu aktualisieren.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Vorschau';
  }

  @override
  String get playerNoVideosReady =>
      'Diese Routine enthält noch keine abspielbereiten Videos.';

  @override
  String get playerPlaybackFailed =>
      'Dieses Video kann gerade nicht abgespielt werden. Bitte versuche es erneut.';

  @override
  String get libraryTabCurated => 'Ausgewählt';

  @override
  String get libraryTabAiGenerated => 'Von KI erstellt';

  @override
  String get profileSavedRoutines => 'Gespeicherte Routinen';

  @override
  String get savedRoutinesNoFavorites => 'Noch keine Lieblingsroutinen.';

  @override
  String get savedRoutinesEmpty => 'Noch keine gespeicherten Routinen.';

  @override
  String get actionFavorite => 'Als Favorit speichern';

  @override
  String get actionUnfavorite => 'Aus Favoriten entfernen';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String routineDurationHours(int hours) {
    return '$hours Std.';
  }

  @override
  String get difficultyEasy => 'Einfach';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwierig';

  @override
  String get categoryStrength => 'Kraft';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Flexibilität';

  @override
  String get categoryMindfulness => 'Achtsamkeit';

  @override
  String get categoryDance => 'Tanz';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Benutzerdefiniert';

  @override
  String get navHome => 'Startseite';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get equipmentNone => 'Keine';

  @override
  String get equipmentDumbbells => 'Kurzhanteln';

  @override
  String get equipmentResistanceBands => 'Widerstandsbänder';

  @override
  String get equipmentYogaMat => 'Yogamatte';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Klimmzugstange';

  @override
  String get equipmentJumpRope => 'Springseil';

  @override
  String get nutritionTitle => 'Ernährung';

  @override
  String get nutritionSubtitle => 'Kalorien, Makros und Mahlzeitenverlauf';

  @override
  String get nutritionSetGoalsTitle => 'Tägliche Ernährungsziele festlegen';

  @override
  String get nutritionSetGoalsBody =>
      'Füge dein Gewicht, deine Größe, dein Alter und dein Geschlecht hinzu, damit Celia berechnen kann, wie viele Kalorien und Nährstoffe du täglich zu dir nehmen solltest.';

  @override
  String get nutritionSetUpGoals => 'Ziele festlegen';

  @override
  String get nutritionDailyTarget => 'Tagesziel';

  @override
  String get nutritionDailyGoals => 'Tägliche Ziele';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Heute';

  @override
  String get nutritionMealHistory => 'Mahlzeitenverlauf';

  @override
  String get nutritionCeliaInsights => 'Celia-Einblicke';

  @override
  String get nutritionWeeklyTrend => 'Wöchentlicher Trend';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mahlzeiten',
      one: '$count Mahlzeit',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mahlzeiten',
      one: '$count Mahlzeit',
    );
    return 'von $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'M,D,M,D,F,S,S';

  @override
  String get nutritionFieldFoodName => 'Lebensmittelname';

  @override
  String get nutritionFieldGrams => 'Gramm';

  @override
  String get nutritionFieldCalories => 'Kalorien';

  @override
  String get scannerStatusAnalyzing => 'ANALYSE LÄUFT...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => 'Lebensmittelname';

  @override
  String get scannerFieldGrams => 'Gramm';

  @override
  String get scannerFieldCalories => 'Kalorien';

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
    return 'Heute verbleiben $calories kcal und ${grams}g Protein';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal über deinem Tagesziel';
  }

  @override
  String get scannerButtonAnalyzing => 'Wird analysiert';

  @override
  String get scannerButtonQuotaNeeded => 'Kontingent erforderlich';

  @override
  String get scannerButtonScanNow => 'Jetzt scannen';

  @override
  String get scannerButtonLogging => 'Wird protokolliert';

  @override
  String get scannerButtonLogMeal => 'Mahlzeit protokollieren';

  @override
  String get scannerNoClearFood =>
      'Noch kein eindeutiges Lebensmittel erkannt. Sorge für besseres Licht oder gehe näher heran.';

  @override
  String get scannerErrorCameraPermission =>
      'Die Kameraberechtigung wird zum Scannen von Mahlzeiten benötigt.';

  @override
  String get scannerErrorBackendMissing =>
      'Das Backend für den Kalorienscanner ist noch nicht eingerichtet.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'Der OpenAI-API-Schlüssel für das Kalorienscannen ist ungültig. Ersetze ihn in der Backend-Umgebung, führe ein erneutes Deployment durch und versuche es dann erneut.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Für das Kalorienscannen ist ein OpenAI-API-Schlüssel erforderlich. Füge ihn in Vercel hinzu, führe ein erneutes Deployment durch und versuche es dann erneut.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Die OpenAI-Guthaben für das Kalorienscannen sind aufgebraucht. Füge API-Guthaben hinzu oder erhöhe das Abrechnungslimit und versuche es dann erneut.';

  @override
  String get scannerErrorTimeout =>
      'Celia benötigte mehr Zeit, um diese Mahlzeit zu analysieren. Halte die Kamera ruhig und scanne erneut.';

  @override
  String get scannerErrorNotSignedIn =>
      'Bitte melde dich an, bevor du Mahlzeiten scannst.';

  @override
  String get scannerErrorMealTableMissing =>
      'Die Tabelle zur Mahlzeitenprotokollierung ist noch nicht bereit. Das Scanergebnis ist weiterhin verfügbar.';

  @override
  String get scannerErrorGeneric =>
      'Celia konnte diese Mahlzeit noch nicht analysieren. Halte die Kamera ruhig, richte sie auf das Essen und scanne erneut.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '$count Eintrag',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Mahlzeitdetails';

  @override
  String get nutritionFoodItems => 'Lebensmittel';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Eine Mahlzeit benötigt mindestens ein Lebensmittel.';

  @override
  String get nutritionMealUpdated => 'Mahlzeit aktualisiert';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Mahlzeit konnte nicht aktualisiert werden: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Mahlzeit löschen?';

  @override
  String get nutritionDeleteMealBody =>
      'Dadurch wird die Mahlzeit aus deinem Ernährungsverlauf entfernt.';

  @override
  String get nutritionDeleteMeal => 'Mahlzeit löschen';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Mahlzeit konnte nicht gelöscht werden: $error';
  }

  @override
  String get nutritionEditFood => 'Lebensmittel bearbeiten';

  @override
  String get nutritionSaveFood => 'Lebensmittel speichern';

  @override
  String get nutritionLoadFailed => 'Mahlzeiten konnten nicht geladen werden';

  @override
  String get nutritionLoadFailedBody =>
      'Ziehe zum Aktualisieren nach unten oder überprüfe die Backend-Verbindung.';

  @override
  String get nutritionNoMeals => 'Noch keine Mahlzeiten erfasst';

  @override
  String get nutritionNoMealsBody =>
      'Scanne deine erste Mahlzeit, damit Celia deinen Ernährungsverlauf erstellt.';

  @override
  String get progressToday => 'Heute';

  @override
  String get progressSetGoals =>
      'Lege deine Ernährungsziele fest, um die Kalorien- und Makroverfolgung zu aktivieren.';

  @override
  String progressOfTarget(int target) {
    return 'von $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal über dem Ziel';
  }

  @override
  String progressKcalLeft(int calories) {
    return 'Noch $calories kcal';
  }

  @override
  String get progressProtein => 'Protein';

  @override
  String get progressCarbs => 'Kohlenhydrate';

  @override
  String get progressFat => 'Fett';

  @override
  String get scannerEditItem => 'Lebensmittel bearbeiten';

  @override
  String get scannerSaveChanges => 'Änderungen speichern';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Sicherheit $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count weitere Lebensmittel in diesem Mahlzeitenprotokoll enthalten';
  }

  @override
  String get scannerIfYouLog => 'Wenn du diese Mahlzeit erfasst';

  @override
  String scannerAfterLogging(int after, int target) {
    return 'Heute $after / $target kcal';
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
  String get scannerNoMealDetected => 'Keine Mahlzeit erkannt';

  @override
  String onboardingWelcome(String name) {
    return 'Willkommen, $name';
  }

  @override
  String get onboardingGender => 'Geschlecht';

  @override
  String get onboardingCalculateGoals => 'Meine Ziele berechnen';

  @override
  String get onboardingScanFirstMeal => 'Meine erste Mahlzeit scannen';

  @override
  String get onboardingExploreRoutines => 'Routinen entdecken';

  @override
  String get onboardingGoHome => 'Zur Startseite';

  @override
  String get onboardingDailyTargets => 'Deine täglichen Ziele';

  @override
  String onboardingProtein(int grams) {
    return 'Protein ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Protein ${protein}g • Kohlenhydrate ${carbs}g • Fett ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Deine täglichen Ernährungsziele sind bereit. Wähle, wie du beginnen möchtest.';

  @override
  String get onboardingWeightKg => 'Gewicht (kg)';

  @override
  String get onboardingHeightCm => 'Größe (cm)';

  @override
  String get onboardingAge => 'Alter';

  @override
  String get onboardingInvalidWeight => 'Gib ein gültiges Gewicht in kg ein.';

  @override
  String get onboardingInvalidHeight => 'Gib eine gültige Größe in cm ein.';

  @override
  String get onboardingInvalidAge =>
      'Gib ein gültiges Alter zwischen 13 und 100 ein.';

  @override
  String get onboardingSaveFailed =>
      'Dein Ernährungsprofil konnte nicht gespeichert werden.';

  @override
  String get genderMale => 'Männlich';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get genderOther => 'Andere';

  @override
  String get nutritionSetupTitle => 'Tägliche Ernährungsziele';

  @override
  String get nutritionSetupBody =>
      'Erzähle Celia etwas über deinen Körper, damit sie deine täglichen Kalorien- und Makroziele berechnen kann.';

  @override
  String get nutritionSetupGender => 'Geschlecht';

  @override
  String get nutritionSetupFootnote =>
      'Celia verwendet dein Gewicht, deine Größe, dein Alter und dein Geschlecht, um deine täglichen Kalorien- und Makroziele bei einem moderaten Aktivitätsniveau zu schätzen.';

  @override
  String get nutritionSourcesTitle => 'How these targets are calculated';

  @override
  String get nutritionSourcesBody =>
      'Daily calories use the Mifflin–St Jeor resting energy equation with a moderate physical activity factor (about 1.55). Protein is estimated near 1.8 g per kg body weight for active adults. Fat is set near 25% of calories, with carbs filling the remainder — within common dietary guidance ranges.';

  @override
  String get nutritionSourcesDisclaimer =>
      'These figures are general wellness estimates only. They are not a diagnosis, prescription, or substitute for advice from a qualified clinician or registered dietitian.';

  @override
  String get nutritionSetupSave => 'Ziele speichern';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Mitglied';

  @override
  String get profileAccount => 'Konto';

  @override
  String profileSignedInAs(String email) {
    return 'Angemeldet als:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Unbekannt';

  @override
  String get profileDarkMode => 'Dunkelmodus';

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get profileLogOutTitle => 'Abmelden?';

  @override
  String get profileLogOutBody => 'Möchtest du dich wirklich abmelden?';

  @override
  String get profileLogOut => 'Abmelden';

  @override
  String get profileLogOutButton => 'Abmelden';

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
  String get profileFavoriteRoutines => 'Favorisierte Routinen';

  @override
  String get profileSubscription => 'Abonnement';

  @override
  String get profileNutrition => 'Ernährung';

  @override
  String get profileHelpSupport => 'Hilfe & Support';

  @override
  String get profileFriend => 'Freund';

  @override
  String get profileStatSaved => 'Gespeichert';

  @override
  String get profileStatStreak => 'Serie';

  @override
  String get profileStatWorkouts => 'Workouts';

  @override
  String get streakDayOneStarted =>
      'Tag 1 hat begonnen – komm morgen wieder, um deine Serie aufzubauen.';

  @override
  String get streakRebuild =>
      'Du warst gestern aktiv – logge heute eine Mahlzeit oder schließe ein Workout ab, um deine Serie wieder aufzubauen.';

  @override
  String get streakStart =>
      'Logge eine Mahlzeit oder schließe ein Workout ab, um deine aktive Serie zu starten.';

  @override
  String streakLongRun(int days) {
    return '$days Tage Serie! Bleib dran – Celia verfolgt deine Beständigkeit.';
  }

  @override
  String streakBothLogged(int days) {
    return '$days Tage Serie – Workout und Ernährung heute protokolliert.';
  }

  @override
  String streakNeedWorkout(int days) {
    return '$days Tage Serie. Ein kurzes Workout würde den heutigen Tag abrunden.';
  }

  @override
  String streakNeedMeal(int days) {
    return '$days Tage Serie. Logge eine Mahlzeit, um deine Energiezufuhr zu verfolgen.';
  }

  @override
  String streakStayActive(int days) {
    return '$days Tage Serie – bleib heute aktiv.';
  }

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get editProfileName => 'Name';

  @override
  String get editProfileFootnote =>
      'Änderungen werden in deinem Konto gespeichert und auf der Startseite/im Profil angezeigt.';

  @override
  String get editProfileSaveFailed =>
      'Profil konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Gerätesprache';

  @override
  String get languageSystemSubtitle =>
      'Verwende die Sprache, die auf deinem Smartphone eingestellt ist';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get insightStartFuelingTitle =>
      'Starte heute mit deiner Energiezufuhr';

  @override
  String get insightStartFuelingBody =>
      'Dein gesamtes Kalorienbudget ist noch verfügbar. Scanne oder protokolliere deine erste Mahlzeit, um auf Kurs zu bleiben.';

  @override
  String get insightAboveTargetTitle => 'Heute über dem Ziel';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Du liegst heute $calories kcal über deinem Tagesziel. Halte das Abendessen etwas leichter oder ergänze ein kurzes Workout.';
  }

  @override
  String get insightLowProteinTitle => 'Protein ist noch zu niedrig';

  @override
  String insightLowProteinBody(int grams) {
    return 'Dir fehlen heute noch etwa ${grams}g Protein, um dein Ziel zu erreichen.';
  }

  @override
  String get insightAlmostThereTitle => 'Fast am Ziel';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Du hast heute noch $calories kcal übrig. Ein ausgewogener Snack passt gut dazu.';
  }

  @override
  String get insightOnTrackTitle => 'Heute auf Kurs';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Noch $calories kcal und ${grams}g Protein bis zu deinen Tageszielen.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Entwickle deinen Wochenrhythmus';

  @override
  String get insightWeeklyRhythmBody =>
      'Protokolliere über die Woche hinweg deine Mahlzeiten, damit Celia Muster erkennt und dich besser coachen kann.';

  @override
  String get insightWeeklyTrendTitle => 'Wöchentlicher Trend';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Du hast an $days der letzten 7 Tage Mahlzeiten protokolliert und dabei durchschnittlich $average kcal aufgenommen – $direction.';
  }

  @override
  String get insightTrendOnTarget =>
      'im Durchschnitt genau in der Nähe deines Tagesziels';

  @override
  String insightTrendAbove(int delta) {
    return 'im Durchschnitt $delta kcal über deinem Ziel';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'im Durchschnitt $delta kcal unter deinem Ziel';
  }

  @override
  String get insightsSectionTitle => 'Celia-Einblicke';
}
