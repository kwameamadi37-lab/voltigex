import 'package:voltigex/features/auth/domain/entities/user_entity.dart';
import 'package:voltigex/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<void> call(String fcmToken){
    return repository.logout(fcmToken);
  }
}