class UserEntity {
  final String id;
  final String email;
  final String username;
  final String token;
  /// URL brute renvoyée par Laravel (peut être relative ou absente).
  final String? profilePhotoUrl;
  /// Rôle Laravel (`user`, `admin`, …) — utilisé pour le flux support.
  final String? role;

  UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.token = '',
    this.profilePhotoUrl,
    this.role,
  });
}
