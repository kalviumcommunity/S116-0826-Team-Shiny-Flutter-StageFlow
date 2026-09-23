import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/events_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';

class ScheduleTab extends StatelessWidget {
  final String prodId;

  const ScheduleTab({super.key, required this.prodId});

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

  Map<DateTime, List<EventModel>> _groupEventsByDate(List<EventModel> events) {
    final Map<DateTime, List<EventModel>> grouped = {};
    for (final event in events) {
      final day =
          DateTime.utc(event.date.year, event.date.month, event.date.day);
      grouped.putIfAbsent(day, () => []).add(event);
    }
    return grouped;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EventsViewModel eventsVm,
    String eventId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: const Text(
              'Are you sure you want to remove this scheduled call?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.conflictRed,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await eventsVm.deleteEvent(prodId, eventId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsVm = context.watch<EventsViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final isDirector = authVm.currentUser?.role == 'director';
    final timeFormat = DateFormat('h:mm a');
    final dayFormat = DateFormat('EEEE, MMMM d, yyyy');

    if (eventsVm.isLoading && eventsVm.events.isEmpty) {
      return const Center(
        child: LoadingIndicator(message: 'Loading schedule...'),
      );
    }

    final grouped = _groupEventsByDate(eventsVm.events);

    return Column(
      children: [
        if (eventsVm.errorMessage != null) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ErrorBanner(
              message: eventsVm.errorMessage!,
              isDismissible: true,
              onDismiss: () => eventsVm.clearMessages(),
            ),
          ),
        ],
        if (isDirector)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${eventsVm.events.length} Events Scheduled',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      context.push('/production/$prodId/event/create'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Event'),
                ),
              ],
            ),
          ),
        Expanded(
          child: eventsVm.events.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 48,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No events scheduled',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDirector
                              ? 'Tap "+ Add Event" to schedule rehearsals, calls, and shows.'
                              : 'Rehearsals and call times will appear here once scheduled.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, dateIndex) {
                    final date = grouped.keys.elementAt(dateIndex);
                    final dayEvents = grouped[date]!;

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
                        ...dayEvents.map((event) {
                          final timeRange =
                              '${timeFormat.format(event.start)} - ${timeFormat.format(event.end)}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time and Type Chip
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        timeRange,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTypeBgColor(event.type),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          event.type,
                                          style: TextStyle(
                                            color: _getTypeColor(event.type),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                event.venue,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (event.notes.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            event.notes,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          event.castIds.isEmpty
                                              ? 'All Cast'
                                              : '${event.castIds.length} Cast Called',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppColors.spotlightAmberDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isDirector && event.id != null)
                                    PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          context.push(
                                            '/production/$prodId/event/edit',
                                            extra: event,
                                          );
                                        } else if (val == 'delete') {
                                          _confirmDelete(
                                            context,
                                            eventsVm,
                                            event.id!,
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.conflictRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
