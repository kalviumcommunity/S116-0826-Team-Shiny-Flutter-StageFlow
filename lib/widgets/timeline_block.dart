import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';
import '../models/event.dart';
import 'stageflow_card.dart';
import 'status_chip.dart';

class TimelineBlock extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onTap;

  const TimelineBlock({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasConflict = event.hasConflict;

    return StageFlowCard(
      onTap: onTap,
      borderColor: hasConflict ? AppColors.conflictRed : Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle,
      backgroundColor: hasConflict ? AppColors.conflictRedBg.withAlpha(50) : Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.timeSlotString,
                style: AppTypography.metadata.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusChip(
                label: event.status,
                type: hasConflict ? ChipType.conflict : ChipType.success,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: AppTypography.headlineMd.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.theater_comedy, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                event.productionTitle,
                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                event.venueName,
                style: AppTypography.bodyMd,
              ),
            ],
          ),
          if (hasConflict) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.conflictRedBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.conflictRedText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.notes,
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.conflictRedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
