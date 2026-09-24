import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/conflict.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class ResolveConflictScreen extends StatefulWidget {
  const ResolveConflictScreen({super.key});

  @override
  State<ResolveConflictScreen> createState() => _ResolveConflictScreenState();
}

class _ResolveConflictScreenState extends State<ResolveConflictScreen> {
  final _repository = MockStageFlowRepository();
  ScheduleConflict? _conflict;
  bool _isLoading = true;
  int _selectedOptionIndex = 0;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _loadConflict();
  }

  Future<void> _loadConflict() async {
    final conflicts = await _repository.getConflicts();
    if (mounted) {
      setState(() {
        _conflict = conflicts.isNotEmpty ? conflicts.first : null;
        _isLoading = false;
      });
    }
  }

  void _applyResolution() async {
    if (_conflict == null) return;
    setState(() {
      _isResolving = true;
    });

    final selectedResolution = _conflict!.resolutionOptions[_selectedOptionIndex];
    await _repository.resolveConflict(_conflict!.id, selectedResolution);

    if (mounted) {
      context.go('/conflicts/success');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resolve Conflict')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_conflict == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resolve Conflict')),
        body: const Center(child: Text('No active conflicts found.')),
      );
    }

    final conflict = _conflict!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve Stage Conflict'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Row(
              children: [
                const StatusChip(label: 'CONFLICT AUDIT', type: ChipType.conflict, icon: Icons.warning_amber_rounded),
                const SizedBox(width: 8),
                Text(conflict.type, style: AppTypography.metadata.copyWith(color: AppColors.conflictRed)),
              ],
            ),
            const SizedBox(height: 10),
            Text(conflict.title, style: AppTypography.headlineLg.copyWith(fontSize: 24)),
            const SizedBox(height: 16),

            // Side-by-side Conflict Breakdown
            StageFlowCard(
              borderColor: AppColors.conflictRed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConflictSection('WHO', conflict.who),
                  const Divider(height: 16),
                  _buildConflictSection('WHAT', conflict.what),
                  const Divider(height: 16),
                  _buildConflictSection('WHEN', conflict.when),
                  const Divider(height: 16),
                  _buildConflictSection('WHERE', conflict.where),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Competing Productions Comparison
            Text('COMPETING SCHEDULED CALLS', style: AppTypography.metadata.copyWith(color: AppColors.deepNavy)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StageFlowCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Theme.of(context).extension<StageFlowThemeExtension>()!.surfaceContainerLow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusChip(label: 'CALL A', type: ChipType.info),
                        const SizedBox(height: 6),
                        Text(conflict.primaryProduction, style: AppTypography.headlineMd.copyWith(fontSize: 16)),
                        Text(conflict.primaryEventTitle, style: AppTypography.bodyMd),
                        const SizedBox(height: 4),
                        const Text('2:00 PM - 4:00 PM', style: AppTypography.metadata),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.compare_arrows, color: AppColors.conflictRed, size: 28),
                ),
                Expanded(
                  child: StageFlowCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: AppColors.conflictRedBg.withAlpha(90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StatusChip(label: 'CALL B', type: ChipType.conflict),
                        const SizedBox(height: 6),
                        Text(conflict.conflictingProduction, style: AppTypography.headlineMd.copyWith(fontSize: 16)),
                        Text(conflict.conflictingEventTitle, style: AppTypography.bodyMd),
                        const SizedBox(height: 4),
                        const Text('2:30 PM - 5:00 PM', style: AppTypography.metadata),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resolution Options Selector
            Text('RECOMMENDED RESOLUTION ACTION', style: AppTypography.metadata.copyWith(color: AppColors.deepNavy)),
            const SizedBox(height: 10),

            Column(
              children: List.generate(conflict.resolutionOptions.length, (index) {
                final option = conflict.resolutionOptions[index];
                final isSelected = _selectedOptionIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedOptionIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.deepNavy : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.deepNavy : Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppColors.stageRed : Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: AppTypography.bodyLg.copyWith(
                                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            StageFlowButton(
              label: 'Confirm & Execute Resolution',
              variant: ButtonVariant.primary,
              icon: Icons.check_circle,
              isLoading: _isResolving,
              onPressed: _applyResolution,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictSection(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTypography.metadata.copyWith(
              color: AppColors.conflictRedText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyLg.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
