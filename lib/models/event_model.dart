import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String productionId;
  final String? productionTitle;
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final String type; // 'Rehearsal', 'Audition', 'Performance'
  final String venue;
  final List<String> castIds;
  final String notes;

  const EventModel({
    required this.id,
    required this.productionId,
    this.productionTitle,
    required this.date,
    required this.start,
    required this.end,
    required this.type,
    required this.venue,
    required this.castIds,
    this.notes = '',
  });

  bool get isRehearsal => type.toLowerCase() == 'rehearsal';
  bool get isAudition => type.toLowerCase() == 'audition';
  bool get isPerformance => type.toLowerCase() == 'performance';

  factory EventModel.fromFirestore(
    DocumentSnapshot doc,
    String productionId, [
    String? productionTitle,
  ]) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseTimestamp(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      return fallback;
    }

    final dateVal = parseTimestamp(data['date'], DateTime.now());
    final startVal = parseTimestamp(data['start'], dateVal);
    final endVal = parseTimestamp(data['end'], startVal.add(const Duration(hours: 2)));

    final rawCast = data['castIds'];
    final List<String> castList = [];
    if (rawCast is List) {
      for (var item in rawCast) {
        if (item != null) castList.add(item.toString());
      }
    }

    return EventModel(
      id: doc.id,
      productionId: productionId,
      productionTitle: productionTitle,
      date: dateVal,
      start: startVal,
      end: endVal,
      type: data['type'] as String? ?? 'Rehearsal',
      venue: data['venue'] as String? ?? '',
      castIds: castList,
      notes: data['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'type': type,
      'venue': venue,
      'castIds': castIds,
      'notes': notes,
    };
  }

  EventModel copyWith({
    String? id,
    String? productionId,
    String? productionTitle,
    DateTime? date,
    DateTime? start,
    DateTime? end,
    String? type,
    String? venue,
    List<String>? castIds,
    String? notes,
  }) {
    return EventModel(
      id: id ?? this.id,
      productionId: productionId ?? this.productionId,
      productionTitle: productionTitle ?? this.productionTitle,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
      venue: venue ?? this.venue,
      castIds: castIds ?? this.castIds,
      notes: notes ?? this.notes,
    );
  }
}
