import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/schedule_viewmodel.dart';
import '../../widgets/common/timeline_event_card.dart';

class MasterScheduleScreen extends StatefulWidget {
  const MasterScheduleScreen({super.key});

  @override
  State<MasterScheduleScreen> createState() => _MasterScheduleScreenState();
}

class _MasterScheduleScreenState extends State<MasterScheduleScreen> {
  String _selectedCategory = 'all'; // 'all', 'rehearsals', 'auditions', 'performances'
  bool _isCalendarView = false;
  DateTime _selectedCalendarDay = DateTime.now();
  String? _lastWatchedUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthViewModel>();
    final uid = auth.currentUser?.uid;

    if (uid != null && uid != _lastWatchedUid) {
      _lastWatchedUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final schedVm = context.read<ScheduleViewModel?>();
          schedVm?.startWatching(uid);
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScheduleViewModel? schedVm;
    try {
      schedVm = context.watch<ScheduleViewModel?>();
    } catch (_) {}

    final allItems = schedVm?.scheduledItems ?? <GlobalScheduleItem>[];

    // Category Counts
    final rehearsalCount = allItems.where((i) => i.event.type.toLowerCase().contains('rehearsal')).length;
    final auditionCount = allItems.where((i) => i.event.type.toLowerCase().contains('audition')).length;
    final perfCount = allItems.where((i) => i.event.type.toLowerCase().contains('performance')).length;

    // Filter by Category
    List<GlobalScheduleItem> filtered = allItems.where((i) {
      if (_selectedCategory == 'rehearsals') {
        return i.event.type.toLowerCase().contains('rehearsal');
      } else if (_selectedCategory == 'auditions') {
        return i.event.type.toLowerCase().contains('audition');
      } else if (_selectedCategory == 'performances') {
        return i.event.type.toLowerCase().contains('performance');
      }
      return true;
    }).toList();

    // If Calendar View is active, further filter by selected calendar day
    if (_isCalendarView) {
      filtered = filtered.where((i) {
        final d = i.event.date;
        return d.year == _selectedCalendarDay.year &&
            d.month == _selectedCalendarDay.month &&
            d.day == _selectedCalendarDay.day;
      }).toList();
    }

    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.canvasBase,
      appBar: AppBar(
        title: Text(
          'Master Schedule',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textCol,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24, color: AppColors.primaryContainer),
            tooltip: 'Create Event',
            onPressed: () => context.push('/schedule/create'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subheader & View Toggle (List / Cal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Production Callboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                        ),
                      ),
                      Text(
                        'Synchronized timeline & rehearsal calls',
                        style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                      ),
                    ],
                  ),
                  // Segmented View Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161F36) : const Color(0xFFEAEDFF),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _isCalendarView = false),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: !_isCalendarView
                                  ? (isDark ? const Color(0xFF283044) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: !_isCalendarView
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.format_list_bulleted,
                                  size: 14,
                                  color: !_isCalendarView ? AppColors.primaryContainer : subTextCol,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'List',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: !_isCalendarView ? FontWeight.w700 : FontWeight.w500,
                                    color: !_isCalendarView ? AppColors.primaryContainer : subTextCol,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isCalendarView = true),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isCalendarView
                                  ? (isDark ? const Color(0xFF283044) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: _isCalendarView
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_view_week,
                                  size: 14,
                                  color: _isCalendarView ? AppColors.primaryContainer : subTextCol,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Cal',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: _isCalendarView ? FontWeight.w700 : FontWeight.w500,
                                    color: _isCalendarView ? AppColors.primaryContainer : subTextCol,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      count: allItems.length,
                      key: 'all',
                      isSelected: _selectedCategory == 'all',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Rehearsals',
                      count: rehearsalCount,
                      key: 'rehearsals',
                      isSelected: _selectedCategory == 'rehearsals',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Auditions',
                      count: auditionCount,
                      key: 'auditions',
                      isSelected: _selectedCategory == 'auditions',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Performances',
                      count: perfCount,
                      key: 'performances',
                      isSelected: _selectedCategory == 'performances',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            // Week Day Selector Bar (When Calendar View is selected)
            if (_isCalendarView) _buildWeekCalendarBar(isDark, textCol, subTextCol),

            // Timeline Content Area
            Expanded(
              child: schedVm?.isLoading ?? false
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_note, size: 48, color: subTextCol.withValues(alpha: 0.5)),
                                const SizedBox(height: 12),
                                Text(
                                  'No calls scheduled in this view',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textCol,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap "Create Event" to log a rehearsal or performance call.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/schedule/create'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryContainer,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Create Event'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primaryContainer,
                          onRefresh: () async {
                            if (_lastWatchedUid != null) {
                              schedVm?.startWatching(_lastWatchedUid!);
                            }
                          },
                          child: _buildTimelineList(filtered, isDark, textCol, subTextCol),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendarBar(bool isDark, Color textCol, Color subTextCol) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F36) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final isSelected = day.year == _selectedCalendarDay.year &&
              day.month == _selectedCalendarDay.month &&
              day.day == _selectedCalendarDay.day;
          final isToday = day.year == now.year && day.month == now.month && day.day == now.day;

          return InkWell(
            onTap: () => setState(() => _selectedCalendarDay = day),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : (isToday ? AppColors.surfaceHigh : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(day)[0],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : subTextCol,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day.day.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : (isToday ? AppColors.primaryContainer : textCol),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required String key,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedCategory = key),
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : (isDark ? const Color(0xFF1E293B) : AppColors.surfaceHigh),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFDAE2FD)),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineList(
    List<GlobalScheduleItem> items,
    bool isDark,
    Color textCol,
    Color subTextCol,
  ) {
    // Group items by date string
    final Map<String, List<GlobalScheduleItem>> dateGroups = {};
    final now = DateTime.now();

    for (final item in items) {
      final d = item.event.date;
      String groupLabel;
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        groupLabel = 'Today • ${DateFormat("MMM d").format(d)}';
      } else if (d.year == now.year && d.month == now.month && d.day == now.day + 1) {
        groupLabel = 'Tomorrow • ${DateFormat("MMM d").format(d)}';
      } else {
        groupLabel = DateFormat('EEEE • MMM d, y').format(d);
      }
      dateGroups.putIfAbsent(groupLabel, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: dateGroups.entries.map((entry) {
        final label = entry.key;
        final groupItems = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Group Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Divider(
                      color: isDark ? const Color(0xFF283044) : AppColors.borderHairline,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Events in group with timeline line
            ...groupItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 6),
                child: TimelineEventCard(
                  event: item.event,
                  productionTitle: item.productionTitle,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
