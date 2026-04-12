// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KaamSathi';

  @override
  String get tagline => 'Empowering Blue Collar India';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get languageName => 'English';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get continueBtn => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get goBack => 'Go Back';

  @override
  String get myProfile => 'My Profile';

  @override
  String get helperHome => 'Jobs matching your skills';

  @override
  String get employerHome => 'Helpers near you';

  @override
  String get selfHelp => 'Self Help';

  @override
  String get selfHelpSubtitle => 'Learn, grow, and know your rights';

  @override
  String get conversations => 'Conversations';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get roleHelper => 'I\'m looking for work';

  @override
  String get roleEmployer => 'I need to hire someone';

  @override
  String get chooseRole => 'How would you like to use KaamSathi?';

  @override
  String get completeSetup => 'Complete Setup';

  @override
  String get profileSetup => 'Set Up Your Profile';

  @override
  String get profileSetupSubtitle => 'Tell us about yourself and your skills';

  @override
  String get yourSkills => 'Your Skills';

  @override
  String get availability => 'Availability';

  @override
  String get fullTime => 'Full-time';

  @override
  String get hourly => 'Hourly';

  @override
  String get workCities => 'Work Cities';

  @override
  String get searchCity => 'Search and add a city';

  @override
  String get noHelpersFound => 'No helpers found';

  @override
  String get noEmployersFound => 'No employers found matching your skills';

  @override
  String get contactBtn => 'Contact';

  @override
  String get phonePrivate => 'Your phone number is always kept private';

  @override
  String get changeRole => 'Change Role';

  @override
  String get chooseRoleSubtitle => 'Choose your role to get started';

  @override
  String get roleHelperSubtitle => 'Browse jobs, apply, and get hired';

  @override
  String get roleEmployerSubtitle => 'Post jobs and find skilled workers';

  @override
  String get categoryRightsAtWork => 'Your Rights at Work';

  @override
  String get categoryMoneySavings => 'Money & Savings';

  @override
  String get categoryInsurance => 'Insurance Made Simple';

  @override
  String get categoryGovernmentSchemes => 'Government Schemes for You';

  @override
  String get quizNext => 'Next';

  @override
  String get quizSeeResult => 'See Result';

  @override
  String get quizContinueLearn => 'Continue to Learn';

  @override
  String get quizGreatJob => 'Great job!';

  @override
  String get quizGoodEffort => 'Good effort!';

  @override
  String get quizPassMessage =>
      'You already know this topic well! Keep reading to learn even more.';

  @override
  String get quizFailMessage =>
      'No worries — the content below will help you understand step by step.';

  @override
  String quizScore(int score, int total) {
    return 'You got $score out of $total right.';
  }

  @override
  String get loginWelcome => 'Welcome!';

  @override
  String get loginPhoneSubtitle => 'Enter your phone number to get started';

  @override
  String get keepSignedIn => 'Keep me signed in';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get loginOr => 'or';

  @override
  String get useEmailInstead => 'Use email instead';

  @override
  String get invalidPhoneNumber => 'Enter a valid 10-digit number';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get enterVerificationCode => 'Enter Verification Code';

  @override
  String get otpSentMessage => 'We sent a 6-digit code to your phone number';

  @override
  String get sending => 'Sending...';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get otpResentSuccess => 'OTP resent successfully';

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code';

  @override
  String get emailLogin => 'Email Login';

  @override
  String get emailLoginSubtitle => 'Sign in or create an account';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Re-enter Password';

  @override
  String get continueButton => 'Continue';

  @override
  String get invalidEmailPassword =>
      'Enter valid email and password (min 6 chars)';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get checkYourInbox => 'Check Your Inbox';

  @override
  String get emailVerificationSent =>
      'We\'ve sent a verification link to your email address. Please click the link to verify, then tap Continue.';

  @override
  String get checkSpamFolder =>
      'Check your spam folder if you don\'t see the email';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get emailNotVerified => 'Email not verified yet. Check your inbox.';

  @override
  String get verificationEmailResent => 'Verification email resent';

  @override
  String get fullNameHint => 'Your full name';

  @override
  String get selectStateHint => 'Select your state';

  @override
  String get addCustomSkillHint => 'Add a custom skill';

  @override
  String get yearsOfExperienceHint => 'Years of experience';

  @override
  String get hoursPerDayHint => 'Hours per day (e.g. 4)';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get inappropriateName => 'Please enter an appropriate name';

  @override
  String get stateRequired => 'Please select your state';

  @override
  String get citiesRequired => 'Add at least one city';

  @override
  String get experienceRequired => 'Please enter years of experience';

  @override
  String get experienceRange => 'Enter a number between 0 and 50';

  @override
  String get hoursRequired => 'Please enter hours per day';

  @override
  String get hoursRange => 'Enter a number between 1 and 24';

  @override
  String get skillsRequired => 'Please select at least one skill';

  @override
  String get skillAlreadyExists => 'Skill already added';

  @override
  String get confirmYourSkills => 'Confirm Your Skills';

  @override
  String get selectedSkillsLabel => 'You have selected the following skills:';

  @override
  String get skillsLockedWarning => 'Skills cannot be changed after setup.';

  @override
  String get citiesYouCanWorkIn => 'Cities you can work in';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get failedToSave => 'Failed to save. Please try again.';

  @override
  String get sectionAccount => 'ACCOUNT';

  @override
  String get labelFullName => 'Full Name';

  @override
  String get sectionLocation => 'LOCATION';

  @override
  String get labelState => 'State';

  @override
  String get sectionSkills => 'SKILLS';

  @override
  String get sectionExperience => 'EXPERIENCE';

  @override
  String get labelExperience => 'Experience';

  @override
  String get yearSingular => 'year';

  @override
  String get yearPlural => 'years';

  @override
  String get sectionAvailability => 'AVAILABILITY';

  @override
  String get sectionWorkCities => 'WORK CITIES';

  @override
  String get labelSchedule => 'Schedule';

  @override
  String get labelHoursPerDay => 'Hours/day';

  @override
  String get hoursAbbreviation => 'hrs';
}
