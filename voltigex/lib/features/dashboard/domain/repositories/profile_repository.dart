import 'package:voltigex/features/dashboard/domain/entities/profile_user_entity.dart';

abstract class ProfileRepository {
  Future<ProfileUserEntity> getCurrentUser();

  Future<void> updateContact({
    required String email,
    required String phone,
  });

  Future<void> updateIdentity({
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? nationalite,
    String? numeroIdentification,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> updateAddress({
    required String addressLine,
    required String country,
    required String city,
    required String zipCode,
  });
}
