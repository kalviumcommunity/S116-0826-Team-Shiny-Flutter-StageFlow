class ScheduleEvent {
  final String id;
  final String title;
  final String productionId;
  final String productionTitle;
  final String type; // 'Rehearsal', 'Tech Call', 'Fitting', 'Audition', 'Performance'
  final DateTime startTime;
  final DateTime endTime;
  final String venueName;
  final List<String> requiredRoles;
  final List<String> requiredCast;
  final bool hasConflict;
  final String status; // 'Confirmed', 'Pending', 'Conflict'
  final String notes;

  const ScheduleEvent({
    required this.id,
    required this.title,
    required this.productionId,
    required this.productionTitle,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.venueName,
    required this.requiredRoles,
    required this.requiredCast,
    this.hasConflict = false,
    this.status = 'Confirmed',
    this.notes = '',
  });

  String get timeSlotString {
    final startHour = startTime.hour > 12 ? startTime.hour - 12 : (startTime.hour == 0 ? 12 : startTime.hour);
    final startAmpm = startTime.hour >= 12 ? 'PM' : 'AM';
    final startMin = startTime.minute.toString().padLeft(2, '0');

    final endHour = endTime.hour > 12 ? endTime.hour - 12 : (endTime.hour == 0 ? 12 : endTime.hour);
    final endAmpm = endTime.hour >= 12 ? 'PM' : 'AM';
    final endMin = endTime.minute.toString().padLeft(2, '0');

    return '$startHour:$startMin $startAmpm - $endHour:$endMin $endAmpm';
  }
}
