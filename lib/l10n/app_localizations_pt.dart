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
  String get errorDeleteAccount =>
      'Não foi possível eliminar a sua conta. Tente novamente.';

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
  String get chatMicTooltip => 'Mantenha pressionado para falar';

  @override
  String get chatListening => 'Ouvindo…';

  @override
  String get chatMicDenied =>
      'É necessário acesso ao microfone para falar com a Celia.';

  @override
  String get chatSpeechUnavailable =>
      'O reconhecimento de voz não está disponível neste dispositivo.';

  @override
  String get avatarModeReady => 'Pronta';

  @override
  String get avatarModeThinking => 'Pensando…';

  @override
  String get avatarModeSpeaking => 'Falando…';

  @override
  String get avatarModeHoldToTalk => 'Segure para falar';

  @override
  String get avatarModeExit => 'Modo manual';

  @override
  String get avatarModeConfirmTitle => 'Confirmar com a Celia?';

  @override
  String get avatarModeConfirmBody => 'Celia quer guardar algo. Permitir?';

  @override
  String get avatarModeConfirmYes => 'Permitir';

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
  String get nutritionSourcesTitle => 'Como estes objetivos são calculados';

  @override
  String get nutritionSourcesBody =>
      'As calorias diárias usam a equação de energia em repouso de Mifflin–St Jeor com um fator de atividade física moderada (cerca de 1,55). A proteína é estimada perto de 1,8 g por kg de peso corporal para adultos ativos. A gordura fica perto de 25% das calorias, com os hidratos a preencher o restante — dentro de intervalos comuns de orientação alimentar.';

  @override
  String get nutritionSourcesDisclaimer =>
      'Estes valores são apenas estimativas gerais de bem-estar. Não são um diagnóstico, uma prescrição nem um substituto do conselho de um clínico ou nutricionista qualificado.';

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
  String get profileAvatarMode => 'Modo avatar';

  @override
  String get profileAvatarModeSubtitle => 'Fale com a Celia em ecrã inteiro';

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
  String get profileDeleteAccount => 'Eliminar conta';

  @override
  String get profileDeleteAccountConfirmTitle => 'Eliminar a sua conta?';

  @override
  String get profileDeleteAccountConfirmBody =>
      'Isto elimina permanentemente a sua conta e todos os seus dados, incluindo rotinas guardadas, registos de refeições e histórico de chat. Não pode ser anulado.';

  @override
  String get profileDeleteAccountPasswordPrompt =>
      'Introduza a sua palavra-passe para confirmar.';

  @override
  String get profileDeleteAccountPasswordLabel => 'Palavra-passe';

  @override
  String get profileDeleteAccountButton => 'Eliminar a minha conta';

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

  @override
  String get bodyScanTitle => 'Escaneamento corporal';

  @override
  String get bodyScanContinue => 'Continuar';

  @override
  String get bodyScanDone => 'Concluído';

  @override
  String get bodyScanConsentTitle => 'Antes de escanear';

  @override
  String get bodyScanConsentBody =>
      'Um escaneamento corporal estima sua composição corporal a partir de duas fotos. Veja exatamente o que acontece com elas.';

  @override
  String get bodyScanConsentPhotosTitle => 'Duas fotos, tiradas por você';

  @override
  String get bodyScanConsentPhotosBody =>
      'Uma de frente para a câmera e outra do seu lado direito. Use roupas justas para que o contorno do seu corpo fique nítido.';

  @override
  String get bodyScanConsentProcessingTitle => 'Analisadas pela Bodygram';

  @override
  String get bodyScanConsentProcessingBody =>
      'Suas fotos são enviadas à nossa fornecedora de escaneamento, a Bodygram, para estimar suas medidas. Elas não são usadas para nenhuma outra finalidade.';

  @override
  String get bodyScanConsentStorageTitle => 'Suas fotos nunca são armazenadas';

  @override
  String get bodyScanConsentStorageBody =>
      'A Celia não as mantém. Apenas os números resultantes e seu modelo 3D são salvos na sua conta, e excluir sua conta os apaga.';

  @override
  String get bodyScanConsentAgeTitle => 'Você precisa ter 18 anos ou mais';

  @override
  String get bodyScanConsentAgeBody =>
      'O escaneamento corporal não está disponível para menores de 18 anos.';

  @override
  String get bodyScanConsentAgree =>
      'Entendo e concordo que minhas fotos sejam analisadas';

  @override
  String get bodyScanStatsTitle => 'Confirme seus dados';

  @override
  String get bodyScanStatsBody =>
      'Eles são usados diretamente na estimativa, portanto, um peso desatualizado distorcerá seus resultados.';

  @override
  String get bodyScanStatsHeight => 'Altura';

  @override
  String get bodyScanStatsWeight => 'Peso';

  @override
  String get bodyScanStatsAge => 'Idade';

  @override
  String get bodyScanStatsSex => 'Sexo';

  @override
  String get bodyScanStatsSexNote =>
      'O modelo de escaneamento foi desenvolvido com apenas dois grupos de referência. Escolha o que mais se aproxima do seu corpo; isso afeta a estimativa, não a forma como a Celia trata você.';

  @override
  String get bodyScanStatsFemale => 'Feminino';

  @override
  String get bodyScanStatsMale => 'Masculino';

  @override
  String get bodyScanStatsInvalid =>
      'Insira uma altura, um peso e uma idade válidos. Você precisa ter 18 anos ou mais para escanear.';

  @override
  String get bodyScanCaptureFrontTitle => 'Fique de frente para a câmera';

  @override
  String get bodyScanCaptureRightTitle => 'Vire-se para a direita';

  @override
  String get bodyScanCaptureHowTo =>
      'Apoie seu celular a cerca de 3 m de distância, afaste-se até que seu corpo inteiro caiba no contorno e então inicie o timer.';

  @override
  String get bodyScanCaptureTips =>
      'Roupas justas, fundo liso, boa iluminação uniforme e braços ligeiramente afastados do corpo.';

  @override
  String get bodyScanPoseFront => 'Frente';

  @override
  String get bodyScanPoseRight => 'Lado direito';

  @override
  String get bodyScanStartTimer => 'Iniciar timer';

  @override
  String get bodyScanCancelTimer => 'Cancelar timer';

  @override
  String get bodyScanRetake => 'Tirar novamente';

  @override
  String get bodyScanNextPose => 'Próxima foto';

  @override
  String get bodyScanGetResults => 'Ver meus resultados';

  @override
  String get bodyScanProcessingTitle => 'Analisando seu escaneamento';

  @override
  String get bodyScanProcessingBody =>
      'Criando seu modelo 3D e estimando suas medidas. Isso leva até um minuto.';

  @override
  String get bodyScanResultTitle => 'Seu escaneamento corporal';

  @override
  String get bodyScanResultSubtitle =>
      'Estimado a partir das suas fotos. Ideal para acompanhar uma tendência ao longo do tempo.';

  @override
  String get bodyScanBodyFat => 'Gordura corporal';

  @override
  String get bodyScanLeanMass => 'Massa magra';

  @override
  String get bodyScanFatMass => 'Massa gorda';

  @override
  String get bodyScanWaist => 'Cintura';

  @override
  String get bodyScanHip => 'Quadris';

  @override
  String get bodyScanChest => 'Peito';

  @override
  String get bodyScanWaistToHip => 'Cintura-quadril';

  @override
  String bodyScanQuotaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escaneamentos restantes neste período',
      one: '1 escaneamento restante neste período',
      zero: 'Nenhum escaneamento restante neste período',
    );
    return '$_temp0';
  }

  @override
  String get bodyScanEmptyTitle => 'Veja como seu corpo está mudando';

  @override
  String get bodyScanEmptyBody =>
      'Duas fotos fornecem uma estimativa da sua gordura corporal, massa magra e principais medidas, além de um modelo 3D que você pode comparar ao longo do tempo.';

  @override
  String get bodyScanLatestTitle => 'Escaneamento mais recente';

  @override
  String get bodyScanHistoryTitle => 'Escaneamentos anteriores';

  @override
  String get bodyScanStartCta => 'Iniciar escaneamento corporal';

  @override
  String get bodyScanRescanCta => 'Escanear novamente';

  @override
  String get bodyScanRescanHint =>
      'A composição corporal muda lentamente. Fazer um escaneamento aproximadamente uma vez por mês proporciona a comparação mais significativa.';

  @override
  String bodyScanDeltaSinceLast(String value) {
    return 'Variação de $value% desde seu último escaneamento';
  }

  @override
  String get bodyScanNoComposition => 'Sem estimativa';

  @override
  String get bodyScanSourcesTitle => 'Como isso é calculado';

  @override
  String get bodyScanSourcesBody =>
      'Suas fotos são transformadas em um contorno 3D do seu corpo, e a gordura corporal e a massa magra são estimadas a partir desse formato, juntamente com sua altura, peso, idade e sexo. A massa magra inclui músculos, água, ossos e órgãos, e não apenas proteína.';

  @override
  String get bodyScanDisclaimer =>
      'Estas são estimativas, não medições médicas. Estudos desse método relatam um erro médio de cerca de 3,5% na gordura corporal em comparação com um exame DXA clínico, e a concordância é menor para acompanhar mudanças do que para uma única leitura. Não serve para diagnóstico. Converse com um profissional de saúde sobre decisões relacionadas à sua saúde.';

  @override
  String get bodyScanErrorCameraPermission =>
      'A Celia precisa de acesso à câmera para escanear seu corpo.';

  @override
  String get bodyScanErrorNoCamera =>
      'Nenhuma câmera está disponível neste dispositivo.';

  @override
  String get bodyScanErrorFraming =>
      'Seu corpo inteiro precisa estar no enquadramento. Afaste o celular e certifique-se de que sua cabeça e seus pés estejam visíveis.';

  @override
  String get bodyScanErrorQuality =>
      'As fotos estavam escuras ou desfocadas demais. Procure uma iluminação mais clara e uniforme e fique parado enquanto o cronômetro estiver ativo.';

  @override
  String get bodyScanErrorPose =>
      'Sua pose não estava adequada. Fique em pé, de frente para a câmera, com os braços levemente afastados do corpo. Depois, vire-se completamente para a direita para a segunda foto.';

  @override
  String get bodyScanErrorClothing =>
      'Roupas largas escondem seu contorno. Roupas ajustadas permitem um escaneamento adequado.';

  @override
  String get bodyScanErrorPhotoUnknown =>
      'Não foi possível usar essas fotos. Tente novamente contra um fundo liso e com boa iluminação.';

  @override
  String get bodyScanErrorPhotosTooLarge =>
      'Essas fotos eram grandes demais para enviar. Tente novamente.';

  @override
  String get bodyScanErrorQuota =>
      'Você usou seus escaneamentos deste período. Poderá escanear novamente quando a cota for renovada.';

  @override
  String get bodyScanErrorAge =>
      'O escaneamento corporal está disponível apenas para usuários com 18 anos ou mais.';

  @override
  String get bodyScanErrorStats =>
      'Confira sua altura, peso, idade e sexo e tente novamente.';

  @override
  String get bodyScanErrorSignedIn => 'Faça login novamente para escanear.';

  @override
  String get bodyScanErrorUnavailable =>
      'O escaneamento corporal não está disponível no momento.';

  @override
  String get bodyScanErrorNetwork =>
      'Não foi possível acessar a Celia. Verifique sua conexão e tente novamente.';

  @override
  String get bodyScanErrorServer =>
      'Algo deu errado com seu escaneamento. Tente novamente.';

  @override
  String get bodyScanErrorLoadHistory =>
      'Não foi possível carregar seus escaneamentos anteriores.';

  @override
  String get profileBodyScan => 'Escaneamento corporal';

  @override
  String get homeBodyScan => 'Escaneamento corporal';

  @override
  String get homeBodyScanSubtitle => 'Estime a gordura corporal com duas fotos';
}
