import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';

class UpdateIdentityUseCase {
  UpdateIdentityUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? nationalite,
    String? numeroIdentification,
  }) {
    return _repository.updateIdentity(
      nom: nom,
      prenom: prenom,
      dateNaissance: dateNaissance,
      nationalite: nationalite,
      numeroIdentification: numeroIdentification,
    );
  }
}
