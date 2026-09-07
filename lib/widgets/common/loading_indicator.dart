import 'package:flutter/material.dart';
import 'package:stagesync/theme/app_colors.dart';

/// A centered loading indicator for StageSync.
///
/// Features a customizable [CircularProgressIndicator] centered in its container
/// with an optional status [message] underneath.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 36.0,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.spotlightAmber;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
