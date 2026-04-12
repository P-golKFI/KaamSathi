import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'gradient_button.dart';

/// Shows the number share request UI (accept/decline) or
/// the shared numbers with a "Tap to Call" button.
class NumberShareCard extends StatelessWidget {
  final String? otherName;
  final String? otherPhone;
  final String? myPhone;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isShared;

  const NumberShareCard({
    super.key,
    this.otherName,
    this.otherPhone,
    this.myPhone,
    this.onAccept,
    this.onDecline,
    this.isShared = false,
  });

  Future<void> _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Numbers already shared — show phone + call button
    if (isShared && otherPhone != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.teal.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.teal,
              size: 36,
            ),
            const SizedBox(height: 10),
            const Text(
              'Numbers shared!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              otherPhone!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 14),
            GradientButton(
              text: 'Tap to Call ${otherName ?? ''}',
              gradient: AppGradients.orangeButtonGradient,
              onPressed: () => _makeCall(otherPhone!),
            ),
            const SizedBox(height: 8),
            Text(
              'Your number has been shared with them.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Accept / Decline request
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.phone_outlined,
            color: AppColors.orange,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            '${otherName ?? 'Someone'} wants to share phone numbers with you.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Accept',
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
