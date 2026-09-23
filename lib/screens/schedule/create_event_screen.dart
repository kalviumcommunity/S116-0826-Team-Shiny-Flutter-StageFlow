import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_typography.dart';
import '../../models/event.dart';
import '../../repositories/stageflow_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../utils/validators.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _repository = MockStageFlowRepository();

  String _selectedType = 'Rehearsal';
  String _selectedProduction = 'Hamlet';
  String _selectedVenue = 'Main Stage';
  DateTime _eventDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  bool _isSaving = false;

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final start = DateTime(_eventDate.year, _eventDate.month, _eventDate.day, _startTime.hour, _startTime.minute);
      final end = DateTime(_eventDate.year, _eventDate.month, _eventDate.day, _endTime.hour, _endTime.minute);

      final newEvent = ScheduleEvent(
        id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        productionId: _selectedProduction.toLowerCase(),
        productionTitle: _selectedProduction,
        type: _selectedType,
        startTime: start,
        endTime: end,
        venueName: _selectedVenue,
        requiredRoles: ['Lead Cast', 'Stage Manager'],
        requiredCast: ['Eleanor Vance', 'Arjun Patel'],
        hasConflict: false,
        status: 'Confirmed',
        notes: _notesController.text,
      );

      await _repository.addEvent(newEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New event successfully added to schedule!'),
            backgroundColor: AppTheme.emerald,
          ),
        );
        context.go('/schedule');
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.burgundy,
              onPrimary: Colors.white,
              onSurface: AppTheme.charcoal,
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
              primary: AppTheme.burgundy,
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
              primary: AppTheme.burgundy,
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

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Schedule Call & Cue'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isSaving
                ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ))
                : TextButton(
                    onPressed: _saveEvent,
                    child: const Text(
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
              Text(
                'Call Title',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Act 2 Scene 1 Rehearsal',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => Validators.required(v, 'Please enter event title'),
              ),
              const SizedBox(height: 20),

              // Event Type Choice Chips
              Text(
                'Call Type',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeChip('Rehearsal'),
                    const SizedBox(width: 8),
                    _buildTypeChip('Tech Call'),
                    const SizedBox(width: 8),
                    _buildTypeChip('Fitting'),
                    const SizedBox(width: 8),
                    _buildTypeChip('Audition'),
                    const SizedBox(width: 8),
                    _buildTypeChip('Performance'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Production selector
              DropdownButtonFormField<String>(
                value: _selectedProduction,
                decoration: const InputDecoration(
                  labelText: 'Production',
                  prefixIcon: Icon(Icons.theater_comedy),
                ),
                items: ['Hamlet', 'Macbeth', 'The Tempest', 'Romeo & Juliet'].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProduction = val);
                },
              ),
              const SizedBox(height: 20),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    DateFormatter.formatFullDate(_eventDate),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Range Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 20),

              // Venue Dropdown
              DropdownButtonFormField<String>(
                value: _selectedVenue,
                decoration: const InputDecoration(
                  labelText: 'Venue / Room',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: ['Main Stage', 'Studio Theatre', 'Rehearsal Room A', 'Rehearsal Room B'].map((v) {
                  return DropdownMenuItem(value: v, child: Text(v));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedVenue = val);
                },
              ),
              const SizedBox(height: 20),

              // Notes Input
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Technical / Script Notes',
                  hintText: 'Specific props, lighting setups, or script pages...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.burgundy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveEvent,
                  child: const Text('Save & Publish Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = type),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }
}
