import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';

class UpdatePasswordUseCase {
  UpdatePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
