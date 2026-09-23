import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  EventModel({
    this.id,
    required this.date,
    required this.start,
    required this.end,
    required this.type,
    required this.venue,
    required this.venueKey,
    required this.castIds,
    required this.notes,
  });

  final String? id;
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final String type;
  final String venue;
  final String venueKey;
  final List<String> castIds;
  final String notes;

  EventModel copyWith({
    String? id,
    DateTime? date,
    DateTime? start,
    DateTime? end,
    String? type,
    String? venue,
    String? venueKey,
    List<String>? castIds,
    String? notes,
  }) {
    return EventModel(
      id: id ?? this.id,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
      venue: venue ?? this.venue,
      venueKey: venueKey ?? this.venueKey,
      castIds: castIds ?? this.castIds,
      notes: notes ?? this.notes,
    );
  }

  static String normalizeVenue(String venue) {
    return venue.trim().toLowerCase();
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    final venue = map['venue'] as String? ?? '';
    return EventModel(
      id: id,
      date: _coerceDateTime(
        map['date'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      start: _coerceDateTime(
        map['start'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      end: _coerceDateTime(
        map['end'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      type: map['type'] as String? ?? '',
      venue: venue,
      venueKey: map['venueKey'] as String? ?? normalizeVenue(venue),
      castIds:
          List<String>.from((map['castIds'] as List?) ?? const <dynamic>[]),
      notes: map['notes'] as String? ?? '',
    );
  }

  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return EventModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'start': start,
      'end': end,
      'type': type,
      'venue': venue,
      'venueKey': venueKey,
      'castIds': castIds,
      'notes': notes,
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
