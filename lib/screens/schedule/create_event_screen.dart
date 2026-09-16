import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_typography.dart';
import '../../models/event.dart';
import '../../repositories/stageflow_repository.dart';
import '../../widgets/stageflow_button.dart';
import '../../widgets/stageflow_text_field.dart';

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
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  bool _isSaving = false;

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
      final end = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);

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
          const SnackBar(content: Text('New event successfully added to schedule!')),
        );
        context.go('/schedule');
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event Call'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule Call & Cue', style: AppTypography.headlineLg),
              const SizedBox(height: 4),
              Text('Define the call title, venue assignment, time slot, and cast requirements.', style: AppTypography.bodyMd),
              const SizedBox(height: 24),

              // Title Input
              StageFlowTextField(
                label: 'Call Title',
                hint: 'e.g. Act 2 Scene 1 Rehearsal',
                controller: _titleController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Production Dropdown
              Text('PRODUCTION', style: AppTypography.metadata),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedProduction,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                items: ['Hamlet', 'Macbeth', 'The Tempest', 'Romeo & Juliet'].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProduction = val);
                },
              ),
              const SizedBox(height: 16),

              // Event Type Dropdown
              Text('EVENT TYPE', style: AppTypography.metadata),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                items: ['Rehearsal', 'Tech Call', 'Fitting', 'Audition', 'Performance'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),

              // Venue Dropdown
              Text('VENUE / ROOM', style: AppTypography.metadata),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedVenue,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                items: ['Main Stage', 'Studio Theatre', 'Rehearsal Room A', 'Rehearsal Room B'].map((v) {
                  return DropdownMenuItem(value: v, child: Text(v));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedVenue = val);
                },
              ),
              const SizedBox(height: 16),

              // Time Picker Buttons
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('START TIME', style: AppTypography.metadata),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: _startTime);
                            if (picked != null) setState(() => _startTime = picked);
                          },
                          child: Text(_startTime.format(context)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('END TIME', style: AppTypography.metadata),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: _endTime);
                            if (picked != null) setState(() => _endTime = picked);
                          },
                          child: Text(_endTime.format(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes Input
              StageFlowTextField(
                label: 'Technical / Script Notes',
                hint: 'Specific props, lighting setups, or script pages...',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              StageFlowButton(
                label: 'Save & Publish Call',
                variant: ButtonVariant.primary,
                isLoading: _isSaving,
                onPressed: _saveEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
