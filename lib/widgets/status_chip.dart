import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';

enum ChipType { success, warning, conflict, info, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.type = ChipType.neutral,
    this.icon,
  });

  factory StatusChip.fromStatusString(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('conflict') || lower.contains('double')) {
      return StatusChip(label: status, type: ChipType.conflict, icon: Icons.warning_amber_rounded);
    } else if (lower.contains('rehearsal') || lower.contains('confirmed') || lower.contains('cast') || lower.contains('available')) {
      return StatusChip(label: status, type: ChipType.success, icon: Icons.check_circle_outline);
    } else if (lower.contains('tech') || lower.contains('called') || lower.contains('occupied') || lower.contains('review')) {
      return StatusChip(label: status, type: ChipType.warning, icon: Icons.access_time_rounded);
    } else if (lower.contains('pre-production') || lower.contains('open') || lower.contains('pending')) {
      return StatusChip(label: status, type: ChipType.info, icon: Icons.info_outline);
    }
    return StatusChip(label: status, type: ChipType.neutral);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<StageFlowThemeExtension>()!;

    Color bg;
    Color fg;

    switch (type) {
      case ChipType.success:
        bg = ext.successBg;
        fg = ext.successText;
        break;
      case ChipType.warning:
        bg = ext.warningBg;
        fg = ext.warningText;
        break;
      case ChipType.conflict:
        bg = ext.conflictBg;
        fg = ext.conflictText;
        break;
      case ChipType.info:
        bg = ext.infoBg;
        fg = ext.infoText;
        break;
      case ChipType.neutral:
        bg = ext.surfaceContainerLow;
        fg = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.metadata.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
