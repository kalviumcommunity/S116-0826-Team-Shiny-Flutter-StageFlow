import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import '../../models/production.dart';

import '../../providers/production_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../services/conflict_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/date_utils.dart';

class CreateEditEventScreen extends StatefulWidget {
  final EventModel? event;
  final Production? defaultProduction;

  const CreateEditEventScreen({
    super.key,
    this.event,
    this.defaultProduction,
  });

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProductionId;
  String _selectedType = 'Rehearsal'; // 'Rehearsal', 'Audition', 'Performance'
  late DateTime _eventDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final List<String> _selectedCastIds = [];

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _selectedProductionId = widget.event!.productionId;
      _selectedType = widget.event!.type;
      _eventDate = widget.event!.date;
      _startTime = TimeOfDay.fromDateTime(widget.event!.start);
      _endTime = TimeOfDay.fromDateTime(widget.event!.end);
      _venueController.text = widget.event!.venue;
      _notesController.text = widget.event!.notes;
      _selectedCastIds.addAll(widget.event!.castIds);
    } else {
      _selectedProductionId = widget.defaultProduction?.id;
      _eventDate = DateTime.now();
      _startTime = const TimeOfDay(hour: 18, minute: 0); // 6:00 PM
      _endTime = const TimeOfDay(hour: 20, minute: 0);   // 8:00 PM
      _venueController.text = 'Main Auditorium';
    }
  }

  @override
  void dispose() {
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _toggleCastMember(String userId) {
    setState(() {
      if (_selectedCastIds.contains(userId)) {
        _selectedCastIds.remove(userId);
      } else {
        _selectedCastIds.add(userId);
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductionId == null || _selectedProductionId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a production')),
      );
      return;
    }

    final startDateTime = _combineDateAndTime(_eventDate, _startTime);
    final endDateTime = _combineDateAndTime(_eventDate, _endTime);

    if (!Validators.isEndAfterStart(startDateTime, endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final prodProv = context.read<ProductionProvider>();
    final schedProv = context.read<ScheduleProvider>();

    final prodTitle = prodProv.productions
        .firstWhere((p) => p.id == _selectedProductionId,
            orElse: () => Production(
                  id: '',
                  title: 'Production',
                  description: '',
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  directorId: '',
                ))
        .title;

    final eventToSave = EventModel(
      id: widget.event?.id ?? '',
      productionId: _selectedProductionId!,
      productionTitle: prodTitle,
      date: _eventDate,
      start: startDateTime,
      end: endDateTime,
      type: _selectedType,
      venue: _venueController.text.trim(),
      castIds: _selectedCastIds,
      notes: _notesController.text.trim(),
    );

    // Save with Conflict Check
    ConflictResult? conflict;
    if (isEditing) {
      conflict = await schedProv.updateEventWithConflictCheck(
        event: eventToSave,
        usersMap: prodProv.usersMap,
      );
    } else {
      conflict = await schedProv.createEventWithConflictCheck(
        event: eventToSave,
        usersMap: prodProv.usersMap,
      );
    }

    if (conflict != null && conflict.hasConflict) {
      if (mounted) {
        _showConflictDialog(conflict);
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Event updated successfully!' : 'Event scheduled successfully!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      context.pop();
    }
  }

  void _showConflictDialog(ConflictResult conflict) {
    final isVenue = conflict.type == ConflictType.venue;
    final existingEvent = conflict.conflictingEvent;
    final existingProd = existingEvent?.productionTitle ?? 'Active Production';
    final existingType = existingEvent?.type ?? 'Event';
    final existingTime = existingEvent != null
        ? AppDateUtils.formatTimeRange(existingEvent.start, existingEvent.end)
        : 'Conflicting Time Window';
    final venueName = conflict.venue ?? existingEvent?.venue ?? _venueController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isVenue ? 'Venue Conflict' : 'Cast Member Conflict',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoal,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isVenue
                  ? 'This venue is already booked for another scheduled event during this time window.'
                  : '${conflict.conflictedUserName ?? "A performer"} is already scheduled for another call during this time window.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E0DA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isVenue && conflict.conflictedUserName != null) ...[
                    _buildConflictRow('Cast Member', conflict.conflictedUserName!),
                    const SizedBox(height: 6),
                  ],
                  _buildConflictRow('Existing Production', existingProd),
                  const SizedBox(height: 6),
                  _buildConflictRow('Existing Call', existingType),
                  const SizedBox(height: 6),
                  _buildConflictRow('Time', existingTime),
                  if (isVenue) ...[
                    const SizedBox(height: 6),
                    _buildConflictRow('Venue', venueName),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Cancel Call'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.burgundy,
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 40),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Edit Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prodProv = context.watch<ProductionProvider>();
    final schedProv = context.watch<ScheduleProvider>();
    final productions = prodProv.productions;
    final allUsers = prodProv.allUsers;

    if (_selectedProductionId == null && productions.isNotEmpty) {
      _selectedProductionId = productions.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Call' : 'Schedule Call'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: schedProv.isCheckingConflicts ? null : _handleSave,
              child: schedProv.isCheckingConflicts
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Choice Chips
              const Text(
                'Call Type',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip('Rehearsal'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Audition'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Performance'),
                ],
              ),
              const SizedBox(height: 18),

              // Production selector
              DropdownButtonFormField<String>(
                value: _selectedProductionId,
                decoration: const InputDecoration(
                  labelText: 'Production',
                  prefixIcon: Icon(Icons.theater_comedy),
                ),
                items: productions.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.title));
                }).toList(),
                onChanged: isEditing ? null : (val) => setState(() => _selectedProductionId = val),
                validator: (v) => Validators.required(v, 'Please choose a production'),
              ),
              const SizedBox(height: 18),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    AppDateUtils.formatDate(_eventDate),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Range Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _startTime.format(context),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time_filled),
                        ),
                        child: Text(
                          _endTime.format(context),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Venue Input
              TextFormField(
                controller: _venueController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Venue / Room',
                  hintText: 'e.g. Main Auditorium, Studio 2',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => Validators.required(v, 'Venue is required'),
              ),
              const SizedBox(height: 20),

              // Cast Multi-selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Called Cast Members',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    '${_selectedCastIds.length} Selected',
                    style: const TextStyle(
                      color: AppTheme.burgundy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: allUsers.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No performers found in directory.'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allUsers.length,
                        itemBuilder: (context, index) {
                          final user = allUsers[index];
                          final isSelected = _selectedCastIds.contains(user.id);
                          return CheckboxListTile(
                            dense: true,
                            activeColor: AppTheme.burgundy,
                            title: Text(
                              user.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            subtitle: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            value: isSelected,
                            onChanged: (_) => _toggleCastMember(user.id),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 18),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Scene Agenda',
                  hintText: 'e.g. Act I blocking, Scene 2 run-through with full props',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Conflict Detection Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.burgundy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.burgundy.withOpacity(0.18)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppTheme.burgundy, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'StageSync performs automated conflict detection across all productions for both venues and cast members before booking.',
                        style: TextStyle(fontSize: 12, height: 1.4, color: AppTheme.charcoal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: schedProv.isCheckingConflicts ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: schedProv.isCheckingConflicts
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Checking Availability...'),
                        ],
                      )
                    : Text(isEditing ? 'Update Scheduled Call' : 'Schedule Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = type);
      },
      selectedColor: AppTheme.burgundy.withOpacity(0.12),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppTheme.burgundy : Colors.black87,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.burgundy : const Color(0xFFE5E0DA),
      ),
    );
  }
}
