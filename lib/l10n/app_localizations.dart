import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// The app's name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Celia Integral Coach'**
  String get appName;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get actionSeeAll;

  /// No description provided for @actionYesDoIt.
  ///
  /// In en, this message translates to:
  /// **'Yes, do it'**
  String get actionYesDoIt;

  /// No description provided for @actionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionNotNow;

  /// No description provided for @loadingPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing Celia...'**
  String get loadingPreparing;

  /// No description provided for @loadingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingGeneric;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorCanceled.
  ///
  /// In en, this message translates to:
  /// **'Action canceled.'**
  String get errorCanceled;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorBadCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorBadCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Try logging in instead.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a stronger password and try again.'**
  String get errorWeakPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorNoPermission;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in and try again.'**
  String get errorNotSignedIn;

  /// No description provided for @errorDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete your account. Please try again.'**
  String get errorDeleteAccount;

  /// No description provided for @errorNoConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a new chat to continue.'**
  String get errorNoConversation;

  /// No description provided for @errorNoPlayableVideos.
  ///
  /// In en, this message translates to:
  /// **'No playable videos are available for this routine yet.'**
  String get errorNoPlayableVideos;

  /// No description provided for @errorLoadRoutines.
  ///
  /// In en, this message translates to:
  /// **'Could not load routines right now. Please try again.'**
  String get errorLoadRoutines;

  /// No description provided for @errorLoadSavedRoutines.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved routines right now. Please try again.'**
  String get errorLoadSavedRoutines;

  /// No description provided for @errorGenerateRoutine.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a routine right now. Please try again.'**
  String get errorGenerateRoutine;

  /// No description provided for @errorLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Unable to load saved chats right now.'**
  String get errorLoadChats;

  /// No description provided for @errorCeliaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Celia is unavailable right now. Please try again.'**
  String get errorCeliaUnavailable;

  /// No description provided for @errorOpenConversation.
  ///
  /// In en, this message translates to:
  /// **'Could not open that conversation.'**
  String get errorOpenConversation;

  /// No description provided for @errorDeleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this conversation. Please try again.'**
  String get errorDeleteConversation;

  /// No description provided for @errorSignIn.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get errorSignIn;

  /// No description provided for @errorCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not create your account. Please try again.'**
  String get errorCreateAccount;

  /// No description provided for @errorSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email. Please try again.'**
  String get errorSendResetEmail;

  /// No description provided for @errorSendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not send verification email. Please try again.'**
  String get errorSendVerificationEmail;

  /// No description provided for @errorGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get errorGoogleSignIn;

  /// No description provided for @errorAppleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get errorAppleSignIn;

  /// No description provided for @errorRefreshNutrition.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh nutrition data.'**
  String get errorRefreshNutrition;

  /// No description provided for @errorLoadNutritionProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your nutrition profile.'**
  String get errorLoadNutritionProfile;

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the app'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please close and reopen the app. If this continues, contact support.'**
  String get startupErrorBody;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Your fitness buddy'**
  String get authTagline;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLogIn;

  /// No description provided for @authVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String authVersion(String version);

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authAuthenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authAuthenticating;

  /// No description provided for @authEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get authEnterYourName;

  /// No description provided for @authNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign Up'**
  String get authNeedAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get authHaveAccount;

  /// No description provided for @authFieldName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get authFieldName;

  /// No description provided for @authFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authFieldEmail;

  /// No description provided for @authFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authFieldPassword;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailHeading.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get verifyEmailHeading;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to your email.'**
  String get verifyEmailBody;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verifyEmailSent;

  /// No description provided for @verifyEmailContinue.
  ///
  /// In en, this message translates to:
  /// **'I have verified, continue'**
  String get verifyEmailContinue;

  /// No description provided for @verifyEmailSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get verifyEmailSignOut;

  /// No description provided for @verifyEmailSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get verifyEmailSending;

  /// No description provided for @verifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String verifyEmailResendIn(int seconds);

  /// No description provided for @verifyEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String verifyEmailAddress(String email);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get forgotPasswordEmptyEmail;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get forgotPasswordSent;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get forgotPasswordSending;

  /// No description provided for @nameSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'What should Celia call you?'**
  String get nameSetupTitle;

  /// No description provided for @nameSetupBody.
  ///
  /// In en, this message translates to:
  /// **'We use your name across the app so coaching feels personal.'**
  String get nameSetupBody;

  /// No description provided for @nameSetupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your name. Please try again.'**
  String get nameSetupSaveFailed;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get homeGoodMorning;

  /// No description provided for @homeCeliaActive.
  ///
  /// In en, this message translates to:
  /// **'CELIA ACTIVE'**
  String get homeCeliaActive;

  /// No description provided for @homeGenerateRoutine.
  ///
  /// In en, this message translates to:
  /// **'Generate your\npersonalized\nroutine with AI'**
  String get homeGenerateRoutine;

  /// No description provided for @homeCreateRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get homeCreateRoutine;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get homeUpNext;

  /// No description provided for @homeNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming routines yet.\nCreate one or browse the library.'**
  String get homeNoUpcoming;

  /// No description provided for @homeChatWithCelia.
  ///
  /// In en, this message translates to:
  /// **'Chat with Celia'**
  String get homeChatWithCelia;

  /// No description provided for @homeChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about your form or diet'**
  String get homeChatSubtitle;

  /// No description provided for @homeScanMeal.
  ///
  /// In en, this message translates to:
  /// **'Scan Meal'**
  String get homeScanMeal;

  /// No description provided for @homeScanMealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identify food & calories'**
  String get homeScanMealSubtitle;

  /// No description provided for @homeNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get homeNutrition;

  /// No description provided for @homeNutritionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View calories, macros & meals'**
  String get homeNutritionSubtitle;

  /// No description provided for @homeBrowseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Browse\nLibrary'**
  String get homeBrowseLibrary;

  /// No description provided for @homeTrackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track\nProgress'**
  String get homeTrackProgress;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach Celia'**
  String get chatTitle;

  /// No description provided for @chatEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'How can I help you\nget fit today?'**
  String get chatEmptyPrompt;

  /// No description provided for @chatYourChats.
  ///
  /// In en, this message translates to:
  /// **'Your chats'**
  String get chatYourChats;

  /// No description provided for @chatNoSavedChats.
  ///
  /// In en, this message translates to:
  /// **'No saved chats yet.'**
  String get chatNoSavedChats;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatHistory;

  /// No description provided for @chatNew.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatNew;

  /// No description provided for @chatOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening chat...'**
  String get chatOpening;

  /// No description provided for @chatScanAMeal.
  ///
  /// In en, this message translates to:
  /// **'Scan a meal'**
  String get chatScanAMeal;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Celia anything about your training...'**
  String get chatInputHint;

  /// No description provided for @chatMicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get chatMicTooltip;

  /// No description provided for @chatListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get chatListening;

  /// No description provided for @chatMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to talk to Celia.'**
  String get chatMicDenied;

  /// No description provided for @chatSpeechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn\'t available on this device.'**
  String get chatSpeechUnavailable;

  /// No description provided for @avatarModeReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get avatarModeReady;

  /// No description provided for @avatarModeThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get avatarModeThinking;

  /// No description provided for @avatarModeSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking…'**
  String get avatarModeSpeaking;

  /// No description provided for @avatarModeHoldToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get avatarModeHoldToTalk;

  /// No description provided for @avatarModeExit.
  ///
  /// In en, this message translates to:
  /// **'Manual mode'**
  String get avatarModeExit;

  /// No description provided for @avatarModeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm with Celia?'**
  String get avatarModeConfirmTitle;

  /// No description provided for @avatarModeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Celia wants to save something. Allow it?'**
  String get avatarModeConfirmBody;

  /// No description provided for @avatarModeConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get avatarModeConfirmYes;

  /// No description provided for @chatCouldNotOpenRoutine.
  ///
  /// In en, this message translates to:
  /// **'Could not open that routine'**
  String get chatCouldNotOpenRoutine;

  /// No description provided for @chatThisRoutine.
  ///
  /// In en, this message translates to:
  /// **'this routine'**
  String get chatThisRoutine;

  /// No description provided for @chatThisMeal.
  ///
  /// In en, this message translates to:
  /// **'this meal'**
  String get chatThisMeal;

  /// No description provided for @chatYourRoutine.
  ///
  /// In en, this message translates to:
  /// **'Your routine'**
  String get chatYourRoutine;

  /// No description provided for @chatMoreExercises.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String chatMoreExercises(int count);

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about your training, your food, or your progress.'**
  String get chatEmptySubtitle;

  /// No description provided for @chatLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'You\'ve logged {calories} kcal today.'**
  String chatLoggedToday(int calories);

  /// No description provided for @chatSuggestionHiit.
  ///
  /// In en, this message translates to:
  /// **'Build me a 20-minute HIIT routine'**
  String get chatSuggestionHiit;

  /// No description provided for @chatSuggestionDinner.
  ///
  /// In en, this message translates to:
  /// **'What should I eat tonight?'**
  String get chatSuggestionDinner;

  /// No description provided for @chatSuggestionProgress.
  ///
  /// In en, this message translates to:
  /// **'How am I doing this week?'**
  String get chatSuggestionProgress;

  /// No description provided for @chatSuggestionIngredients.
  ///
  /// In en, this message translates to:
  /// **'I have chicken, rice and spinach'**
  String get chatSuggestionIngredients;

  /// No description provided for @chatJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get chatJustNow;

  /// No description provided for @chatMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String chatMinutesAgo(int minutes);

  /// No description provided for @chatHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String chatHoursAgo(int hours);

  /// No description provided for @chatDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String chatDaysAgo(int days);

  /// No description provided for @chatRoutineAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already in your library — tap to open'**
  String get chatRoutineAlreadySaved;

  /// No description provided for @chatRoutineTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get chatRoutineTapToOpen;

  /// No description provided for @chatToolCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get chatToolCancelled;

  /// No description provided for @chatToolFailed.
  ///
  /// In en, this message translates to:
  /// **'{label} — that did not work'**
  String chatToolFailed(String label);

  /// No description provided for @chatToolRoutineSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the routine'**
  String get chatToolRoutineSaveFailed;

  /// No description provided for @chatToolRoutineSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your library'**
  String get chatToolRoutineSaved;

  /// No description provided for @chatToolMealLogged.
  ///
  /// In en, this message translates to:
  /// **'Added to today\'s log'**
  String get chatToolMealLogged;

  /// No description provided for @chatToolRoutineAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your library'**
  String get chatToolRoutineAdded;

  /// No description provided for @activityCheckingProgress.
  ///
  /// In en, this message translates to:
  /// **'Checking your progress'**
  String get activityCheckingProgress;

  /// No description provided for @activityCheckingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Checking what you ate today'**
  String get activityCheckingNutrition;

  /// No description provided for @activityReviewingMeals.
  ///
  /// In en, this message translates to:
  /// **'Reviewing your recent meals'**
  String get activityReviewingMeals;

  /// No description provided for @activityLookingAtRoutines.
  ///
  /// In en, this message translates to:
  /// **'Looking at your routines'**
  String get activityLookingAtRoutines;

  /// No description provided for @activityReadingRoutine.
  ///
  /// In en, this message translates to:
  /// **'Reading that routine'**
  String get activityReadingRoutine;

  /// No description provided for @activitySearchingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Searching the exercise library'**
  String get activitySearchingLibrary;

  /// No description provided for @activityBuildingRoutine.
  ///
  /// In en, this message translates to:
  /// **'Building your routine'**
  String get activityBuildingRoutine;

  /// No description provided for @activityLoggingMeal.
  ///
  /// In en, this message translates to:
  /// **'Logging your meal'**
  String get activityLoggingMeal;

  /// No description provided for @activitySavingToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Saving to your library'**
  String get activitySavingToLibrary;

  /// No description provided for @activityWorking.
  ///
  /// In en, this message translates to:
  /// **'Working on it'**
  String get activityWorking;

  /// No description provided for @approvalSaveRoutineWithCount.
  ///
  /// In en, this message translates to:
  /// **'Save \"{name}\" with {count} exercises to your library?'**
  String approvalSaveRoutineWithCount(String name, int count);

  /// No description provided for @approvalSaveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save \"{name}\" to your library?'**
  String approvalSaveRoutine(String name);

  /// No description provided for @approvalLogMealWithCalories.
  ///
  /// In en, this message translates to:
  /// **'Log \"{name}\" at {calories} kcal?'**
  String approvalLogMealWithCalories(String name, int calories);

  /// No description provided for @approvalLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log \"{name}\"?'**
  String approvalLogMeal(String name);

  /// No description provided for @approvalAddRoutine.
  ///
  /// In en, this message translates to:
  /// **'Add this routine to your library?'**
  String get approvalAddRoutine;

  /// No description provided for @approvalGeneric.
  ///
  /// In en, this message translates to:
  /// **'Allow Celia to do this?'**
  String get approvalGeneric;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Library'**
  String get libraryTitle;

  /// No description provided for @librarySteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} step} other{{count} steps}}'**
  String librarySteps(int count);

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get libraryEmpty;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create and publish routines in the admin dashboard.'**
  String get libraryEmptyBody;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load routines'**
  String get libraryLoadFailed;

  /// No description provided for @routineStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get routineStartWorkout;

  /// No description provided for @routineNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps available'**
  String get routineNoSteps;

  /// No description provided for @routineNoVideoForStep.
  ///
  /// In en, this message translates to:
  /// **'No video available for this step'**
  String get routineNoVideoForStep;

  /// No description provided for @routineVideoProcessing.
  ///
  /// In en, this message translates to:
  /// **'Video is still processing. Please try again later.'**
  String get routineVideoProcessing;

  /// No description provided for @routineMissingPlaybackUrl.
  ///
  /// In en, this message translates to:
  /// **'Playback URL is missing for this video'**
  String get routineMissingPlaybackUrl;

  /// No description provided for @routinePreviewBanner.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW — full video coming soon'**
  String get routinePreviewBanner;

  /// No description provided for @routinePreview.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get routinePreview;

  /// No description provided for @routineDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get routineDetails;

  /// No description provided for @routineNotFound.
  ///
  /// In en, this message translates to:
  /// **'Routine not found'**
  String get routineNotFound;

  /// No description provided for @routineCompletedTimes.
  ///
  /// In en, this message translates to:
  /// **'Completed {count}x'**
  String routineCompletedTimes(int count);

  /// No description provided for @playerVideoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This video is not available right now.'**
  String get playerVideoUnavailable;

  /// No description provided for @playerSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get playerSteps;

  /// No description provided for @playerStepCounter.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String playerStepCounter(int current, int total);

  /// No description provided for @playerNoPlayableVideos.
  ///
  /// In en, this message translates to:
  /// **'No playable videos'**
  String get playerNoPlayableVideos;

  /// No description provided for @playerWorkoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete!'**
  String get playerWorkoutComplete;

  /// No description provided for @playerSavingStreak.
  ///
  /// In en, this message translates to:
  /// **'Saving to your streak…'**
  String get playerSavingStreak;

  /// No description provided for @playerSavedStreak.
  ///
  /// In en, this message translates to:
  /// **'Saved to your streak'**
  String get playerSavedStreak;

  /// No description provided for @playerRetrySave.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get playerRetrySave;

  /// No description provided for @playerReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get playerReplay;

  /// No description provided for @playerNotReady.
  ///
  /// In en, this message translates to:
  /// **'Player not ready'**
  String get playerNotReady;

  /// No description provided for @playerPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview not available right now.'**
  String get playerPreviewUnavailable;

  /// No description provided for @playerClipCounter.
  ///
  /// In en, this message translates to:
  /// **'Clip {current} of {total} · {duration}'**
  String playerClipCounter(int current, int total, String duration);

  /// No description provided for @playerErrorLoadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Error loading video'**
  String get playerErrorLoadingVideo;

  /// No description provided for @playerLoadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Loading video...'**
  String get playerLoadingVideo;

  /// No description provided for @playerFailedToLoadVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get playerFailedToLoadVideo;

  /// No description provided for @playerNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Video player not initialized'**
  String get playerNotInitialized;

  /// No description provided for @guidedExerciseCounter.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current}/{total}'**
  String guidedExerciseCounter(int current, int total);

  /// No description provided for @guidedGetReady.
  ///
  /// In en, this message translates to:
  /// **'GET READY'**
  String get guidedGetReady;

  /// No description provided for @guidedSetOf.
  ///
  /// In en, this message translates to:
  /// **'Set {current} of {total}'**
  String guidedSetOf(int current, int total);

  /// No description provided for @guidedRest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get guidedRest;

  /// No description provided for @guidedSkipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get guidedSkipRest;

  /// No description provided for @guidedPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get guidedPaused;

  /// No description provided for @guidedResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get guidedResume;

  /// No description provided for @guidedWorkoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get guidedWorkoutComplete;

  /// No description provided for @guidedEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End workout?'**
  String get guidedEndTitle;

  /// No description provided for @guidedEndBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress for this session will not be saved.'**
  String get guidedEndBody;

  /// No description provided for @guidedKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get guidedKeepGoing;

  /// No description provided for @guidedEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get guidedEnd;

  /// No description provided for @guidedReps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} rep} other{{count} reps}}'**
  String guidedReps(int count);

  /// No description provided for @generateSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Routine with AI'**
  String get generateSheetTitle;

  /// No description provided for @generateSheetPrompt.
  ///
  /// In en, this message translates to:
  /// **'What kind of workout do you want?'**
  String get generateSheetPrompt;

  /// No description provided for @generateSheetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"A quick morning stretch to wake up\" or \"Full body strength training for beginners\"'**
  String get generateSheetHint;

  /// No description provided for @generateSheetDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get generateSheetDuration;

  /// No description provided for @generateSheetMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String generateSheetMinutes(int count);

  /// No description provided for @generateSheetDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get generateSheetDifficulty;

  /// No description provided for @generateSheetEquipment.
  ///
  /// In en, this message translates to:
  /// **'Available Equipment'**
  String get generateSheetEquipment;

  /// No description provided for @generateSheetGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generateSheetGenerating;

  /// No description provided for @generateSheetSubmit.
  ///
  /// In en, this message translates to:
  /// **'Generate Routine'**
  String get generateSheetSubmit;

  /// No description provided for @generateSheetDescribeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please describe the workout you want'**
  String get generateSheetDescribeFirst;

  /// No description provided for @generateSheetAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'You already have this one: {title}'**
  String generateSheetAlreadyExists(String title);

  /// No description provided for @generateSheetCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {title}'**
  String generateSheetCreated(String title);

  /// No description provided for @generateSheetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate routine'**
  String get generateSheetFailed;

  /// No description provided for @guidedNoExercises.
  ///
  /// In en, this message translates to:
  /// **'This routine has no exercises yet.'**
  String get guidedNoExercises;

  /// No description provided for @guidedStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to start this workout right now. Please try again.'**
  String get guidedStartFailed;

  /// No description provided for @guidedSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this workout. Tap retry to update your streak.'**
  String get guidedSaveFailed;

  /// No description provided for @guidedOfReps.
  ///
  /// In en, this message translates to:
  /// **'of {count} reps'**
  String guidedOfReps(int count);

  /// No description provided for @guidedHold.
  ///
  /// In en, this message translates to:
  /// **'hold'**
  String get guidedHold;

  /// No description provided for @guidedNextSet.
  ///
  /// In en, this message translates to:
  /// **'Next set'**
  String get guidedNextSet;

  /// No description provided for @guidedUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get guidedUpNext;

  /// No description provided for @guidedSetsHold.
  ///
  /// In en, this message translates to:
  /// **'{sets} × {seconds}s hold'**
  String guidedSetsHold(int sets, int seconds);

  /// No description provided for @coachGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready. {exercise}'**
  String coachGetReady(String exercise);

  /// No description provided for @coachStartReps.
  ///
  /// In en, this message translates to:
  /// **'Go. {count} reps.'**
  String coachStartReps(int count);

  /// No description provided for @coachStartHold.
  ///
  /// In en, this message translates to:
  /// **'Hold for {seconds} seconds.'**
  String coachStartHold(int seconds);

  /// No description provided for @coachRest.
  ///
  /// In en, this message translates to:
  /// **'Rest. Next up: {exercise}'**
  String coachRest(String exercise);

  /// No description provided for @coachRestShort.
  ///
  /// In en, this message translates to:
  /// **'Rest.'**
  String get coachRestShort;

  /// No description provided for @coachComplete.
  ///
  /// In en, this message translates to:
  /// **'Great work. Workout complete.'**
  String get coachComplete;

  /// No description provided for @coachRep.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String coachRep(int count);

  /// No description provided for @coachCountdown.
  ///
  /// In en, this message translates to:
  /// **'{seconds}'**
  String coachCountdown(int seconds);

  /// No description provided for @playerNoVideosInRoutine.
  ///
  /// In en, this message translates to:
  /// **'No playable videos found in this routine.'**
  String get playerNoVideosInRoutine;

  /// No description provided for @playerLoadRoutineFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this routine right now. Please try again.'**
  String get playerLoadRoutineFailed;

  /// No description provided for @playerStepLoadFailedSkipping.
  ///
  /// In en, this message translates to:
  /// **'Failed to load \"{title}\". Skipping…'**
  String playerStepLoadFailedSkipping(String title);

  /// No description provided for @playerStepLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load \"{title}\".'**
  String playerStepLoadFailed(String title);

  /// No description provided for @playerSaveCompletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save completion. Tap retry to update your streak.'**
  String get playerSaveCompletionFailed;

  /// No description provided for @playerStepPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{duration} • Preview'**
  String playerStepPreviewSubtitle(String duration);

  /// No description provided for @playerNoVideosReady.
  ///
  /// In en, this message translates to:
  /// **'This routine has no videos ready to play yet.'**
  String get playerNoVideosReady;

  /// No description provided for @playerPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to play this video right now. Please try again.'**
  String get playerPlaybackFailed;

  /// No description provided for @libraryTabCurated.
  ///
  /// In en, this message translates to:
  /// **'Curated'**
  String get libraryTabCurated;

  /// No description provided for @libraryTabAiGenerated.
  ///
  /// In en, this message translates to:
  /// **'AI-Generated'**
  String get libraryTabAiGenerated;

  /// No description provided for @profileSavedRoutines.
  ///
  /// In en, this message translates to:
  /// **'Saved Routines'**
  String get profileSavedRoutines;

  /// No description provided for @savedRoutinesNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite routines yet.'**
  String get savedRoutinesNoFavorites;

  /// No description provided for @savedRoutinesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved routines yet.'**
  String get savedRoutinesEmpty;

  /// No description provided for @actionFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get actionFavorite;

  /// No description provided for @actionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get actionUnfavorite;

  /// No description provided for @routineDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String routineDurationMinutes(int minutes);

  /// No description provided for @routineDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String routineDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @routineDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String routineDurationHours(int hours);

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @categoryStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get categoryStrength;

  /// No description provided for @categoryCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get categoryCardio;

  /// No description provided for @categoryFlexibility.
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get categoryFlexibility;

  /// No description provided for @categoryMindfulness.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get categoryMindfulness;

  /// No description provided for @categoryDance.
  ///
  /// In en, this message translates to:
  /// **'Dance'**
  String get categoryDance;

  /// No description provided for @categoryHiit.
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get categoryHiit;

  /// No description provided for @categoryYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get categoryYoga;

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @equipmentNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get equipmentNone;

  /// No description provided for @equipmentDumbbells.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells'**
  String get equipmentDumbbells;

  /// No description provided for @equipmentResistanceBands.
  ///
  /// In en, this message translates to:
  /// **'Resistance Bands'**
  String get equipmentResistanceBands;

  /// No description provided for @equipmentYogaMat.
  ///
  /// In en, this message translates to:
  /// **'Yoga Mat'**
  String get equipmentYogaMat;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentPullUpBar.
  ///
  /// In en, this message translates to:
  /// **'Pull-up Bar'**
  String get equipmentPullUpBar;

  /// No description provided for @equipmentJumpRope.
  ///
  /// In en, this message translates to:
  /// **'Jump Rope'**
  String get equipmentJumpRope;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTitle;

  /// No description provided for @nutritionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calories, macros, and meal history'**
  String get nutritionSubtitle;

  /// No description provided for @nutritionSetGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your daily nutrition goals'**
  String get nutritionSetGoalsTitle;

  /// No description provided for @nutritionSetGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your weight, height, age, and gender so Celia can calculate how many calories and nutrients you should consume each day.'**
  String get nutritionSetGoalsBody;

  /// No description provided for @nutritionSetUpGoals.
  ///
  /// In en, this message translates to:
  /// **'Set Up Goals'**
  String get nutritionSetUpGoals;

  /// No description provided for @nutritionDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily target'**
  String get nutritionDailyTarget;

  /// No description provided for @nutritionDailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily goals'**
  String get nutritionDailyGoals;

  /// No description provided for @nutritionKcal.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String nutritionKcal(int calories);

  /// No description provided for @nutritionMacroSummary.
  ///
  /// In en, this message translates to:
  /// **'P {protein}g · C {carbs}g · F {fat}g'**
  String nutritionMacroSummary(int protein, int carbs, int fat);

  /// No description provided for @nutritionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get nutritionToday;

  /// No description provided for @nutritionMealHistory.
  ///
  /// In en, this message translates to:
  /// **'Meal History'**
  String get nutritionMealHistory;

  /// No description provided for @nutritionCeliaInsights.
  ///
  /// In en, this message translates to:
  /// **'Celia Insights'**
  String get nutritionCeliaInsights;

  /// No description provided for @nutritionWeeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Trend'**
  String get nutritionWeeklyTrend;

  /// No description provided for @nutritionTodayMeals.
  ///
  /// In en, this message translates to:
  /// **'kcal • {count, plural, one{{count} meal} other{{count} meals}}'**
  String nutritionTodayMeals(int count);

  /// No description provided for @nutritionTodayOfTargetMeals.
  ///
  /// In en, this message translates to:
  /// **'of {target} kcal • {count, plural, one{{count} meal} other{{count} meals}}'**
  String nutritionTodayOfTargetMeals(int target, int count);

  /// Single-letter weekday labels for the weekly chart, Monday first, comma separated.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get nutritionWeekdayInitials;

  /// No description provided for @nutritionFieldFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get nutritionFieldFoodName;

  /// No description provided for @nutritionFieldGrams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get nutritionFieldGrams;

  /// No description provided for @nutritionFieldCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutritionFieldCalories;

  /// No description provided for @scannerStatusAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'ANALYZING...'**
  String get scannerStatusAnalyzing;

  /// No description provided for @scannerStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'CELIA SCANNER'**
  String get scannerStatusIdle;

  /// No description provided for @scannerFieldFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get scannerFieldFoodName;

  /// No description provided for @scannerFieldGrams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get scannerFieldGrams;

  /// No description provided for @scannerFieldCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get scannerFieldCalories;

  /// No description provided for @scannerFieldPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get scannerFieldPro;

  /// No description provided for @scannerMacroPro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get scannerMacroPro;

  /// No description provided for @scannerMacroCarb.
  ///
  /// In en, this message translates to:
  /// **'CARB'**
  String get scannerMacroCarb;

  /// No description provided for @scannerMacroFat.
  ///
  /// In en, this message translates to:
  /// **'FAT'**
  String get scannerMacroFat;

  /// No description provided for @scannerRemainingAfterLogging.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal and {grams}g protein left today'**
  String scannerRemainingAfterLogging(int calories, int grams);

  /// No description provided for @scannerOverTargetAfterLogging.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal over your daily target'**
  String scannerOverTargetAfterLogging(int calories);

  /// No description provided for @scannerButtonAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get scannerButtonAnalyzing;

  /// No description provided for @scannerButtonQuotaNeeded.
  ///
  /// In en, this message translates to:
  /// **'Quota Needed'**
  String get scannerButtonQuotaNeeded;

  /// No description provided for @scannerButtonScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scannerButtonScanNow;

  /// No description provided for @scannerButtonLogging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get scannerButtonLogging;

  /// No description provided for @scannerButtonLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get scannerButtonLogMeal;

  /// No description provided for @scannerNoClearFood.
  ///
  /// In en, this message translates to:
  /// **'No clear food detected yet. Try better lighting or move closer.'**
  String get scannerNoClearFood;

  /// No description provided for @scannerErrorCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to scan meals.'**
  String get scannerErrorCameraPermission;

  /// No description provided for @scannerErrorBackendMissing.
  ///
  /// In en, this message translates to:
  /// **'Calorie scanner backend is not configured yet.'**
  String get scannerErrorBackendMissing;

  /// No description provided for @scannerErrorApiKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'The OpenAI API key for calorie scanning is invalid. Replace it in the backend environment, redeploy, then try again.'**
  String get scannerErrorApiKeyInvalid;

  /// No description provided for @scannerErrorApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API key is required for calorie scanning. Add it in Vercel, redeploy, then try again.'**
  String get scannerErrorApiKeyMissing;

  /// No description provided for @scannerErrorQuotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'OpenAI credits are exhausted for calorie scanning. Add API credits or raise the billing limit, then try again.'**
  String get scannerErrorQuotaExhausted;

  /// No description provided for @scannerErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Celia needed more time to analyze this meal. Hold the camera steady and scan again.'**
  String get scannerErrorTimeout;

  /// No description provided for @scannerErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in before scanning meals.'**
  String get scannerErrorNotSignedIn;

  /// No description provided for @scannerErrorMealTableMissing.
  ///
  /// In en, this message translates to:
  /// **'Meal logging table is not ready yet. The scan result is still available.'**
  String get scannerErrorMealTableMissing;

  /// No description provided for @scannerErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Celia could not analyze this meal yet. Hold the camera steady, keep the food centered, and scan again.'**
  String get scannerErrorGeneric;

  /// No description provided for @nutritionGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams}g'**
  String nutritionGrams(String grams);

  /// No description provided for @nutritionMealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{time} · {count, plural, one{{count} item} other{{count} items}}'**
  String nutritionMealSubtitle(String time, int count);

  /// No description provided for @nutritionMealDetails.
  ///
  /// In en, this message translates to:
  /// **'Meal Details'**
  String get nutritionMealDetails;

  /// No description provided for @nutritionFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Food Items'**
  String get nutritionFoodItems;

  /// No description provided for @nutritionItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{grams}g · {calories} kcal'**
  String nutritionItemSubtitle(int grams, int calories);

  /// No description provided for @nutritionNeedsOneItem.
  ///
  /// In en, this message translates to:
  /// **'A meal needs at least one food item.'**
  String get nutritionNeedsOneItem;

  /// No description provided for @nutritionMealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal updated'**
  String get nutritionMealUpdated;

  /// No description provided for @nutritionUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update meal: {error}'**
  String nutritionUpdateFailed(String error);

  /// No description provided for @nutritionDeleteMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete meal?'**
  String get nutritionDeleteMealTitle;

  /// No description provided for @nutritionDeleteMealBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the meal from your nutrition history.'**
  String get nutritionDeleteMealBody;

  /// No description provided for @nutritionDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get nutritionDeleteMeal;

  /// No description provided for @nutritionDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete meal: {error}'**
  String nutritionDeleteFailed(String error);

  /// No description provided for @nutritionEditFood.
  ///
  /// In en, this message translates to:
  /// **'Edit Food'**
  String get nutritionEditFood;

  /// No description provided for @nutritionSaveFood.
  ///
  /// In en, this message translates to:
  /// **'Save Food'**
  String get nutritionSaveFood;

  /// No description provided for @nutritionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load meals'**
  String get nutritionLoadFailed;

  /// No description provided for @nutritionLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or check the backend connection.'**
  String get nutritionLoadFailedBody;

  /// No description provided for @nutritionNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get nutritionNoMeals;

  /// No description provided for @nutritionNoMealsBody.
  ///
  /// In en, this message translates to:
  /// **'Scan your first meal and Celia will build your nutrition history.'**
  String get nutritionNoMealsBody;

  /// No description provided for @progressToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get progressToday;

  /// No description provided for @progressSetGoals.
  ///
  /// In en, this message translates to:
  /// **'Set your nutrition goals to unlock calorie and macro tracking.'**
  String get progressSetGoals;

  /// No description provided for @progressOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target} kcal'**
  String progressOfTarget(int target);

  /// No description provided for @progressMacroAmount.
  ///
  /// In en, this message translates to:
  /// **'{consumed} / {target}g'**
  String progressMacroAmount(int consumed, int target);

  /// No description provided for @progressKcalOver.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal over'**
  String progressKcalOver(int calories);

  /// No description provided for @progressKcalLeft.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal left'**
  String progressKcalLeft(int calories);

  /// No description provided for @progressProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get progressProtein;

  /// No description provided for @progressCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get progressCarbs;

  /// No description provided for @progressFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get progressFat;

  /// No description provided for @scannerEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Item'**
  String get scannerEditItem;

  /// No description provided for @scannerSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get scannerSaveChanges;

  /// No description provided for @scannerItemCalories.
  ///
  /// In en, this message translates to:
  /// **'{name} · {calories} kcal'**
  String scannerItemCalories(String name, int calories);

  /// No description provided for @scannerConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent}% · {provider}'**
  String scannerConfidence(int percent, String provider);

  /// No description provided for @scannerMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more items included in this meal log'**
  String scannerMoreItems(int count);

  /// No description provided for @scannerIfYouLog.
  ///
  /// In en, this message translates to:
  /// **'If you log this meal'**
  String get scannerIfYouLog;

  /// No description provided for @scannerAfterLogging.
  ///
  /// In en, this message translates to:
  /// **'{after} / {target} kcal today'**
  String scannerAfterLogging(int after, int target);

  /// No description provided for @scannerGramsDecimal.
  ///
  /// In en, this message translates to:
  /// **'{grams}g'**
  String scannerGramsDecimal(String grams);

  /// No description provided for @scannerItemServing.
  ///
  /// In en, this message translates to:
  /// **'{name} · {grams}g'**
  String scannerItemServing(String name, int grams);

  /// No description provided for @scannerNoMealDetected.
  ///
  /// In en, this message translates to:
  /// **'No meal detected'**
  String get scannerNoMealDetected;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String onboardingWelcome(String name);

  /// No description provided for @onboardingGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get onboardingGender;

  /// No description provided for @onboardingCalculateGoals.
  ///
  /// In en, this message translates to:
  /// **'Calculate My Goals'**
  String get onboardingCalculateGoals;

  /// No description provided for @onboardingScanFirstMeal.
  ///
  /// In en, this message translates to:
  /// **'Scan My First Meal'**
  String get onboardingScanFirstMeal;

  /// No description provided for @onboardingExploreRoutines.
  ///
  /// In en, this message translates to:
  /// **'Explore Routines'**
  String get onboardingExploreRoutines;

  /// No description provided for @onboardingGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get onboardingGoHome;

  /// No description provided for @onboardingDailyTargets.
  ///
  /// In en, this message translates to:
  /// **'Your daily targets'**
  String get onboardingDailyTargets;

  /// No description provided for @onboardingProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein {grams}g ·'**
  String onboardingProtein(int grams);

  /// No description provided for @onboardingMacroTargets.
  ///
  /// In en, this message translates to:
  /// **'Protein {protein}g • Carbs {carbs}g • Fat {fat}g'**
  String onboardingMacroTargets(int protein, int carbs, int fat);

  /// No description provided for @onboardingTargetsReady.
  ///
  /// In en, this message translates to:
  /// **'Your daily nutrition targets are ready. Choose how you want to start.'**
  String get onboardingTargetsReady;

  /// No description provided for @onboardingWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get onboardingWeightKg;

  /// No description provided for @onboardingHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get onboardingHeightCm;

  /// No description provided for @onboardingAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAge;

  /// No description provided for @onboardingInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight in kg.'**
  String get onboardingInvalidWeight;

  /// No description provided for @onboardingInvalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid height in cm.'**
  String get onboardingInvalidHeight;

  /// No description provided for @onboardingInvalidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age between 13 and 100.'**
  String get onboardingInvalidAge;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your nutrition profile.'**
  String get onboardingSaveFailed;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @nutritionSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition Goals'**
  String get nutritionSetupTitle;

  /// No description provided for @nutritionSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Tell Celia about your body so she can calculate your daily calories and macros.'**
  String get nutritionSetupBody;

  /// No description provided for @nutritionSetupGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get nutritionSetupGender;

  /// No description provided for @nutritionSetupFootnote.
  ///
  /// In en, this message translates to:
  /// **'Celia estimates daily calorie and macro targets from your weight, height, age, and gender using a moderate activity level. These are wellness estimates, not medical advice.'**
  String get nutritionSetupFootnote;

  /// No description provided for @nutritionSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'How these targets are calculated'**
  String get nutritionSourcesTitle;

  /// No description provided for @nutritionSourcesBody.
  ///
  /// In en, this message translates to:
  /// **'Daily calories use the Mifflin–St Jeor resting energy equation with a moderate physical activity factor (about 1.55). Protein is estimated near 1.8 g per kg body weight for active adults. Fat is set near 25% of calories, with carbs filling the remainder — within common dietary guidance ranges.'**
  String get nutritionSourcesBody;

  /// No description provided for @nutritionSourcesDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These figures are general wellness estimates only. They are not a diagnosis, prescription, or substitute for advice from a qualified clinician or registered dietitian.'**
  String get nutritionSourcesDisclaimer;

  /// No description provided for @nutritionSetupSave.
  ///
  /// In en, this message translates to:
  /// **'Save Goals'**
  String get nutritionSetupSave;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileCeliaAi.
  ///
  /// In en, this message translates to:
  /// **'Celia AI'**
  String get profileCeliaAi;

  /// No description provided for @profileEliteMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get profileEliteMember;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as:\n{email}'**
  String profileSignedInAs(String email);

  /// No description provided for @profileUnknownEmail.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileUnknownEmail;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileAvatarMode.
  ///
  /// In en, this message translates to:
  /// **'Avatar Mode'**
  String get profileAvatarMode;

  /// No description provided for @profileAvatarModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to Celia full-screen, hands-free'**
  String get profileAvatarModeSubtitle;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLogOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogOutTitle;

  /// No description provided for @profileLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogOutBody;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// No description provided for @profileLogOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOutButton;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get profileDeleteAccountConfirmTitle;

  /// No description provided for @profileDeleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all of your data, including saved routines, meal logs, and chat history. This can\'t be undone.'**
  String get profileDeleteAccountConfirmBody;

  /// No description provided for @profileDeleteAccountPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm.'**
  String get profileDeleteAccountPasswordPrompt;

  /// No description provided for @profileDeleteAccountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get profileDeleteAccountPasswordLabel;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get profileDeleteAccountButton;

  /// No description provided for @profileFavoriteRoutines.
  ///
  /// In en, this message translates to:
  /// **'Favorite Routines'**
  String get profileFavoriteRoutines;

  /// No description provided for @profileSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profileSubscription;

  /// No description provided for @profileNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get profileNutrition;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get profileFriend;

  /// No description provided for @profileStatSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileStatSaved;

  /// No description provided for @profileStatStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get profileStatStreak;

  /// No description provided for @profileStatWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get profileStatWorkouts;

  /// No description provided for @streakDayOneStarted.
  ///
  /// In en, this message translates to:
  /// **'Day 1 started — come back tomorrow to build your streak.'**
  String get streakDayOneStarted;

  /// No description provided for @streakRebuild.
  ///
  /// In en, this message translates to:
  /// **'You were active yesterday — log a meal or finish a workout today to rebuild your streak.'**
  String get streakRebuild;

  /// No description provided for @streakStart.
  ///
  /// In en, this message translates to:
  /// **'Log a meal or finish a workout to start your active streak.'**
  String get streakStart;

  /// No description provided for @streakLongRun.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak! Keep showing up — Celia is tracking your consistency.'**
  String streakLongRun(int days);

  /// No description provided for @streakBothLogged.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak — workout and nutrition both logged today.'**
  String streakBothLogged(int days);

  /// No description provided for @streakNeedWorkout.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak. A quick workout would round out today.'**
  String streakNeedWorkout(int days);

  /// No description provided for @streakNeedMeal.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak. Log a meal to track your fueling.'**
  String streakNeedMeal(int days);

  /// No description provided for @streakStayActive.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak — stay active today.'**
  String streakStayActive(int days);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileName;

  /// No description provided for @editProfileFootnote.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved to your account and will show on Home/Profile.'**
  String get editProfileFootnote;

  /// No description provided for @editProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile. Please try again.'**
  String get editProfileSaveFailed;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @languageSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the language your phone is set to'**
  String get languageSystemSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @insightStartFuelingTitle.
  ///
  /// In en, this message translates to:
  /// **'Start fueling today'**
  String get insightStartFuelingTitle;

  /// No description provided for @insightStartFuelingBody.
  ///
  /// In en, this message translates to:
  /// **'You have your full calorie budget left. Scan or log your first meal to stay on track.'**
  String get insightStartFuelingBody;

  /// No description provided for @insightAboveTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Above target today'**
  String get insightAboveTargetTitle;

  /// No description provided for @insightAboveTargetBody.
  ///
  /// In en, this message translates to:
  /// **'You are {calories} kcal above your daily target. Keep dinner lighter or add a short workout.'**
  String insightAboveTargetBody(int calories);

  /// No description provided for @insightLowProteinTitle.
  ///
  /// In en, this message translates to:
  /// **'Protein is still low'**
  String get insightLowProteinTitle;

  /// No description provided for @insightLowProteinBody.
  ///
  /// In en, this message translates to:
  /// **'You still need about {grams}g protein today to hit your target.'**
  String insightLowProteinBody(int grams);

  /// No description provided for @insightAlmostThereTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost at your goal'**
  String get insightAlmostThereTitle;

  /// No description provided for @insightAlmostThereBody.
  ///
  /// In en, this message translates to:
  /// **'You have {calories} kcal left today. A balanced snack should fit nicely.'**
  String insightAlmostThereBody(int calories);

  /// No description provided for @insightOnTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'On track today'**
  String get insightOnTrackTitle;

  /// No description provided for @insightOnTrackBody.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal and {grams}g protein left to reach your daily targets.'**
  String insightOnTrackBody(int calories, int grams);

  /// No description provided for @insightWeeklyRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your weekly rhythm'**
  String get insightWeeklyRhythmTitle;

  /// No description provided for @insightWeeklyRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'Log meals across the week so Celia can spot patterns and coach you better.'**
  String get insightWeeklyRhythmBody;

  /// No description provided for @insightWeeklyTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly trend'**
  String get insightWeeklyTrendTitle;

  /// No description provided for @insightWeeklyTrendBody.
  ///
  /// In en, this message translates to:
  /// **'You logged meals on {days} of the last 7 days, averaging {average} kcal — {direction}.'**
  String insightWeeklyTrendBody(int days, int average, String direction);

  /// No description provided for @insightTrendOnTarget.
  ///
  /// In en, this message translates to:
  /// **'right around your daily target'**
  String get insightTrendOnTarget;

  /// No description provided for @insightTrendAbove.
  ///
  /// In en, this message translates to:
  /// **'{delta} kcal above your target on average'**
  String insightTrendAbove(int delta);

  /// No description provided for @insightTrendBelow.
  ///
  /// In en, this message translates to:
  /// **'{delta} kcal below your target on average'**
  String insightTrendBelow(int delta);

  /// No description provided for @insightsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Celia Insights'**
  String get insightsSectionTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
