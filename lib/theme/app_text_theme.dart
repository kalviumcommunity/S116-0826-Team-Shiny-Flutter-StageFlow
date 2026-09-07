import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stagesync/theme/app_colors.dart';

/// StageSync Material 3 typography configuration using Google Fonts (Inter).
///
/// **Font Choice Justification:**
/// - **Inter**: Selected for its exceptional clarity, neutral geometric structure,
///   and tall x-height. In busy backstage environments and dense production schedules,
///   actors and stage managers need rapid, unambiguous reading of call times,
///   scene numbers, cue notes, and role assignments without distracting decorative flourishes.
abstract class AppTextTheme {
  /// Custom Material 3 TextTheme built with Inter.
  static TextTheme get textTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    return GoogleFonts.interTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: AppColors.textDark,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: AppColors.textDark,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textSubtle,
      ),
    );
  }
}
