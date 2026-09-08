import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.name,
    required this.email,
    required this.role,
    this.photoURL,
    required this.createdAt,
  });

  final String name;
  final String email;
  final String role;
  final String? photoURL;
  final DateTime createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'cast',
      photoURL: map['photoURL'] as String?,
      createdAt: _coerceDateTime(
        map['createdAt'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return UserModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoURL': photoURL,
      'createdAt': createdAt,
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
