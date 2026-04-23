import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class AadhaarNudgeScreen extends StatelessWidget {
  const AadhaarNudgeScreen({super.key});

  static const _benefits = [
    'Verified badge shown on your profile',
    'Employers can see you\'re identity-verified',
    'Higher chance of being contacted',
    'Free and completely optional',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        automaticallyImplyLeading: false,
        title: const Text(
          'Almost Done!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        children: [
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.teal,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Heading
          const Text(
            'Get an Aadhaar Verified Badge',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 10),

          // Subheading
          const Text(
            'Employers trust verified helpers more.\nIt only takes a minute.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Benefits card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: _benefits
                  .map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.teal, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                benefit,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.navyBlue,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Verify button
          GradientButton(
            text: 'Verify with Aadhaar',
            onPressed: () async {
              await Navigator.pushNamed(context, '/aadhaar-verify');
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/helper-home', (_) => false);
              }
            },
          ),
          const SizedBox(height: 12),

          // Skip button
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/helper-home', (_) => false);
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Skip hint
          const Text(
            'You can verify anytime from Profile Settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
