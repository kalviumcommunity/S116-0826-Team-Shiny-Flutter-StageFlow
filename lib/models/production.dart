class Production {
  final String id;
  final String title;
  final String status; // 'In Rehearsal', 'Tech Week', 'Pre-Production', 'Opening'
  final String director;
  final String openingDate;
  final String venue;
  final int totalCast;
  final int totalCues;
  final double progress; // 0.0 to 1.0
  final String imageUrl;
  final String description;

  const Production({
    required this.id,
    required this.title,
    required this.status,
    required this.director,
    required this.openingDate,
    required this.venue,
    required this.totalCast,
    required this.totalCues,
    required this.progress,
    required this.imageUrl,
    required this.description,
  });
}
