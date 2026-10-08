import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/features/chatting/conversation/data/models/conversation_model.dart';
import 'package:voltigex/features/chatting/conversation/data/models/user_search_result_model.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';

class ConversationsRemoteDataSource {
  final String baseUrl;

  ConversationsRemoteDataSource({required this.baseUrl});

  Future<List<ConversationModel>> fetchConversations({
    DateTime? since,
    bool fullSync = false,
  }) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    final Map<String, dynamic>? queryParameters;
    if (!fullSync && since != null) {
      queryParameters = {'since': since.toUtc().toIso8601String()};
    } else {
      queryParameters = null;
    }

    final response = await dio.get(
      '/api/chat/conversations',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is! List) {
        throw Exception('Failed to fetch conversations');
      }
      return data
          .map((json) => ConversationModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }

  /// Liste complète des contacts éligibles ([GET /api/chat/users/contacts]), même forme que la recherche.
  Future<List<UserSearchResultItem>> fetchChatContacts() async {
    final dio = DioClient().createDio(baseUrl: baseUrl);
    final response = await dio.get('/api/chat/users/contacts');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is! List) {
        throw Exception('Failed to fetch chat contacts');
      }
      return data
          .map((json) => UserSearchResultModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    }
    throw Exception('Failed to fetch chat contacts');
  }

  Future<List<UserSearchResultItem>> searchUsers({required String query}) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);
    final q = query.trim();
    final response = await dio.get(
      '/api/chat/users/search',
      queryParameters: {'q': q},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is! List) {
        throw Exception('Failed to search users');
      }
      return data
          .map((json) => UserSearchResultModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    }
    throw Exception('Failed to search users');
  }

  Future<String> checkOrCreateConversation({required String contactId}) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);
    final response = await dio.get('/api/chat/conversations/with-support');

    if(response.statusCode == 200){
      return (response.data['conversation_id'] ?? '').toString();
    } else {
      throw Exception('Failed to check or create support conversation');
    }
  }

  Future<String> getOrCreateConversationWithUser(String clientUserId) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);
    final response = await dio.get('/api/chat/conversations/with-user/$clientUserId');

    if (response.statusCode == 200 && response.data is Map) {
      final map = Map<String, dynamic>.from(response.data as Map);
      return (map['conversation_id'] ?? '').toString();
    }
    throw Exception('Impossible d\'ouvrir la conversation');
  }

}