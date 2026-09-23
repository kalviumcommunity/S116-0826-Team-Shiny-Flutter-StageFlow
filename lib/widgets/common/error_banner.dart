import 'package:flutter/material.dart';
import 'package:stagesync/theme/app_colors.dart';

/// A dismissible banner for displaying errors, warnings, and schedule conflicts.
///
/// Designed specifically for StageSync conflict detection and error surfacing,
/// featuring clear visual hierarchy, optional title/action, and dismissibility.
class ErrorBanner extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool isDismissible;
  final bool isWarning;

  const ErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.isDismissible = true,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isWarning
        ? AppColors.spotlightAmberGlow
        : AppColors.conflictRedContainer;
    final borderColor =
        isWarning ? AppColors.spotlightAmber : AppColors.conflictRed;
    final textColor =
        isWarning ? AppColors.spotlightAmberText : AppColors.conflictRedText;
    final effectiveIcon = icon ??
        (isWarning ? Icons.warning_amber_rounded : Icons.error_outline_rounded);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 10.0),
            child: Icon(
              effectiveIcon,
              color: textColor,
              size: 22,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.35,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      child: Text(
                        actionLabel!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isDismissible && onDismiss != null) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: textColor,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              splashRadius: 16,
              tooltip: 'Dismiss',
              onPressed: onDismiss,
            ),
          ],
        ],
      ),
    );
  }
}
