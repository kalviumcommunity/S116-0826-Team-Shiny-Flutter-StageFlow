import 'package:flutter/material.dart';

/// StageSync Color Palette and Material 3 Color Schemes.
///
/// **Color Choices & Theatrical Justification:**
/// - **Deep Charcoal (`#1E2229`)**: Serves as the primary brand color, evoking the
///   depth of backstage environments, dark-box stages, and rich velvet curtains.
///   It provides strong visual grounding and sophisticated contrast on mobile.
/// - **Warm Spotlight Amber (`#F59E0B` / `#D97706`)**: Serves as the spotlight accent,
///   capturing the warm brilliance of stage illumination cutting through darkness.
///   Used for high-priority cues, primary actions, and key active states.
/// - **Crimson Red (`#DC2626` / `#FEE2E2`)**: Explicitly configured for conflict
///   detection and error banners to immediately alert stage managers to double-bookings.
abstract class AppColors {
  // Brand Primaries (Deep Charcoal & Backstage Dark)
  static const Color primaryCharcoal = Color(0xFF1E2229);
  static const Color primaryCharcoalLight = Color(0xFF2D323B);
  static const Color primaryCharcoalDark = Color(0xFF12151A);

  // Spotlight Accent (Warm Amber & Gold Cues)
  static const Color spotlightAmber = Color(0xFFF59E0B);
  static const Color spotlightAmberDark = Color(0xFFD97706);
  static const Color spotlightAmberGlow = Color(0xFFFEF3C7);
  static const Color spotlightAmberText = Color(0xFF78350F);

  // Theatrical Bronze / Wood Trim
  static const Color stageBronze = Color(0xFFB45309);
  static const Color stageBronzeLight = Color(0xFFFFEDD5);

  // Neutral Surfaces & Backgrounds
  static const Color surfaceLight = Color(0xFFFAFAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFF3F4F6);
  static const Color surfaceBorder = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF1A1D20);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textSubtle = Color(0xFF9CA3AF);

  // Conflict & Status Colors
  static const Color conflictRed = Color(0xFFDC2626);
  static const Color conflictRedContainer = Color(0xFFFEE2E2);
  static const Color conflictRedText = Color(0xFF991B1B);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successGreenContainer = Color(0xFFDCFCE7);

  /// Material 3 light color scheme for StageSync.
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryCharcoal,
    onPrimary: Colors.white,
    primaryContainer: primaryCharcoalLight,
    onPrimaryContainer: Color(0xFFF1F3F5),
    secondary: spotlightAmber,
    onSecondary: primaryCharcoalDark,
    secondaryContainer: spotlightAmberGlow,
    onSecondaryContainer: spotlightAmberText,
    tertiary: stageBronze,
    onTertiary: Colors.white,
    tertiaryContainer: stageBronzeLight,
    onTertiaryContainer: Color(0xFF7C2D12),
    error: conflictRed,
    onError: Colors.white,
    errorContainer: conflictRedContainer,
    onErrorContainer: conflictRedText,
    surface: surfaceLight,
    onSurface: textDark,
    surfaceContainerHighest: surfaceCard,
    onSurfaceVariant: textMuted,
    outline: surfaceBorder,
    outlineVariant: Color(0xFFD1D5DB),
  );
}
