sealed class ProfileEvent {}

/// Alias explicite pour recharger à l’ouverture d’un écran.
class FetchProfileData extends ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class LogoutRequested extends ProfileEvent {}

class UpdateContactSubmitted extends ProfileEvent {
  UpdateContactSubmitted({
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;
}

class UpdateIdentitySubmitted extends ProfileEvent {
  UpdateIdentitySubmitted({
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.nationalite,
    this.numeroIdentification,
  });

  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? nationalite;
  final String? numeroIdentification;
}

class UpdatePasswordSubmitted extends ProfileEvent {
  UpdatePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
}

class UpdateAddressSubmitted extends ProfileEvent {
  UpdateAddressSubmitted({
    required this.addressLine,
    required this.country,
    required this.city,
    required this.zipCode,
  });

  final String addressLine;
  final String country;
  final String city;
  final String zipCode;
}
