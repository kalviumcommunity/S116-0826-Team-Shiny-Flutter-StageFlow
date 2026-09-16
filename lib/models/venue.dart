class Venue {
  final String id;
  final String name;
  final int capacity;
  final String location;
  final String status; // 'Available', 'Occupied', 'Conflict', 'Maintenance'
  final String currentBooking;
  final List<String> techSpecs;
  final String imageUrl;

  const Venue({
    required this.id,
    required this.name,
    required this.capacity,
    required this.location,
    required this.status,
    required this.currentBooking,
    required this.techSpecs,
    required this.imageUrl,
  });
}
