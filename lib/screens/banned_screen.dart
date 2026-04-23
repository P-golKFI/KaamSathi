import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 72, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Account Suspended',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account has been suspended due to a violation of our community guidelines.',
                style: TextStyle(fontSize: 15, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'If you believe this is a mistake, please contact us.',
                style: TextStyle(fontSize: 15, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('mailto:support@kaamsathi.in'),
                ),
                icon: const Icon(Icons.email_outlined, color: AppColors.teal),
                label: const Text(
                  'support@kaamsathi.in',
                  style: TextStyle(color: AppColors.teal),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.teal),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
