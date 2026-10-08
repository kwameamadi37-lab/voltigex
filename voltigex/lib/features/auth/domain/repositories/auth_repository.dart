import 'package:voltigex/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<void> logout(String fcmToken);
}