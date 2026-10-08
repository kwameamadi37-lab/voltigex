import 'package:voltigex/features/dashboard/domain/entities/profile_user_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';

class GetProfileUserUseCase {
  GetProfileUserUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUserEntity> call() => _repository.getCurrentUser();
}
