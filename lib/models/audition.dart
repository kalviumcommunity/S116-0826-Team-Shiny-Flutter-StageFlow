class AuditionCandidate {
  final String id;
  final String candidateName;
  final String roleApplied;
  final String productionTitle;
  final String timeSlot;
  final String status; // 'Called Back', 'Under Review', 'Cast', 'Archived'
  final String headshotUrl;
  final double rating;
  final String directorNotes;
  final String phone;
  final String email;

  const AuditionCandidate({
    required this.id,
    required this.candidateName,
    required this.roleApplied,
    required this.productionTitle,
    required this.timeSlot,
    required this.status,
    required this.headshotUrl,
    required this.rating,
    required this.directorNotes,
    required this.phone,
    required this.email,
  });
}
