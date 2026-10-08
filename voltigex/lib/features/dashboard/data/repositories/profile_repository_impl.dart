import 'package:voltigex/features/dashboard/data/datasources/profile_remote_data_source.dart';
import 'package:voltigex/features/dashboard/domain/entities/profile_user_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<ProfileUserEntity> getCurrentUser() => _remote.fetchMe();

  @override
  Future<void> updateContact({
    required String email,
    required String phone,
  }) {
    return _remote.updateContact(email: email, phone: phone);
  }

  @override
  Future<void> updateIdentity({
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? nationalite,
    String? numeroIdentification,
  }) {
    return _remote.updateIdentity(
      nom: nom,
      prenom: prenom,
      dateNaissance: dateNaissance,
      nationalite: nationalite,
      numeroIdentification: numeroIdentification,
    );
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _remote.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<void> updateAddress({
    required String addressLine,
    required String country,
    required String city,
    required String zipCode,
  }) {
    return _remote.updateAddress(
      addressLine: addressLine,
      city: city,
      postalCode: zipCode,
      country: country,
    );
  }
}
