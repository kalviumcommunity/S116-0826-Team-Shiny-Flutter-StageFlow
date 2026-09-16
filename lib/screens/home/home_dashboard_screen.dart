import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/conflict.dart';
import '../../models/event.dart';
import '../../models/production.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/avatar_badge.dart';
import '../../widgets/conflict_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/timeline_block.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _repository = MockStageFlowRepository();
  bool _isLoading = true;
  Production? _activeProduction;
  List<ScheduleEvent> _todayEvents = [];
  List<ScheduleConflict> _conflicts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prods = await _repository.getProductions();
    final events = await _repository.getEvents();
    final conflicts = await _repository.getConflicts();

    if (mounted) {
      setState(() {
        _activeProduction = prods.isNotEmpty ? prods.first : null;
        _todayEvents = events;
        _conflicts = conflicts.where((c) => !c.isResolved).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.masks, color: AppColors.stageRed, size: 28),
            const SizedBox(width: 8),
            Text(
              'StageFlow',
              style: AppTypography.headlineMd.copyWith(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications: 1 Critical Conflict pending.')),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: AvatarBadge(
              imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
              name: 'Eleanor Vance',
              radius: 16,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Production Highlight Banner
                    if (_activeProduction != null) ...[
                      StageFlowCard(
                        backgroundColor: AppColors.deepNavy,
                        borderColor: AppColors.deepNavy,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const StatusChip(
                                  label: 'ACTIVE PRODUCTION',
                                  type: ChipType.warning,
                                ),
                                Text(
                                  'Opens ${_activeProduction!.openingDate}',
                                  style: AppTypography.metadata.copyWith(color: const Color(0xFF9EA8B0)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _activeProduction!.title,
                              style: AppTypography.display.copyWith(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Director: ${_activeProduction!.director} • Venue: ${_activeProduction!.venue}',
                              style: AppTypography.bodyMd.copyWith(color: const Color(0xFFC4C7CA)),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _activeProduction!.progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.stageRed),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(_activeProduction!.progress * 100).toInt()}% Tech Preparedness',
                                  style: AppTypography.metadata.copyWith(color: Colors.white70),
                                ),
                                InkWell(
                                  onTap: () => context.go('/productions/${_activeProduction!.id}'),
                                  child: Text(
                                    'View Details →',
                                    style: AppTypography.metadata.copyWith(
                                      color: AppColors.stageRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Conflict Alert Section (If unresolved conflict exists)
                    if (_conflicts.isNotEmpty) ...[
                      ConflictCard(
                        conflict: _conflicts.first,
                        onResolvePressed: () => context.go('/conflicts/resolve'),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Today's Rehearsals & Tech Calls
                    SectionHeader(
                      title: "Today's Calls & Cues",
                      actionLabel: 'Master Schedule',
                      onActionPressed: () => context.go('/schedule'),
                    ),
                    const SizedBox(height: 12),

                    if (_todayEvents.isEmpty)
                      const StageFlowCard(
                        child: Center(
                          child: Text('No events scheduled for today.'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todayEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = _todayEvents[index];
                          return TimelineBlock(
                            event: event,
                            onTap: () => context.go('/schedule/events/${event.id}'),
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: StageFlowButton(
                            label: 'New Event',
                            variant: ButtonVariant.darkNavy,
                            icon: Icons.add,
                            onPressed: () => context.go('/schedule/create'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StageFlowButton(
                            label: 'Venues',
                            variant: ButtonVariant.secondary,
                            icon: Icons.location_on,
                            onPressed: () => context.go('/venues'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
