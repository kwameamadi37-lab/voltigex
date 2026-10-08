import 'package:voltigex/core/profile_image_utils.dart';
import 'package:voltigex/features/dashboard/domain/entities/home_profile_entity.dart';

/// Réponse typique : `GET /api/user-info/{id}` → `data` (modèle User Laravel).
class UserProfileModel {
  UserProfileModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.alias,
    this.profilePhotoUrl,
    this.role,
    this.solde,
    this.devise,
  });

  final String id;
  final String nom;
  final String prenom;
  final String? alias;
  final String? profilePhotoUrl;
  final String? role;
  final double? solde;
  final String? devise;

  factory UserProfileModel.fromUserJson(Map<String, dynamic> json) {
    final photo = ProfileImage.firstUrlFromJson(json, [
      'profile_photo_url',
      'photo',
      'avatar',
    ]);
    final nom = (json['nom'] ?? '').toString().trim();
    final prenom = (json['prenom'] ?? '').toString().trim();
    final aliasStr = (json['alias'] ?? '').toString().trim();
    final roleStr = (json['role'] ?? '').toString().trim();

    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      nom: nom,
      prenom: prenom,
      alias: aliasStr.isEmpty ? null : aliasStr,
      profilePhotoUrl: photo,
      role: roleStr.isEmpty ? null : roleStr,
      solde: _parseDouble(json['solde']),
      devise: json['devise']?.toString(),
    );
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.'));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'alias': alias,
        'profile_photo_url': profilePhotoUrl,
        'role': role,
        'solde': solde,
        'devise': devise,
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      alias: json['alias']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      role: json['role']?.toString(),
      solde: _parseDouble(json['solde']),
      devise: json['devise']?.toString(),
    );
  }

  HomeProfileEntity toEntity() {
    final parts = <String>[];
    if (prenom.trim().isNotEmpty) parts.add(prenom.trim());
    if (nom.trim().isNotEmpty) parts.add(nom.trim());
    final name = parts.isNotEmpty
        ? parts.join(' ')
        : ((alias ?? '').trim().isNotEmpty ? alias!.trim() : 'Client');
    return HomeProfileEntity(
      displayName: name,
      photoUrl: profilePhotoUrl,
      role: role,
    );
  }
}
