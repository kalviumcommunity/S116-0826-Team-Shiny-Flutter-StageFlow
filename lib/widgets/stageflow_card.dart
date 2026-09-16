import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

class StageFlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const StageFlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<StageFlowThemeExtension>()!;

    final border = BorderSide(
      color: borderColor ?? ext.borderSubtle,
      width: 1.0,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.fromBorderSide(border),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            const BoxShadow(
              color: Color.fromRGBO(20, 29, 35, 0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
