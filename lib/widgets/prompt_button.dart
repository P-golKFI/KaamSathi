import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PromptButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isDestructive;

  const PromptButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.shade50
                  : AppColors.teal.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDestructive
                    ? Colors.red.shade200
                    : AppColors.teal.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red.shade700 : AppColors.navyBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
