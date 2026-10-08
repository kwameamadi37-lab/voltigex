import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';

class UserSearchResultModel extends UserSearchResultItem {
  UserSearchResultModel({
    required super.userId,
    required super.displayName,
    super.email,
    super.profilePhotoUrl,
    super.participantRole,
    super.conversationId,
  });

  factory UserSearchResultModel.fromJson(Map<String, dynamic> json) {
    final rawPhoto = json['profile_photo_url'] ?? json['profile_image'];
    final s = rawPhoto?.toString().trim();
    final photo = s != null && s.isNotEmpty ? s : null;
    final roleRaw = json['role']?.toString().trim();
    final role = roleRaw != null && roleRaw.isNotEmpty ? roleRaw : null;
    final cid = json['conversation_id'];
    final email = json['email']?.toString();
    return UserSearchResultModel(
      userId: (json['id'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['email'] ?? '').toString(),
      email: email != null && email.isNotEmpty ? email : null,
      profilePhotoUrl: photo,
      participantRole: role,
      conversationId: cid == null ? null : cid.toString(),
    );
  }
}
