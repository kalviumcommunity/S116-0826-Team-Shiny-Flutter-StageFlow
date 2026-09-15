import 'package:flutter/material.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';

/// A standardized primary action button for StageSync.
///
/// Supports loading states with an integrated spinner, optional icons,
/// custom colors, and responsive full-width or wrap-content sizing.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 50.0,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveFgColor = foregroundColor ?? theme.colorScheme.onPrimary;

    Widget buttonChild;

    if (isLoading) {
      buttonChild = const LoadingIndicator(
        size: 22,
        strokeWidth: 2.5,
        message: null,
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: effectiveFgColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: effectiveFgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      buttonChild = Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: effectiveFgColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBgColor,
        foregroundColor: effectiveFgColor,
        disabledBackgroundColor: AppColors.surfaceBorder,
        disabledForegroundColor: AppColors.textSubtle,
        elevation: 0,
        minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }
}
