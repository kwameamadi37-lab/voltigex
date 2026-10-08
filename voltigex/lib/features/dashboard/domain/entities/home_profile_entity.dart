/// Profil affiché sur l’accueil (hors couche auth).
class HomeProfileEntity {
  const HomeProfileEntity({
    required this.displayName,
    this.photoUrl,
    this.role,
  });

  final String displayName;
  final String? photoUrl;
  /// Rôle Laravel (`user`, `admin`, …) pour l’avatar.
  final String? role;
}
