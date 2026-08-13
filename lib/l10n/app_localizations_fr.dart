// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Celia Coach intégral';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionSeeAll => 'Tout voir';

  @override
  String get actionYesDoIt => 'Oui, allez-y';

  @override
  String get actionNotNow => 'Pas maintenant';

  @override
  String get loadingPreparing => 'Préparation de Celia...';

  @override
  String get loadingGeneric => 'Chargement...';

  @override
  String get errorGeneric => 'Une erreur s’est produite. Veuillez réessayer.';

  @override
  String get errorCanceled => 'Action annulée.';

  @override
  String get errorTooManyRequests =>
      'Trop de tentatives. Veuillez patienter une minute, puis réessayer.';

  @override
  String get errorNetwork =>
      'Vérifiez votre connexion Internet, puis réessayez.';

  @override
  String get errorBadCredentials => 'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get errorEmailInUse =>
      'Cette adresse e-mail est déjà utilisée. Essayez plutôt de vous connecter.';

  @override
  String get errorWeakPassword =>
      'Utilisez un mot de passe plus sécurisé, puis réessayez.';

  @override
  String get errorInvalidEmail => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get errorNoPermission =>
      'Vous n’avez pas l’autorisation d’effectuer cette action.';

  @override
  String get errorNotSignedIn => 'Veuillez vous connecter, puis réessayer.';

  @override
  String get errorNoConversation =>
      'Démarrez une nouvelle discussion pour continuer.';

  @override
  String get errorNoPlayableVideos =>
      'Aucune vidéo lisible n’est encore disponible pour cette routine.';

  @override
  String get errorLoadRoutines =>
      'Impossible de charger les routines pour le moment. Veuillez réessayer.';

  @override
  String get errorLoadSavedRoutines =>
      'Impossible de charger les routines enregistrées pour le moment. Veuillez réessayer.';

  @override
  String get errorGenerateRoutine =>
      'Impossible de générer une routine pour le moment. Veuillez réessayer.';

  @override
  String get errorLoadChats =>
      'Impossible de charger les discussions enregistrées pour le moment.';

  @override
  String get errorCeliaUnavailable =>
      'Celia est indisponible pour le moment. Veuillez réessayer.';

  @override
  String get errorOpenConversation => 'Impossible d’ouvrir cette conversation.';

  @override
  String get errorDeleteConversation =>
      'Impossible de supprimer cette conversation. Veuillez réessayer.';

  @override
  String get errorSignIn => 'Impossible de se connecter. Veuillez réessayer.';

  @override
  String get errorCreateAccount =>
      'Impossible de créer votre compte. Veuillez réessayer.';

  @override
  String get errorSendResetEmail =>
      'Impossible d’envoyer l’e-mail de réinitialisation. Veuillez réessayer.';

  @override
  String get errorSendVerificationEmail =>
      'Impossible d’envoyer l’e-mail de vérification. Veuillez réessayer.';

  @override
  String get errorGoogleSignIn =>
      'La connexion avec Google a échoué. Veuillez réessayer.';

  @override
  String get errorAppleSignIn =>
      'La connexion avec Apple a échoué. Veuillez réessayer.';

  @override
  String get errorRefreshNutrition =>
      'Impossible d’actualiser les données nutritionnelles.';

  @override
  String get errorLoadNutritionProfile =>
      'Impossible de charger votre profil nutritionnel.';

  @override
  String get startupErrorTitle => 'Impossible de démarrer l’application';

  @override
  String get startupErrorBody =>
      'Fermez et rouvrez l’application. Si le problème persiste, contactez l’assistance.';

  @override
  String get authTagline => 'Votre compagnon fitness';

  @override
  String get authSignUp => 'S’inscrire';

  @override
  String get authLogIn => 'Se connecter';

  @override
  String authVersion(String version) {
    return 'Version $version';
  }

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authOr => 'OU';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get authAuthenticating => 'Authentification...';

  @override
  String get authEnterYourName => 'Veuillez saisir votre nom.';

  @override
  String get authNeedAccount => 'Besoin d’un compte ? S’inscrire';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ? Se connecter';

  @override
  String get authFieldName => 'Votre nom';

  @override
  String get authFieldEmail => 'E-mail';

  @override
  String get authFieldPassword => 'Mot de passe';

  @override
  String get verifyEmailTitle => 'Vérifiez votre adresse e-mail';

  @override
  String get verifyEmailHeading => 'Consultez votre boîte de réception';

  @override
  String get verifyEmailBody =>
      'Un lien de vérification a été envoyé à votre adresse e-mail.';

  @override
  String get verifyEmailSent => 'E-mail de vérification envoyé !';

  @override
  String get verifyEmailContinue => 'J’ai vérifié, continuer';

  @override
  String get verifyEmailSignOut => 'Se déconnecter';

  @override
  String get verifyEmailSending => 'Envoi...';

  @override
  String get verifyEmailResend => 'Renvoyer l’e-mail de vérification';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'E-mail : $email';
  }

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordBody =>
      'Saisissez votre adresse e-mail pour recevoir un lien de réinitialisation du mot de passe.';

  @override
  String get forgotPasswordEmptyEmail => 'Veuillez saisir une adresse e-mail';

  @override
  String get forgotPasswordSent => 'E-mail de réinitialisation envoyé.';

  @override
  String get forgotPasswordSend => 'Envoyer le lien de réinitialisation';

  @override
  String get forgotPasswordSending => 'Envoi...';

  @override
  String get nameSetupTitle => 'Comment Celia doit-elle vous appeler ?';

  @override
  String get nameSetupBody =>
      'Nous utilisons votre nom dans toute l’application pour personnaliser votre accompagnement.';

  @override
  String get nameSetupSaveFailed =>
      'Impossible d’enregistrer votre nom. Veuillez réessayer.';

  @override
  String get homeGoodMorning => 'Bonjour,';

  @override
  String get homeCeliaActive => 'CELIA ACTIVE';

  @override
  String get homeGenerateRoutine =>
      'Générez votre\nprogramme\npersonnalisé avec l’IA';

  @override
  String get homeCreateRoutine => 'Créer un programme';

  @override
  String get homeQuickActions => 'Actions rapides';

  @override
  String get homeUpNext => 'À venir';

  @override
  String get homeNoUpcoming =>
      'Aucun programme à venir pour le moment.\nCréez-en un ou parcourez la bibliothèque.';

  @override
  String get homeChatWithCelia => 'Discuter avec Celia';

  @override
  String get homeChatSubtitle =>
      'Posez vos questions sur votre technique ou votre alimentation';

  @override
  String get homeScanMeal => 'Scanner un repas';

  @override
  String get homeScanMealSubtitle => 'Identifier les aliments et les calories';

  @override
  String get homeNutrition => 'Nutrition';

  @override
  String get homeNutritionSubtitle =>
      'Voir les calories, les macros et les repas';

  @override
  String get homeBrowseLibrary => 'Parcourir la\nbibliothèque';

  @override
  String get homeTrackProgress => 'Suivre\nvos progrès';

  @override
  String get chatTitle => 'Coach Celia';

  @override
  String get chatEmptyPrompt =>
      'Comment puis-je vous aider\nà vous remettre en forme aujourd’hui ?';

  @override
  String get chatYourChats => 'Vos conversations';

  @override
  String get chatNoSavedChats =>
      'Aucune conversation enregistrée pour le moment.';

  @override
  String get chatHistory => 'Historique des conversations';

  @override
  String get chatNew => 'Nouvelle conversation';

  @override
  String get chatOpening => 'Ouverture de la conversation...';

  @override
  String get chatScanAMeal => 'Scanner un repas';

  @override
  String get chatInputHint =>
      'Posez une question à Celia sur votre entraînement...';

  @override
  String get chatCouldNotOpenRoutine => 'Impossible d’ouvrir ce programme';

  @override
  String get chatThisRoutine => 'ce programme';

  @override
  String get chatThisMeal => 'ce repas';

  @override
  String get chatYourRoutine => 'Votre programme';

  @override
  String chatMoreExercises(int count) {
    return '+ $count de plus';
  }

  @override
  String get chatEmptySubtitle =>
      'Posez vos questions sur votre entraînement, votre alimentation ou vos progrès.';

  @override
  String chatLoggedToday(int calories) {
    return 'Vous avez enregistré $calories kcal aujourd’hui.';
  }

  @override
  String get chatSuggestionHiit => 'Crée-moi un programme HIIT de 20 minutes';

  @override
  String get chatSuggestionDinner => 'Que devrais-je manger ce soir ?';

  @override
  String get chatSuggestionProgress =>
      'Comment est-ce que je progresse cette semaine ?';

  @override
  String get chatSuggestionIngredients =>
      'J’ai du poulet, du riz et des épinards';

  @override
  String get chatJustNow => 'À l’instant';

  @override
  String chatMinutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String chatHoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String chatDaysAgo(int days) {
    return 'Il y a $days j';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Déjà dans votre bibliothèque — appuyez pour ouvrir';

  @override
  String get chatRoutineTapToOpen => 'Appuyez pour ouvrir';

  @override
  String get chatToolCancelled => 'Annulé';

  @override
  String chatToolFailed(String label) {
    return '$label — cela n’a pas fonctionné';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Impossible d’enregistrer la routine';

  @override
  String get chatToolRoutineSaved => 'Enregistrée dans votre bibliothèque';

  @override
  String get chatToolMealLogged => 'Ajouté au journal d’aujourd’hui';

  @override
  String get chatToolRoutineAdded => 'Ajoutée à votre bibliothèque';

  @override
  String get activityCheckingProgress => 'Vérification de votre progression';

  @override
  String get activityCheckingNutrition =>
      'Vérification de ce que vous avez mangé aujourd’hui';

  @override
  String get activityReviewingMeals => 'Analyse de vos repas récents';

  @override
  String get activityLookingAtRoutines => 'Consultation de vos routines';

  @override
  String get activityReadingRoutine => 'Lecture de cette routine';

  @override
  String get activitySearchingLibrary =>
      'Recherche dans la bibliothèque d’exercices';

  @override
  String get activityBuildingRoutine => 'Création de votre routine';

  @override
  String get activityLoggingMeal => 'Ajout de votre repas au journal';

  @override
  String get activitySavingToLibrary =>
      'Enregistrement dans votre bibliothèque';

  @override
  String get activityWorking => 'Traitement en cours';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Enregistrer « $name » avec $count exercices dans votre bibliothèque ?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Enregistrer « $name » dans votre bibliothèque ?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Enregistrer « $name » avec $calories kcal ?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Enregistrer « $name » ?';
  }

  @override
  String get approvalAddRoutine =>
      'Ajouter cette routine à votre bibliothèque ?';

  @override
  String get approvalGeneric => 'Autoriser Celia à effectuer cette action ?';

  @override
  String get libraryTitle => 'Bibliothèque de routines';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '$count étape',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Aucune routine pour le moment';

  @override
  String get libraryEmptyBody =>
      'Créez et publiez des routines dans le tableau de bord d’administration.';

  @override
  String get libraryLoadFailed => 'Impossible de charger les routines';

  @override
  String get routineStartWorkout => 'Commencer la séance';

  @override
  String get routineNoSteps => 'Aucune étape disponible';

  @override
  String get routineNoVideoForStep =>
      'Aucune vidéo disponible pour cette étape';

  @override
  String get routineVideoProcessing =>
      'La vidéo est encore en cours de traitement. Veuillez réessayer plus tard.';

  @override
  String get routineMissingPlaybackUrl =>
      'L’URL de lecture est manquante pour cette vidéo';

  @override
  String get routinePreviewBanner =>
      'APERÇU — la vidéo complète sera bientôt disponible';

  @override
  String get routinePreview => 'APERÇU';

  @override
  String get routineDetails => 'Détails';

  @override
  String get routineNotFound => 'Routine introuvable';

  @override
  String routineCompletedTimes(int count) {
    return 'Terminée $count fois';
  }

  @override
  String get playerVideoUnavailable =>
      'Cette vidéo n’est pas disponible pour le moment.';

  @override
  String get playerSteps => 'Étapes';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Aucune vidéo lisible';

  @override
  String get playerWorkoutComplete => 'Séance terminée !';

  @override
  String get playerSavingStreak => 'Enregistrement dans votre série…';

  @override
  String get playerSavedStreak => 'Enregistré dans votre série';

  @override
  String get playerRetrySave => 'Réessayer l’enregistrement';

  @override
  String get playerReplay => 'Rejouer';

  @override
  String get playerNotReady => 'Lecteur non prêt';

  @override
  String get playerPreviewUnavailable =>
      'L’aperçu n’est pas disponible pour le moment.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clip $current sur $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Erreur lors du chargement de la vidéo';

  @override
  String get playerLoadingVideo => 'Chargement de la vidéo…';

  @override
  String get playerFailedToLoadVideo => 'Impossible de charger la vidéo';

  @override
  String get playerNotInitialized => 'Le lecteur vidéo n’est pas initialisé';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Exercice $current/$total';
  }

  @override
  String get guidedGetReady => 'PRÉPAREZ-VOUS';

  @override
  String guidedSetOf(int current, int total) {
    return 'Série $current sur $total';
  }

  @override
  String get guidedRest => 'REPOS';

  @override
  String get guidedSkipRest => 'Passer le repos';

  @override
  String get guidedPaused => 'En pause';

  @override
  String get guidedResume => 'Reprendre';

  @override
  String get guidedWorkoutComplete => 'Séance terminée';

  @override
  String get guidedEndTitle => 'Terminer la séance ?';

  @override
  String get guidedEndBody =>
      'Votre progression pour cette séance ne sera pas enregistrée.';

  @override
  String get guidedKeepGoing => 'Continuez';

  @override
  String get guidedEnd => 'Terminer';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count répétitions',
      one: '$count répétition',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Générer une routine avec l’IA';

  @override
  String get generateSheetPrompt => 'Quel type d’entraînement souhaitez-vous ?';

  @override
  String get generateSheetHint =>
      'ex. : « Des étirements rapides le matin pour se réveiller » ou « Renforcement musculaire complet pour débutants »';

  @override
  String get generateSheetDuration => 'Durée';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Difficulté';

  @override
  String get generateSheetEquipment => 'Matériel disponible';

  @override
  String get generateSheetGenerating => 'Génération…';

  @override
  String get generateSheetSubmit => 'Générer la routine';

  @override
  String get generateSheetDescribeFirst =>
      'Veuillez décrire l’entraînement souhaité';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Vous avez déjà celle-ci : $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Créée : $title';
  }

  @override
  String get generateSheetFailed => 'Échec de la génération de la routine';

  @override
  String get guidedNoExercises =>
      'Cette routine ne contient encore aucun exercice.';

  @override
  String get guidedStartFailed =>
      'Impossible de démarrer cet entraînement pour le moment. Veuillez réessayer.';

  @override
  String get guidedSaveFailed =>
      'Impossible d’enregistrer cet entraînement. Appuyez sur Réessayer pour mettre à jour votre série.';

  @override
  String guidedOfReps(int count) {
    return 'sur $count répétitions';
  }

  @override
  String get guidedHold => 'maintenir';

  @override
  String get guidedNextSet => 'Série suivante';

  @override
  String get guidedUpNext => 'À suivre';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s de maintien';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Préparez-vous. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'C’est parti. $count répétitions.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Maintenez pendant $seconds secondes.';
  }

  @override
  String coachRest(String exercise) {
    return 'Repos. À suivre : $exercise';
  }

  @override
  String get coachRestShort => 'Repos.';

  @override
  String get coachComplete => 'Excellent travail. Entraînement terminé.';

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
      'Aucune vidéo lisible trouvée dans cette routine.';

  @override
  String get playerLoadRoutineFailed =>
      'Impossible de charger cette routine pour le moment. Veuillez réessayer.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Échec du chargement de « $title ». Passage à la suite…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Échec du chargement de « $title ».';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Impossible d’enregistrer la séance terminée. Appuyez sur Réessayer pour mettre à jour votre série.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Aperçu';
  }

  @override
  String get playerNoVideosReady =>
      'Cette routine ne contient pas encore de vidéos prêtes à être lues.';

  @override
  String get playerPlaybackFailed =>
      'Impossible de lire cette vidéo pour le moment. Veuillez réessayer.';

  @override
  String get libraryTabCurated => 'Sélection';

  @override
  String get libraryTabAiGenerated => 'Générées par l’IA';

  @override
  String get profileSavedRoutines => 'Routines enregistrées';

  @override
  String get savedRoutinesNoFavorites =>
      'Aucune routine favorite pour le moment.';

  @override
  String get savedRoutinesEmpty => 'Aucune routine enregistrée pour le moment.';

  @override
  String get actionFavorite => 'Ajouter aux favoris';

  @override
  String get actionUnfavorite => 'Retirer des favoris';

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
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyenne';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get categoryStrength => 'Renforcement';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Souplesse';

  @override
  String get categoryMindfulness => 'Pleine conscience';

  @override
  String get categoryDance => 'Danse';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Personnalisé';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get equipmentNone => 'Aucun';

  @override
  String get equipmentDumbbells => 'Haltères';

  @override
  String get equipmentResistanceBands => 'Bandes de résistance';

  @override
  String get equipmentYogaMat => 'Tapis de yoga';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Barre de traction';

  @override
  String get equipmentJumpRope => 'Corde à sauter';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionSubtitle => 'Calories, macros et historique des repas';

  @override
  String get nutritionSetGoalsTitle =>
      'Définissez vos objectifs nutritionnels quotidiens';

  @override
  String get nutritionSetGoalsBody =>
      'Ajoutez votre poids, votre taille, votre âge et votre sexe pour que Celia puisse calculer combien de calories et de nutriments vous devriez consommer chaque jour.';

  @override
  String get nutritionSetUpGoals => 'Définir les objectifs';

  @override
  String get nutritionDailyTarget => 'Objectif quotidien';

  @override
  String get nutritionDailyGoals => 'Objectifs quotidiens';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Aujourd’hui';

  @override
  String get nutritionMealHistory => 'Historique des repas';

  @override
  String get nutritionCeliaInsights => 'Conseils de Celia';

  @override
  String get nutritionWeeklyTrend => 'Tendance hebdomadaire';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repas',
      one: '$count repas',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repas',
      one: '$count repas',
    );
    return 'sur $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'L,M,M,J,V,S,D';

  @override
  String get nutritionFieldFoodName => 'Nom de l’aliment';

  @override
  String get nutritionFieldGrams => 'Grammes';

  @override
  String get nutritionFieldCalories => 'Calories';

  @override
  String get scannerStatusAnalyzing => 'ANALYSE EN COURS...';

  @override
  String get scannerStatusIdle => 'SCANNER CELIA';

  @override
  String get scannerFieldFoodName => 'Nom de l’aliment';

  @override
  String get scannerFieldGrams => 'Grammes';

  @override
  String get scannerFieldCalories => 'Calories';

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
    return 'Il vous reste $calories kcal et ${grams}g de protéines aujourd’hui';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal au-dessus de votre objectif quotidien';
  }

  @override
  String get scannerButtonAnalyzing => 'Analyse en cours';

  @override
  String get scannerButtonQuotaNeeded => 'Quota requis';

  @override
  String get scannerButtonScanNow => 'Scanner maintenant';

  @override
  String get scannerButtonLogging => 'Enregistrement';

  @override
  String get scannerButtonLogMeal => 'Enregistrer le repas';

  @override
  String get scannerNoClearFood =>
      'Aucun aliment clairement détecté pour le moment. Essayez avec un meilleur éclairage ou rapprochez-vous.';

  @override
  String get scannerErrorCameraPermission =>
      'L’autorisation d’utiliser la caméra est nécessaire pour scanner les repas.';

  @override
  String get scannerErrorBackendMissing =>
      'Le système de scan des calories n’est pas encore configuré.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'La clé API OpenAI utilisée pour scanner les calories est invalide. Remplacez-la dans l’environnement backend, redéployez, puis réessayez.';

  @override
  String get scannerErrorApiKeyMissing =>
      'Une clé API OpenAI est requise pour scanner les calories. Ajoutez-la dans Vercel, redéployez, puis réessayez.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Les crédits OpenAI pour le scan des calories sont épuisés. Ajoutez des crédits API ou augmentez la limite de facturation, puis réessayez.';

  @override
  String get scannerErrorTimeout =>
      'Celia a besoin de plus de temps pour analyser ce repas. Gardez la caméra immobile et scannez à nouveau.';

  @override
  String get scannerErrorNotSignedIn =>
      'Veuillez vous connecter avant de scanner des repas.';

  @override
  String get scannerErrorMealTableMissing =>
      'La table d’enregistrement des repas n’est pas encore prête. Le résultat du scan est toujours disponible.';

  @override
  String get scannerErrorGeneric =>
      'Celia n’a pas encore pu analyser ce repas. Gardez la caméra immobile, centrez l’aliment et scannez à nouveau.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '$count élément',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Détails du repas';

  @override
  String get nutritionFoodItems => 'Aliments';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Un repas doit contenir au moins un aliment.';

  @override
  String get nutritionMealUpdated => 'Repas mis à jour';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Impossible de mettre à jour le repas : $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Supprimer le repas ?';

  @override
  String get nutritionDeleteMealBody =>
      'Cette action supprimera le repas de votre historique nutritionnel.';

  @override
  String get nutritionDeleteMeal => 'Supprimer le repas';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Impossible de supprimer le repas : $error';
  }

  @override
  String get nutritionEditFood => 'Modifier l’aliment';

  @override
  String get nutritionSaveFood => 'Enregistrer l’aliment';

  @override
  String get nutritionLoadFailed => 'Impossible de charger les repas';

  @override
  String get nutritionLoadFailedBody =>
      'Tirez vers le bas pour actualiser ou vérifiez la connexion au backend.';

  @override
  String get nutritionNoMeals => 'Aucun repas enregistré';

  @override
  String get nutritionNoMealsBody =>
      'Scannez votre premier repas et Celia constituera votre historique nutritionnel.';

  @override
  String get progressToday => 'Aujourd’hui';

  @override
  String get progressSetGoals =>
      'Définissez vos objectifs nutritionnels pour activer le suivi des calories et des macros.';

  @override
  String progressOfTarget(int target) {
    return 'sur $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal en trop';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal restantes';
  }

  @override
  String get progressProtein => 'Protéines';

  @override
  String get progressCarbs => 'Glucides';

  @override
  String get progressFat => 'Lipides';

  @override
  String get scannerEditItem => 'Modifier l’aliment';

  @override
  String get scannerSaveChanges => 'Enregistrer les modifications';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Fiabilité $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count aliments supplémentaires inclus dans ce journal de repas';
  }

  @override
  String get scannerIfYouLog => 'Si vous enregistrez ce repas';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal aujourd’hui';
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
  String get scannerNoMealDetected => 'Aucun repas détecté';

  @override
  String onboardingWelcome(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get onboardingGender => 'Genre';

  @override
  String get onboardingCalculateGoals => 'Calculer mes objectifs';

  @override
  String get onboardingScanFirstMeal => 'Scanner mon premier repas';

  @override
  String get onboardingExploreRoutines => 'Découvrir les routines';

  @override
  String get onboardingGoHome => 'Accéder à l’accueil';

  @override
  String get onboardingDailyTargets => 'Vos objectifs quotidiens';

  @override
  String onboardingProtein(int grams) {
    return 'Protéines ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Protéines ${protein}g • Glucides ${carbs}g • Lipides ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Vos objectifs nutritionnels quotidiens sont prêts. Choisissez comment commencer.';

  @override
  String get onboardingWeightKg => 'Poids (kg)';

  @override
  String get onboardingHeightCm => 'Taille (cm)';

  @override
  String get onboardingAge => 'Âge';

  @override
  String get onboardingInvalidWeight => 'Saisissez un poids valide en kg.';

  @override
  String get onboardingInvalidHeight => 'Saisissez une taille valide en cm.';

  @override
  String get onboardingInvalidAge =>
      'Saisissez un âge valide entre 13 et 100 ans.';

  @override
  String get onboardingSaveFailed =>
      'Impossible d’enregistrer votre profil nutritionnel.';

  @override
  String get genderMale => 'Homme';

  @override
  String get genderFemale => 'Femme';

  @override
  String get genderOther => 'Autre';

  @override
  String get nutritionSetupTitle => 'Objectifs nutritionnels quotidiens';

  @override
  String get nutritionSetupBody =>
      'Parlez à Celia de votre morphologie afin qu’elle calcule vos calories et macros quotidiennes.';

  @override
  String get nutritionSetupGender => 'Genre';

  @override
  String get nutritionSetupFootnote =>
      'Celia utilise votre poids, votre taille, votre âge et votre genre pour estimer vos objectifs quotidiens de calories et de macros selon un niveau d’activité modéré.';

  @override
  String get nutritionSetupSave => 'Enregistrer les objectifs';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Membre Elite';

  @override
  String get profileAccount => 'Compte';

  @override
  String profileSignedInAs(String email) {
    return 'Connecté en tant que :\n$email';
  }

  @override
  String get profileUnknownEmail => 'Inconnu';

  @override
  String get profileDarkMode => 'Mode sombre';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLogOutTitle => 'Se déconnecter ?';

  @override
  String get profileLogOutBody => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get profileLogOut => 'Se déconnecter';

  @override
  String get profileLogOutButton => 'Se déconnecter';

  @override
  String get profileFavoriteRoutines => 'Routines favorites';

  @override
  String get profileSubscription => 'Abonnement';

  @override
  String get profileNutrition => 'Nutrition';

  @override
  String get profileHelpSupport => 'Aide et assistance';

  @override
  String get profileFriend => 'Ami';

  @override
  String get profileStatSaved => 'Enregistrés';

  @override
  String get profileStatStreak => 'Série';

  @override
  String get profileStatWorkouts => 'Entraînements';

  @override
  String get streakDayOneStarted =>
      'Jour 1 commencé — revenez demain pour prolonger votre série.';

  @override
  String get streakRebuild =>
      'Vous étiez actif hier — enregistrez un repas ou terminez un entraînement aujourd’hui pour reconstruire votre série.';

  @override
  String get streakStart =>
      'Enregistrez un repas ou terminez un entraînement pour commencer votre série active.';

  @override
  String streakLongRun(int days) {
    return 'Série de $days jours ! Continuez à être régulier — Celia suit votre assiduité.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Série de $days jours — entraînement et nutrition enregistrés aujourd’hui.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Série de $days jours. Un entraînement rapide compléterait bien votre journée.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Série de $days jours. Enregistrez un repas pour suivre votre alimentation.';
  }

  @override
  String streakStayActive(int days) {
    return 'Série de $days jours — restez actif aujourd’hui.';
  }

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileName => 'Nom';

  @override
  String get editProfileFootnote =>
      'Les modifications sont enregistrées dans votre compte et s’afficheront dans Accueil/Profil.';

  @override
  String get editProfileSaveFailed =>
      'Impossible de mettre à jour le profil. Veuillez réessayer.';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue de l’appareil';

  @override
  String get languageSystemSubtitle =>
      'Utiliser la langue définie sur votre téléphone';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get insightStartFuelingTitle =>
      'Commencez à vous alimenter aujourd’hui';

  @override
  String get insightStartFuelingBody =>
      'Il vous reste tout votre budget calorique. Scannez ou enregistrez votre premier repas pour rester sur la bonne voie.';

  @override
  String get insightAboveTargetTitle => 'Objectif dépassé aujourd’hui';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Vous dépassez votre objectif quotidien de $calories kcal. Optez pour un dîner plus léger ou ajoutez un court entraînement.';
  }

  @override
  String get insightLowProteinTitle => 'Protéines encore insuffisantes';

  @override
  String insightLowProteinBody(int grams) {
    return 'Il vous manque encore environ ${grams}g de protéines aujourd’hui pour atteindre votre objectif.';
  }

  @override
  String get insightAlmostThereTitle => 'Objectif presque atteint';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Il vous reste $calories kcal aujourd’hui. Une collation équilibrée devrait parfaitement convenir.';
  }

  @override
  String get insightOnTrackTitle => 'Bonne journée jusqu’ici';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Il vous reste $calories kcal et ${grams}g de protéines pour atteindre vos objectifs quotidiens.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Trouvez votre rythme hebdomadaire';

  @override
  String get insightWeeklyRhythmBody =>
      'Enregistrez vos repas tout au long de la semaine pour que Celia puisse repérer vos habitudes et mieux vous guider.';

  @override
  String get insightWeeklyTrendTitle => 'Tendance hebdomadaire';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Vous avez enregistré des repas pendant $days des 7 derniers jours, avec une moyenne de $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'tout près de votre objectif quotidien';

  @override
  String insightTrendAbove(int delta) {
    return '$delta kcal au-dessus de votre objectif en moyenne';
  }

  @override
  String insightTrendBelow(int delta) {
    return '$delta kcal en dessous de votre objectif en moyenne';
  }

  @override
  String get insightsSectionTitle => 'Analyses Celia';
}
