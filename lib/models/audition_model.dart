import 'package:cloud_firestore/cloud_firestore.dart';

class AuditionModel {
  AuditionModel({
    required this.date,
    required this.time,
    required this.venue,
    required this.venueKey,
    required this.castIds,
  });

  final DateTime date;
  final String time;
  final String venue;
  final String venueKey;
  final List<String> castIds;

  static String normalizeVenue(String venue) {
    return venue.trim().toLowerCase();
  }

  factory AuditionModel.fromMap(Map<String, dynamic> map, String id) {
    final venue = map['venue'] as String? ?? '';
    return AuditionModel(
      date: _coerceDateTime(
        map['date'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      time: map['time'] as String? ?? '',
      venue: venue,
      venueKey: map['venueKey'] as String? ?? normalizeVenue(venue),
      castIds:
          List<String>.from((map['castIds'] as List?) ?? const <dynamic>[]),
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
