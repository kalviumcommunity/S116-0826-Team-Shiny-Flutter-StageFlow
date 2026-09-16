import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';
import '../models/conflict.dart';
import 'stageflow_button.dart';
import 'stageflow_card.dart';
import 'status_chip.dart';

class ConflictCard extends StatelessWidget {
  final ScheduleConflict conflict;
  final VoidCallback onResolvePressed;

  const ConflictCard({
    super.key,
    required this.conflict,
    required this.onResolvePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<StageFlowThemeExtension>()!;

    return StageFlowCard(
      borderColor: theme.colorScheme.error,
      backgroundColor: ext.conflictBg.withAlpha(80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusChip(
                label: 'CRITICAL CONFLICT',
                type: ChipType.conflict,
                icon: Icons.error_outline,
              ),
              const Spacer(),
              Text(
                conflict.type,
                style: AppTypography.metadata.copyWith(color: ext.conflictText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conflict.title,
            style: AppTypography.headlineMd.copyWith(color: ext.conflictText),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: ext.conflictText.withAlpha(100)),
          const SizedBox(height: 12),

          // WHO
          _buildInfoRow(context, Icons.groups_outlined, 'WHO', conflict.who),
          const SizedBox(height: 6),

          // WHAT
          _buildInfoRow(context, Icons.report_problem_outlined, 'WHAT', conflict.what),
          const SizedBox(height: 6),

          // WHEN
          _buildInfoRow(context, Icons.schedule_outlined, 'WHEN', conflict.when),
          const SizedBox(height: 6),

          // WHERE
          _buildInfoRow(context, Icons.location_on_outlined, 'WHERE', conflict.where),
          const SizedBox(height: 14),

          StageFlowButton(
            label: 'Resolve Conflict',
            variant: ButtonVariant.primary,
            icon: Icons.flash_on,
            onPressed: onResolvePressed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final ext = Theme.of(context).extension<StageFlowThemeExtension>()!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ext.conflictText),
        const SizedBox(width: 8),
        SizedBox(
          width: 55,
          child: Text(
            '$label:',
            style: AppTypography.metadata.copyWith(
              color: ext.conflictText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
