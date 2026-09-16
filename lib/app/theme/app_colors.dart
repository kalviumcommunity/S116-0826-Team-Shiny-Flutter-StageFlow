import 'package:flutter/material.dart';

/// Design tokens for StageFlow, unified for Light and Dark modes.
class AppColors {
  // Brand Anchors
  static const Color stageRed = Color(0xFFAF101A);
  static const Color stageRedHover = Color(0xFF940D15);
  static const Color deepNavy = Color(0xFF141D23);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Light Theme Neutrals
  static const Color lightBackground = Color(0xFFF8F9FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE1E2E4);
  static const Color lightSurfaceContainerLow = Color(0xFFF2F4F6);
  static const Color lightTextPrimary = Color(0xFF191C1E);
  static const Color lightTextSecondary = Color(0xFF44474A);
  static const Color lightOutline = Color(0xFF74777B);
  static const Color lightOutlineVariant = Color(0xFFC4C7CA);
  static const Color lightBorderSubtle = Color(0xFFE1E2E4);

  // Dark Theme Neutrals (Cinemax Inspired)
  static const Color darkBackground = Color(0xFF171725);
  static const Color darkSurface = Color(0xFF1F1D2B);
  static const Color darkSurfaceVariant = Color(0xFF252836);
  static const Color darkSurfaceContainerLow = Color(0xFF252836);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkOutline = Color(0xFF4B5563);
  static const Color darkOutlineVariant = Color(0xFF374151);

  // Legacy color aliases for compatibility
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceContainerLow = lightSurfaceContainerLow;
  static const Color borderSubtle = lightBorderSubtle;
  static const Color outline = lightOutline;
  static const Color outlineVariant = lightOutlineVariant;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  // deepNavy already defined as a brand anchor
  // textOnDark already defined above
  static const Color darkBorderSubtle = Color(0xFF252836);

  // Status Tints (Light)
  static const Color conflictRed = Color(0xFFBA1A1A);
  static const Color conflictRedBg = Color(0xFFFFDAD6);
  static const Color conflictRedText = Color(0xFF93000A);
  static const Color successGreen = Color(0xFF1E6D3B);
  static const Color successGreenBg = Color(0xFFE8F5E9);
  static const Color successGreenText = Color(0xFF0D3B1E);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberBg = Color(0xFFFEF3C7);
  static const Color warningAmberText = Color(0xFF78350F);
  static const Color infoBlue = Color(0xFF0284C7);
  static const Color infoBlueBg = Color(0xFFE0F2FE);
  static const Color infoBlueText = Color(0xFF075985);

  // Status Tints (Dark)
  static const Color darkConflictRed = Color(0xFFFFB4AB);
  static const Color darkConflictRedBg = Color(0xFF93000A);
  static const Color darkConflictRedText = Color(0xFFFFDAD6);
  static const Color darkSuccessGreen = Color(0xFF81C995);
  static const Color darkSuccessGreenBg = Color(0xFF0D3B1E);
  static const Color darkSuccessGreenText = Color(0xFFE8F5E9);
  static const Color darkWarningAmber = Color(0xFFFCD34D);
  static const Color darkWarningAmberBg = Color(0xFF78350F);
  static const Color darkWarningAmberText = Color(0xFFFEF3C7);
  static const Color darkInfoBlue = Color(0xFF7DD3FC);
  static const Color darkInfoBlueBg = Color(0xFF075985);
  static const Color darkInfoBlueText = Color(0xFFE0F2FE);

  // Constant Text Colors
  static const Color textOnRed = Color(0xFFFFFFFF);
}

/// Custom extension for non-Material semantic colors (status chips, subtle borders, etc.)
class StageFlowThemeExtension extends ThemeExtension<StageFlowThemeExtension> {
  final Color successBg;
  final Color successText;
  final Color warningBg;
  final Color warningText;
  final Color infoBg;
  final Color infoText;
  final Color conflictBg;
  final Color conflictText;
  final Color borderSubtle;
  final Color surfaceContainerLow;
  final Color
      deepNavyOrSurface; // Used for secondary buttons (dark text in light, white text in dark)

  StageFlowThemeExtension({
    required this.successBg,
    required this.successText,
    required this.warningBg,
    required this.warningText,
    required this.infoBg,
    required this.infoText,
    required this.conflictBg,
    required this.conflictText,
    required this.borderSubtle,
    required this.surfaceContainerLow,
    required this.deepNavyOrSurface,
  });

  @override
  ThemeExtension<StageFlowThemeExtension> copyWith() => this;

  @override
  ThemeExtension<StageFlowThemeExtension> lerp(
          ThemeExtension<StageFlowThemeExtension>? other, double t) =>
      this;
}
