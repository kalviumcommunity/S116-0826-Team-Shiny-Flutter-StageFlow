import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../repositories/stageflow_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/empty_state.dart';

class MasterScheduleScreen extends StatefulWidget {
  const MasterScheduleScreen({super.key});

  @override
  State<MasterScheduleScreen> createState() => _MasterScheduleScreenState();
}

class _MasterScheduleScreenState extends State<MasterScheduleScreen> {
  final _repository = MockStageFlowRepository();
  List<ScheduleEvent> _allEvents = [];
  bool _isLoading = true;
  String _selectedTypeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _repository.getEvents();
    if (mounted) {
      setState(() {
        _allEvents = events;
        _isLoading = false;
      });
    }
  }

  Map<String, List<ScheduleEvent>> _groupEvents(List<ScheduleEvent> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final Map<String, List<ScheduleEvent>> groups = {
      'TODAY': [],
      'TOMORROW': [],
      'UPCOMING': [],
      'PAST CALLS': [],
    };

    for (final event in events) {
      final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
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
    final auth = context.watch<AuthViewModel>();
    final isDirector = auth.currentUser?.role.toLowerCase() == 'director';

    final filteredEvents = _allEvents.where((e) {
      if (_selectedTypeFilter == 'All') return true;
      if (_selectedTypeFilter == 'Conflicts') return e.hasConflict;
      return e.type.toLowerCase() == _selectedTypeFilter.toLowerCase();
    }).toList();

    // Sort by startTime
    filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    final grouped = _groupEvents(filteredEvents);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Production Schedule'),
        actions: [
          if (isDirector)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Event',
              onPressed: () => context.go('/schedule/create'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Chips Row
                Container(
                  color: theme.colorScheme.surface,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Calls', 'All', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Conflicts', 'Conflicts', theme, isAlert: true),
                        const SizedBox(width: 8),
                        _buildFilterChip('Rehearsals', 'Rehearsal', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tech Calls', 'Tech Call', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('Fittings', 'Fitting', theme),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: filteredEvents.isEmpty
                      ? EmptyState(
                          icon: Icons.calendar_today_outlined,
                          title: 'No upcoming calls',
                          subtitle: isDirector
                              ? 'Schedule rehearsals, blocking sessions, or performances with live conflict detection.'
                              : 'You have no scheduled calls or rehearsals under this filter.',
                          actionLabel: isDirector ? 'Schedule Call' : null,
                          onAction: isDirector
                              ? () => context.go('/schedule/create')
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
      floatingActionButton: isDirector && _allEvents.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/schedule/create'),
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Call', style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String filterValue, ThemeData theme, {bool isAlert = false}) {
    final isSelected = _selectedTypeFilter == filterValue;
    
    Color selectedBgColor = isAlert ? const Color(0xFFBA1A1A).withOpacity(0.12) : theme.colorScheme.primary.withOpacity(0.12);
    Color selectedTextColor = isAlert ? const Color(0xFFBA1A1A) : theme.colorScheme.primary;
    Color borderColor = isSelected 
        ? (isAlert ? const Color(0xFFBA1A1A) : theme.colorScheme.primary) 
        : theme.colorScheme.outline;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedTypeFilter = filterValue;
        });
      },
      selectedColor: selectedBgColor,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? selectedTextColor : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: borderColor,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, ScheduleEvent event, bool isDirector) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => context.go('/schedule/events/${event.id}'),
        borderRadius: BorderRadius.circular(12),
        child: EventCard(
          event: event,
          isDirector: isDirector,
          onEdit: isDirector ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit event not implemented in mock.')),
            );
          } : null,
          onDelete: isDirector ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Delete event not implemented in mock.')),
            );
          } : null,
        ),
      ),
    );
  }
}
