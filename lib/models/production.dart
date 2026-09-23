import 'package:cloud_firestore/cloud_firestore.dart';

class Production {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String directorId;
  final String? imageURL;

  const Production({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.directorId,
    this.imageURL,
  });

  factory Production.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Production(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      startDate: data['startDate'] is Timestamp
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] is Timestamp
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30)),
      directorId: data['directorId'] as String? ?? '',
      imageURL: data['imageURL'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'directorId': directorId,
      'imageURL': imageURL,
    };
  }

  Production copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? directorId,
    String? imageURL,
  }) {
    return Production(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      directorId: directorId ?? this.directorId,
      imageURL: imageURL ?? this.imageURL,
    );
  }
}
