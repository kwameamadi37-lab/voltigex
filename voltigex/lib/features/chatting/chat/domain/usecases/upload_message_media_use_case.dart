import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';

class UploadMessageMediaUseCase {
  final MessagesRepository messagesRepository;

  UploadMessageMediaUseCase({required this.messagesRepository,});

  Future<Map<String, dynamic>> call(
    String filePath, {
    String? originalFileName,
  }) async {
    return messagesRepository.uploadMedia(
      filePath,
      originalFileName: originalFileName,
    );
  }
}