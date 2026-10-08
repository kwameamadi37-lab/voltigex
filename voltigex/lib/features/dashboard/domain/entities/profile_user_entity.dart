/// Utilisateur connecté (profil / paramètres), aligné sur GET /api/user.
class ProfileUserEntity {
  const ProfileUserEntity({
    required this.userId,
    required this.email,
    required this.phone,
    required this.nom,
    required this.prenom,
    this.alias = '',
    this.role = '',
    this.emailVerified = false,
    this.phoneVerified = false,
    this.country = '',
    this.city = '',
    this.postalCode = '',
    this.addressLine = '',
    this.dateNaissance = '',
    this.nationalite = '',
    this.numeroIdentification = '',
    this.profilePhotoUrl,
  });

  final String userId;
  final String email;
  final String phone;
  final String nom;
  final String prenom;
  final String alias;
  final String role;
  final bool emailVerified;
  final bool phoneVerified;
  final String country;
  final String city;
  final String postalCode;
  final String addressLine;
  final String dateNaissance;
  final String nationalite;
  final String numeroIdentification;
  final String? profilePhotoUrl;

  String get displayName {
    final p = prenom.trim();
    final n = nom.trim();
    if (p.isEmpty && n.isEmpty) {
      return alias.trim().isNotEmpty ? alias.trim() : 'Utilisateur';
    }
    return '$p $n'.trim();
  }
}
