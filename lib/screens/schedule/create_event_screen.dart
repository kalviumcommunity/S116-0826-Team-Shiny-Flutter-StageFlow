import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stagesync/theme/app_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../models/production_model.dart';
import '../../theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/events_viewmodel.dart';
import '../../viewmodels/productions_viewmodel.dart';
import '../../viewmodels/roles_viewmodel.dart';
import '../../widgets/dialogs/venue_conflict_dialog.dart';

class CreateEventScreen extends StatefulWidget {
  final String? initialProductionId;

  const CreateEventScreen({
    super.key,
    this.initialProductionId,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController(
    text: 'Act 1 blocking rehearsal and script walk-through.',
  );
  final _venueController = TextEditingController(text: 'Main Auditorium');

  String _selectedType = 'Rehearsal';
  String? _selectedProductionId;
  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);

  final Set<String> _selectedCastIds = <String>{};
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _eventTypes = [
    {'label': 'Rehearsal', 'icon': Icons.theater_comedy},
    {'label': 'Performance', 'icon': Icons.local_activity},
    {'label': 'Audition', 'icon': Icons.how_to_reg},
    {'label': 'Prod Meeting', 'icon': Icons.groups},
  ];

  final List<String> _predefinedVenues = [
    'Main Auditorium',
    'Black Box Rehearsal Hall A',
    'Studio 3 (Upstairs)',
    'Green Room Annex',
    'Stage Left Practice Room',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final prodVm = context.read<ProductionsViewModel>();
      final uid = authVm.currentUser?.uid;
      if (prodVm.productions.isEmpty && uid != null && uid.isNotEmpty) {
        prodVm.startWatching(uid);
      }

      final initialId = widget.initialProductionId ??
          (prodVm.productions.isNotEmpty ? prodVm.productions.first.id : null);

      if (initialId != null) {
        setState(() {
          _selectedProductionId = initialId;
        });
        context.read<RolesViewModel>().startWatching(initialId);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryCrimson,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryCrimson,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryCrimson,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _onProductionChanged(String? newId) {
    if (newId != null && newId != _selectedProductionId) {
      setState(() {
        _selectedProductionId = newId;
        _selectedCastIds.clear();
      });
      context.read<RolesViewModel>().startWatching(newId);
    }
  }

  Future<void> _handleCreateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductionId == null || _selectedProductionId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a production.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _eventDate.year,
      _eventDate.month,
      _eventDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _eventDate.year,
      _eventDate.month,
      _eventDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (!startDateTime.isBefore(endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time must be strictly before end time.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final venue = _venueController.text.trim();
    if (venue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify or select a venue.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final newEvent = EventModel(
      date: DateTime(_eventDate.year, _eventDate.month, _eventDate.day),
      start: startDateTime,
      end: endDateTime,
      type: _selectedType,
      venue: venue,
      venueKey: EventModel.normalizeVenue(venue),
      castIds: _selectedCastIds.toList(),
      notes: _notesController.text.trim(),
    );

    final eventsVm = context.read<EventsViewModel>();
    final success = await eventsVm.createEvent(_selectedProductionId!, newEvent);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Event call published successfully.')),
            ],
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/schedule');
      }
    } else {
      if (eventsVm.conflictMessage != null) {
        VenueConflictDialog.show(
          context,
          venueName: venue,
          conflictDetails: eventsVm.conflictMessage!,
          conflictingEventTitle: 'Overlapping Scheduled Event',
          conflictingEventTime:
              '${DateFormat('h:mm a').format(startDateTime)} - ${DateFormat('h:mm a').format(endDateTime)}',
          onEditEvent: () {
            // Stay on form to allow editing
          },
        );
      } else if (eventsVm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventsVm.errorMessage!),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : AppColors.borderHairline;
    final textCol = isDark ? const Color(0xFFFAF8FF) : AppColors.onSurface;
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final productionsVm = context.watch<ProductionsViewModel>();
    final rolesVm = context.watch<RolesViewModel>();

    // Select production fallback if not set
    final effectiveProdId = _selectedProductionId ??
        (productionsVm.productions.isNotEmpty ? productionsVm.productions.first.id : null);
    if (_selectedProductionId == null && effectiveProdId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedProductionId == null) {
          setState(() => _selectedProductionId = effectiveProdId);
          context.read<RolesViewModel>().startWatching(effectiveProdId);
        }
      });
    }

    ProductionModel? currentProd;
    try {
      currentProd = productionsVm.productions.firstWhere(
        (p) => p.id == effectiveProdId,
      );
    } catch (_) {
      currentProd = productionsVm.productions.isNotEmpty
          ? productionsVm.productions.first
          : null;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/schedule');
            }
          },
        ),
        title: Text(
          'Production Operations',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title & Context Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRODUCTION OPERATIONS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: subTextCol,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryCrimson,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Drafting Call',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryCrimson,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Create Event',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Log an official rehearsal call or callboard event for the company ledger.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: subTextCol,
                ),
              ),
              const SizedBox(height: 16),

              // Production Visual Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF223042),
                      Color(0xFF640023),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE REPERTORY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.secondaryWarmAmber,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentProd != null
                          ? '${currentProd.title} (${DateFormat('MMM d').format(currentProd.startDate)} – ${DateFormat('MMM d').format(currentProd.endDate)})'
                          : 'Select an active production below',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Event Type Selector (Segmented 2x2 Flow)
              Text(
                'Event Type',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.8,
                children: _eventTypes.map((t) {
                  final isSelected = _selectedType == t['label'];
                  return InkWell(
                    onTap: () => setState(() => _selectedType = t['label'] as String),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryCrimson
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryCrimson : borderCol,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : subTextCol,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              t['label'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : textCol,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Production Selection Dropdown Field
              Text(
                'Production',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 8),
              if (productionsVm.productions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: inputBg,
                    border: Border.all(color: borderCol),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.secondaryWarmAmber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No productions found. Create a production first.',
                          style: GoogleFonts.inter(fontSize: 13, color: subTextCol),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedProductionId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.theater_comedy, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: productionsVm.productions.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Text(
                        '${p.title} (${DateFormat('MMM d').format(p.startDate)} – ${DateFormat('MMM d').format(p.endDate)})',
                        style: GoogleFonts.inter(fontSize: 13, color: textCol),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _onProductionChanged,
                ),
              const SizedBox(height: 20),

              // Date Selection
              Text(
                'Date',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryCrimson),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('MMMM d, yyyy').format(_eventDate),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textCol,
                          ),
                        ),
                      ),
                      Icon(Icons.edit_calendar, size: 18, color: subTextCol),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Row (Two Columns)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickStartTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderCol),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule, size: 18, color: subTextCol),
                                const SizedBox(width: 8),
                                Text(
                                  _startTime.format(context),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textCol,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderCol),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.update, size: 18, color: subTextCol),
                                const SizedBox(width: 8),
                                Text(
                                  _endTime.format(context),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textCol,
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
              const SizedBox(height: 20),

              // Venue Selector with Availability Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Venue',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textCol,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Available',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Venue input / dropdown
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.stadium, size: 20),
                  hintText: 'e.g. Main Auditorium',
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.unfold_more),
                    onSelected: (val) {
                      setState(() => _venueController.text = val);
                    },
                    itemBuilder: (ctx) => _predefinedVenues.map((v) {
                      return PopupMenuItem<String>(
                        value: v,
                        child: Text(v, style: GoogleFonts.inter(fontSize: 13)),
                      );
                    }).toList(),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Venue is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Called Cast Members Multi-select Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Called Cast Members (${_selectedCastIds.length})',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textCol,
                    ),
                  ),
                  Text(
                    'Production Roster',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: subTextCol,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (rolesVm.castUsers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: inputBg,
                    border: Border.all(color: borderCol),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 20, color: subTextCol),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No cast members registered yet for this production.',
                          style: GoogleFonts.inter(fontSize: 12, color: subTextCol),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...rolesVm.castUsers.map((castUser) {
                      final isSelected = _selectedCastIds.contains(castUser.uid);
                      return FilterChip(
                        selected: isSelected,
                        avatar: CircleAvatar(
                          radius: 12,
                          backgroundColor: isSelected
                              ? AppColors.primaryCrimson
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          child: Text(
                            castUser.name.isNotEmpty
                                ? castUser.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textCol,
                            ),
                          ),
                        ),
                        label: Text(
                          castUser.name,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryCrimson : textCol,
                          ),
                        ),
                        selectedColor: AppColors.primaryCrimson.withValues(alpha: 0.12),
                        checkmarkColor: AppColors.primaryCrimson,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCastIds.add(castUser.uid ?? '');
                            } else {
                              _selectedCastIds.remove(castUser.uid ?? '');
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 20),

              // Rehearsal & Callboard Notes
              Text(
                'Rehearsal & Callboard Notes',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Specify scenes, call requirements, or blocking instructions...',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Visible to company stage management and summoned cast.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: subTextCol,
                ),
              ),
              const SizedBox(height: 16),

              // Immediate Callboard Sync Helper Mini-Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        size: 18,
                        color: AppColors.primaryCrimson,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Immediate Callboard Sync',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Creating this call will notify summoned cast and update their personal rehearsal calendar.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subTextCol,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Primary Action & Cancel Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleCreateEvent,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add_task, size: 20),
                  label: Text(
                    _isSubmitting ? 'Creating Call...' : 'Create Event',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/schedule');
                    }
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subTextCol,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
