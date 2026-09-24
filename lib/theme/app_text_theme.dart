import 'package:flutter/material.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:stagesync/theme/app_colors.dart';

/// StageSync typography using Plus Jakarta Sans for headers & Inter for body/tabular data.
abstract class AppTextTheme {
  /// Tabular figures feature for numeric alignment in calls and timelines
  static const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

  static TextTheme get textTheme {
    return TextTheme(
      // Headlines & Display (Plus Jakarta Sans)
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.onSurface,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.onSurface,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.onSurface,
      ),

      // Titles (Inter / Plus Jakarta Sans)
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.onSurface,
      ),

      // Body (Inter)
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: AppColors.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: AppColors.textMuted,
      ),

      // Labels & Metadata (Inter)
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: AppColors.textMuted,
      ),
    );
  }
}
