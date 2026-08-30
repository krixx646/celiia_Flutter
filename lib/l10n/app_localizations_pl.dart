// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionEdit => 'Edytuj';

  @override
  String get actionRetry => 'Spróbuj ponownie';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get actionContinue => 'Kontynuuj';

  @override
  String get actionSeeAll => 'Zobacz wszystko';

  @override
  String get actionYesDoIt => 'Tak, zrób to';

  @override
  String get actionNotNow => 'Nie teraz';

  @override
  String get loadingPreparing => 'Przygotowywanie Celii...';

  @override
  String get loadingGeneric => 'Ładowanie...';

  @override
  String get errorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorCanceled => 'Anulowano działanie.';

  @override
  String get errorTooManyRequests =>
      'Zbyt wiele prób. Odczekaj minutę i spróbuj ponownie.';

  @override
  String get errorNetwork =>
      'Sprawdź połączenie z internetem i spróbuj ponownie.';

  @override
  String get errorBadCredentials => 'Nieprawidłowy adres e-mail lub hasło.';

  @override
  String get errorEmailInUse =>
      'Ten adres e-mail jest już używany. Spróbuj się zalogować.';

  @override
  String get errorWeakPassword => 'Użyj silniejszego hasła i spróbuj ponownie.';

  @override
  String get errorInvalidEmail => 'Wpisz prawidłowy adres e-mail.';

  @override
  String get errorNoPermission => 'Nie masz uprawnień, aby to zrobić.';

  @override
  String get errorNotSignedIn => 'Zaloguj się i spróbuj ponownie.';

  @override
  String get errorDeleteAccount =>
      'Nie udało się usunąć Twojego konta. Spróbuj ponownie.';

  @override
  String get errorNoConversation => 'Rozpocznij nowy czat, aby kontynuować.';

  @override
  String get errorNoPlayableVideos =>
      'Dla tego treningu nie ma jeszcze dostępnych filmów do odtworzenia.';

  @override
  String get errorLoadRoutines =>
      'Nie udało się teraz załadować treningów. Spróbuj ponownie.';

  @override
  String get errorLoadSavedRoutines =>
      'Nie udało się teraz załadować zapisanych treningów. Spróbuj ponownie.';

  @override
  String get errorGenerateRoutine =>
      'Nie udało się teraz wygenerować treningu. Spróbuj ponownie.';

  @override
  String get errorLoadChats => 'Nie można teraz załadować zapisanych czatów.';

  @override
  String get errorCeliaUnavailable =>
      'Celia jest teraz niedostępna. Spróbuj ponownie.';

  @override
  String get errorOpenConversation => 'Nie udało się otworzyć tej rozmowy.';

  @override
  String get errorDeleteConversation =>
      'Nie udało się usunąć tej rozmowy. Spróbuj ponownie.';

  @override
  String get errorSignIn => 'Nie udało się zalogować. Spróbuj ponownie.';

  @override
  String get errorCreateAccount =>
      'Nie udało się utworzyć konta. Spróbuj ponownie.';

  @override
  String get errorSendResetEmail =>
      'Nie udało się wysłać wiadomości e-mail umożliwiającej zresetowanie hasła. Spróbuj ponownie.';

  @override
  String get errorSendVerificationEmail =>
      'Nie udało się wysłać wiadomości e-mail z prośbą o weryfikację. Spróbuj ponownie.';

  @override
  String get errorGoogleSignIn =>
      'Logowanie przez Google nie powiodło się. Spróbuj ponownie.';

  @override
  String get errorAppleSignIn =>
      'Logowanie przez Apple nie powiodło się. Spróbuj ponownie.';

  @override
  String get errorRefreshNutrition =>
      'Nie udało się odświeżyć danych żywieniowych.';

  @override
  String get errorLoadNutritionProfile =>
      'Nie udało się załadować Twojego profilu żywieniowego.';

  @override
  String get startupErrorTitle => 'Nie można uruchomić aplikacji';

  @override
  String get startupErrorBody =>
      'Zamknij i ponownie otwórz aplikację. Jeśli problem będzie się powtarzał, skontaktuj się z pomocą techniczną.';

  @override
  String get authTagline => 'Twój partner treningowy';

  @override
  String get authSignUp => 'Zarejestruj się';

  @override
  String get authLogIn => 'Zaloguj się';

  @override
  String authVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get authForgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get authOr => 'LUB';

  @override
  String get authContinueWithGoogle => 'Kontynuuj przez Google';

  @override
  String get authContinueWithApple => 'Kontynuuj przez Apple';

  @override
  String get authAuthenticating => 'Uwierzytelnianie...';

  @override
  String get authEnterYourName => 'Wpisz swoje imię.';

  @override
  String get authNeedAccount => 'Nie masz konta? Zarejestruj się';

  @override
  String get authHaveAccount => 'Masz już konto? Zaloguj się';

  @override
  String get authFieldName => 'Twoje imię';

  @override
  String get authFieldEmail => 'E-mail';

  @override
  String get authFieldPassword => 'Hasło';

  @override
  String get verifyEmailTitle => 'Zweryfikuj swój adres e-mail';

  @override
  String get verifyEmailHeading => 'Sprawdź swoją skrzynkę odbiorczą';

  @override
  String get verifyEmailBody =>
      'Link weryfikacyjny został wysłany na Twój adres e-mail.';

  @override
  String get verifyEmailSent => 'E-mail weryfikacyjny został wysłany!';

  @override
  String get verifyEmailContinue => 'Zweryfikowano, kontynuuj';

  @override
  String get verifyEmailSignOut => 'Wyloguj się';

  @override
  String get verifyEmailSending => 'Wysyłanie...';

  @override
  String get verifyEmailResend => 'Wyślij ponownie e-mail weryfikacyjny';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Wyślij ponownie za ${seconds}s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'E-mail: $email';
  }

  @override
  String get forgotPasswordTitle => 'Nie pamiętasz hasła?';

  @override
  String get forgotPasswordBody =>
      'Wpisz swój adres e-mail, aby otrzymać link do resetowania hasła.';

  @override
  String get forgotPasswordEmptyEmail => 'Wpisz adres e-mail';

  @override
  String get forgotPasswordSent =>
      'E-mail z linkiem do resetowania hasła został wysłany.';

  @override
  String get forgotPasswordSend => 'Wyślij link resetujący';

  @override
  String get forgotPasswordSending => 'Wysyłanie...';

  @override
  String get nameSetupTitle => 'Jak Celia ma się do Ciebie zwracać?';

  @override
  String get nameSetupBody =>
      'Używamy Twojego imienia w całej aplikacji, aby coaching był bardziej osobisty.';

  @override
  String get nameSetupSaveFailed =>
      'Nie udało się zapisać imienia. Spróbuj ponownie.';

  @override
  String get homeGoodMorning => 'Dzień dobry,';

  @override
  String get homeCeliaActive => 'CELIA AKTYWNA';

  @override
  String get homeGenerateRoutine =>
      'Wygeneruj swój\nspersonalizowany\nplan z AI';

  @override
  String get homeCreateRoutine => 'Utwórz plan';

  @override
  String get homeQuickActions => 'Szybkie akcje';

  @override
  String get homeUpNext => 'Następne';

  @override
  String get homeNoUpcoming =>
      'Brak nadchodzących planów.\nUtwórz plan lub przejrzyj bibliotekę.';

  @override
  String get homeChatWithCelia => 'Porozmawiaj z Celia';

  @override
  String get homeChatSubtitle => 'Zapytaj o technikę lub dietę';

  @override
  String get homeScanMeal => 'Zeskanuj posiłek';

  @override
  String get homeScanMealSubtitle => 'Rozpoznaj jedzenie i kalorie';

  @override
  String get homeNutrition => 'Odżywianie';

  @override
  String get homeNutritionSubtitle =>
      'Zobacz kalorie, makroskładniki i posiłki';

  @override
  String get homeBrowseLibrary => 'Przeglądaj\nbibliotekę';

  @override
  String get homeTrackProgress => 'Śledź\npostępy';

  @override
  String get chatTitle => 'Trener Celia';

  @override
  String get chatEmptyPrompt => 'Jak mogę Ci pomóc\nzadbać dziś o formę?';

  @override
  String get chatYourChats => 'Twoje czaty';

  @override
  String get chatNoSavedChats => 'Brak zapisanych czatów.';

  @override
  String get chatHistory => 'Historia czatów';

  @override
  String get chatNew => 'Nowy czat';

  @override
  String get chatOpening => 'Otwieranie czatu...';

  @override
  String get chatScanAMeal => 'Zeskanuj posiłek';

  @override
  String get chatInputHint =>
      'Zapytaj Celia o cokolwiek związanego z treningiem...';

  @override
  String get chatMicTooltip => 'Przytrzymaj, aby mówić';

  @override
  String get chatAvatarReady => 'Gotowa';

  @override
  String get chatAvatarThinking => 'Myśli…';

  @override
  String get chatAvatarSpeaking => 'Mówi…';

  @override
  String chatAvatarSemantics(String status) {
    return 'Awatar Celii, $status';
  }

  @override
  String get chatListening => 'Słucham…';

  @override
  String get chatMicDenied =>
      'Dostęp do mikrofonu jest potrzebny, aby rozmawiać z Celią.';

  @override
  String get chatSpeechUnavailable =>
      'Rozpoznawanie mowy nie jest dostępne na tym urządzeniu.';

  @override
  String get chatCouldNotOpenRoutine => 'Nie udało się otworzyć tego planu';

  @override
  String get chatThisRoutine => 'tego planu';

  @override
  String get chatThisMeal => 'tego posiłku';

  @override
  String get chatYourRoutine => 'Twój plan';

  @override
  String chatMoreExercises(int count) {
    return '+ $count więcej';
  }

  @override
  String get chatEmptySubtitle =>
      'Zapytaj o swój trening, jedzenie lub postępy.';

  @override
  String chatLoggedToday(int calories) {
    return 'Dzisiaj zapisano $calories kcal.';
  }

  @override
  String get chatSuggestionHiit => 'Ułóż mi 20-minutowy plan HIIT';

  @override
  String get chatSuggestionDinner => 'Co powinienem dziś zjeść na kolację?';

  @override
  String get chatSuggestionProgress => 'Jak mi idzie w tym tygodniu?';

  @override
  String get chatSuggestionIngredients => 'Mam kurczaka, ryż i szpinak';

  @override
  String get chatJustNow => 'Przed chwilą';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes min temu';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours godz. temu';
  }

  @override
  String chatDaysAgo(int days) {
    return '$days dni temu';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Już w Twojej bibliotece — dotknij, aby otworzyć';

  @override
  String get chatRoutineTapToOpen => 'Dotknij, aby otworzyć';

  @override
  String get chatToolCancelled => 'Anulowano';

  @override
  String chatToolFailed(String label) {
    return '$label — nie udało się';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Nie udało się zapisać rutyny';

  @override
  String get chatToolRoutineSaved => 'Zapisano w bibliotece';

  @override
  String get chatToolMealLogged => 'Dodano do dzisiejszego dziennika';

  @override
  String get chatToolRoutineAdded => 'Dodano do biblioteki';

  @override
  String get activityCheckingProgress => 'Sprawdzanie Twoich postępów';

  @override
  String get activityCheckingNutrition => 'Sprawdzanie, co dziś jesz';

  @override
  String get activityReviewingMeals => 'Przeglądanie ostatnich posiłków';

  @override
  String get activityLookingAtRoutines => 'Przeglądanie Twoich rutyn';

  @override
  String get activityReadingRoutine => 'Odczytywanie tej rutyny';

  @override
  String get activitySearchingLibrary => 'Wyszukiwanie w bibliotece ćwiczeń';

  @override
  String get activityBuildingRoutine => 'Tworzenie Twojej rutyny';

  @override
  String get activityLoggingMeal => 'Dodawanie posiłku do dziennika';

  @override
  String get activitySavingToLibrary => 'Zapisywanie w bibliotece';

  @override
  String get activityWorking => 'Pracujemy nad tym';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Zapisać „$name” z $count ćwiczeniami w bibliotece?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Zapisać „$name” w bibliotece?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Dodać „$name” do dziennika ($calories kcal)?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Dodać „$name” do dziennika?';
  }

  @override
  String get approvalAddRoutine => 'Dodać tę rutynę do biblioteki?';

  @override
  String get approvalGeneric => 'Zezwolić Celia na wykonanie tej czynności?';

  @override
  String get libraryTitle => 'Biblioteka rutyn';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Brak rutyn';

  @override
  String get libraryEmptyBody =>
      'Twórz i publikuj rutyny w panelu administracyjnym.';

  @override
  String get libraryLoadFailed => 'Nie udało się załadować rutyn';

  @override
  String get routineStartWorkout => 'Rozpocznij trening';

  @override
  String get routineNoSteps => 'Brak dostępnych kroków';

  @override
  String get routineNoVideoForStep => 'Brak dostępnego filmu dla tego kroku';

  @override
  String get routineVideoProcessing =>
      'Film jest nadal przetwarzany. Spróbuj ponownie później.';

  @override
  String get routineMissingPlaybackUrl =>
      'Brak adresu URL odtwarzania tego filmu';

  @override
  String get routinePreviewBanner => 'PODGLĄD — pełny film już wkrótce';

  @override
  String get routinePreview => 'PODGLĄD';

  @override
  String get routineDetails => 'Szczegóły';

  @override
  String get routineNotFound => 'Nie znaleziono rutyny';

  @override
  String routineCompletedTimes(int count) {
    return 'Ukończono $count×';
  }

  @override
  String get playerVideoUnavailable => 'Ten film jest teraz niedostępny.';

  @override
  String get playerSteps => 'Kroki';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Brak filmów do odtworzenia';

  @override
  String get playerWorkoutComplete => 'Trening ukończony!';

  @override
  String get playerSavingStreak => 'Zapisywanie do serii…';

  @override
  String get playerSavedStreak => 'Zapisano do serii';

  @override
  String get playerRetrySave => 'Spróbuj zapisać ponownie';

  @override
  String get playerReplay => 'Odtwórz ponownie';

  @override
  String get playerNotReady => 'Odtwarzacz nie jest gotowy';

  @override
  String get playerPreviewUnavailable => 'Podgląd jest teraz niedostępny.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Klip $current z $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Błąd podczas ładowania filmu';

  @override
  String get playerLoadingVideo => 'Ładowanie filmu...';

  @override
  String get playerFailedToLoadVideo => 'Nie udało się załadować filmu';

  @override
  String get playerNotInitialized =>
      'Odtwarzacz wideo nie został zainicjalizowany';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Ćwiczenie $current/$total';
  }

  @override
  String get guidedGetReady => 'PRZYGOTUJ SIĘ';

  @override
  String guidedSetOf(int current, int total) {
    return 'Seria $current z $total';
  }

  @override
  String get guidedRest => 'ODPOCZYNEK';

  @override
  String get guidedSkipRest => 'Pomiń odpoczynek';

  @override
  String get guidedPaused => 'Wstrzymano';

  @override
  String get guidedResume => 'Wznów';

  @override
  String get guidedWorkoutComplete => 'Trening ukończony';

  @override
  String get guidedEndTitle => 'Zakończyć trening?';

  @override
  String get guidedEndBody => 'Postępy z tej sesji nie zostaną zapisane.';

  @override
  String get guidedKeepGoing => 'Kontynuuj';

  @override
  String get guidedEnd => 'Zakończ';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count powtórzeń',
      one: '$count powtórzenie',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Wygeneruj trening za pomocą AI';

  @override
  String get generateSheetPrompt => 'Jaki trening chcesz wykonać?';

  @override
  String get generateSheetHint =>
      'np. „Szybkie poranne rozciąganie na pobudzenie” lub „Trening siłowy całego ciała dla początkujących”';

  @override
  String get generateSheetDuration => 'Czas trwania';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Poziom trudności';

  @override
  String get generateSheetEquipment => 'Dostępny sprzęt';

  @override
  String get generateSheetGenerating => 'Generowanie...';

  @override
  String get generateSheetSubmit => 'Wygeneruj trening';

  @override
  String get generateSheetDescribeFirst =>
      'Opisz najpierw trening, który chcesz wykonać';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Już masz ten trening: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Utworzono: $title';
  }

  @override
  String get generateSheetFailed => 'Nie udało się wygenerować treningu';

  @override
  String get guidedNoExercises => 'Ten trening nie zawiera jeszcze ćwiczeń.';

  @override
  String get guidedStartFailed =>
      'Nie można teraz rozpocząć tego treningu. Spróbuj ponownie.';

  @override
  String get guidedSaveFailed =>
      'Nie udało się zapisać tego treningu. Stuknij „Ponów”, aby zaktualizować swoją passę.';

  @override
  String guidedOfReps(int count) {
    return 'z $count powtórzeń';
  }

  @override
  String get guidedHold => 'utrzymaj';

  @override
  String get guidedNextSet => 'Następna seria';

  @override
  String get guidedUpNext => 'Następne';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s utrzymania';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Przygotuj się. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Zaczynamy. $count powtórzeń.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Utrzymaj przez $seconds sekund.';
  }

  @override
  String coachRest(String exercise) {
    return 'Odpocznij. Następne: $exercise';
  }

  @override
  String get coachRestShort => 'Odpocznij.';

  @override
  String get coachComplete => 'Świetna robota. Trening ukończony.';

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
      'Nie znaleziono odtwarzalnych filmów w tym treningu.';

  @override
  String get playerLoadRoutineFailed =>
      'Nie można teraz załadować tego treningu. Spróbuj ponownie.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Nie udało się załadować „$title”. Pomijanie…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Nie udało się załadować „$title”.';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Nie udało się zapisać ukończenia. Stuknij „Ponów”, aby zaktualizować swoją passę.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Podgląd';
  }

  @override
  String get playerNoVideosReady =>
      'Ten trening nie zawiera jeszcze filmów gotowych do odtworzenia.';

  @override
  String get playerPlaybackFailed =>
      'Nie można teraz odtworzyć tego filmu. Spróbuj ponownie.';

  @override
  String get libraryTabCurated => 'Wybrane';

  @override
  String get libraryTabAiGenerated => 'Wygenerowane przez AI';

  @override
  String get profileSavedRoutines => 'Zapisane treningi';

  @override
  String get savedRoutinesNoFavorites =>
      'Nie masz jeszcze ulubionych treningów.';

  @override
  String get savedRoutinesEmpty => 'Nie masz jeszcze zapisanych treningów.';

  @override
  String get actionFavorite => 'Dodaj do ulubionych';

  @override
  String get actionUnfavorite => 'Usuń z ulubionych';

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
  String get difficultyEasy => 'Łatwy';

  @override
  String get difficultyMedium => 'Średni';

  @override
  String get difficultyHard => 'Trudny';

  @override
  String get categoryStrength => 'Siła';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Elastyczność';

  @override
  String get categoryMindfulness => 'Uważność';

  @override
  String get categoryDance => 'Taniec';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Joga';

  @override
  String get categoryCustom => 'Własna';

  @override
  String get navHome => 'Strona główna';

  @override
  String get navLibrary => 'Biblioteka';

  @override
  String get navChat => 'Czat';

  @override
  String get navProfile => 'Profil';

  @override
  String get equipmentNone => 'Brak';

  @override
  String get equipmentDumbbells => 'Hantle';

  @override
  String get equipmentResistanceBands => 'Gumy oporowe';

  @override
  String get equipmentYogaMat => 'Mata do jogi';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Drążek do podciągania';

  @override
  String get equipmentJumpRope => 'Skakanka';

  @override
  String get nutritionTitle => 'Odżywianie';

  @override
  String get nutritionSubtitle => 'Kalorie, makroskładniki i historia posiłków';

  @override
  String get nutritionSetGoalsTitle => 'Ustaw dzienne cele żywieniowe';

  @override
  String get nutritionSetGoalsBody =>
      'Dodaj swoją wagę, wzrost, wiek i płeć, aby Celia mogła obliczyć, ile kalorii i składników odżywczych należy spożywać każdego dnia.';

  @override
  String get nutritionSetUpGoals => 'Ustaw cele';

  @override
  String get nutritionDailyTarget => 'Dzienny cel';

  @override
  String get nutritionDailyGoals => 'Dzienne cele';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Dzisiaj';

  @override
  String get nutritionMealHistory => 'Historia posiłków';

  @override
  String get nutritionCeliaInsights => 'Wskazówki Celii';

  @override
  String get nutritionWeeklyTrend => 'Trend tygodniowy';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '$count meal',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '$count meal',
    );
    return 'of $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'P,W,Ś,C,P,S,N';

  @override
  String get nutritionFieldFoodName => 'Nazwa produktu';

  @override
  String get nutritionFieldGrams => 'Gramy';

  @override
  String get nutritionFieldCalories => 'Kalorie';

  @override
  String get scannerStatusAnalyzing => 'ANALIZOWANIE...';

  @override
  String get scannerStatusIdle => 'SKANER CELII';

  @override
  String get scannerFieldFoodName => 'Nazwa produktu';

  @override
  String get scannerFieldGrams => 'Gramy';

  @override
  String get scannerFieldCalories => 'Kalorie';

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
    return 'Pozostało dziś $calories kcal i ${grams}g białka';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal ponad dzienny cel';
  }

  @override
  String get scannerButtonAnalyzing => 'Analizowanie';

  @override
  String get scannerButtonQuotaNeeded => 'Wymagany limit';

  @override
  String get scannerButtonScanNow => 'Skanuj teraz';

  @override
  String get scannerButtonLogging => 'Zapisywanie';

  @override
  String get scannerButtonLogMeal => 'Zapisz posiłek';

  @override
  String get scannerNoClearFood =>
      'Nie wykryto jeszcze wyraźnie produktu. Spróbuj lepszego oświetlenia lub przybliż aparat.';

  @override
  String get scannerErrorCameraPermission =>
      'Do skanowania posiłków potrzebne jest pozwolenie na korzystanie z aparatu.';

  @override
  String get scannerErrorBackendMissing =>
      'Backend skanera kalorii nie jest jeszcze skonfigurowany.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'Klucz API OpenAI do skanowania kalorii jest nieprawidłowy. Zastąp go w środowisku backendu, wdróż ponownie i spróbuj jeszcze raz.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Do skanowania kalorii wymagany jest klucz API OpenAI. Dodaj go w Vercel, wdróż ponownie i spróbuj jeszcze raz.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Kredyty OpenAI do skanowania kalorii zostały wyczerpane. Dodaj kredyty API lub zwiększ limit rozliczeń, a następnie spróbuj ponownie.';

  @override
  String get scannerErrorTimeout =>
      'Celia potrzebowała więcej czasu na przeanalizowanie tego posiłku. Trzymaj aparat nieruchomo i zeskanuj ponownie.';

  @override
  String get scannerErrorNotSignedIn =>
      'Zaloguj się przed skanowaniem posiłków.';

  @override
  String get scannerErrorMealTableMissing =>
      'Tabela zapisywania posiłków nie jest jeszcze gotowa. Wynik skanowania jest nadal dostępny.';

  @override
  String get scannerErrorGeneric =>
      'Celia nie mogła jeszcze przeanalizować tego posiłku. Trzymaj aparat nieruchomo, umieść jedzenie na środku kadru i zeskanuj ponownie.';

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
  String get nutritionMealDetails => 'Szczegóły posiłku';

  @override
  String get nutritionFoodItems => 'Produkty';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Posiłek musi zawierać co najmniej jeden produkt.';

  @override
  String get nutritionMealUpdated => 'Posiłek zaktualizowany';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Nie udało się zaktualizować posiłku: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Usunąć posiłek?';

  @override
  String get nutritionDeleteMealBody =>
      'Spowoduje to usunięcie posiłku z historii żywienia.';

  @override
  String get nutritionDeleteMeal => 'Usuń posiłek';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Nie udało się usunąć posiłku: $error';
  }

  @override
  String get nutritionEditFood => 'Edytuj produkt';

  @override
  String get nutritionSaveFood => 'Zapisz produkt';

  @override
  String get nutritionLoadFailed => 'Nie udało się wczytać posiłków';

  @override
  String get nutritionLoadFailedBody =>
      'Pociągnij, aby odświeżyć, lub sprawdź połączenie z backendem.';

  @override
  String get nutritionNoMeals => 'Nie zapisano jeszcze żadnych posiłków';

  @override
  String get nutritionNoMealsBody =>
      'Zeskanuj swój pierwszy posiłek, a Celia utworzy Twoją historię żywienia.';

  @override
  String get progressToday => 'Dzisiaj';

  @override
  String get progressSetGoals =>
      'Ustaw cele żywieniowe, aby włączyć śledzenie kalorii i makroskładników.';

  @override
  String progressOfTarget(int target) {
    return 'z $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal ponad cel';
  }

  @override
  String progressKcalLeft(int calories) {
    return 'Pozostało $calories kcal';
  }

  @override
  String get progressProtein => 'Białko';

  @override
  String get progressCarbs => 'Węglowodany';

  @override
  String get progressFat => 'Tłuszcze';

  @override
  String get scannerEditItem => 'Edytuj produkt';

  @override
  String get scannerSaveChanges => 'Zapisz zmiany';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Pewność $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count dodatkowych produktów uwzględnionych w tym posiłku';
  }

  @override
  String get scannerIfYouLog => 'Jeśli zapiszesz ten posiłek';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal dzisiaj';
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
  String get scannerNoMealDetected => 'Nie wykryto posiłku';

  @override
  String onboardingWelcome(String name) {
    return 'Witaj, $name';
  }

  @override
  String get onboardingGender => 'Płeć';

  @override
  String get onboardingCalculateGoals => 'Oblicz moje cele';

  @override
  String get onboardingScanFirstMeal => 'Zeskanuj mój pierwszy posiłek';

  @override
  String get onboardingExploreRoutines => 'Odkrywaj treningi';

  @override
  String get onboardingGoHome => 'Przejdź do ekranu głównego';

  @override
  String get onboardingDailyTargets => 'Twoje dzienne cele';

  @override
  String onboardingProtein(int grams) {
    return 'Białko ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Białko ${protein}g • Węglowodany ${carbs}g • Tłuszcze ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Twoje dzienne cele żywieniowe są gotowe. Wybierz, jak chcesz zacząć.';

  @override
  String get onboardingWeightKg => 'Waga (kg)';

  @override
  String get onboardingHeightCm => 'Wzrost (cm)';

  @override
  String get onboardingAge => 'Wiek';

  @override
  String get onboardingInvalidWeight => 'Wprowadź prawidłową wagę w kg.';

  @override
  String get onboardingInvalidHeight => 'Wprowadź prawidłowy wzrost w cm.';

  @override
  String get onboardingInvalidAge =>
      'Wprowadź prawidłowy wiek od 13 do 100 lat.';

  @override
  String get onboardingSaveFailed =>
      'Nie udało się zapisać profilu żywieniowego.';

  @override
  String get genderMale => 'Mężczyzna';

  @override
  String get genderFemale => 'Kobieta';

  @override
  String get genderOther => 'Inna';

  @override
  String get nutritionSetupTitle => 'Dzienne cele żywieniowe';

  @override
  String get nutritionSetupBody =>
      'Opowiedz Celii o swoim ciele, aby mogła obliczyć Twoje dzienne zapotrzebowanie na kalorie i makroskładniki.';

  @override
  String get nutritionSetupGender => 'Płeć';

  @override
  String get nutritionSetupFootnote =>
      'Celia wykorzystuje Twoją wagę, wzrost, wiek i płeć do oszacowania dziennego zapotrzebowania na kalorie i makroskładniki przy umiarkowanym poziomie aktywności.';

  @override
  String get nutritionSourcesTitle => 'Jak obliczane są te cele';

  @override
  String get nutritionSourcesBody =>
      'Dzienne kalorie opierają się na równaniu Mifflin–St Jeor dla energii spoczynkowej z umiarkowanym współczynnikiem aktywności fizycznej (ok. 1,55). Białko szacuje się na ok. 1,8 g na kg masy ciała u aktywnych dorosłych. Tłuszcz ustawia się na ok. 25% kalorii, a węglowodany uzupełniają resztę — w typowych zakresach zaleceń żywieniowych.';

  @override
  String get nutritionSourcesDisclaimer =>
      'Te wartości to tylko ogólne szacunki wellness. Nie stanowią diagnozy, recepty ani zamiennika porady wykwalifikowanego klinicysty lub dietetyka.';

  @override
  String get nutritionSetupSave => 'Zapisz cele';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Członek';

  @override
  String get profileAccount => 'Konto';

  @override
  String profileSignedInAs(String email) {
    return 'Zalogowano jako:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Nieznany';

  @override
  String get profileDarkMode => 'Tryb ciemny';

  @override
  String get profileLanguage => 'Język';

  @override
  String get profileLogOutTitle => 'Wylogować się?';

  @override
  String get profileLogOutBody => 'Czy na pewno chcesz się wylogować?';

  @override
  String get profileLogOut => 'Wyloguj się';

  @override
  String get profileLogOutButton => 'Wyloguj';

  @override
  String get profileDeleteAccount => 'Usuń konto';

  @override
  String get profileDeleteAccountConfirmTitle => 'Usunąć Twoje konto?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'To trwale usuwa Twoje konto i wszystkie dane, w tym zapisane rutyny, dzienniki posiłków i historię czatu. Tej operacji nie można cofnąć.';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'Wpisz hasło, aby potwierdzić.';

  @override
  String get profileDeleteAccountPasswordLabel => 'Hasło';

  @override
  String get profileDeleteAccountButton => 'Usuń moje konto';

  @override
  String get profileFavoriteRoutines => 'Ulubione treningi';

  @override
  String get profileSubscription => 'Subskrypcja';

  @override
  String get profileNutrition => 'Odżywianie';

  @override
  String get profileHelpSupport => 'Pomoc i wsparcie';

  @override
  String get profileFriend => 'Znajomy';

  @override
  String get profileStatSaved => 'Zapisane';

  @override
  String get profileStatStreak => 'Seria';

  @override
  String get profileStatWorkouts => 'Treningi';

  @override
  String get streakDayOneStarted =>
      'Rozpoczęto dzień 1 — wróć jutro, aby zbudować swoją serię.';

  @override
  String get streakRebuild =>
      'Wczoraj byłeś aktywny — zapisz posiłek lub ukończ dziś trening, aby odbudować serię.';

  @override
  String get streakStart =>
      'Zapisz posiłek lub ukończ trening, aby rozpocząć serię aktywności.';

  @override
  String streakLongRun(int days) {
    return 'Seria trwa już $days dni! Nie przestawaj — Celia śledzi Twoją regularność.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Seria trwa już $days dni — dzisiejszy trening i odżywianie zostały zapisane.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Seria trwa już $days dni. Krótki trening dopełni dzisiejszy dzień.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Seria trwa już $days dni. Zapisz posiłek, aby śledzić swoje odżywianie.';
  }

  @override
  String streakStayActive(int days) {
    return 'Seria trwa już $days dni — bądź dziś aktywny.';
  }

  @override
  String get editProfileTitle => 'Edytuj profil';

  @override
  String get editProfileName => 'Imię';

  @override
  String get editProfileFootnote =>
      'Zmiany zostaną zapisane na Twoim koncie i będą widoczne na ekranie głównym oraz w profilu.';

  @override
  String get editProfileSaveFailed =>
      'Nie udało się zaktualizować profilu. Spróbuj ponownie.';

  @override
  String get languageTitle => 'Język';

  @override
  String get languageSystem => 'Język urządzenia';

  @override
  String get languageSystemSubtitle => 'Używaj języka ustawionego w telefonie';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get languageSpanish => 'Hiszpański';

  @override
  String get insightStartFuelingTitle => 'Zacznij dziś uzupełniać energię';

  @override
  String get insightStartFuelingBody =>
      'Masz do dyspozycji cały dzienny limit kalorii. Zeskanuj lub zapisz pierwszy posiłek, aby trzymać się planu.';

  @override
  String get insightAboveTargetTitle => 'Dziś powyżej celu';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Przekraczasz dzienny cel o $calories kcal. Zjedz lżejszą kolację lub dodaj krótki trening.';
  }

  @override
  String get insightLowProteinTitle => 'Wciąż za mało białka';

  @override
  String insightLowProteinBody(int grams) {
    return 'Potrzebujesz jeszcze około $grams g białka, aby osiągnąć dzisiejszy cel.';
  }

  @override
  String get insightAlmostThereTitle => 'Prawie osiągasz cel';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Pozostało Ci dziś $calories kcal. Zbilansowana przekąska powinna idealnie się zmieścić.';
  }

  @override
  String get insightOnTrackTitle => 'Dziś jesteś na dobrej drodze';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Do osiągnięcia dziennych celów pozostało Ci $calories kcal i $grams g białka.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Zbuduj tygodniowy rytm';

  @override
  String get insightWeeklyRhythmBody =>
      'Zapisuj posiłki w ciągu tygodnia, aby Celia mogła dostrzegać wzorce i lepiej Cię wspierać.';

  @override
  String get insightWeeklyTrendTitle => 'Tygodniowy trend';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'W ciągu ostatnich 7 dni zapisywałeś posiłki przez $days dni, średnio po $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget =>
      'średnio niemal dokładnie tyle, ile wynosi Twój dzienny cel';

  @override
  String insightTrendAbove(int delta) {
    return 'średnio o $delta kcal powyżej celu';
  }

  @override
  String insightTrendBelow(int delta) {
    return 'średnio o $delta kcal poniżej celu';
  }

  @override
  String get insightsSectionTitle => 'Wskazówki Celia';
}
