import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/venue.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final _repository = MockStageFlowRepository();
  List<Venue> _venues = [];
  bool _isLoading = true;
  bool _hasActiveConflict = false;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    final venues = await _repository.getVenues();
    final conflicts = await _repository.getConflicts();
    if (mounted) {
      setState(() {
        _venues = venues;
        _hasActiveConflict = conflicts.any((c) => !c.isResolved && c.type.contains('Venue'));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues & Spaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVenues,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Conflict Warning Banner
                  if (_hasActiveConflict) ...[
                    StageFlowCard(
                      borderColor: AppColors.conflictRed,
                      backgroundColor: AppColors.conflictRedBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded, color: AppColors.conflictRedText, size: 24),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'VENUE DOUBLE BOOKING DETECTED',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.conflictRedText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Main Stage Auditorium is booked simultaneously by Hamlet (Rehearsal) and Macbeth (Tech Call) today at 2:00 PM.',
                            style: AppTypography.bodyMd.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 14),
                          StageFlowButton(
                            label: 'Resolve Venue Conflict Now',
                            variant: ButtonVariant.primary,
                            icon: Icons.flash_on,
                            onPressed: () => context.go('/conflicts/resolve'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SectionHeader(title: 'Theatre Facility Spaces'),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _venues.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final venue = _venues[index];
                      final isConflict = venue.status.toLowerCase().contains('conflict');

                      return StageFlowCard(
                        borderColor: isConflict ? AppColors.conflictRed : Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    venue.name,
                                    style: AppTypography.headlineMd,
                                  ),
                                ),
                                StatusChip.fromStatusString(venue.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Location: ${venue.location} • Capacity: ${venue.capacity} seats',
                              style: AppTypography.bodyMd,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isConflict ? AppColors.conflictRedBg.withAlpha(90) : Theme.of(context).extension<StageFlowThemeExtension>()!.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isConflict ? Icons.error_outline : Icons.event_seat_outlined,
                                    size: 16,
                                    color: isConflict ? AppColors.conflictRedText : AppColors.deepNavy,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Current: ${venue.currentBooking}',
                                      style: AppTypography.metadata.copyWith(
                                        color: isConflict ? AppColors.conflictRedText : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: venue.techSpecs.map((spec) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                  ),
                                  child: Text(
                                    spec,
                                    style: AppTypography.metadata.copyWith(fontSize: 10),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
