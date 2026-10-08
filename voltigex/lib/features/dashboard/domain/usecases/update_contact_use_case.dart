import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';

class UpdateContactUseCase {
  UpdateContactUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required String email,
    required String phone,
  }) {
    return _repository.updateContact(email: email, phone: phone);
  }
}
