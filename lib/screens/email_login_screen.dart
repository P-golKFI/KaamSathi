import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _keepSignedIn = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _keepSignedIn = prefs.getBool('keepSignedIn') ?? true;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidEmailPassword),
        ),
      );
      return;
    }

    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordsMismatch)),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.signInWithEmail(email, password);

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }

    // New registration — needs email verification
    if (authProvider.emailVerificationPending) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/email-verification',
        (_) => false,
      );
      return;
    }

    if (authProvider.status == AuthStatus.authenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role-selection',
        (_) => false,
      );
    } else if (authProvider.status == AuthStatus.roleSelected) {
      final role = authProvider.userModel!.role;
      final profileDone = authProvider.userModel!.profileComplete;
      String route;
      if (role == 'helper') {
        route = profileDone ? '/helper-home' : '/helper-profile-setup';
      } else {
        route = profileDone ? '/employer-home' : '/employer-profile-setup';
      }
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top section with back button and logo
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: screenHeight * 0.3,
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Logo centered
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom card
              Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.7,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final l = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.emailLogin,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.emailLoginSubtitle,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.navyBlue,
                            ),
                            decoration: AppDecorations.styledInput(
                              hint: 'you@example.com',
                              prefixIcon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.navyBlue,
                            ),
                            decoration: AppDecorations.styledInput(
                              hint: l.passwordHint,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.navyBlue,
                            ),
                            decoration: AppDecorations.styledInput(
                              hint: l.confirmPasswordHint,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _keepSignedIn,
                                  activeColor: AppColors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) async {
                                    setState(() => _keepSignedIn = val ?? true);
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('keepSignedIn', _keepSignedIn);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l.keepSignedIn,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GradientButton(
                            text: l.continueButton,
                            isLoading: auth.isLoading,
                            onPressed: auth.isLoading ? null : _signIn,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
