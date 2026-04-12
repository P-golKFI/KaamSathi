import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  void _checkVerification() async {
    setState(() => _isChecking = true);

    final authProvider = context.read<AuthProvider>();
    final verified = await authProvider.checkEmailVerified();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (verified) {
      _navigateAfterVerification(authProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.emailNotVerified),
        ),
      );
    }
  }

  void _navigateAfterVerification(AuthProvider auth) {
    if (auth.status == AuthStatus.authenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role-selection',
        (_) => false,
      );
    } else if (auth.status == AuthStatus.roleSelected) {
      final role = auth.userModel!.role;
      final profileDone = auth.userModel!.profileComplete;
      String route;
      if (role == 'helper') {
        route = profileDone ? '/helper-home' : '/helper-profile-setup';
      } else {
        route = profileDone ? '/employer-home' : '/employer-profile-setup';
      }
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    }
  }

  void _resendEmail() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.resendVerificationEmail();

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.verificationEmailResent)),
      );
      _startCooldown();
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
              // Top section with icon
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: screenHeight * 0.3,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          onPressed: () async {
                            await context.read<AuthProvider>().signOut();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/email-login',
                              (_) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.verifyEmail,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                            l.checkYourInbox,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.emailVerificationSent,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Info box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.teal.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 20,
                                    color: AppColors.teal
                                        .withValues(alpha: 0.8)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l.checkSpamFolder,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textGrey,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          GradientButton(
                            text: l.continueButton,
                            isLoading: _isChecking,
                            onPressed: _isChecking ? null : _checkVerification,
                          ),
                          const SizedBox(height: 24),

                          // Resend email button
                          Center(
                            child: auth.isResending
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        l.sending,
                                        style: const TextStyle(
                                          color: AppColors.teal,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : TextButton(
                                    onPressed: _cooldownSeconds > 0
                                        ? null
                                        : _resendEmail,
                                    child: Text(
                                      _cooldownSeconds > 0
                                          ? l.resendIn(_cooldownSeconds)
                                          : l.resendEmail,
                                      style: TextStyle(
                                        color: _cooldownSeconds > 0
                                            ? AppColors.textGrey
                                            : AppColors.teal,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
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
