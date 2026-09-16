class ScheduleConflict {
  final String id;
  final String title;
  final String type; // 'Venue Double Booking', 'Cast Double Booking'
  final String who; // e.g. "Hamlet & Macbeth Cast" or "Eleanor Vance"
  final String what; // e.g. "Main Stage overlap during Act 1 Rehearsal"
  final String when; // e.g. "Today, 2:00 PM - 4:00 PM"
  final String where; // e.g. "Main Stage Auditorium"
  final String primaryProduction;
  final String conflictingProduction;
  final String primaryEventTitle;
  final String conflictingEventTitle;
  final List<String> resolutionOptions;
  bool isResolved;

  ScheduleConflict({
    required this.id,
    required this.title,
    required this.type,
    required this.who,
    required this.what,
    required this.when,
    required this.where,
    required this.primaryProduction,
    required this.conflictingProduction,
    required this.primaryEventTitle,
    required this.conflictingEventTitle,
    required this.resolutionOptions,
    this.isResolved = false,
  });
}
