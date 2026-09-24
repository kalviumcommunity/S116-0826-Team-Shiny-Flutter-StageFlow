import 'package:flutter/material.dart';

/// Design tokens for StageFlow / StageSync, unified for Light and Dark modes.
class AppColors {
  // Brand Anchors (Stitch Velvet Crimson)
  static const Color primaryCrimson = Color(0xFF640023);
  static const Color primaryContainer = Color(0xFF881337);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFF93A6);
  static const Color stageRed = Color(0xFF881337);
  static const Color stageRedHover = Color(0xFF640023);
  static const Color deepNavy = Color(0xFF131B2E);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Light Theme Neutrals (Stitch Canvas Base)
  static const Color lightBackground = Color(0xFFFAF8FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFDAE2FD);
  static const Color lightSurfaceContainerLow = Color(0xFFF2F3FF);
  static const Color lightSurfaceContainer = Color(0xFFEAEDFF);
  static const Color lightTextPrimary = Color(0xFF131B2E);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightOutline = Color(0xFFE2E8F0);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);
  static const Color lightBorderSubtle = Color(0xFFE2E8F0);

  // Dark Theme Neutrals
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkSurfaceVariant = Color(0xFF223042);
  static const Color darkSurfaceContainerLow = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFFAF8FF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF475569);
  static const Color darkOutlineVariant = Color(0xFF334155);
  static const Color darkBorderSubtle = Color(0xFF334155);

  // Legacy color aliases for compatibility
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceContainerLow = lightSurfaceContainerLow;
  static const Color borderSubtle = lightBorderSubtle;
  static const Color outline = lightOutline;
  static const Color outlineVariant = lightOutlineVariant;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;

  // Status Tints (Light)
  static const Color conflictRed = Color(0xFFB91C1C);
  static const Color conflictRedBg = Color(0xFFFEF2F2);
  static const Color conflictRedText = Color(0xFF991B1B);
  static const Color successGreen = Color(0xFF15803D);
  static const Color successGreenBg = Color(0xFFF0FDF4);
  static const Color successGreenText = Color(0xFF166534);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberBg = Color(0xFFFFFBEB);
  static const Color warningAmberText = Color(0xFF92400E);
  static const Color infoBlue = Color(0xFF223042);
  static const Color infoBlueBg = Color(0xFFF2F3FF);
  static const Color infoBlueText = Color(0xFF131B2E);

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
  static const Color darkInfoBlue = Color(0xFFB9C7DF);
  static const Color darkInfoBlueBg = Color(0xFF223042);
  static const Color darkInfoBlueText = Color(0xFFD5E3FC);

  // Constant Text Colors
  static const Color textOnRed = Color(0xFFFFFFFF);
}

/// Custom extension for semantic colors (status chips, subtle borders, etc.)
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
  final Color deepNavyOrSurface;

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
  ThemeExtension<StageFlowThemeExtension> copyWith({
    Color? successBg,
    Color? successText,
    Color? warningBg,
    Color? warningText,
    Color? infoBg,
    Color? infoText,
    Color? conflictBg,
    Color? conflictText,
    Color? borderSubtle,
    Color? surfaceContainerLow,
    Color? deepNavyOrSurface,
  }) {
    return StageFlowThemeExtension(
      successBg: successBg ?? this.successBg,
      successText: successText ?? this.successText,
      warningBg: warningBg ?? this.warningBg,
      warningText: warningText ?? this.warningText,
      infoBg: infoBg ?? this.infoBg,
      infoText: infoText ?? this.infoText,
      conflictBg: conflictBg ?? this.conflictBg,
      conflictText: conflictText ?? this.conflictText,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      deepNavyOrSurface: deepNavyOrSurface ?? this.deepNavyOrSurface,
    );
  }

  @override
  ThemeExtension<StageFlowThemeExtension> lerp(
      ThemeExtension<StageFlowThemeExtension>? other, double t) {
    if (other is! StageFlowThemeExtension) return this;
    return StageFlowThemeExtension(
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      conflictBg: Color.lerp(conflictBg, other.conflictBg, t)!,
      conflictText: Color.lerp(conflictText, other.conflictText, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      deepNavyOrSurface:
          Color.lerp(deepNavyOrSurface, other.deepNavyOrSurface, t)!,
    );
  }
}
