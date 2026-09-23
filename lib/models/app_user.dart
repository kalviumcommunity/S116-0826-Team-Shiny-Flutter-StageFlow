class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'director' or 'cast'
  final String? photoURL;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoURL,
  });

  bool get isDirector => role.toLowerCase() == 'director';
  bool get isCast => role.toLowerCase() == 'cast' || role.toLowerCase() == 'cast member';

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      id: documentId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'cast',
      photoURL: map['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoURL': photoURL,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? photoURL,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}
