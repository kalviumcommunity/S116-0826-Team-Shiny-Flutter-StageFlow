import 'package:flutter/material.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  // Stitch Design System Tokens
  static const Color velvetCrimson = Color(0xFF881337);
  static const Color primaryCrimson = Color(0xFF640023);
  static const Color stageAmber = Color(0xFFD97706);
  static const Color stageAmberDark = Color(0xFF904D00);
  static const Color slateBlue = Color(0xFF223042);
  static const Color slateBlueLight = Color(0xFF475569);
  static const Color deepCharcoal = Color(0xFF131B2E);
  static const Color darkSlate = Color(0xFF0F172A);

  // Surfaces
  static const Color canvasBase = Color(0xFFFAF8FF);
  static const Color canvasBaseAlt = Color(0xFFF8F9FA);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);

  // Hairline Borders
  static const Color borderHairline = Color(0xFFE2E8F0);
  static const Color borderElevated = Color(0xFFCBD5E1);

  // Status Colors
  static const Color alertError = Color(0xFFB91C1C);
  static const Color alertErrorBg = Color(0xFFFEF2F2);
  static const Color warningAmber = Color(0xFFC2410C);
  static const Color warningAmberBg = Color(0xFFFFFBEB);
  static const Color affirmationGreen = Color(0xFF15803D);
  static const Color affirmationGreenBg = Color(0xFFF0FDF4);

  // Backwards compatibility aliases
  static const Color burgundy = velvetCrimson;
  static const Color burgundyDark = primaryCrimson;
  static const Color burgundyLight = Color(0xFF9E263C);
  static const Color gold = stageAmber;
  static const Color amber = stageAmber;
  static const Color emerald = affirmationGreen;
  static const Color charcoal = deepCharcoal;
  static const Color backgroundLight = canvasBase;
  static const Color surfaceLight = cardSurface;
  static const Color surfaceContainerHighestLight = surfaceContainerLow;
  static const Color borderLight = borderHairline;
  static const Color textPrimaryLight = deepCharcoal;
  static const Color textSecondaryLight = slateBlueLight;
  static const Color textTertiaryLight = Color(0xFF64748B);

  static const Color backgroundDark = darkSlate;
  static const Color surfaceDark = Color(0xFF161F36);
  static const Color surfaceContainerHighestDark = Color(0xFF1F2942);
  static const Color borderDark = Color(0xFF2E384D);
  static const Color textPrimaryDark = Color(0xFFFAF8FF);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  static ThemeData get lightTheme {
    final textTheme = AppTextTheme.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: canvasBase,
      colorScheme: AppColors.lightColorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: cardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: deepCharcoal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: deepCharcoal),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderHairline, width: 1),
        ),
        color: cardSurface,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      dividerTheme: const DividerThemeData(
        color: borderHairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF8A7174), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: slateBlueLight, fontSize: 13, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderElevated, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderElevated, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: velvetCrimson, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: alertError, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: velvetCrimson,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepCharcoal,
          minimumSize: const Size(double.infinity, 44),
          side: const BorderSide(color: borderHairline, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: cardSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: velvetCrimson.withValues(alpha: 0.08),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: velvetCrimson, size: 22);
          }
          return const IconThemeData(color: slateBlueLight, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              color: velvetCrimson,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return GoogleFonts.inter(
            color: slateBlueLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: velvetCrimson,
        unselectedLabelColor: slateBlueLight,
        indicatorColor: velvetCrimson,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkSlate,
      colorScheme: AppColors.darkColorScheme,
      textTheme: AppTextTheme.textTheme.apply(
        bodyColor: const Color(0xFFFAF8FF),
        displayColor: const Color(0xFFFAF8FF),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        color: surfaceDark,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(color: textTertiaryDark, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondaryDark, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF93A6), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: velvetCrimson,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: surfaceDark,
        indicatorColor: velvetCrimson.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFFF93A6),
        unselectedLabelColor: textSecondaryDark,
        indicatorColor: Color(0xFFFF93A6),
      ),
    );
  }
}
