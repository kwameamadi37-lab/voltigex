import 'package:voltigex/features/chatting/chat/data/datasources/messages_remote_data_source.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/chat_messages_fetch_result.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/daily_question_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesRemoteDataSource remoteDataSource;

  MessagesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatMessagesFetchResult> fetchMessages(
    String conversationId, {
    String? afterMessageId,
    String? updatedAfter,
    String? beforeMessageId,
    int? limit,
  }) async {
    return remoteDataSource.fetchMessages(
      conversationId,
      afterMessageId: afterMessageId,
      updatedAfter: updatedAfter,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    throw UnimplementedError();
  }

  @override
  Future<DailyQuestionEntity  > fetchDailyQuestion(String conversationId) async {
    return await remoteDataSource.fetchDailyQuestion(conversationId);
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, List<String> messageIds) async{
    // await remoteDataSource.markMessagesAsRead(conversationId, messageIds);
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadMedia(
    String filePath, {
    String? originalFileName,
  }) {
    return remoteDataSource.uploadMedia(
      filePath,
      originalFileName: originalFileName,
    );
  }

  @override
  Future<Map<String, dynamic>> createConversationAndSendMessage({
    required String recipientUserId,
    required String type,
    String? content,
    String? mediaType,
    String? mediaUrl,
    int? mediaWidth,
    int? mediaHeight,
    String? blurhash,
    Map<String, dynamic>? metadata,
    String? clientId,
  }) {
    return remoteDataSource.createConversationAndSendMessage(
      recipientUserId: recipientUserId,
      type: type,
      content: content,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      mediaWidth: mediaWidth,
      mediaHeight: mediaHeight,
      blurhash: blurhash,
      metadata: metadata,
      clientId: clientId,
    );
  }
}