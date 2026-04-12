// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'কামসাথী';

  @override
  String get tagline => 'ব্লু কলার ভারতকে এগিয়ে নিয়ে যাওয়া';

  @override
  String get chooseLanguage => 'আপনার ভাষা বেছে নিন';

  @override
  String get languageName => 'বাংলা';

  @override
  String get signIn => 'সাইন ইন করুন';

  @override
  String get signOut => 'সাইন আউট করুন';

  @override
  String get continueBtn => 'চালিয়ে যান';

  @override
  String get save => 'সেভ করুন';

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get confirm => 'ঠিক আছে';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get myProfile => 'আমার প্রোফাইল';

  @override
  String get helperHome => 'আপনার কাজ অনুযায়ী চাকরি';

  @override
  String get employerHome => 'আপনার কাছের কাজের লোক';

  @override
  String get selfHelp => 'সেলফ হেল্প';

  @override
  String get selfHelpSubtitle => 'শিখুন, বাড়ুন এবং আপনার অধিকার জানুন';

  @override
  String get conversations => 'চ্যাট';

  @override
  String get noConversations => 'এখনও কোনো চ্যাট নেই';

  @override
  String get roleHelper => 'আমি কাজ খুঁজছি';

  @override
  String get roleEmployer => 'আমার সাহায্য দরকার';

  @override
  String get chooseRole => 'আপনি কীভাবে কামসাথী ব্যবহার করতে চান?';

  @override
  String get completeSetup => 'সেটআপ শেষ করুন';

  @override
  String get profileSetup => 'আপনার প্রোফাইল তৈরি করুন';

  @override
  String get profileSetupSubtitle => 'নিজের ও কাজের কথা জানান';

  @override
  String get yourSkills => 'আপনার দক্ষতা';

  @override
  String get availability => 'কাজের সময়';

  @override
  String get fullTime => 'পূর্ণ সময়';

  @override
  String get hourly => 'প্রতি ঘণ্টা';

  @override
  String get workCities => 'কাজের শহর';

  @override
  String get searchCity => 'শহর খুঁজুন এবং যোগ করুন';

  @override
  String get noHelpersFound => 'কেউ পাওয়া যায়নি';

  @override
  String get noEmployersFound => 'আপনার কাজের সাথে মেলে এমন কেউ পাওয়া যায়নি';

  @override
  String get contactBtn => 'যোগাযোগ করুন';

  @override
  String get phonePrivate => 'আপনার ফোন নম্বর সবসময় গোপন থাকে';

  @override
  String get changeRole => 'অ্যাকাউন্ট বদলান';

  @override
  String get chooseRoleSubtitle => 'শুরু করতে আপনার ভূমিকা বেছে নিন';

  @override
  String get roleHelperSubtitle => 'কাজ দেখুন, আবেদন করুন এবং কাজ পান';

  @override
  String get roleEmployerSubtitle => 'কাজ দিন এবং দক্ষ লোক খুঁজুন';

  @override
  String get categoryRightsAtWork => 'কাজে আপনার অধিকার';

  @override
  String get categoryMoneySavings => 'টাকা ও সঞ্চয়';

  @override
  String get categoryInsurance => 'বীমা সহজ ভাষায়';

  @override
  String get categoryGovernmentSchemes => 'আপনার জন্য সরকারি প্রকল্প';

  @override
  String get quizNext => 'পরের প্রশ্ন';

  @override
  String get quizSeeResult => 'ফল দেখুন';

  @override
  String get quizContinueLearn => 'পড়তে থাকুন';

  @override
  String get quizGreatJob => 'দারুণ!';

  @override
  String get quizGoodEffort => 'ভালো চেষ্টা!';

  @override
  String get quizPassMessage =>
      'আপনি এই বিষয়টি আগে থেকেই ভালো জানেন! আরও জানতে পড়তে থাকুন।';

  @override
  String get quizFailMessage =>
      'চিন্তা নেই — নিচের তথ্য আপনাকে ধাপে ধাপে বুঝতে সাহায্য করবে।';

  @override
  String quizScore(int score, int total) {
    return '$total এর মধ্যে $scoreটি সঠিক উত্তর দিয়েছেন।';
  }

  @override
  String get loginWelcome => 'স্বাগতম!';

  @override
  String get loginPhoneSubtitle => 'শুরু করতে আপনার ফোন নম্বর দিন';

  @override
  String get keepSignedIn => 'সাইন ইন রাখুন';

  @override
  String get sendOtp => 'OTP পাঠান';

  @override
  String get loginOr => 'অথবা';

  @override
  String get useEmailInstead => 'পরিবর্তে ইমেল ব্যবহার করুন';

  @override
  String get invalidPhoneNumber => 'সঠিক ১০ সংখ্যার নম্বর দিন';

  @override
  String get verifyOtp => 'OTP যাচাই করুন';

  @override
  String get enterVerificationCode => 'যাচাই কোড দিন';

  @override
  String get otpSentMessage => 'আপনার ফোন নম্বরে ৬ সংখ্যার কোড পাঠানো হয়েছে';

  @override
  String get sending => 'পাঠানো হচ্ছে...';

  @override
  String resendIn(int seconds) {
    return '$seconds সেকেন্ডে আবার পাঠান';
  }

  @override
  String get resendCode => 'কোড আবার পাঠান';

  @override
  String get otpResentSuccess => 'OTP সফলভাবে পাঠানো হয়েছে';

  @override
  String get enterSixDigitCode => '৬ সংখ্যার কোড দিন';

  @override
  String get emailLogin => 'ইমেল লগইন';

  @override
  String get emailLoginSubtitle => 'সাইন ইন করুন বা নতুন অ্যাকাউন্ট তৈরি করুন';

  @override
  String get passwordHint => 'পাসওয়ার্ড';

  @override
  String get confirmPasswordHint => 'পাসওয়ার্ড আবার দিন';

  @override
  String get continueButton => 'চালিয়ে যান';

  @override
  String get invalidEmailPassword =>
      'সঠিক ইমেল ও পাসওয়ার্ড দিন (কমপক্ষে ৬ অক্ষর)';

  @override
  String get passwordsMismatch => 'পাসওয়ার্ড মিলছে না';

  @override
  String get verifyEmail => 'ইমেল যাচাই করুন';

  @override
  String get checkYourInbox => 'আপনার ইনবক্স দেখুন';

  @override
  String get emailVerificationSent =>
      'আমরা আপনার ইমেলে একটি যাচাই লিংক পাঠিয়েছি। লিংকে ক্লিক করে যাচাই করুন, তারপর চালিয়ে যান ট্যাপ করুন।';

  @override
  String get checkSpamFolder => 'ইমেল না পেলে স্প্যাম ফোল্ডার দেখুন';

  @override
  String get resendEmail => 'ইমেল আবার পাঠান';

  @override
  String get emailNotVerified => 'ইমেল এখনও যাচাই হয়নি। আপনার ইনবক্স দেখুন।';

  @override
  String get verificationEmailResent => 'যাচাই ইমেল আবার পাঠানো হয়েছে';

  @override
  String get fullNameHint => 'আপনার পুরো নাম';

  @override
  String get selectStateHint => 'আপনার রাজ্য বেছে নিন';

  @override
  String get addCustomSkillHint => 'নতুন কাজ যোগ করুন';

  @override
  String get yearsOfExperienceHint => 'অভিজ্ঞতার বছর';

  @override
  String get hoursPerDayHint => 'প্রতিদিন ঘণ্টা (যেমন ৪)';

  @override
  String get nameRequired => 'নাম দেওয়া আবশ্যক';

  @override
  String get inappropriateName => 'সঠিক নাম দিন';

  @override
  String get stateRequired => 'আপনার রাজ্য বেছে নিন';

  @override
  String get citiesRequired => 'অন্তত একটি শহর যোগ করুন';

  @override
  String get experienceRequired => 'অভিজ্ঞতার বছর দিন';

  @override
  String get experienceRange => '০ থেকে ৫০-এর মধ্যে সংখ্যা দিন';

  @override
  String get hoursRequired => 'প্রতিদিন ঘণ্টা দিন';

  @override
  String get hoursRange => '১ থেকে ২৪-এর মধ্যে সংখ্যা দিন';

  @override
  String get skillsRequired => 'অন্তত একটি কাজ বেছে নিন';

  @override
  String get skillAlreadyExists => 'এই কাজটি আগেই যোগ করা হয়েছে';

  @override
  String get confirmYourSkills => 'আপনার কাজ নিশ্চিত করুন';

  @override
  String get selectedSkillsLabel => 'আপনি এই কাজগুলো বেছেছেন:';

  @override
  String get skillsLockedWarning => 'সেটআপের পরে কাজ পরিবর্তন করা যাবে না।';

  @override
  String get citiesYouCanWorkIn => 'যেসব শহরে কাজ করতে পারবেন';

  @override
  String get somethingWentWrong => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get failedToSave => 'সেভ হয়নি। আবার চেষ্টা করুন।';

  @override
  String get sectionAccount => 'অ্যাকাউন্ট';

  @override
  String get labelFullName => 'পুরো নাম';

  @override
  String get sectionLocation => 'অবস্থান';

  @override
  String get labelState => 'রাজ্য';

  @override
  String get sectionSkills => 'কাজ';

  @override
  String get sectionExperience => 'অভিজ্ঞতা';

  @override
  String get labelExperience => 'অভিজ্ঞতা';

  @override
  String get yearSingular => 'বছর';

  @override
  String get yearPlural => 'বছর';

  @override
  String get sectionAvailability => 'কাজের সময়';

  @override
  String get sectionWorkCities => 'কাজের শহর';

  @override
  String get labelSchedule => 'সময়সূচি';

  @override
  String get labelHoursPerDay => 'ঘণ্টা/দিন';

  @override
  String get hoursAbbreviation => 'ঘ.';
}
