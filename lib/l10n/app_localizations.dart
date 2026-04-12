import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ne.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('ne'),
  ];

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'KaamSathi'**
  String get appName;

  /// Splash screen tagline
  ///
  /// In en, this message translates to:
  /// **'Empowering Blue Collar India'**
  String get tagline;

  /// Language selection screen title
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// Name of this language in its own script
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @helperHome.
  ///
  /// In en, this message translates to:
  /// **'Jobs matching your skills'**
  String get helperHome;

  /// No description provided for @employerHome.
  ///
  /// In en, this message translates to:
  /// **'Helpers near you'**
  String get employerHome;

  /// No description provided for @selfHelp.
  ///
  /// In en, this message translates to:
  /// **'Self Help'**
  String get selfHelp;

  /// No description provided for @selfHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn, grow, and know your rights'**
  String get selfHelpSubtitle;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @roleHelper.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for work'**
  String get roleHelper;

  /// No description provided for @roleEmployer.
  ///
  /// In en, this message translates to:
  /// **'I need to hire someone'**
  String get roleEmployer;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use KaamSathi?'**
  String get chooseRole;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get profileSetup;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself and your skills'**
  String get profileSetupSubtitle;

  /// No description provided for @yourSkills.
  ///
  /// In en, this message translates to:
  /// **'Your Skills'**
  String get yourSkills;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @fullTime.
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get fullTime;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @workCities.
  ///
  /// In en, this message translates to:
  /// **'Work Cities'**
  String get workCities;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search and add a city'**
  String get searchCity;

  /// No description provided for @noHelpersFound.
  ///
  /// In en, this message translates to:
  /// **'No helpers found'**
  String get noHelpersFound;

  /// No description provided for @noEmployersFound.
  ///
  /// In en, this message translates to:
  /// **'No employers found matching your skills'**
  String get noEmployersFound;

  /// No description provided for @contactBtn.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactBtn;

  /// No description provided for @phonePrivate.
  ///
  /// In en, this message translates to:
  /// **'Your phone number is always kept private'**
  String get phonePrivate;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRole;

  /// No description provided for @chooseRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to get started'**
  String get chooseRoleSubtitle;

  /// No description provided for @roleHelperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse jobs, apply, and get hired'**
  String get roleHelperSubtitle;

  /// No description provided for @roleEmployerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post jobs and find skilled workers'**
  String get roleEmployerSubtitle;

  /// No description provided for @categoryRightsAtWork.
  ///
  /// In en, this message translates to:
  /// **'Your Rights at Work'**
  String get categoryRightsAtWork;

  /// No description provided for @categoryMoneySavings.
  ///
  /// In en, this message translates to:
  /// **'Money & Savings'**
  String get categoryMoneySavings;

  /// No description provided for @categoryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance Made Simple'**
  String get categoryInsurance;

  /// No description provided for @categoryGovernmentSchemes.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes for You'**
  String get categoryGovernmentSchemes;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizSeeResult.
  ///
  /// In en, this message translates to:
  /// **'See Result'**
  String get quizSeeResult;

  /// No description provided for @quizContinueLearn.
  ///
  /// In en, this message translates to:
  /// **'Continue to Learn'**
  String get quizContinueLearn;

  /// No description provided for @quizGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get quizGreatJob;

  /// No description provided for @quizGoodEffort.
  ///
  /// In en, this message translates to:
  /// **'Good effort!'**
  String get quizGoodEffort;

  /// No description provided for @quizPassMessage.
  ///
  /// In en, this message translates to:
  /// **'You already know this topic well! Keep reading to learn even more.'**
  String get quizPassMessage;

  /// No description provided for @quizFailMessage.
  ///
  /// In en, this message translates to:
  /// **'No worries — the content below will help you understand step by step.'**
  String get quizFailMessage;

  /// Quiz score display
  ///
  /// In en, this message translates to:
  /// **'You got {score} out of {total} right.'**
  String quizScore(int score, int total);

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginWelcome;

  /// No description provided for @loginPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to get started'**
  String get loginPhoneSubtitle;

  /// No description provided for @keepSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get keepSignedIn;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @useEmailInstead.
  ///
  /// In en, this message translates to:
  /// **'Use email instead'**
  String get useEmailInstead;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit number'**
  String get invalidPhoneNumber;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your phone number'**
  String get otpSentMessage;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// Resend countdown button label
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @otpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccess;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterSixDigitCode;

  /// No description provided for @emailLogin.
  ///
  /// In en, this message translates to:
  /// **'Email Login'**
  String get emailLogin;

  /// No description provided for @emailLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account'**
  String get emailLoginSubtitle;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter Password'**
  String get confirmPasswordHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @invalidEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email and password (min 6 chars)'**
  String get invalidEmailPassword;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check Your Inbox'**
  String get checkYourInbox;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to your email address. Please click the link to verify, then tap Continue.'**
  String get emailVerificationSent;

  /// No description provided for @checkSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder if you don\'t see the email'**
  String get checkSpamFolder;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Check your inbox.'**
  String get emailNotVerified;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get verificationEmailResent;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHint;

  /// No description provided for @selectStateHint.
  ///
  /// In en, this message translates to:
  /// **'Select your state'**
  String get selectStateHint;

  /// No description provided for @addCustomSkillHint.
  ///
  /// In en, this message translates to:
  /// **'Add a custom skill'**
  String get addCustomSkillHint;

  /// No description provided for @yearsOfExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsOfExperienceHint;

  /// No description provided for @hoursPerDayHint.
  ///
  /// In en, this message translates to:
  /// **'Hours per day (e.g. 4)'**
  String get hoursPerDayHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @inappropriateName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an appropriate name'**
  String get inappropriateName;

  /// No description provided for @stateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your state'**
  String get stateRequired;

  /// No description provided for @citiesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one city'**
  String get citiesRequired;

  /// No description provided for @experienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter years of experience'**
  String get experienceRequired;

  /// No description provided for @experienceRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 0 and 50'**
  String get experienceRange;

  /// No description provided for @hoursRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter hours per day'**
  String get hoursRequired;

  /// No description provided for @hoursRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and 24'**
  String get hoursRange;

  /// No description provided for @skillsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one skill'**
  String get skillsRequired;

  /// No description provided for @skillAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Skill already added'**
  String get skillAlreadyExists;

  /// No description provided for @confirmYourSkills.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Skills'**
  String get confirmYourSkills;

  /// No description provided for @selectedSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'You have selected the following skills:'**
  String get selectedSkillsLabel;

  /// No description provided for @skillsLockedWarning.
  ///
  /// In en, this message translates to:
  /// **'Skills cannot be changed after setup.'**
  String get skillsLockedWarning;

  /// No description provided for @citiesYouCanWorkIn.
  ///
  /// In en, this message translates to:
  /// **'Cities you can work in'**
  String get citiesYouCanWorkIn;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get failedToSave;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get sectionAccount;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// No description provided for @sectionLocation.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get sectionLocation;

  /// No description provided for @labelState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get labelState;

  /// No description provided for @sectionSkills.
  ///
  /// In en, this message translates to:
  /// **'SKILLS'**
  String get sectionSkills;

  /// No description provided for @sectionExperience.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE'**
  String get sectionExperience;

  /// No description provided for @labelExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get labelExperience;

  /// No description provided for @yearSingular.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get yearSingular;

  /// No description provided for @yearPlural.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get yearPlural;

  /// No description provided for @sectionAvailability.
  ///
  /// In en, this message translates to:
  /// **'AVAILABILITY'**
  String get sectionAvailability;

  /// No description provided for @sectionWorkCities.
  ///
  /// In en, this message translates to:
  /// **'WORK CITIES'**
  String get sectionWorkCities;

  /// No description provided for @labelSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get labelSchedule;

  /// No description provided for @labelHoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Hours/day'**
  String get labelHoursPerDay;

  /// No description provided for @hoursAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hoursAbbreviation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
