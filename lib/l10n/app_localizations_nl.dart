// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionDelete => 'Verwijderen';

  @override
  String get actionEdit => 'Bewerken';

  @override
  String get actionRetry => 'Opnieuw proberen';

  @override
  String get actionDone => 'Gereed';

  @override
  String get actionClose => 'Sluiten';

  @override
  String get actionContinue => 'Doorgaan';

  @override
  String get actionSeeAll => 'Alles bekijken';

  @override
  String get actionYesDoIt => 'Ja, doen';

  @override
  String get actionNotNow => 'Niet nu';

  @override
  String get loadingPreparing => 'Celia voorbereiden...';

  @override
  String get loadingGeneric => 'Laden...';

  @override
  String get errorGeneric => 'Er is iets misgegaan. Probeer het opnieuw.';

  @override
  String get errorCanceled => 'Actie geannuleerd.';

  @override
  String get errorTooManyRequests =>
      'Te veel pogingen. Wacht een minuut en probeer het opnieuw.';

  @override
  String get errorNetwork =>
      'Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get errorBadCredentials => 'Onjuist e-mailadres of wachtwoord.';

  @override
  String get errorEmailInUse =>
      'Dit e-mailadres is al in gebruik. Probeer in plaats daarvan in te loggen.';

  @override
  String get errorWeakPassword =>
      'Gebruik een sterker wachtwoord en probeer het opnieuw.';

  @override
  String get errorInvalidEmail => 'Voer een geldig e-mailadres in.';

  @override
  String get errorNoPermission => 'Je hebt geen toestemming om dit te doen.';

  @override
  String get errorNotSignedIn => 'Log in en probeer het opnieuw.';

  @override
  String get errorNoConversation => 'Start een nieuwe chat om door te gaan.';

  @override
  String get errorNoPlayableVideos =>
      'Er zijn nog geen afspeelbare video\'s beschikbaar voor deze routine.';

  @override
  String get errorLoadRoutines =>
      'De routines kunnen momenteel niet worden geladen. Probeer het opnieuw.';

  @override
  String get errorLoadSavedRoutines =>
      'De opgeslagen routines kunnen momenteel niet worden geladen. Probeer het opnieuw.';

  @override
  String get errorGenerateRoutine =>
      'Er kan momenteel geen routine worden gegenereerd. Probeer het opnieuw.';

  @override
  String get errorLoadChats =>
      'De opgeslagen chats kunnen momenteel niet worden geladen.';

  @override
  String get errorCeliaUnavailable =>
      'Celia is momenteel niet beschikbaar. Probeer het opnieuw.';

  @override
  String get errorOpenConversation => 'Dit gesprek kon niet worden geopend.';

  @override
  String get errorDeleteConversation =>
      'Dit gesprek kon niet worden verwijderd. Probeer het opnieuw.';

  @override
  String get errorSignIn => 'Inloggen is mislukt. Probeer het opnieuw.';

  @override
  String get errorCreateAccount =>
      'Je account kon niet worden aangemaakt. Probeer het opnieuw.';

  @override
  String get errorSendResetEmail =>
      'De e-mail voor het opnieuw instellen kon niet worden verzonden. Probeer het opnieuw.';

  @override
  String get errorSendVerificationEmail =>
      'De verificatiemail kon niet worden verzonden. Probeer het opnieuw.';

  @override
  String get errorGoogleSignIn =>
      'Inloggen met Google is mislukt. Probeer het opnieuw.';

  @override
  String get errorAppleSignIn =>
      'Inloggen met Apple is mislukt. Probeer het opnieuw.';

  @override
  String get errorRefreshNutrition =>
      'De voedingsgegevens konden niet worden vernieuwd.';

  @override
  String get errorLoadNutritionProfile =>
      'Je voedingsprofiel kon niet worden geladen.';

  @override
  String get startupErrorTitle => 'De app kan niet worden gestart';

  @override
  String get startupErrorBody =>
      'Sluit de app en open deze opnieuw. Neem contact op met support als dit probleem aanhoudt.';

  @override
  String get authTagline => 'Je fitnessmaatje';

  @override
  String get authSignUp => 'Registreren';

  @override
  String get authLogIn => 'Inloggen';

  @override
  String authVersion(String version) {
    return 'Versie $version';
  }

  @override
  String get authForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get authOr => 'OF';

  @override
  String get authContinueWithGoogle => 'Doorgaan met Google';

  @override
  String get authContinueWithApple => 'Doorgaan met Apple';

  @override
  String get authAuthenticating => 'Verifiëren...';

  @override
  String get authEnterYourName => 'Voer je naam in.';

  @override
  String get authNeedAccount => 'Nog geen account? Registreren';

  @override
  String get authHaveAccount => 'Al een account? Inloggen';

  @override
  String get authFieldName => 'Je naam';

  @override
  String get authFieldEmail => 'E-mailadres';

  @override
  String get authFieldPassword => 'Wachtwoord';

  @override
  String get verifyEmailTitle => 'Verifieer je e-mailadres';

  @override
  String get verifyEmailHeading => 'Controleer je inbox';

  @override
  String get verifyEmailBody =>
      'Er is een verificatielink naar je e-mail gestuurd.';

  @override
  String get verifyEmailSent => 'Verificatie-e-mail verzonden!';

  @override
  String get verifyEmailContinue => 'Ik heb geverifieerd, doorgaan';

  @override
  String get verifyEmailSignOut => 'Uitloggen';

  @override
  String get verifyEmailSending => 'Verzenden...';

  @override
  String get verifyEmailResend => 'Verificatie-e-mail opnieuw verzenden';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Opnieuw verzenden over ${seconds}s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'E-mail: $email';
  }

  @override
  String get forgotPasswordTitle => 'Wachtwoord vergeten';

  @override
  String get forgotPasswordBody =>
      'Voer je e-mailadres in om een link voor het opnieuw instellen van je wachtwoord te ontvangen.';

  @override
  String get forgotPasswordEmptyEmail => 'Vul een e-mailadres in';

  @override
  String get forgotPasswordSent =>
      'E-mail voor het opnieuw instellen van je wachtwoord verzonden.';

  @override
  String get forgotPasswordSend => 'Resetlink verzenden';

  @override
  String get forgotPasswordSending => 'Verzenden...';

  @override
  String get nameSetupTitle => 'Hoe moet Celia je noemen?';

  @override
  String get nameSetupBody =>
      'We gebruiken je naam in de hele app, zodat de coaching persoonlijk aanvoelt.';

  @override
  String get nameSetupSaveFailed =>
      'Je naam kon niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get homeGoodMorning => 'Goedemorgen,';

  @override
  String get homeCeliaActive => 'CELIA ACTIEF';

  @override
  String get homeGenerateRoutine => 'Genereer je\npersoonlijke\nroutine met AI';

  @override
  String get homeCreateRoutine => 'Routine maken';

  @override
  String get homeQuickActions => 'Snelle acties';

  @override
  String get homeUpNext => 'Hierna';

  @override
  String get homeNoUpcoming =>
      'Nog geen aankomende routines.\nMaak er een of bekijk de bibliotheek.';

  @override
  String get homeChatWithCelia => 'Chat met Celia';

  @override
  String get homeChatSubtitle => 'Vraag naar je techniek of voeding';

  @override
  String get homeScanMeal => 'Maaltijd scannen';

  @override
  String get homeScanMealSubtitle => 'Voeding en calorieën herkennen';

  @override
  String get homeNutrition => 'Voeding';

  @override
  String get homeNutritionSubtitle =>
      'Bekijk calorieën, macro\'s en maaltijden';

  @override
  String get homeBrowseLibrary => 'Bibliotheek\nbekijken';

  @override
  String get homeTrackProgress => 'Voortgang\nbijhouden';

  @override
  String get chatTitle => 'Coach Celia';

  @override
  String get chatEmptyPrompt =>
      'Hoe kan ik je vandaag\nhelpen fitter te worden?';

  @override
  String get chatYourChats => 'Je chats';

  @override
  String get chatNoSavedChats => 'Nog geen opgeslagen chats.';

  @override
  String get chatHistory => 'Chatgeschiedenis';

  @override
  String get chatNew => 'Nieuwe chat';

  @override
  String get chatOpening => 'Chat openen...';

  @override
  String get chatScanAMeal => 'Een maaltijd scannen';

  @override
  String get chatInputHint => 'Vraag Celia alles over je training...';

  @override
  String get chatCouldNotOpenRoutine => 'Die routine kon niet worden geopend';

  @override
  String get chatThisRoutine => 'deze routine';

  @override
  String get chatThisMeal => 'deze maaltijd';

  @override
  String get chatYourRoutine => 'Je routine';

  @override
  String chatMoreExercises(int count) {
    return '+ $count meer';
  }

  @override
  String get chatEmptySubtitle =>
      'Vraag naar je training, voeding of voortgang.';

  @override
  String chatLoggedToday(int calories) {
    return 'Je hebt vandaag $calories kcal gelogd.';
  }

  @override
  String get chatSuggestionHiit =>
      'Maak een HIIT-routine van 20 minuten voor me';

  @override
  String get chatSuggestionDinner => 'Wat zal ik vanavond eten?';

  @override
  String get chatSuggestionProgress => 'Hoe doe ik het deze week?';

  @override
  String get chatSuggestionIngredients => 'Ik heb kip, rijst en spinazie';

  @override
  String get chatJustNow => 'Zojuist';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes min geleden';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours uur geleden';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days dagen geleden';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Al in je bibliotheek — tik om te openen';

  @override
  String get chatRoutineTapToOpen => 'Tik om te openen';

  @override
  String get chatToolCancelled => 'Geannuleerd';

  @override
  String chatToolFailed(String label) {
    return '$label — dat is niet gelukt';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Kan de routine niet opslaan';

  @override
  String get chatToolRoutineSaved => 'Opgeslagen in je bibliotheek';

  @override
  String get chatToolMealLogged => 'Toegevoegd aan het logboek van vandaag';

  @override
  String get chatToolRoutineAdded => 'Toegevoegd aan je bibliotheek';

  @override
  String get activityCheckingProgress => 'Je voortgang controleren';

  @override
  String get activityCheckingNutrition =>
      'Controleren wat je vandaag hebt gegeten';

  @override
  String get activityReviewingMeals => 'Je recente maaltijden bekijken';

  @override
  String get activityLookingAtRoutines => 'Je routines bekijken';

  @override
  String get activityReadingRoutine => 'Die routine doornemen';

  @override
  String get activitySearchingLibrary => 'De oefeningenbibliotheek doorzoeken';

  @override
  String get activityBuildingRoutine => 'Je routine samenstellen';

  @override
  String get activityLoggingMeal => 'Je maaltijd registreren';

  @override
  String get activitySavingToLibrary => 'Opslaan in je bibliotheek';

  @override
  String get activityWorking => 'Even bezig';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return '\"$name\" met $count oefeningen opslaan in je bibliotheek?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return '\"$name\" opslaan in je bibliotheek?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return '\"$name\" registreren met $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return '\"$name\" registreren?';
  }

  @override
  String get approvalAddRoutine => 'Deze routine aan je bibliotheek toevoegen?';

  @override
  String get approvalGeneric => 'Celia toestaan dit te doen?';

  @override
  String get libraryTitle => 'Routinesbibliotheek';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stappen',
      one: '$count stap',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Nog geen routines';

  @override
  String get libraryEmptyBody =>
      'Maak routines en publiceer ze in het beheerdersdashboard.';

  @override
  String get libraryLoadFailed => 'Routines laden mislukt';

  @override
  String get routineStartWorkout => 'Training starten';

  @override
  String get routineNoSteps => 'Geen stappen beschikbaar';

  @override
  String get routineNoVideoForStep => 'Geen video beschikbaar voor deze stap';

  @override
  String get routineVideoProcessing =>
      'De video wordt nog verwerkt. Probeer het later opnieuw.';

  @override
  String get routineMissingPlaybackUrl =>
      'Afspeel-URL ontbreekt voor deze video';

  @override
  String get routinePreviewBanner =>
      'VOORBEELD — volledige video binnenkort beschikbaar';

  @override
  String get routinePreview => 'VOORBEELD';

  @override
  String get routineDetails => 'Details';

  @override
  String get routineNotFound => 'Routine niet gevonden';

  @override
  String routineCompletedTimes(int count) {
    return '${count}x voltooid';
  }

  @override
  String get playerVideoUnavailable =>
      'Deze video is momenteel niet beschikbaar.';

  @override
  String get playerSteps => 'Stappen';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Geen afspeelbare video\'s';

  @override
  String get playerWorkoutComplete => 'Training voltooid!';

  @override
  String get playerSavingStreak => 'Opslaan in je reeks…';

  @override
  String get playerSavedStreak => 'Opgeslagen in je reeks';

  @override
  String get playerRetrySave => 'Opnieuw opslaan';

  @override
  String get playerReplay => 'Opnieuw afspelen';

  @override
  String get playerNotReady => 'Speler niet gereed';

  @override
  String get playerPreviewUnavailable =>
      'Voorbeeld momenteel niet beschikbaar.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current van $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Fout bij het laden van de video';

  @override
  String get playerLoadingVideo => 'Video laden...';

  @override
  String get playerFailedToLoadVideo => 'Video laden mislukt';

  @override
  String get playerNotInitialized => 'Videospeler niet geïnitialiseerd';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Oefening $current/$total';
  }

  @override
  String get guidedGetReady => 'MAAK JE KLAAR';

  @override
  String guidedSetOf(int current, int total) {
    return 'Set $current van $total';
  }

  @override
  String get guidedRest => 'RUST';

  @override
  String get guidedSkipRest => 'Rust overslaan';

  @override
  String get guidedPaused => 'Gepauzeerd';

  @override
  String get guidedResume => 'Hervatten';

  @override
  String get guidedWorkoutComplete => 'Training voltooid';

  @override
  String get guidedEndTitle => 'Training beëindigen?';

  @override
  String get guidedEndBody =>
      'Je voortgang voor deze sessie wordt niet opgeslagen.';

  @override
  String get guidedKeepGoing => 'Ga door';

  @override
  String get guidedEnd => 'Beëindigen';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count herhalingen',
      one: '$count herhaling',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Routine genereren met AI';

  @override
  String get generateSheetPrompt => 'Wat voor training wil je doen?';

  @override
  String get generateSheetHint =>
      'bijv. \"Een korte ochtendstretch om wakker te worden\" of \"Krachttraining voor het hele lichaam voor beginners\"';

  @override
  String get generateSheetDuration => 'Duur';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Moeilijkheidsgraad';

  @override
  String get generateSheetEquipment => 'Beschikbare apparatuur';

  @override
  String get generateSheetGenerating => 'Genereren...';

  @override
  String get generateSheetSubmit => 'Routine genereren';

  @override
  String get generateSheetDescribeFirst =>
      'Beschrijf eerst de training die je wilt';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Je hebt deze al: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Aangemaakt: $title';
  }

  @override
  String get generateSheetFailed => 'Routine genereren mislukt';

  @override
  String get guidedNoExercises => 'Deze routine bevat nog geen oefeningen.';

  @override
  String get guidedStartFailed =>
      'Deze training kan momenteel niet worden gestart. Probeer het opnieuw.';

  @override
  String get guidedSaveFailed =>
      'Deze training kon niet worden opgeslagen. Tik op Opnieuw proberen om je reeks bij te werken.';

  @override
  String guidedOfReps(int count) {
    return 'van $count herhalingen';
  }

  @override
  String get guidedHold => 'vasthouden';

  @override
  String get guidedNextSet => 'Volgende set';

  @override
  String get guidedUpNext => 'Hierna';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s vasthouden';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Maak je klaar. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Start. $count herhalingen.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Houd $seconds seconden vast.';
  }

  @override
  String coachRest(String exercise) {
    return 'Rust. Hierna: $exercise';
  }

  @override
  String get coachRestShort => 'Rust.';

  @override
  String get coachComplete => 'Goed gedaan. Training voltooid.';

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
      'Geen afspeelbare video\'s gevonden in deze routine.';

  @override
  String get playerLoadRoutineFailed =>
      'Deze routine kan momenteel niet worden geladen. Probeer het opnieuw.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Laden van \"$title\" mislukt. Overslaan…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Laden van \"$title\" mislukt.';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Voltooien kon niet worden opgeslagen. Tik op Opnieuw proberen om je reeks bij te werken.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Voorbeeld';
  }

  @override
  String get playerNoVideosReady =>
      'Deze routine bevat nog geen video\'s die kunnen worden afgespeeld.';

  @override
  String get playerPlaybackFailed =>
      'Deze video kan momenteel niet worden afgespeeld. Probeer het opnieuw.';

  @override
  String get libraryTabCurated => 'Samengesteld';

  @override
  String get libraryTabAiGenerated => 'Door AI gegenereerd';

  @override
  String get profileSavedRoutines => 'Opgeslagen routines';

  @override
  String get savedRoutinesNoFavorites => 'Nog geen favoriete routines.';

  @override
  String get savedRoutinesEmpty => 'Nog geen opgeslagen routines.';

  @override
  String get actionFavorite => 'Aan favorieten toevoegen';

  @override
  String get actionUnfavorite => 'Uit favorieten verwijderen';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '${hours}u ${minutes}m';
  }

  @override
  String routineDurationHours(int hours) {
    return '${hours}u';
  }

  @override
  String get difficultyEasy => 'Makkelijk';

  @override
  String get difficultyMedium => 'Gemiddeld';

  @override
  String get difficultyHard => 'Moeilijk';

  @override
  String get categoryStrength => 'Kracht';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Flexibiliteit';

  @override
  String get categoryMindfulness => 'Mindfulness';

  @override
  String get categoryDance => 'Dans';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Aangepast';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Bibliotheek';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profiel';

  @override
  String get equipmentNone => 'Geen';

  @override
  String get equipmentDumbbells => 'Halters';

  @override
  String get equipmentResistanceBands => 'Weerstandsbanden';

  @override
  String get equipmentYogaMat => 'Yogamat';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Optrekstang';

  @override
  String get equipmentJumpRope => 'Springtouw';

  @override
  String get nutritionTitle => 'Voeding';

  @override
  String get nutritionSubtitle => 'Calorieën, macro\'s en maaltijdgeschiedenis';

  @override
  String get nutritionSetGoalsTitle => 'Stel je dagelijkse voedingsdoelen in';

  @override
  String get nutritionSetGoalsBody =>
      'Voeg je gewicht, lengte, leeftijd en geslacht toe, zodat Celia kan berekenen hoeveel calorieën en voedingsstoffen je elke dag moet binnenkrijgen.';

  @override
  String get nutritionSetUpGoals => 'Doelen instellen';

  @override
  String get nutritionDailyTarget => 'Dagelijks doel';

  @override
  String get nutritionDailyGoals => 'Dagelijkse doelen';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Vandaag';

  @override
  String get nutritionMealHistory => 'Maaltijdgeschiedenis';

  @override
  String get nutritionCeliaInsights => 'Celia-inzichten';

  @override
  String get nutritionWeeklyTrend => 'Wekelijkse trend';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maaltijden',
      one: '$count maaltijd',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maaltijden',
      one: '$count maaltijd',
    );
    return 'van $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'M,D,W,D,V,Z,Z';

  @override
  String get nutritionFieldFoodName => 'Naam van voedingsmiddel';

  @override
  String get nutritionFieldGrams => 'Gram';

  @override
  String get nutritionFieldCalories => 'Calorieën';

  @override
  String get scannerStatusAnalyzing => 'ANALYSEREN...';

  @override
  String get scannerStatusIdle => 'CELIA SCANNER';

  @override
  String get scannerFieldFoodName => 'Naam van voedingsmiddel';

  @override
  String get scannerFieldGrams => 'Gram';

  @override
  String get scannerFieldCalories => 'Calorieën';

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
    return 'Nog $calories kcal en ${grams}g eiwit over voor vandaag';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal boven je dagelijkse doel';
  }

  @override
  String get scannerButtonAnalyzing => 'Analyseren';

  @override
  String get scannerButtonQuotaNeeded => 'Quotum vereist';

  @override
  String get scannerButtonScanNow => 'Nu scannen';

  @override
  String get scannerButtonLogging => 'Loggen';

  @override
  String get scannerButtonLogMeal => 'Maaltijd loggen';

  @override
  String get scannerNoClearFood =>
      'Er is nog geen duidelijk voedingsmiddel gedetecteerd. Zorg voor betere belichting of houd de camera dichterbij.';

  @override
  String get scannerErrorCameraPermission =>
      'Cameratoegang is nodig om maaltijden te scannen.';

  @override
  String get scannerErrorBackendMissing =>
      'De backend voor de caloriescanner is nog niet geconfigureerd.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'De OpenAI API-sleutel voor het scannen van calorieën is ongeldig. Vervang deze in de backendomgeving, implementeer opnieuw en probeer het nogmaals.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Een OpenAI API-sleutel is vereist om calorieën te scannen. Voeg deze toe in Vercel, implementeer opnieuw en probeer het nogmaals.';

  @override
  String get scannerErrorQuotaExhausted =>
      'De OpenAI-tegoeden voor het scannen van calorieën zijn op. Voeg API-tegoed toe of verhoog de factureringslimiet en probeer het nogmaals.';

  @override
  String get scannerErrorTimeout =>
      'Celia had meer tijd nodig om deze maaltijd te analyseren. Houd de camera stil en scan opnieuw.';

  @override
  String get scannerErrorNotSignedIn =>
      'Meld je aan voordat je maaltijden scant.';

  @override
  String get scannerErrorMealTableMissing =>
      'De tabel voor het loggen van maaltijden is nog niet klaar. Het scanresultaat is nog steeds beschikbaar.';

  @override
  String get scannerErrorGeneric =>
      'Celia kon deze maaltijd nog niet analyseren. Houd de camera stil, houd het eten in het midden en scan opnieuw.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Maaltijddetails';

  @override
  String get nutritionFoodItems => 'Voedingsmiddelen';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Een maaltijd moet minstens één voedingsmiddel bevatten.';

  @override
  String get nutritionMealUpdated => 'Maaltijd bijgewerkt';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Maaltijd bijwerken mislukt: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Maaltijd verwijderen?';

  @override
  String get nutritionDeleteMealBody =>
      'Hiermee verwijder je de maaltijd uit je voedingsgeschiedenis.';

  @override
  String get nutritionDeleteMeal => 'Maaltijd verwijderen';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Maaltijd verwijderen mislukt: $error';
  }

  @override
  String get nutritionEditFood => 'Voedingsmiddel bewerken';

  @override
  String get nutritionSaveFood => 'Voedingsmiddel opslaan';

  @override
  String get nutritionLoadFailed => 'Maaltijden laden mislukt';

  @override
  String get nutritionLoadFailedBody =>
      'Trek omlaag om te vernieuwen of controleer de verbinding met de backend.';

  @override
  String get nutritionNoMeals => 'Nog geen maaltijden geregistreerd';

  @override
  String get nutritionNoMealsBody =>
      'Scan je eerste maaltijd en Celia bouwt je voedingsgeschiedenis op.';

  @override
  String get progressToday => 'Vandaag';

  @override
  String get progressSetGoals =>
      'Stel je voedingsdoelen in om calorieën en macro\'s bij te houden.';

  @override
  String progressOfTarget(int target) {
    return 'van $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal boven doel';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal over';
  }

  @override
  String get progressProtein => 'Eiwit';

  @override
  String get progressCarbs => 'Koolhydraten';

  @override
  String get progressFat => 'Vet';

  @override
  String get scannerEditItem => 'Voedingsmiddel bewerken';

  @override
  String get scannerSaveChanges => 'Wijzigingen opslaan';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Betrouwbaarheid $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count extra voedingsmiddelen in deze maaltijdregistratie';
  }

  @override
  String get scannerIfYouLog => 'Als je deze maaltijd registreert';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal vandaag';
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
  String get scannerNoMealDetected => 'Geen maaltijd gedetecteerd';

  @override
  String onboardingWelcome(String name) {
    return 'Welkom, $name';
  }

  @override
  String get onboardingGender => 'Geslacht';

  @override
  String get onboardingCalculateGoals => 'Mijn doelen berekenen';

  @override
  String get onboardingScanFirstMeal => 'Mijn eerste maaltijd scannen';

  @override
  String get onboardingExploreRoutines => 'Routines ontdekken';

  @override
  String get onboardingGoHome => 'Naar Home';

  @override
  String get onboardingDailyTargets => 'Je dagelijkse doelen';

  @override
  String onboardingProtein(int grams) {
    return 'Eiwit ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Eiwit ${protein}g • Koolhydraten ${carbs}g • Vet ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Je dagelijkse voedingsdoelen zijn klaar. Kies hoe je wilt beginnen.';

  @override
  String get onboardingWeightKg => 'Gewicht (kg)';

  @override
  String get onboardingHeightCm => 'Lengte (cm)';

  @override
  String get onboardingAge => 'Leeftijd';

  @override
  String get onboardingInvalidWeight => 'Voer een geldig gewicht in kg in.';

  @override
  String get onboardingInvalidHeight => 'Voer een geldige lengte in cm in.';

  @override
  String get onboardingInvalidAge =>
      'Voer een geldige leeftijd tussen 13 en 100 in.';

  @override
  String get onboardingSaveFailed =>
      'Je voedingsprofiel kon niet worden opgeslagen.';

  @override
  String get genderMale => 'Man';

  @override
  String get genderFemale => 'Vrouw';

  @override
  String get genderOther => 'Anders';

  @override
  String get nutritionSetupTitle => 'Dagelijkse voedingsdoelen';

  @override
  String get nutritionSetupBody =>
      'Vertel Celia over je lichaam, zodat ze je dagelijkse calorieën en macro\'s kan berekenen.';

  @override
  String get nutritionSetupGender => 'Geslacht';

  @override
  String get nutritionSetupFootnote =>
      'Celia gebruikt je gewicht, lengte, leeftijd en geslacht om je dagelijkse calorie- en macronutriëntendoelen te schatten op basis van een gemiddeld activiteitsniveau.';

  @override
  String get nutritionSetupSave => 'Doelen opslaan';

  @override
  String get profileTitle => 'Profiel';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Lid';

  @override
  String get profileAccount => 'Account';

  @override
  String profileSignedInAs(String email) {
    return 'Ingelogd als:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Onbekend';

  @override
  String get profileDarkMode => 'Donkere modus';

  @override
  String get profileLanguage => 'Taal';

  @override
  String get profileLogOutTitle => 'Uitloggen?';

  @override
  String get profileLogOutBody => 'Weet je zeker dat je wilt uitloggen?';

  @override
  String get profileLogOut => 'Uitloggen';

  @override
  String get profileLogOutButton => 'Uitloggen';

  @override
  String get profileFavoriteRoutines => 'Favoriete routines';

  @override
  String get profileSubscription => 'Abonnement';

  @override
  String get profileNutrition => 'Voeding';

  @override
  String get profileHelpSupport => 'Help en ondersteuning';

  @override
  String get profileFriend => 'Vriend';

  @override
  String get profileStatSaved => 'Opgeslagen';

  @override
  String get profileStatStreak => 'Reeks';

  @override
  String get profileStatWorkouts => 'Work-outs';

  @override
  String get streakDayOneStarted =>
      'Dag 1 is begonnen — kom morgen terug om je reeks op te bouwen.';

  @override
  String get streakRebuild =>
      'Je was gisteren actief — log vandaag een maaltijd of voltooi een work-out om je reeks opnieuw op te bouwen.';

  @override
  String get streakStart =>
      'Log een maaltijd of voltooi een work-out om je actieve reeks te starten.';

  @override
  String streakLongRun(int days) {
    return 'Reeks van $days dagen! Blijf komen opdagen — Celia houdt je consistentie bij.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Reeks van $days dagen — vandaag zijn zowel je work-out als voeding geregistreerd.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Reeks van $days dagen. Met een korte work-out maak je vandaag compleet.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Reeks van $days dagen. Log een maaltijd om je voeding bij te houden.';
  }

  @override
  String streakStayActive(int days) {
    return 'Reeks van $days dagen — blijf vandaag actief.';
  }

  @override
  String get editProfileTitle => 'Profiel bewerken';

  @override
  String get editProfileName => 'Naam';

  @override
  String get editProfileFootnote =>
      'Wijzigingen worden opgeslagen in je account en weergegeven op Home/Profiel.';

  @override
  String get editProfileSaveFailed =>
      'Profiel bijwerken mislukt. Probeer het opnieuw.';

  @override
  String get languageTitle => 'Taal';

  @override
  String get languageSystem => 'Apparaattaal';

  @override
  String get languageSystemSubtitle =>
      'Volg de taal die op je telefoon is ingesteld';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageSpanish => 'Spaans';

  @override
  String get insightStartFuelingTitle => 'Begin vandaag met eten';

  @override
  String get insightStartFuelingBody =>
      'Je hebt nog je volledige calorieënbudget over. Scan of log je eerste maaltijd om op koers te blijven.';

  @override
  String get insightAboveTargetTitle => 'Vandaag boven je doel';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Je zit $calories kcal boven je dagelijkse doel. Eet een lichtere avondmaaltijd of voeg een korte work-out toe.';
  }

  @override
  String get insightLowProteinTitle => 'Nog weinig eiwitten';

  @override
  String insightLowProteinBody(int grams) {
    return 'Je hebt vandaag nog ongeveer ${grams}g eiwitten nodig om je doel te halen.';
  }

  @override
  String get insightAlmostThereTitle => 'Bijna bij je doel';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Je hebt vandaag nog $calories kcal over. Een uitgebalanceerde snack past hier goed bij.';
  }

  @override
  String get insightOnTrackTitle => 'Vandaag op koers';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Nog $calories kcal en ${grams}g eiwitten om je dagelijkse doelen te bereiken.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Bouw je wekelijkse ritme op';

  @override
  String get insightWeeklyRhythmBody =>
      'Log maaltijden gedurende de week, zodat Celia patronen kan herkennen en je beter kan begeleiden.';

  @override
  String get insightWeeklyTrendTitle => 'Wekelijkse trend';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Je hebt op $days van de afgelopen 7 dagen maaltijden gelogd, gemiddeld $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'precies rond je dagelijkse doel';

  @override
  String insightTrendAbove(int delta) {
    return 'gemiddeld $delta kcal boven je doel';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'gemiddeld $delta kcal onder je doel';
  }

  @override
  String get insightsSectionTitle => 'Inzichten van Celia';
}
