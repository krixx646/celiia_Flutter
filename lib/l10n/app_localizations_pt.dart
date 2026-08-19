// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Celia Integral Coach';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionSeeAll => 'Ver tudo';

  @override
  String get actionYesDoIt => 'Sim, fazer isso';

  @override
  String get actionNotNow => 'Agora não';

  @override
  String get loadingPreparing => 'Preparando a Celia...';

  @override
  String get loadingGeneric => 'Carregando...';

  @override
  String get errorGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get errorCanceled => 'Ação cancelada.';

  @override
  String get errorTooManyRequests =>
      'Muitas tentativas. Aguarde um minuto e tente novamente.';

  @override
  String get errorNetwork =>
      'Verifique sua conexão com a internet e tente novamente.';

  @override
  String get errorBadCredentials => 'E-mail ou senha incorretos.';

  @override
  String get errorEmailInUse =>
      'Este e-mail já está em uso. Tente fazer login.';

  @override
  String get errorWeakPassword => 'Use uma senha mais forte e tente novamente.';

  @override
  String get errorInvalidEmail => 'Insira um endereço de e-mail válido.';

  @override
  String get errorNoPermission => 'Você não tem permissão para fazer isso.';

  @override
  String get errorNotSignedIn => 'Faça login e tente novamente.';

  @override
  String get errorNoConversation => 'Inicie um novo chat para continuar.';

  @override
  String get errorNoPlayableVideos =>
      'Ainda não há vídeos reproduzíveis disponíveis para esta rotina.';

  @override
  String get errorLoadRoutines =>
      'Não foi possível carregar as rotinas agora. Tente novamente.';

  @override
  String get errorLoadSavedRoutines =>
      'Não foi possível carregar as rotinas salvas agora. Tente novamente.';

  @override
  String get errorGenerateRoutine =>
      'Não foi possível gerar uma rotina agora. Tente novamente.';

  @override
  String get errorLoadChats =>
      'Não foi possível carregar os chats salvos agora.';

  @override
  String get errorCeliaUnavailable =>
      'A Celia está indisponível no momento. Tente novamente.';

  @override
  String get errorOpenConversation => 'Não foi possível abrir essa conversa.';

  @override
  String get errorDeleteConversation =>
      'Não foi possível excluir esta conversa. Tente novamente.';

  @override
  String get errorSignIn => 'Não foi possível fazer login. Tente novamente.';

  @override
  String get errorCreateAccount =>
      'Não foi possível criar sua conta. Tente novamente.';

  @override
  String get errorSendResetEmail =>
      'Não foi possível enviar o e-mail de redefinição. Tente novamente.';

  @override
  String get errorSendVerificationEmail =>
      'Não foi possível enviar o e-mail de verificação. Tente novamente.';

  @override
  String get errorGoogleSignIn =>
      'Não foi possível fazer login com o Google. Tente novamente.';

  @override
  String get errorAppleSignIn =>
      'Não foi possível fazer login com a Apple. Tente novamente.';

  @override
  String get errorRefreshNutrition =>
      'Não foi possível atualizar os dados nutricionais.';

  @override
  String get errorLoadNutritionProfile =>
      'Não foi possível carregar seu perfil nutricional.';

  @override
  String get startupErrorTitle => 'Não foi possível iniciar o app';

  @override
  String get startupErrorBody =>
      'Feche e reabra o app. Se o problema continuar, entre em contato com o suporte.';

  @override
  String get authTagline => 'Sua companheira de fitness';

  @override
  String get authSignUp => 'Criar conta';

  @override
  String get authLogIn => 'Fazer login';

  @override
  String authVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get authOr => 'OU';

  @override
  String get authContinueWithGoogle => 'Continuar com o Google';

  @override
  String get authContinueWithApple => 'Continuar com a Apple';

  @override
  String get authAuthenticating => 'Autenticando...';

  @override
  String get authEnterYourName => 'Insira seu nome.';

  @override
  String get authNeedAccount => 'Precisa de uma conta? Criar conta';

  @override
  String get authHaveAccount => 'Já tem uma conta? Fazer login';

  @override
  String get authFieldName => 'Seu nome';

  @override
  String get authFieldEmail => 'E-mail';

  @override
  String get authFieldPassword => 'Senha';

  @override
  String get verifyEmailTitle => 'Verifique seu e-mail';

  @override
  String get verifyEmailHeading => 'Confira sua caixa de entrada';

  @override
  String get verifyEmailBody =>
      'Um link de verificação foi enviado para seu e-mail.';

  @override
  String get verifyEmailSent => 'E-mail de verificação enviado!';

  @override
  String get verifyEmailContinue => 'Já verifiquei, continuar';

  @override
  String get verifyEmailSignOut => 'Sair';

  @override
  String get verifyEmailSending => 'Enviando...';

  @override
  String get verifyEmailResend => 'Reenviar e-mail de verificação';

  @override
  String verifyEmailResendIn(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String verifyEmailAddress(String email) {
    return 'E-mail: $email';
  }

  @override
  String get forgotPasswordTitle => 'Esqueci a senha';

  @override
  String get forgotPasswordBody =>
      'Digite seu e-mail para receber um link de redefinição de senha.';

  @override
  String get forgotPasswordEmptyEmail => 'Digite um e-mail';

  @override
  String get forgotPasswordSent => 'E-mail de redefinição de senha enviado.';

  @override
  String get forgotPasswordSend => 'Enviar link de redefinição';

  @override
  String get forgotPasswordSending => 'Enviando...';

  @override
  String get nameSetupTitle => 'Como Celia deve chamar você?';

  @override
  String get nameSetupBody =>
      'Usamos seu nome no app para tornar o acompanhamento mais pessoal.';

  @override
  String get nameSetupSaveFailed =>
      'Não foi possível salvar seu nome. Tente novamente.';

  @override
  String get homeGoodMorning => 'Bom dia,';

  @override
  String get homeCeliaActive => 'CELIA ATIVA';

  @override
  String get homeGenerateRoutine => 'Gere sua\nrotina\npersonalizada com IA';

  @override
  String get homeCreateRoutine => 'Criar rotina';

  @override
  String get homeQuickActions => 'Ações rápidas';

  @override
  String get homeUpNext => 'A seguir';

  @override
  String get homeNoUpcoming =>
      'Nenhuma rotina próxima ainda.\nCrie uma ou explore a biblioteca.';

  @override
  String get homeChatWithCelia => 'Conversar com Celia';

  @override
  String get homeChatSubtitle => 'Pergunte sobre sua execução ou dieta';

  @override
  String get homeScanMeal => 'Escanear refeição';

  @override
  String get homeScanMealSubtitle => 'Identifique alimentos e calorias';

  @override
  String get homeNutrition => 'Nutrição';

  @override
  String get homeNutritionSubtitle => 'Veja calorias, macros e refeições';

  @override
  String get homeBrowseLibrary => 'Explorar\nbiblioteca';

  @override
  String get homeTrackProgress => 'Acompanhar\nprogresso';

  @override
  String get chatTitle => 'Coach Celia';

  @override
  String get chatEmptyPrompt =>
      'Como posso ajudar você a\nentrar em forma hoje?';

  @override
  String get chatYourChats => 'Suas conversas';

  @override
  String get chatNoSavedChats => 'Nenhuma conversa salva ainda.';

  @override
  String get chatHistory => 'Histórico de conversas';

  @override
  String get chatNew => 'Nova conversa';

  @override
  String get chatOpening => 'Abrindo conversa...';

  @override
  String get chatScanAMeal => 'Escanear uma refeição';

  @override
  String get chatInputHint =>
      'Pergunte qualquer coisa à Celia sobre seu treino...';

  @override
  String get chatCouldNotOpenRoutine => 'Não foi possível abrir essa rotina';

  @override
  String get chatThisRoutine => 'essa rotina';

  @override
  String get chatThisMeal => 'essa refeição';

  @override
  String get chatYourRoutine => 'Sua rotina';

  @override
  String chatMoreExercises(int count) {
    return '+ $count a mais';
  }

  @override
  String get chatEmptySubtitle =>
      'Pergunte sobre seu treino, sua alimentação ou seu progresso.';

  @override
  String chatLoggedToday(int calories) {
    return 'Você registrou $calories kcal hoje.';
  }

  @override
  String get chatSuggestionHiit =>
      'Crie uma rotina HIIT de 20 minutos para mim';

  @override
  String get chatSuggestionDinner => 'O que devo comer hoje à noite?';

  @override
  String get chatSuggestionProgress => 'Como estou indo nesta semana?';

  @override
  String get chatSuggestionIngredients => 'Tenho frango, arroz e espinafre';

  @override
  String get chatJustNow => 'Agora mesmo';

  @override
  String chatMinutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String chatHoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String chatDaysAgo(int days) {
    return 'há $days d';
  }

  @override
  String get chatRoutineAlreadySaved =>
      'Já está na sua biblioteca — toque para abrir';

  @override
  String get chatRoutineTapToOpen => 'Toque para abrir';

  @override
  String get chatToolCancelled => 'Cancelado';

  @override
  String chatToolFailed(String label) {
    return '$label — não deu certo';
  }

  @override
  String get chatToolRoutineSaveFailed => 'Não foi possível salvar a rotina';

  @override
  String get chatToolRoutineSaved => 'Salva na sua biblioteca';

  @override
  String get chatToolMealLogged => 'Adicionada ao registro de hoje';

  @override
  String get chatToolRoutineAdded => 'Adicionada à sua biblioteca';

  @override
  String get activityCheckingProgress => 'Verificando seu progresso';

  @override
  String get activityCheckingNutrition => 'Verificando o que você comeu hoje';

  @override
  String get activityReviewingMeals => 'Analisando suas refeições recentes';

  @override
  String get activityLookingAtRoutines => 'Consultando suas rotinas';

  @override
  String get activityReadingRoutine => 'Lendo essa rotina';

  @override
  String get activitySearchingLibrary =>
      'Pesquisando na biblioteca de exercícios';

  @override
  String get activityBuildingRoutine => 'Criando sua rotina';

  @override
  String get activityLoggingMeal => 'Registrando sua refeição';

  @override
  String get activitySavingToLibrary => 'Salvando na sua biblioteca';

  @override
  String get activityWorking => 'Processando';

  @override
  String approvalSaveRoutineWithCount(String name, int count) {
    return 'Salvar \"$name\" com $count exercícios na sua biblioteca?';
  }

  @override
  String approvalSaveRoutine(String name) {
    return 'Salvar \"$name\" na sua biblioteca?';
  }

  @override
  String approvalLogMealWithCalories(String name, int calories) {
    return 'Registrar \"$name\" com $calories kcal?';
  }

  @override
  String approvalLogMeal(String name) {
    return 'Registrar \"$name\"?';
  }

  @override
  String get approvalAddRoutine => 'Adicionar esta rotina à sua biblioteca?';

  @override
  String get approvalGeneric => 'Permitir que Celia faça isso?';

  @override
  String get libraryTitle => 'Biblioteca de rotinas';

  @override
  String librarySteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etapas',
      one: '$count etapa',
    );
    return '$_temp0';
  }

  @override
  String get libraryEmpty => 'Nenhuma rotina ainda';

  @override
  String get libraryEmptyBody =>
      'Crie e publique rotinas no painel administrativo.';

  @override
  String get libraryLoadFailed => 'Não foi possível carregar as rotinas';

  @override
  String get routineStartWorkout => 'Iniciar treino';

  @override
  String get routineNoSteps => 'Nenhuma etapa disponível';

  @override
  String get routineNoVideoForStep => 'Nenhum vídeo disponível para esta etapa';

  @override
  String get routineVideoProcessing =>
      'O vídeo ainda está sendo processado. Tente novamente mais tarde.';

  @override
  String get routineMissingPlaybackUrl =>
      'O URL de reprodução está ausente para este vídeo';

  @override
  String get routinePreviewBanner => 'PRÉVIA — vídeo completo em breve';

  @override
  String get routinePreview => 'PRÉVIA';

  @override
  String get routineDetails => 'Detalhes';

  @override
  String get routineNotFound => 'Rotina não encontrada';

  @override
  String routineCompletedTimes(int count) {
    return 'Concluída ${count}x';
  }

  @override
  String get playerVideoUnavailable =>
      'Este vídeo não está disponível no momento.';

  @override
  String get playerSteps => 'Etapas';

  @override
  String playerStepCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get playerNoPlayableVideos => 'Nenhum vídeo reproduzível';

  @override
  String get playerWorkoutComplete => 'Treino concluído!';

  @override
  String get playerSavingStreak => 'Salvando na sua sequência…';

  @override
  String get playerSavedStreak => 'Salvo na sua sequência';

  @override
  String get playerRetrySave => 'Tentar salvar novamente';

  @override
  String get playerReplay => 'Reproduzir novamente';

  @override
  String get playerNotReady => 'Player não está pronto';

  @override
  String get playerPreviewUnavailable =>
      'A prévia não está disponível no momento.';

  @override
  String playerClipCounter(int current, int total, String duration) {
    return 'Clipe $current de $total · $duration';
  }

  @override
  String get playerErrorLoadingVideo => 'Erro ao carregar o vídeo';

  @override
  String get playerLoadingVideo => 'Carregando vídeo...';

  @override
  String get playerFailedToLoadVideo => 'Não foi possível carregar o vídeo';

  @override
  String get playerNotInitialized => 'Player de vídeo não inicializado';

  @override
  String guidedExerciseCounter(int current, int total) {
    return 'Exercício $current/$total';
  }

  @override
  String get guidedGetReady => 'PREPARE-SE';

  @override
  String guidedSetOf(int current, int total) {
    return 'Série $current de $total';
  }

  @override
  String get guidedRest => 'DESCANSO';

  @override
  String get guidedSkipRest => 'Pular descanso';

  @override
  String get guidedPaused => 'Pausado';

  @override
  String get guidedResume => 'Retomar';

  @override
  String get guidedWorkoutComplete => 'Treino concluído';

  @override
  String get guidedEndTitle => 'Encerrar treino?';

  @override
  String get guidedEndBody => 'Seu progresso nesta sessão não será salvo.';

  @override
  String get guidedKeepGoing => 'Continue';

  @override
  String get guidedEnd => 'Encerrar';

  @override
  String guidedReps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repetições',
      one: '$count repetição',
    );
    return '$_temp0';
  }

  @override
  String get generateSheetTitle => 'Gerar rotina com IA';

  @override
  String get generateSheetPrompt => 'Que tipo de treino você quer?';

  @override
  String get generateSheetHint =>
      'ex.: \"Um alongamento matinal rápido para acordar\" ou \"Treino de força para o corpo todo, para iniciantes\"';

  @override
  String get generateSheetDuration => 'Duração';

  @override
  String generateSheetMinutes(int count) {
    return '$count min';
  }

  @override
  String get generateSheetDifficulty => 'Dificuldade';

  @override
  String get generateSheetEquipment => 'Equipamentos disponíveis';

  @override
  String get generateSheetGenerating => 'Gerando...';

  @override
  String get generateSheetSubmit => 'Gerar rotina';

  @override
  String get generateSheetDescribeFirst => 'Descreva o treino que você quer';

  @override
  String generateSheetAlreadyExists(String title) {
    return 'Você já tem esta rotina: $title';
  }

  @override
  String generateSheetCreated(String title) {
    return 'Criada: $title';
  }

  @override
  String get generateSheetFailed => 'Não foi possível gerar a rotina';

  @override
  String get guidedNoExercises => 'Esta rotina ainda não tem exercícios.';

  @override
  String get guidedStartFailed =>
      'Não foi possível iniciar este treino agora. Tente novamente.';

  @override
  String get guidedSaveFailed =>
      'Não foi possível salvar este treino. Toque em tentar novamente para atualizar sua sequência.';

  @override
  String guidedOfReps(int count) {
    return 'de $count repetições';
  }

  @override
  String get guidedHold => 'mantenha';

  @override
  String get guidedNextSet => 'Próxima série';

  @override
  String get guidedUpNext => 'A seguir';

  @override
  String guidedSetsHold(int sets, int seconds) {
    return '$sets × ${seconds}s mantendo';
  }

  @override
  String coachGetReady(String exercise) {
    return 'Prepare-se. $exercise';
  }

  @override
  String coachStartReps(int count) {
    return 'Vamos. $count repetições.';
  }

  @override
  String coachStartHold(int seconds) {
    return 'Mantenha por $seconds segundos.';
  }

  @override
  String coachRest(String exercise) {
    return 'Descanse. A seguir: $exercise';
  }

  @override
  String get coachRestShort => 'Descanse.';

  @override
  String get coachComplete => 'Ótimo trabalho. Treino concluído.';

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
      'Nenhum vídeo reproduzível foi encontrado nesta rotina.';

  @override
  String get playerLoadRoutineFailed =>
      'Não foi possível carregar esta rotina agora. Tente novamente.';

  @override
  String playerStepLoadFailedSkipping(String title) {
    return 'Falha ao carregar \"$title\". Pulando…';
  }

  @override
  String playerStepLoadFailed(String title) {
    return 'Falha ao carregar \"$title\".';
  }

  @override
  String get playerSaveCompletionFailed =>
      'Não foi possível salvar a conclusão. Toque em tentar novamente para atualizar sua sequência.';

  @override
  String playerStepPreviewSubtitle(String duration) {
    return '$duration • Prévia';
  }

  @override
  String get playerNoVideosReady =>
      'Esta rotina ainda não tem vídeos prontos para reprodução.';

  @override
  String get playerPlaybackFailed =>
      'Não foi possível reproduzir este vídeo agora. Tente novamente.';

  @override
  String get libraryTabCurated => 'Selecionados';

  @override
  String get libraryTabAiGenerated => 'Gerados por IA';

  @override
  String get profileSavedRoutines => 'Rotinas salvas';

  @override
  String get savedRoutinesNoFavorites =>
      'Você ainda não tem rotinas favoritas.';

  @override
  String get savedRoutinesEmpty => 'Você ainda não tem rotinas salvas.';

  @override
  String get actionFavorite => 'Favoritar';

  @override
  String get actionUnfavorite => 'Remover dos favoritos';

  @override
  String routineDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String routineDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String routineDurationHours(int hours) {
    return '${hours}h';
  }

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get categoryStrength => 'Força';

  @override
  String get categoryCardio => 'Cardio';

  @override
  String get categoryFlexibility => 'Flexibilidade';

  @override
  String get categoryMindfulness => 'Atenção plena';

  @override
  String get categoryDance => 'Dança';

  @override
  String get categoryHiit => 'HIIT';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryCustom => 'Personalizado';

  @override
  String get navHome => 'Início';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get equipmentNone => 'Nenhum';

  @override
  String get equipmentDumbbells => 'Halteres';

  @override
  String get equipmentResistanceBands => 'Faixas de resistência';

  @override
  String get equipmentYogaMat => 'Tapete de yoga';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentPullUpBar => 'Barra fixa';

  @override
  String get equipmentJumpRope => 'Corda de pular';

  @override
  String get nutritionTitle => 'Nutrição';

  @override
  String get nutritionSubtitle => 'Calorias, macros e histórico de refeições';

  @override
  String get nutritionSetGoalsTitle => 'Defina suas metas nutricionais diárias';

  @override
  String get nutritionSetGoalsBody =>
      'Adicione seu peso, altura, idade e sexo para que a Celia calcule quantas calorias e nutrientes você deve consumir por dia.';

  @override
  String get nutritionSetUpGoals => 'Definir metas';

  @override
  String get nutritionDailyTarget => 'Meta diária';

  @override
  String get nutritionDailyGoals => 'Metas diárias';

  @override
  String nutritionKcal(int calories) {
    return '$calories kcal';
  }

  @override
  String nutritionMacroSummary(int protein, int carbs, int fat) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get nutritionToday => 'Hoje';

  @override
  String get nutritionMealHistory => 'Histórico de refeições';

  @override
  String get nutritionCeliaInsights => 'Insights da Celia';

  @override
  String get nutritionWeeklyTrend => 'Tendência semanal';

  @override
  String nutritionTodayMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições',
      one: '$count refeição',
    );
    return 'kcal • $_temp0';
  }

  @override
  String nutritionTodayOfTargetMeals(int target, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições',
      one: '$count refeição',
    );
    return 'de $target kcal • $_temp0';
  }

  @override
  String get nutritionWeekdayInitials => 'S,T,Q,Q,S,S,D';

  @override
  String get nutritionFieldFoodName => 'Nome do alimento';

  @override
  String get nutritionFieldGrams => 'Gramas';

  @override
  String get nutritionFieldCalories => 'Calorias';

  @override
  String get scannerStatusAnalyzing => 'ANALISANDO...';

  @override
  String get scannerStatusIdle => 'SCANNER DA CELIA';

  @override
  String get scannerFieldFoodName => 'Nome do alimento';

  @override
  String get scannerFieldGrams => 'Gramas';

  @override
  String get scannerFieldCalories => 'Calorias';

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
    return 'Restam $calories kcal e ${grams}g de proteína hoje';
  }

  @override
  String scannerOverTargetAfterLogging(int calories) {
    return '$calories kcal acima da sua meta diária';
  }

  @override
  String get scannerButtonAnalyzing => 'Analisando';

  @override
  String get scannerButtonQuotaNeeded => 'Cota necessária';

  @override
  String get scannerButtonScanNow => 'Digitalizar agora';

  @override
  String get scannerButtonLogging => 'Registrando';

  @override
  String get scannerButtonLogMeal => 'Registrar refeição';

  @override
  String get scannerNoClearFood =>
      'Nenhum alimento identificado com clareza. Tente melhorar a iluminação ou se aproximar.';

  @override
  String get scannerErrorCameraPermission =>
      'É necessário permitir o acesso à câmera para digitalizar refeições.';

  @override
  String get scannerErrorBackendMissing =>
      'O sistema de digitalização de calorias ainda não está configurado.';

  @override
  String get scannerErrorApiKeyInvalid =>
      'A chave da API da OpenAI para digitalização de calorias é inválida. Substitua-a no ambiente do backend, faça o deploy novamente e tente outra vez.';

  @override
  String get scannerErrorApiKeyMissing =>
      'É necessária uma chave da API da OpenAI para digitalizar calorias. Adicione-a na Vercel, faça o deploy novamente e tente outra vez.';

  @override
  String get scannerErrorQuotaExhausted =>
      'Os créditos da OpenAI para digitalização de calorias foram esgotados. Adicione créditos à API ou aumente o limite de cobrança e tente outra vez.';

  @override
  String get scannerErrorTimeout =>
      'A Celia precisou de mais tempo para analisar esta refeição. Mantenha a câmera estável e digitalize novamente.';

  @override
  String get scannerErrorNotSignedIn =>
      'Faça login antes de digitalizar refeições.';

  @override
  String get scannerErrorMealTableMissing =>
      'A tabela de registro de refeições ainda não está pronta. O resultado da digitalização continua disponível.';

  @override
  String get scannerErrorGeneric =>
      'A Celia ainda não conseguiu analisar esta refeição. Mantenha a câmera estável, centralize o alimento e digitalize novamente.';

  @override
  String nutritionGrams(String grams) {
    return '${grams}g';
  }

  @override
  String nutritionMealSubtitle(String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '$count item',
    );
    return '$time · $_temp0';
  }

  @override
  String get nutritionMealDetails => 'Detalhes da refeição';

  @override
  String get nutritionFoodItems => 'Itens alimentares';

  @override
  String nutritionItemSubtitle(int grams, int calories) {
    return '${grams}g · $calories kcal';
  }

  @override
  String get nutritionNeedsOneItem =>
      'Uma refeição precisa de pelo menos um item alimentar.';

  @override
  String get nutritionMealUpdated => 'Refeição atualizada';

  @override
  String nutritionUpdateFailed(String error) {
    return 'Não foi possível atualizar a refeição: $error';
  }

  @override
  String get nutritionDeleteMealTitle => 'Excluir refeição?';

  @override
  String get nutritionDeleteMealBody =>
      'Isso removerá a refeição do seu histórico nutricional.';

  @override
  String get nutritionDeleteMeal => 'Excluir refeição';

  @override
  String nutritionDeleteFailed(String error) {
    return 'Não foi possível excluir a refeição: $error';
  }

  @override
  String get nutritionEditFood => 'Editar alimento';

  @override
  String get nutritionSaveFood => 'Salvar alimento';

  @override
  String get nutritionLoadFailed => 'Não foi possível carregar as refeições';

  @override
  String get nutritionLoadFailedBody =>
      'Puxe para atualizar ou verifique a conexão com o backend.';

  @override
  String get nutritionNoMeals => 'Nenhuma refeição registrada ainda';

  @override
  String get nutritionNoMealsBody =>
      'Escaneie sua primeira refeição e a Celia criará seu histórico nutricional.';

  @override
  String get progressToday => 'Hoje';

  @override
  String get progressSetGoals =>
      'Defina suas metas nutricionais para desbloquear o acompanhamento de calorias e macronutrientes.';

  @override
  String progressOfTarget(int target) {
    return 'de $target kcal';
  }

  @override
  String progressMacroAmount(int consumed, int target) {
    return '$consumed / ${target}g';
  }

  @override
  String progressKcalOver(int calories) {
    return '$calories kcal acima';
  }

  @override
  String progressKcalLeft(int calories) {
    return '$calories kcal restantes';
  }

  @override
  String get progressProtein => 'Proteína';

  @override
  String get progressCarbs => 'Carboidratos';

  @override
  String get progressFat => 'Gorduras';

  @override
  String get scannerEditItem => 'Editar item alimentar';

  @override
  String get scannerSaveChanges => 'Salvar alterações';

  @override
  String scannerItemCalories(String name, int calories) {
    return '$name · $calories kcal';
  }

  @override
  String scannerConfidence(int percent, String provider) {
    return 'Confiança de $percent% · $provider';
  }

  @override
  String scannerMoreItems(int count) {
    return '+ $count itens adicionais incluídos neste registro de refeição';
  }

  @override
  String get scannerIfYouLog => 'Se você registrar esta refeição';

  @override
  String scannerAfterLogging(int after, int target) {
    return '$after / $target kcal hoje';
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
  String get scannerNoMealDetected => 'Nenhuma refeição detectada';

  @override
  String onboardingWelcome(String name) {
    return 'Boas-vindas, $name';
  }

  @override
  String get onboardingGender => 'Sexo';

  @override
  String get onboardingCalculateGoals => 'Calcular minhas metas';

  @override
  String get onboardingScanFirstMeal => 'Escanear minha primeira refeição';

  @override
  String get onboardingExploreRoutines => 'Explorar rotinas';

  @override
  String get onboardingGoHome => 'Ir para o início';

  @override
  String get onboardingDailyTargets => 'Suas metas diárias';

  @override
  String onboardingProtein(int grams) {
    return 'Proteína ${grams}g ·';
  }

  @override
  String onboardingMacroTargets(int protein, int carbs, int fat) {
    return 'Proteína ${protein}g • Carboidratos ${carbs}g • Gorduras ${fat}g';
  }

  @override
  String get onboardingTargetsReady =>
      'Suas metas nutricionais diárias estão prontas. Escolha como deseja começar.';

  @override
  String get onboardingWeightKg => 'Peso (kg)';

  @override
  String get onboardingHeightCm => 'Altura (cm)';

  @override
  String get onboardingAge => 'Idade';

  @override
  String get onboardingInvalidWeight => 'Insira um peso válido em kg.';

  @override
  String get onboardingInvalidHeight => 'Insira uma altura válida em cm.';

  @override
  String get onboardingInvalidAge => 'Insira uma idade válida entre 13 e 100.';

  @override
  String get onboardingSaveFailed =>
      'Não foi possível salvar seu perfil nutricional.';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Feminino';

  @override
  String get genderOther => 'Outro';

  @override
  String get nutritionSetupTitle => 'Metas nutricionais diárias';

  @override
  String get nutritionSetupBody =>
      'Conte à Celia sobre seu corpo para que ela calcule suas calorias e seus macronutrientes diários.';

  @override
  String get nutritionSetupGender => 'Sexo';

  @override
  String get nutritionSetupFootnote =>
      'A Celia usa seu peso, altura, idade e sexo para estimar suas metas diárias de calorias e macronutrientes com base em um nível de atividade moderado.';

  @override
  String get nutritionSetupSave => 'Salvar metas';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileCeliaAi => 'Celia AI';

  @override
  String get profileEliteMember => 'Membro';

  @override
  String get profileAccount => 'Conta';

  @override
  String profileSignedInAs(String email) {
    return 'Conectado como:\n$email';
  }

  @override
  String get profileUnknownEmail => 'Desconhecido';

  @override
  String get profileDarkMode => 'Modo escuro';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLogOutTitle => 'Sair?';

  @override
  String get profileLogOutBody => 'Tem certeza de que deseja sair?';

  @override
  String get profileLogOut => 'Sair';

  @override
  String get profileLogOutButton => 'Sair';

  @override
  String get profileFavoriteRoutines => 'Rotinas favoritas';

  @override
  String get profileSubscription => 'Assinatura';

  @override
  String get profileNutrition => 'Nutrição';

  @override
  String get profileHelpSupport => 'Ajuda e suporte';

  @override
  String get profileFriend => 'Amigo';

  @override
  String get profileStatSaved => 'Salvos';

  @override
  String get profileStatStreak => 'Sequência';

  @override
  String get profileStatWorkouts => 'Treinos';

  @override
  String get streakDayOneStarted =>
      'O dia 1 começou — volte amanhã para criar sua sequência.';

  @override
  String get streakRebuild =>
      'Você esteve ativo ontem — registre uma refeição ou conclua um treino hoje para reconstruir sua sequência.';

  @override
  String get streakStart =>
      'Registre uma refeição ou conclua um treino para iniciar sua sequência ativa.';

  @override
  String streakLongRun(int days) {
    return 'Sequência de $days dias! Continue presente — a Celia está acompanhando sua consistência.';
  }

  @override
  String streakBothLogged(int days) {
    return 'Sequência de $days dias — treino e nutrição registrados hoje.';
  }

  @override
  String streakNeedWorkout(int days) {
    return 'Sequência de $days dias. Um treino rápido completaria o dia de hoje.';
  }

  @override
  String streakNeedMeal(int days) {
    return 'Sequência de $days dias. Registre uma refeição para acompanhar sua alimentação.';
  }

  @override
  String streakStayActive(int days) {
    return 'Sequência de $days dias — mantenha-se ativo hoje.';
  }

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get editProfileName => 'Nome';

  @override
  String get editProfileFootnote =>
      'As alterações são salvas na sua conta e aparecerão na Página inicial/Perfil.';

  @override
  String get editProfileSaveFailed =>
      'Não foi possível atualizar o perfil. Tente novamente.';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma do dispositivo';

  @override
  String get languageSystemSubtitle => 'Usar o idioma definido no seu celular';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get insightStartFuelingTitle => 'Comece a se alimentar hoje';

  @override
  String get insightStartFuelingBody =>
      'Você ainda tem todo o seu orçamento de calorias disponível. Escaneie ou registre sua primeira refeição para manter o foco.';

  @override
  String get insightAboveTargetTitle => 'Acima da meta hoje';

  @override
  String insightAboveTargetBody(int calories) {
    return 'Você está $calories kcal acima da sua meta diária. Faça um jantar mais leve ou adicione um treino curto.';
  }

  @override
  String get insightLowProteinTitle => 'A proteína ainda está baixa';

  @override
  String insightLowProteinBody(int grams) {
    return 'Você ainda precisa de cerca de ${grams}g de proteína hoje para atingir sua meta.';
  }

  @override
  String get insightAlmostThereTitle => 'Quase na sua meta';

  @override
  String insightAlmostThereBody(int calories) {
    return 'Você ainda tem $calories kcal para hoje. Um lanche equilibrado pode se encaixar bem.';
  }

  @override
  String get insightOnTrackTitle => 'No caminho certo hoje';

  @override
  String insightOnTrackBody(int calories, int grams) {
    return 'Faltam $calories kcal e ${grams}g de proteína para atingir suas metas diárias.';
  }

  @override
  String get insightWeeklyRhythmTitle => 'Crie seu ritmo semanal';

  @override
  String get insightWeeklyRhythmBody =>
      'Registre refeições ao longo da semana para que a Celia identifique padrões e oriente você melhor.';

  @override
  String get insightWeeklyTrendTitle => 'Tendência semanal';

  @override
  String insightWeeklyTrendBody(int days, int average, String direction) {
    return 'Você registrou refeições em $days dos últimos 7 dias, com média de $average kcal — $direction.';
  }

  @override
  String get insightTrendOnTarget => 'praticamente na sua meta diária';

  @override
  String insightTrendAbove(int delta) {
    return '$delta kcal acima da sua meta, em média';
  }

  @override
  String insightTrendBelow(int delta) {
    return '$delta kcal abaixo da sua meta, em média';
  }

  @override
  String get insightsSectionTitle => 'Insights da Celia';
}
