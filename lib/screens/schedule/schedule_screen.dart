import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/schedule_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final uid = authVm.currentUser?.uid;
      if (uid != null) {
        context.read<ScheduleViewModel>().startWatching(uid);
      }
    });
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'rehearsal':
        return Colors.blue.shade700;
      case 'audition':
        return AppColors.spotlightAmberDark;
      case 'performance':
        return AppColors.primaryCharcoal;
      default:
        return AppColors.textDark;
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'rehearsal':
        return Colors.blue.shade50;
      case 'audition':
        return AppColors.spotlightAmberGlow;
      case 'performance':
        return AppColors.primaryCharcoalLight.withValues(alpha: 0.15);
      default:
        return AppColors.surfaceCard;
    }
  }

  Map<DateTime, List<GlobalScheduleItem>> _groupByDate(
    List<GlobalScheduleItem> items,
  ) {
    final Map<DateTime, List<GlobalScheduleItem>> grouped = {};
    for (final item in items) {
      final day = DateTime.utc(
        item.event.date.year,
        item.event.date.month,
        item.event.date.day,
      );
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduleVm = context.watch<ScheduleViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.currentUser;
    final timeFormat = DateFormat('h:mm a');
    final dayFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Master Schedule',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryCharcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user?.uid != null) {
              scheduleVm.startWatching(user!.uid!);
            }
          },
          child: _buildBody(context, scheduleVm, timeFormat, dayFormat),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ScheduleViewModel scheduleVm,
    DateFormat timeFormat,
    DateFormat dayFormat,
  ) {
    final theme = Theme.of(context);

    if (scheduleVm.isLoading && scheduleVm.scheduledItems.isEmpty) {
      return const Center(
        child: LoadingIndicator(message: 'Syncing schedule...'),
      );
    }

    if (scheduleVm.errorMessage != null && scheduleVm.scheduledItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ErrorBanner(
            message: scheduleVm.errorMessage!,
            isDismissible: false,
          ),
        ),
      );
    }

    if (scheduleVm.scheduledItems.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  size: 44,
                  color: AppColors.textSubtle,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Scheduled Events',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have no rehearsals, auditions, or performances on your calendar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = _groupByDate(scheduleVm.scheduledItems);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: grouped.keys.length,
      itemBuilder: (context, dateIndex) {
        final date = grouped.keys.elementAt(dateIndex);
        final dayItems = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                dayFormat.format(date),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryCharcoal,
                ),
              ),
            ),
            ...dayItems.map((item) {
              final ev = item.event;
              final timeRange =
                  '${timeFormat.format(ev.start)} - ${timeFormat.format(ev.end)}';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.push('/production/${item.prodId}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Production title badge & Event type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCharcoalLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.productionTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeBgColor(ev.type),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ev.type,
                                style: TextStyle(
                                  color: _getTypeColor(ev.type),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Time and Venue
                        Row(
                          children: [
                            Text(
                              timeRange,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      ev.venue,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (ev.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            ev.notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
