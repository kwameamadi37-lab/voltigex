import 'package:voltigex/core/profile_image_utils.dart';
import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  ContactModel({
    required String id,
    required String username,
    required String email,
    String? profilePhotoUrl,
    String? role,
  }) : super(
          id: id,
          username: username,
          email: email,
          profilePhotoUrl: profilePhotoUrl,
          role: role,
        );

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final photo = ProfileImage.firstUrlFromJson(json, [
      'profile_photo_url',
      'profile_image',
      'avatar',
      'photo',
    ]);
    final roleRaw = json['role']?.toString().trim();
    return ContactModel(
      id: json['contact_id'].toString(),
      username: json['username'].toString(),
      email: json['email'].toString(),
      profilePhotoUrl: photo,
      role: roleRaw != null && roleRaw.isNotEmpty ? roleRaw : null,
    );
  }
}