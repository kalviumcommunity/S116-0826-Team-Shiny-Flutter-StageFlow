import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/event.dart';
import '../../repositories/stageflow_repository.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stageflow_card.dart';
import '../../widgets/timeline_block.dart';

class MasterScheduleScreen extends StatefulWidget {
  const MasterScheduleScreen({super.key});

  @override
  State<MasterScheduleScreen> createState() => _MasterScheduleScreenState();
}

class _MasterScheduleScreenState extends State<MasterScheduleScreen> {
  final _repository = MockStageFlowRepository();
  List<ScheduleEvent> _events = [];
  bool _isLoading = true;
  int _selectedDayIndex = 0; // Today
  String _selectedTypeFilter = 'All';

  final List<DateTime> _weekDays = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _repository.getEvents();
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _weekDays[_selectedDayIndex];

    final filteredEvents = _events.where((e) {
      final matchesType = _selectedTypeFilter == 'All' ||
          (_selectedTypeFilter == 'Conflicts' ? e.hasConflict : e.type == _selectedTypeFilter);
      return matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/schedule/create'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday Selector Bar
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weekDays.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final day = _weekDays[index];
                        final isSelected = index == _selectedDayIndex;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.deepNavy : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.deepNavy : Theme.of(context).extension<StageFlowThemeExtension>()!.borderSubtle,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormatter.formatShortDate(day).split(',')[0].toUpperCase(),
                                  style: AppTypography.metadata.copyWith(
                                    color: isSelected ? AppColors.stageRed : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${day.day}',
                                  style: AppTypography.headlineMd.copyWith(
                                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Conflicts', 'Rehearsal', 'Tech Call', 'Fitting'].map((type) {
                        final isSelected = _selectedTypeFilter == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            selectedColor: type == 'Conflicts' ? AppColors.conflictRed : AppColors.deepNavy,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTypeFilter = type;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionHeader(
                    title: DateFormatter.formatFullDate(selectedDate),
                    actionLabel: '+ Add Event',
                    onActionPressed: () => context.go('/schedule/create'),
                  ),
                  const SizedBox(height: 12),

                  // Schedule List
                  Expanded(
                    child: filteredEvents.isEmpty
                        ? const StageFlowCard(
                            child: Center(
                              child: Text('No events found for selected filters.'),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredEvents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];
                              return TimelineBlock(
                                event: event,
                                onTap: () => context.go('/schedule/events/${event.id}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/schedule/create'),
        backgroundColor: AppColors.stageRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
