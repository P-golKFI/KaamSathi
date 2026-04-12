import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _otpController.dispose();
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

  void _resendOtp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.resendOtp();

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.otpResentSuccess)),
      );
      _startCooldown();
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterSixDigitCode)),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOtp(_otpController.text.trim());

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }

    _navigateAfterAuth(authProvider);
  }

  void _navigateAfterAuth(AuthProvider auth) {
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
              // Top section with back button and icon
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
                          onPressed: () => Navigator.pop(context),
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
                                Icons.sms_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.verifyOtp,
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
                            l.enterVerificationCode,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.otpSentMessage,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 36),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              letterSpacing: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                            decoration: AppDecorations.styledInput(
                              hint: '------',
                            ).copyWith(
                              hintStyle: TextStyle(
                                fontSize: 28,
                                letterSpacing: 12,
                                color: Colors.grey.shade300,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                          const SizedBox(height: 28),
                          GradientButton(
                            text: l.verifyOtp,
                            isLoading: auth.isLoading,
                            onPressed: auth.isLoading ? null : _verifyOtp,
                          ),
                          const SizedBox(height: 24),
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
                                        : _resendOtp,
                                    child: Text(
                                      _cooldownSeconds > 0
                                          ? l.resendIn(_cooldownSeconds)
                                          : l.resendCode,
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
