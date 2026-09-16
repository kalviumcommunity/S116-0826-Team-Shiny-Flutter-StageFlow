class CastMember {
  final String id;
  final String name;
  final String role; // Character or Position
  final String productionId;
  final String email;
  final String phone;
  final String avatarUrl;
  final String status; // 'Confirmed', 'Called Away', 'Understudy', 'On Stage'
  final bool isAvailable;

  const CastMember({
    required this.id,
    required this.name,
    required this.role,
    required this.productionId,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.status,
    required this.isAvailable,
  });
}
