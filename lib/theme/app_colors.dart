import 'package:flutter/material.dart';

class AppColors {
  static const Color navyBlue = Color(0xFF1A3A5C);
  static const Color navyDark = Color(0xFF0F2744);
  static const Color teal = Color(0xFF00BCD4);
  static const Color tealLight = Color(0xFF26C6DA);
  static const Color orange = Color(0xFFF5A623);
  static const Color orangeBright = Color(0xFFFF9800);
  static const Color white = Colors.white;
  static const Color offWhite = Color(0xFFF5F5F0);
  static const Color greyLight = Color(0xFFF0F4F8);
  static const Color textGrey = Color(0xFF6B7280);
}

class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.navyDark,
      AppColors.navyBlue,
      Color(0xFF1E4D6E),
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [AppColors.teal, AppColors.tealLight],
  );

  static const LinearGradient orangeButtonGradient = LinearGradient(
    colors: [AppColors.orange, AppColors.orangeBright],
  );
}

class AppDecorations {
  static InputDecoration styledInput({
    required String hint,
    String? label,
    IconData? prefixIcon,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixText: prefixText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.teal)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.textGrey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
