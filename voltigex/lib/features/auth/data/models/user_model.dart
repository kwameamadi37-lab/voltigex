import 'package:voltigex/core/profile_image_utils.dart';
import 'package:voltigex/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String username,
    required String email,
    required String token,
    String? profilePhotoUrl,
    String? role,
  }) : super(
          id: id,
          username: username,
          email: email,
          token: token,
          profilePhotoUrl: profilePhotoUrl,
          role: role,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final photo = ProfileImage.firstUrlFromJson(json, [
      'profile_photo_url',
      'profile_image',
      'avatar',
      'photo',
    ]);
    return UserModel(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? json['alias'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      token: json['token'] ?? '',
      profilePhotoUrl: photo,
      role: json['role']?.toString(),
    );
  }
}