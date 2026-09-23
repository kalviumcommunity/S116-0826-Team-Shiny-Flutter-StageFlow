import 'package:flutter/material.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

class EventCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDirector;

  const EventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.isDirector = false,
  });

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'performance':
        return AppTheme.gold;
      case 'audition':
        return AppTheme.emerald;
      case 'rehearsal':
      default:
        return AppTheme.burgundy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = _getTypeColor(event.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type badge & actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.35), width: 1),
                  ),
                  child: Text(
                    event.type.toUpperCase(),
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                if (isDirector)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 17,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              size: 17,
                              color: Color(0xFFBA1A1A),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Production Title
            if (event.productionTitle != null && event.productionTitle!.isNotEmpty) ...[
              Text(
                event.productionTitle!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Time and Date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${AppDateUtils.formatDayOfWeek(event.startTime)}, ${AppDateUtils.formatDate(event.startTime)} • ${AppDateUtils.formatTimeRange(event.startTime, event.endTime)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Venue
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.venueName,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            // Cast called indicator
            if (event.requiredCast.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${event.requiredCast.length} cast member${event.requiredCast.length == 1 ? '' : 's'} called',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            // Notes
            if (event.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  event.notes,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


