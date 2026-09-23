import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/theme/app_colors.dart';
import 'package:stagesync/viewmodels/events_viewmodel.dart';
import 'package:stagesync/viewmodels/roles_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class CreateEditEventScreen extends StatefulWidget {
  final String prodId;
  final EventModel? initialEvent;

  const CreateEditEventScreen({
    super.key,
    required this.prodId,
    this.initialEvent,
  });

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _eventDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  String _eventType = 'Rehearsal';
  final Set<String> _selectedCastIds = {};
  String? _clientValidationError;

  bool get _isEditing => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      final ev = widget.initialEvent!;
      _eventDate = ev.date;
      _startTime = TimeOfDay.fromDateTime(ev.start);
      _endTime = TimeOfDay.fromDateTime(ev.end);
      _eventType = ev.type;
      _venueController.text = ev.venue;
      _notesController.text = ev.notes;
      _selectedCastIds.addAll(ev.castIds);
    }

    // Clear any previous error states from viewmodel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsViewModel>().clearMessages();
    });
  }

  @override
  void dispose() {
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
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
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  bool _validateTimes(DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      setState(() {
        _clientValidationError = 'End time must be after start time.';
      });
      return false;
    }
    setState(() {
      _clientValidationError = null;
    });
    return true;
  }

  void _showCastSelectDialog(List<RoleModel> roles) {
    final assignedRoles = roles.where((r) => r.assignedUserId != null).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Called Cast'),
              content: SizedBox(
                width: double.maxFinite,
                child: assignedRoles.isEmpty
                    ? const Text(
                        'No assigned roles available in this production yet. You can assign cast members in the Roles tab.',
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: assignedRoles.length,
                        itemBuilder: (context, index) {
                          final role = assignedRoles[index];
                          final userId = role.assignedUserId!;
                          final isSelected = _selectedCastIds.contains(userId);

                          return CheckboxListTile(
                            title: Text(role.name),
                            value: isSelected,
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  _selectedCastIds.add(userId);
                                } else {
                                  _selectedCastIds.remove(userId);
                                }
                              });
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveEvent() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final startDateTime = _combineDateTime(_eventDate, _startTime);
    final endDateTime = _combineDateTime(_eventDate, _endTime);

    if (!_validateTimes(startDateTime, endDateTime)) {
      return;
    }

    final eventsVm = context.read<EventsViewModel>();
    final newEvent = EventModel(
      id: widget.initialEvent?.id,
      date: DateTime.utc(_eventDate.year, _eventDate.month, _eventDate.day),
      start: startDateTime,
      end: endDateTime,
      type: _eventType,
      venue: _venueController.text.trim(),
      venueKey: EventModel.normalizeVenue(_venueController.text),
      castIds: _selectedCastIds.toList(),
      notes: _notesController.text.trim(),
    );

    bool success = false;
    if (_isEditing) {
      success = await eventsVm.updateEvent(
        widget.prodId,
        widget.initialEvent!.id!,
        newEvent,
      );
    } else {
      success = await eventsVm.createEvent(widget.prodId, newEvent);
    }

    // Notice: if conflictMessage occurred, success is false and we remain on screen
    if (success && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsVm = context.watch<EventsViewModel>();
    final rolesVm = context.watch<RolesViewModel>();
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Event' : 'Schedule Event'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // High-priority Schedule Conflict Warning Banner
                  if (eventsVm.conflictMessage != null) ...[
                    ErrorBanner(
                      title: 'Double-Booking Conflict Detected',
                      message: eventsVm.conflictMessage!,
                      isWarning: true,
                      isDismissible: true,
                      onDismiss: () => eventsVm.clearMessages(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Generic Error Banner
                  if (eventsVm.errorMessage != null) ...[
                    ErrorBanner(
                      message: eventsVm.errorMessage!,
                      isDismissible: true,
                      onDismiss: () => eventsVm.clearMessages(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Client validation message
                  if (_clientValidationError != null) ...[
                    ErrorBanner(
                      message: _clientValidationError!,
                      isDismissible: true,
                      onDismiss: () =>
                          setState(() => _clientValidationError = null),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Event Type Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _eventType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Event Type *',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Rehearsal',
                        child: Text('Rehearsal'),
                      ),
                      DropdownMenuItem(
                        value: 'Audition',
                        child: Text('Audition'),
                      ),
                      DropdownMenuItem(
                        value: 'Performance',
                        child: Text('Performance'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _eventType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Calendar Date Picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date *',
                        suffixIcon:
                            Icon(Icons.calendar_today_rounded, size: 20),
                      ),
                      child: Text(
                        dateFormat.format(_eventDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start and End Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartTime,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Time *',
                              suffixIcon:
                                  Icon(Icons.access_time_rounded, size: 20),
                            ),
                            child: Text(
                              _startTime.format(context),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: InkWell(
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Time *',
                              suffixIcon:
                                  Icon(Icons.access_time_rounded, size: 20),
                            ),
                            child: Text(
                              _endTime.format(context),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Venue Field with conflict helper text
                  TextFormField(
                    controller: _venueController,
                    decoration: const InputDecoration(
                      labelText: 'Venue *',
                      hintText: 'e.g. Main Stage, Rehearsal Room B',
                      helperText:
                          'Venue names must match exactly to detect conflicts',
                      helperMaxLines: 2,
                    ),
                    validator: (val) {
                      if ((val ?? '').trim().isEmpty) {
                        return 'Venue is required for conflict checks.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Cast Selection Multi-Select Button
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Called Cast Members',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        _selectedCastIds.isEmpty
                            ? 'No cast members selected (open call)'
                            : '${_selectedCastIds.length} cast members selected',
                        style: TextStyle(
                          color: _selectedCastIds.isEmpty
                              ? AppColors.textSubtle
                              : AppColors.spotlightAmberDark,
                        ),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () => _showCastSelectDialog(rolesVm.roles),
                        child: const Text('Select'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'e.g. Bring script, blocking Act 1 Scene 2',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button with double-tap prevention
                  PrimaryButton(
                    label: _isEditing ? 'Save Changes' : 'Schedule Event',
                    isLoading: eventsVm.isLoading,
                    onPressed: _saveEvent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
