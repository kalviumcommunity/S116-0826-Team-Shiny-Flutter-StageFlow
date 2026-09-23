import 'package:cloud_firestore/cloud_firestore.dart';

class Audition {
  final String id;
  final String productionId;
  final String? productionTitle;
  final DateTime date;
  final String time;
  final String venue;
  final List<String> castIds;

  const Audition({
    required this.id,
    required this.productionId,
    this.productionTitle,
    required this.date,
    required this.time,
    required this.venue,
    required this.castIds,
  });

  bool isUserSignedUp(String userId) => castIds.contains(userId);

  factory Audition.fromFirestore(
    DocumentSnapshot doc,
    String productionId, [
    String? productionTitle,
  ]) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    final rawCast = data['castIds'];
    final List<String> castList = [];
    if (rawCast is List) {
      for (var item in rawCast) {
        if (item != null) castList.add(item.toString());
      }
    }

    return Audition(
      id: doc.id,
      productionId: productionId,
      productionTitle: productionTitle,
      date: parseTimestamp(data['date']),
      time: data['time'] as String? ?? '',
      venue: data['venue'] as String? ?? '',
      castIds: castList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'time': time,
      'venue': venue,
      'castIds': castIds,
    };
  }

  Audition copyWith({
    String? id,
    String? productionId,
    String? productionTitle,
    DateTime? date,
    String? time,
    String? venue,
    List<String>? castIds,
  }) {
    return Audition(
      id: id ?? this.id,
      productionId: productionId ?? this.productionId,
      productionTitle: productionTitle ?? this.productionTitle,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      castIds: castIds ?? this.castIds,
    );
  }
}
