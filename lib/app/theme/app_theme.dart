import 'package:flutter/material.dart';
import '../../theme/app_theme.dart' as base_theme;
import 'app_colors.dart';

class AppTheme {
  static final _lightExtension = StageFlowThemeExtension(
    successBg: AppColors.successGreenBg,
    successText: AppColors.successGreenText,
    warningBg: AppColors.warningAmberBg,
    warningText: AppColors.warningAmberText,
    infoBg: AppColors.infoBlueBg,
    infoText: AppColors.infoBlueText,
    conflictBg: AppColors.conflictRedBg,
    conflictText: AppColors.conflictRedText,
    borderSubtle: AppColors.lightBorderSubtle,
    surfaceContainerLow: AppColors.lightSurfaceContainerLow,
    deepNavyOrSurface: AppColors.deepNavy,
  );

  static final _darkExtension = StageFlowThemeExtension(
    successBg: AppColors.darkSuccessGreenBg,
    successText: AppColors.darkSuccessGreenText,
    warningBg: AppColors.darkWarningAmberBg,
    warningText: AppColors.darkWarningAmberText,
    infoBg: AppColors.darkInfoBlueBg,
    infoText: AppColors.darkInfoBlueText,
    conflictBg: AppColors.darkConflictRedBg,
    conflictText: AppColors.darkConflictRedText,
    borderSubtle: AppColors.darkBorderSubtle,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    deepNavyOrSurface: AppColors.darkTextPrimary,
  );

  static ThemeData get lightTheme {
    return base_theme.AppTheme.lightTheme.copyWith(
      extensions: [_lightExtension],
    );
  }

  static ThemeData get darkTheme {
    return base_theme.AppTheme.darkTheme.copyWith(
      extensions: [_darkExtension],
    );
  }
}
