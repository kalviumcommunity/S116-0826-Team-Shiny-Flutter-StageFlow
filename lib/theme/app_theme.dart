import 'package:flutter/material.dart';

class AppTheme {
  // Stitch Approved Palette: Warm Neutrals with Restrained Stage Burgundy
  static const Color burgundy = Color(0xFF80182A);
  static const Color burgundyDark = Color(0xFF63101E);
  static const Color burgundyLight = Color(0xFF9E263C);
  static const Color gold = Color(0xFFC49A45);
  static const Color amber = Color(0xFFD97706);
  static const Color emerald = Color(0xFF059669);
  static const Color charcoal = Color(0xFF131B2E);
  
  // Light Mode Surfaces & Neutrals
  static const Color backgroundLight = Color(0xFFFAF8F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighestLight = Color(0xFFF3EFEB);
  static const Color borderLight = Color(0xFFE7E2DA);
  static const Color textPrimaryLight = Color(0xFF131B2E);
  static const Color textSecondaryLight = Color(0xFF57534E);
  static const Color textTertiaryLight = Color(0xFF78716C);

  // Dark Mode Surfaces & Neutrals
  static const Color backgroundDark = Color(0xFF161413);
  static const Color surfaceDark = Color(0xFF221F1D);
  static const Color surfaceContainerHighestDark = Color(0xFF2C2825);
  static const Color borderDark = Color(0xFF38332F);
  static const Color textPrimaryDark = Color(0xFFF5F3EF);
  static const Color textSecondaryDark = Color(0xFFA8A29E);
  static const Color textTertiaryDark = Color(0xFF78716C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: burgundy,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        surfaceContainerHighest: surfaceContainerHighestLight,
        onSurfaceVariant: textSecondaryLight,
        outline: borderLight,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textPrimaryLight),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        color: surfaceLight,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textTertiaryLight, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: burgundy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryLight,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: borderLight, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        elevation: 1,
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: burgundy.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: burgundy, size: 24);
          }
          return const IconThemeData(color: textSecondaryLight, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: burgundy,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: textSecondaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: burgundy,
        unselectedLabelColor: textSecondaryLight,
        indicatorColor: burgundy,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: burgundyLight,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: Colors.white,
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: surfaceContainerHighestDark,
        onSurfaceVariant: textSecondaryDark,
        outline: borderDark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textPrimaryDark),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        color: surfaceDark,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textTertiaryDark, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: burgundyLight, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundyLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        elevation: 1,
        backgroundColor: surfaceDark,
        indicatorColor: burgundyLight.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: burgundyLight,
        unselectedLabelColor: textSecondaryDark,
        indicatorColor: burgundyLight,
      ),
    );
  }
}
