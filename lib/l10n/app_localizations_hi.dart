// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'कामसाथी';

  @override
  String get tagline => 'ब्लू कॉलर भारत को सशक्त बनाना';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get languageName => 'हिंदी';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get continueBtn => 'जारी रखें';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get goBack => 'वापस जाएं';

  @override
  String get myProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get helperHome => 'आपके कौशल से मेल खाती नौकरियाँ';

  @override
  String get employerHome => 'आपके पास के सहायक';

  @override
  String get selfHelp => 'सेल्फ हेल्प';

  @override
  String get selfHelpSubtitle => 'सीखें, बढ़ें और अपने अधिकार जानें';

  @override
  String get conversations => 'बातचीत';

  @override
  String get noConversations => 'अभी तक कोई बातचीत नहीं';

  @override
  String get roleHelper => 'मुझे काम चाहिए';

  @override
  String get roleEmployer => 'मुझे मदद चाहिए';

  @override
  String get chooseRole => 'आप कामसाथी का उपयोग कैसे करना चाहते हैं?';

  @override
  String get completeSetup => 'सेटअप पूरा करें';

  @override
  String get profileSetup => 'अपनी प्रोफ़ाइल बनाएं';

  @override
  String get profileSetupSubtitle =>
      'अपने बारे में और अपने कौशल के बारे में बताएं';

  @override
  String get yourSkills => 'आपके कौशल';

  @override
  String get availability => 'उपलब्धता';

  @override
  String get fullTime => 'पूर्णकालिक';

  @override
  String get hourly => 'प्रति घंटा';

  @override
  String get workCities => 'काम के शहर';

  @override
  String get searchCity => 'शहर खोजें और जोड़ें';

  @override
  String get noHelpersFound => 'कोई सहायक नहीं मिला';

  @override
  String get noEmployersFound =>
      'आपके काम से मेल खाता कोई काम देने वाला नहीं मिला';

  @override
  String get contactBtn => 'संपर्क करें';

  @override
  String get phonePrivate => 'आपका फोन नंबर हमेशा निजी रहता है';

  @override
  String get changeRole => 'अकाउंट बदलें';

  @override
  String get chooseRoleSubtitle => 'शुरू करने के लिए अपनी भूमिका चुनें';

  @override
  String get roleHelperSubtitle => 'नौकरियाँ देखें, आवेदन करें और काम पाएं';

  @override
  String get roleEmployerSubtitle =>
      'काम देने वाले बनें और कुशल लोगों को खोजें';

  @override
  String get categoryRightsAtWork => 'काम पर आपके अधिकार';

  @override
  String get categoryMoneySavings => 'पैसे और बचत';

  @override
  String get categoryInsurance => 'बीमा आसान भाषा में';

  @override
  String get categoryGovernmentSchemes => 'आपके लिए सरकारी योजनाएं';

  @override
  String get quizNext => 'आगे';

  @override
  String get quizSeeResult => 'नतीजा देखें';

  @override
  String get quizContinueLearn => 'पढ़ना जारी रखें';

  @override
  String get quizGreatJob => 'शाबाश!';

  @override
  String get quizGoodEffort => 'अच्छी कोशिश!';

  @override
  String get quizPassMessage =>
      'आप यह विषय पहले से अच्छी तरह जानते हैं! और ज़्यादा सीखने के लिए पढ़ते रहें।';

  @override
  String get quizFailMessage =>
      'कोई बात नहीं — नीचे दी गई जानकारी आपको कदम-दर-कदम समझने में मदद करेगी।';

  @override
  String quizScore(int score, int total) {
    return '$score में से $total सही जवाब दिए।';
  }

  @override
  String get loginWelcome => 'स्वागत है!';

  @override
  String get loginPhoneSubtitle => 'शुरू करने के लिए अपना फोन नंबर दर्ज करें';

  @override
  String get keepSignedIn => 'मुझे साइन इन रखें';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get loginOr => 'या';

  @override
  String get useEmailInstead => 'इसके बजाय ईमेल से लॉगिन करें';

  @override
  String get invalidPhoneNumber => 'कृपया 10 अंकों का सही नंबर दर्ज करें';

  @override
  String get verifyOtp => 'OTP सत्यापित करें';

  @override
  String get enterVerificationCode => 'सत्यापन कोड दर्ज करें';

  @override
  String get otpSentMessage => 'हमने आपके फोन नंबर पर 6 अंकों का कोड भेजा है';

  @override
  String get sending => 'भेजा जा रहा है...';

  @override
  String resendIn(int seconds) {
    return '$seconds सेकंड में दोबारा भेजें';
  }

  @override
  String get resendCode => 'कोड दोबारा भेजें';

  @override
  String get otpResentSuccess => 'OTP सफलतापूर्वक भेजा गया';

  @override
  String get enterSixDigitCode => '6 अंकों का कोड दर्ज करें';

  @override
  String get emailLogin => 'ईमेल लॉगिन';

  @override
  String get emailLoginSubtitle => 'साइन इन करें या नया खाता बनाएं';

  @override
  String get passwordHint => 'पासवर्ड';

  @override
  String get confirmPasswordHint => 'पासवर्ड दोबारा दर्ज करें';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get invalidEmailPassword =>
      'कृपया सही ईमेल और पासवर्ड दर्ज करें (कम से कम 6 अक्षर)';

  @override
  String get passwordsMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get verifyEmail => 'ईमेल सत्यापित करें';

  @override
  String get checkYourInbox => 'अपना इनबॉक्स देखें';

  @override
  String get emailVerificationSent =>
      'हमने आपके ईमेल पर एक सत्यापन लिंक भेजा है। लिंक पर क्लिक करके सत्यापित करें, फिर जारी रखें टैप करें।';

  @override
  String get checkSpamFolder => 'अगर ईमेल न मिले तो स्पैम फ़ोल्डर देखें';

  @override
  String get resendEmail => 'ईमेल दोबारा भेजें';

  @override
  String get emailNotVerified =>
      'ईमेल अभी सत्यापित नहीं हुआ। कृपया अपना इनबॉक्स देखें।';

  @override
  String get verificationEmailResent => 'सत्यापन ईमेल दोबारा भेजा गया';

  @override
  String get fullNameHint => 'आपका पूरा नाम';

  @override
  String get selectStateHint => 'अपना राज्य चुनें';

  @override
  String get addCustomSkillHint => 'कोई नया काम जोड़ें';

  @override
  String get yearsOfExperienceHint => 'अनुभव के वर्ष';

  @override
  String get hoursPerDayHint => 'प्रति दिन घंटे (जैसे 4)';

  @override
  String get nameRequired => 'नाम ज़रूरी है';

  @override
  String get inappropriateName => 'कृपया सही नाम दर्ज करें';

  @override
  String get stateRequired => 'कृपया अपना राज्य चुनें';

  @override
  String get citiesRequired => 'कम से कम एक शहर जोड़ें';

  @override
  String get experienceRequired => 'कृपया अनुभव के वर्ष दर्ज करें';

  @override
  String get experienceRange => '0 से 50 के बीच संख्या दर्ज करें';

  @override
  String get hoursRequired => 'कृपया प्रति दिन घंटे दर्ज करें';

  @override
  String get hoursRange => '1 से 24 के बीच संख्या दर्ज करें';

  @override
  String get skillsRequired => 'कम से कम एक काम चुनें';

  @override
  String get skillAlreadyExists => 'यह काम पहले से जोड़ा जा चुका है';

  @override
  String get confirmYourSkills => 'अपने कामों की पुष्टि करें';

  @override
  String get selectedSkillsLabel => 'आपने ये काम चुने हैं:';

  @override
  String get skillsLockedWarning => 'सेटअप के बाद काम नहीं बदले जा सकते।';

  @override
  String get citiesYouCanWorkIn => 'जिन शहरों में काम कर सकते हैं';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया। कृपया दोबारा कोशिश करें।';

  @override
  String get failedToSave => 'सेव नहीं हुआ। कृपया दोबारा कोशिश करें।';

  @override
  String get sectionAccount => 'खाता';

  @override
  String get labelFullName => 'पूरा नाम';

  @override
  String get sectionLocation => 'स्थान';

  @override
  String get labelState => 'राज्य';

  @override
  String get sectionSkills => 'काम';

  @override
  String get sectionExperience => 'अनुभव';

  @override
  String get labelExperience => 'अनुभव';

  @override
  String get yearSingular => 'वर्ष';

  @override
  String get yearPlural => 'वर्ष';

  @override
  String get sectionAvailability => 'उपलब्धता';

  @override
  String get sectionWorkCities => 'काम के शहर';

  @override
  String get labelSchedule => 'शेड्यूल';

  @override
  String get labelHoursPerDay => 'घंटे/दिन';

  @override
  String get hoursAbbreviation => 'घं.';
}
