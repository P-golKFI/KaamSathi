import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/email_login_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/helper_home_screen.dart';
import 'screens/employer_shell_screen.dart';
import 'screens/employer_profile_setup_screen.dart';
import 'screens/helper_profile_setup_screen.dart';
import 'screens/helper_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/conversation_list_screen.dart';
import 'screens/self_help_screen.dart';
import 'screens/self_help_detail_screen.dart';
import 'screens/self_help_quiz_screen.dart';
import 'screens/rights_at_work_content_screen.dart';
import 'screens/money_savings_content_screen.dart';
import 'screens/insurance_content_screen.dart';
import 'screens/add_phone_screen.dart';
import 'screens/avatar_selection_screen.dart';
import 'screens/employer_profile_screen.dart';
import 'screens/helper_profile_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/government_schemes_content_screen.dart';
import 'screens/aadhaar_verification_screen.dart';

class KaamSathiApp extends StatelessWidget {
  const KaamSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch LocaleProvider — whenever the user changes language, MaterialApp
    // rebuilds with the new locale and all strings update instantly.
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      title: 'KaamSathi',
      debugShowCheckedModeBanner: false,

      // --- Localisation setup ---
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,          // our own .arb strings
        GlobalMaterialLocalizations.delegate, // Material widget strings (OK, Cancel, etc.)
        GlobalWidgetsLocalizations.delegate,  // text direction (LTR/RTL)
        GlobalCupertinoLocalizations.delegate,// iOS-style widget strings
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1A3A5C),
          onPrimary: Colors.white,
          secondary: Color(0xFF00BCD4),
          onSecondary: Colors.white,
          tertiary: Color(0xFFF5A623),
          onTertiary: Colors.white,
          error: Color(0xFFB00020),
          onError: Colors.white,
          surface: Color(0xFFF5F5F0),
          onSurface: Color(0xFF1A3A5C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (_) => const SplashScreen(),
        '/language-selection': (_) => const LanguageSelectionScreen(),
        '/phone-login': (_) => const PhoneLoginScreen(),
        '/otp': (_) => const OtpVerificationScreen(),
        '/email-login': (_) => const EmailLoginScreen(),
        '/email-verification': (_) => const EmailVerificationScreen(),
        '/role-selection': (_) => const RoleSelectionScreen(),
        '/helper-home': (_) => const HelperHomeScreen(),
        '/helper-profile-setup': (_) => const HelperProfileSetupScreen(),
        '/employer-home': (_) => const EmployerShellScreen(),
        '/employer-profile-setup': (_) => const EmployerProfileSetupScreen(),
        '/employer-profile': (_) => const EmployerProfileScreen(),
        '/helper-profile': (_) => const HelperProfileScreen(),
        '/helper-detail': (_) => const HelperDetailScreen(),
        '/add-phone': (_) => const AddPhoneScreen(),
        '/avatar-selection': (_) => const AvatarSelectionScreen(),
        '/chat': (_) => const ChatScreen(),
        '/conversations': (_) => const ConversationListScreen(),
        '/self-help': (_) => const SelfHelpScreen(),
        '/self-help-detail': (_) => const SelfHelpDetailScreen(),
        '/self-help-quiz': (_) => const SelfHelpQuizScreen(),
        '/rights-at-work': (_) => const RightsAtWorkContentScreen(),
        '/money-savings': (_) => const MoneySavingsContentScreen(),
        '/insurance': (_) => const InsuranceContentScreen(),
        '/government-schemes': (_) => const GovernmentSchemesContentScreen(),
        '/aadhaar-verify': (_) => const AadhaarVerificationScreen(),
      },
    );
  }
}
