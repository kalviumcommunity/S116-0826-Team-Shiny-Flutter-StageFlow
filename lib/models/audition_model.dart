import 'package:cloud_firestore/cloud_firestore.dart';

class AuditionModel {
  AuditionModel({
    this.id,
    required this.date,
    required this.time,
    required this.venue,
    required this.venueKey,
    required this.castIds,
    this.status = 'open',
    this.capacity,
  });

  final String? id;
  final DateTime date;
  final String time;
  final String venue;
  final String venueKey;
  final List<String> castIds;
  final String status;
  final int? capacity;

  bool get isFull => capacity != null && castIds.length >= capacity!;
  bool get isOpen => status == 'open' && !isFull;

  AuditionModel copyWith({
    String? id,
    DateTime? date,
    String? time,
    String? venue,
    String? venueKey,
    List<String>? castIds,
    String? status,
    int? capacity,
    bool clearCapacity = false,
  }) {
    return AuditionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      venueKey: venueKey ?? this.venueKey,
      castIds: castIds ?? this.castIds,
      status: status ?? this.status,
      capacity: clearCapacity ? null : (capacity ?? this.capacity),
    );
  }

  static String normalizeVenue(String venue) {
    return venue.trim().toLowerCase();
  }

  factory AuditionModel.fromMap(Map<String, dynamic> map, String id) {
    final venue = map['venue'] as String? ?? '';
    return AuditionModel(
      id: id,
      date: _coerceDateTime(
        map['date'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      time: map['time'] as String? ?? '',
      venue: venue,
      venueKey: map['venueKey'] as String? ?? normalizeVenue(venue),
      castIds:
          List<String>.from((map['castIds'] as List?) ?? const <dynamic>[]),
      status: map['status'] as String? ?? 'open',
      capacity: map['capacity'] is int ? map['capacity'] as int : null,
    );
  }

  factory AuditionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return AuditionModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'venue': venue,
      'venueKey': venueKey,
      'castIds': castIds,
      'status': status,
      if (capacity != null) 'capacity': capacity,
    };
  }

  static DateTime _coerceDateTime(dynamic value, {required DateTime fallback}) {
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return fallback;
  }
}
