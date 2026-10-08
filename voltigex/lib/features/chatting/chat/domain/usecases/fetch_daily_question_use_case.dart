import 'package:voltigex/features/chatting/chat/domain/entiies/daily_question_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';

class FetchDailyQuestionUseCase {
  final MessagesRepository messagesRepository;

  FetchDailyQuestionUseCase({required this.messagesRepository});

  Future<DailyQuestionEntity> call(String conversationId) async{
    return await messagesRepository.fetchDailyQuestion(conversationId);
  }
}