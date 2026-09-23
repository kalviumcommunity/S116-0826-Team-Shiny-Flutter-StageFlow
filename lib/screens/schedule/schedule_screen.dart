import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/production_provider.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';
import '../../widgets/empty_state.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  Map<String, List<EventModel>> _groupEvents(List<EventModel> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final Map<String, List<EventModel>> groups = {
      'TODAY': [],
      'TOMORROW': [],
      'UPCOMING': [],
      'PAST CALLS': [],
    };

    for (final event in events) {
      final eventDate = DateTime(event.start.year, event.start.month, event.start.day);
      if (eventDate.isAtSameMomentAs(today)) {
        groups['TODAY']!.add(event);
      } else if (eventDate.isAtSameMomentAs(tomorrow)) {
        groups['TOMORROW']!.add(event);
      } else if (eventDate.isAfter(tomorrow)) {
        groups['UPCOMING']!.add(event);
      } else {
        groups['PAST CALLS']!.add(event);
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final schedProv = context.watch<ScheduleProvider>();
    final prodProv = context.watch<ProductionProvider>();

    final isDirector = auth.isDirector;
    final currentUserId = auth.currentUser?.id;
    final events = schedProv.getFilteredEvents(
      castUserId: isDirector ? null : currentUserId,
    );

    final grouped = _groupEvents(events);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Schedule'),
        actions: [
          if (isDirector)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Event',
              onPressed: () {
                if (prodProv.productions.isNotEmpty) {
                  context.push('/schedule/new', extra: prodProv.productions.first);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please create a production first.')),
                  );
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: theme.colorScheme.surface,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Calls', 'all', schedProv, theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rehearsals', 'rehearsals', schedProv, theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Auditions', 'auditions', schedProv, theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Performances', 'performances', schedProv, theme),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: events.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No upcoming calls',
                    subtitle: isDirector
                        ? 'Schedule rehearsals, blocking sessions, or performances with live conflict detection.'
                        : 'You have no scheduled calls or rehearsals under this filter.',
                    actionLabel: isDirector && prodProv.productions.isNotEmpty ? 'Schedule Call' : null,
                    onAction: isDirector && prodProv.productions.isNotEmpty
                        ? () => context.push('/schedule/new', extra: prodProv.productions.first)
                        : null,
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (grouped['TODAY']!.isNotEmpty) ...[
                        _buildSectionHeader('TODAY', grouped['TODAY']!.length, theme),
                        ...grouped['TODAY']!.map((e) => _buildEventItem(context, e, isDirector)),
                      ],
                      if (grouped['TOMORROW']!.isNotEmpty) ...[
                        _buildSectionHeader('TOMORROW', grouped['TOMORROW']!.length, theme),
                        ...grouped['TOMORROW']!.map((e) => _buildEventItem(context, e, isDirector)),
                      ],
                      if (grouped['UPCOMING']!.isNotEmpty) ...[
                        _buildSectionHeader('UPCOMING', grouped['UPCOMING']!.length, theme),
                        ...grouped['UPCOMING']!.map((e) => _buildEventItem(context, e, isDirector)),
                      ],
                      if (grouped['PAST CALLS']!.isNotEmpty) ...[
                        _buildSectionHeader('PAST CALLS', grouped['PAST CALLS']!.length, theme),
                        ...grouped['PAST CALLS']!.map((e) => _buildEventItem(context, e, isDirector)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: isDirector && prodProv.productions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/schedule/new', extra: prodProv.productions.first),
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Call'),
            )
          : null,
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, EventModel event, bool isDirector) {
    return EventCard(
      event: event,
      isDirector: isDirector,
      onEdit: isDirector ? () => context.push('/schedule/edit', extra: event) : null,
      onDelete: isDirector ? () => _confirmDelete(context, event.productionId, event.id) : null,
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    ScheduleProvider provider,
    ThemeData theme,
  ) {
    final isSelected = provider.activeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setFilter(value),
      selectedColor: theme.colorScheme.primary.withOpacity(0.12),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
        width: 1,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productionId, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel & Delete Event'),
        content: const Text(
          'Are you sure you want to remove this scheduled call? Any assigned cast members will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ScheduleProvider>().deleteEvent(productionId, eventId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scheduled call removed')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
