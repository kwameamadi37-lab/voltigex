class ContactEntity {
  final String id;
  final String username;
  final String email;
  final String? profilePhotoUrl;
  final String? role;

  ContactEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profilePhotoUrl,
    this.role,
  });
}
