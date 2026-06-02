import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryBlue = Color(0xFF0984E3);
  static const Color primaryDark = Color(0xFF1A1A2E);

  static const LinearGradient purpleBlueGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFE8E0F0), Color(0xFFD5CCF0), Color(0xFFC8BEF0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient scoreGradient = RadialGradient(
    colors: [Color(0xFF8B7AE8), primaryPurple],
    center: Alignment.center,
    radius: 0.8,
  );

  static const Color background = Color(0xFFF8F9FE);
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFF0F0F8);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color successGreen = Color(0xFF00B894);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color warningOrange = Color(0xFFF39C12);

  static const Color categoryArgumentative = Color(0xFF6C5CE7);
  static const Color categoryLiterature = Color(0xFF0984E3);
  static const Color categoryEthics = Color(0xFFE17055);
  static const Color categoryHistory = Color(0xFF00B894);
  static const Color categoryNarrative = Color(0xFFFDAA5E);
  static const Color categoryOther = Color(0xFF636E72);

  static const Color grammarCardBg = Color(0xFFF8F7FF);
  static const Color coherenceCardBg = Color(0xFFF5F9FF);
  static const Color vocabularyCardBg = Color(0xFFFFF8F5);
  static const Color semanticsCardBg = Color(0xFFF5FFF8);

  static const Color grammarIconBg = Color(0xFFEDE9FF);
  static const Color coherenceIconBg = Color(0xFFE3F0FF);
  static const Color vocabularyIconBg = Color(0xFFFFE8E0);
  static const Color semanticsIconBg = Color(0xFFE0FFE8);

  static Color getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'ARGUMENTATIVE':
        return categoryArgumentative;
      case 'LITERATURE REVIEW':
      case 'LITERATURE':
        return categoryLiterature;
      case 'ETHICS':
        return categoryEthics;
      case 'HISTORY':
        return categoryHistory;
      case 'NARRATIVE':
        return categoryNarrative;
      default:
        return categoryOther;
    }
  }
}
