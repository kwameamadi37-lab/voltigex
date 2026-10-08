import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/features/chatting/chat/data/models/message_model.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_media_entity.dart';

class MessageMediaModel extends MessageMediaEntity {
  MessageMediaModel({
    required String id,
    required String messageId,
    required String mediaType,
    required String mediaUrl,
    required String? thumbnailUrl,
    required Map<String, dynamic>? metadata,
}) : super(
    id: id,
    messageId: messageId,
    mediaType: mediaType,
    mediaUrl: mediaUrl,
    thumbnailUrl: thumbnailUrl,
    metadata: metadata,
  );

  factory MessageMediaModel.fromJson(Map<String, dynamic> json){

    return MessageMediaModel(
      id: json['id'],
      messageId: json['message_id'],
      mediaType: json['media_type'],
      mediaUrl: MediaPathUtils.normalizeStoredMediaPath(json['media_url']?.toString()) ?? '',
      thumbnailUrl: MediaPathUtils.normalizeStoredMediaPath(json['thumbnail_url']?.toString()),
      metadata: MessageModel.metadataFromJson(json['metadata']),
    );
  }
}