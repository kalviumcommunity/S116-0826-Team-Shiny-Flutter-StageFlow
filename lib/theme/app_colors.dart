import 'package:flutter/material.dart';

/// StageSync Stitch Color Palette and Design System Tokens.
///
/// Designed specifically for theatre production management, rehearsal operations,
/// and backstage callboard administration.
abstract class AppColors {
  // Brand Primaries (Velvet Crimson)
  static const Color primaryCrimson = Color(0xFF640023);
  static const Color primaryContainer = Color(0xFF881337);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFF93A6);
  static const Color inversePrimary = Color(0xFFFFB2BD);

  // Secondary (Stage Warm Amber)
  static const Color secondaryAmber = Color(0xFF904D00);
  static const Color secondaryWarmAmber = Color(0xFFD97706);
  static const Color secondaryContainer = Color(0xFFFE932C);
  static const Color onSecondaryContainer = Color(0xFF663500);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color secondaryFixedDim = Color(0xFFFFB77D);

  // Tertiary (Calm Slate Blue)
  static const Color tertiarySlate = Color(0xFF223042);
  static const Color tertiarySlateLight = Color(0xFF475569);
  static const Color tertiaryContainer = Color(0xFF384659);
  static const Color onTertiaryContainer = Color(0xFFA5B4CB);
  static const Color tertiaryFixed = Color(0xFFD5E3FC);
  static const Color tertiaryFixedDim = Color(0xFFB9C7DF);

  // Neutrals (Deep Charcoal Slate)
  static const Color deepCharcoal = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF574144);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color inverseSurface = Color(0xFF283044);
  static const Color inverseOnSurface = Color(0xFFEEF0FF);

  // Canvas & Surfaces
  static const Color canvasBase = Color(0xFFFAF8FF);
  static const Color canvasBaseAlt = Color(0xFFF8F9FA);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceHigh = Color(0xFFE2E7FF);
  static const Color surfaceHighest = Color(0xFFDAE2FD);

  // Hairline Borders & Dividers
  static const Color borderHairline = Color(0xFFE2E8F0);
  static const Color borderElevated = Color(0xFFCBD5E1);
  static const Color outline = Color(0xFF8A7174);
  static const Color outlineVariant = Color(0xFFDEBFC2);

  // Alerts & Functional States
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color conflictRed = Color(0xFFB91C1C);
  static const Color conflictContainer = Color(0xFFFEF2F2);
  static const Color conflictBorder = Color(0xFFFCA5A5);
  static const Color conflictText = Color(0xFF991B1B);

  static const Color warningRust = Color(0xFFC2410C);
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFF92400E);

  static const Color successGreen = Color(0xFF15803D);
  static const Color successContainer = Color(0xFFF0FDF4);
  static const Color successText = Color(0xFF166534);

  // Compatibility Aliases
  static const Color primaryCharcoal = deepCharcoal;
  static const Color primaryCharcoalLight = Color(0xFF1E293B);
  static const Color primaryCharcoalDark = Color(0xFF020617);
  static const Color spotlightAmber = secondaryWarmAmber;
  static const Color spotlightAmberDark = secondaryAmber;
  static const Color spotlightAmberGlow = warningContainer;
  static const Color spotlightAmberText = warningText;
  static const Color stageBronze = secondaryAmber;
  static const Color stageBronzeLight = secondaryFixed;
  static const Color surfaceLight = canvasBase;
  static const Color surfaceWhite = surfaceLowest;
  static const Color surfaceCard = surfaceLowest;
  static const Color surfaceBorder = borderHairline;
  static const Color textDark = onSurface;
  static const Color conflictRedContainer = conflictContainer;
  static const Color conflictRedText = conflictText;
  static const Color successGreenContainer = successContainer;

  /// Material 3 light color scheme for StageSync.
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryCrimson,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondaryAmber,
    onSecondary: Colors.white,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiarySlate,
    onTertiary: Colors.white,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: errorRed,
    onError: Colors.white,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: canvasBase,
    onSurface: onSurface,
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: borderHairline,
    outlineVariant: borderElevated,
  );

  /// Material 3 dark color scheme for StageSync.
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: inversePrimary,
    onPrimary: primaryCrimson,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondaryFixedDim,
    onSecondary: onSecondaryContainer,
    secondaryContainer: secondaryAmber,
    onSecondaryContainer: secondaryFixed,
    tertiary: tertiaryFixed,
    onTertiary: tertiarySlate,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF131B2E),
    onSurface: Color(0xFFFAF8FF),
    surfaceContainerLowest: Color(0xFF0F172A),
    surfaceContainerLow: Color(0xFF1E293B),
    surfaceContainer: Color(0xFF223042),
    surfaceContainerHigh: Color(0xFF283044),
    surfaceContainerHighest: Color(0xFF334155),
    onSurfaceVariant: Color(0xFFCBD5E1),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF64748B),
  );
}
