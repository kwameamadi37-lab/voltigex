import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:voltigex/core/media_path_utils.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/features/chatting/chat/data/models/daily_question_model.dart';
import 'package:voltigex/features/chatting/chat/data/models/message_model.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/chat_messages_fetch_result.dart';

String _chatUploadFileName(String filePath, String? originalFileName) {
  final pathExt = p.extension(filePath).toLowerCase();
  var name = (originalFileName != null && originalFileName.trim().isNotEmpty)
      ? originalFileName.trim()
      : p.basename(filePath);
  if (pathExt.isNotEmpty && p.extension(name).isEmpty) {
    name = '$name$pathExt';
  }
  return name;
}

/// Détecte le MIME automatiquement via `mime` (aucun forçage par défaut).
MediaType? _chatUploadContentType(String fileName, String filePath) {
  final detectedMime = lookupMimeType(fileName) ?? lookupMimeType(filePath);
  if (detectedMime == null || detectedMime.trim().isEmpty) {
    return null;
  }
  try {
    return MediaType.parse(detectedMime);
  } catch (_) {
    return null;
  }
}

class MessagesRemoteDataSource {
  final String baseUrl;

  MessagesRemoteDataSource({required this.baseUrl});

  String? _parsePartnerLastSeenMessageId(Map<String, dynamic>? root) {
    if (root == null) return null;
    final v = root['partner_last_seen_message_id'] ?? root['last_seen_message_id'];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  Future<ChatMessagesFetchResult> fetchMessages(
    String conversationId, {
    String? afterMessageId,
    String? updatedAfter,
    String? beforeMessageId,
    int? limit,
  }) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    try {
      final Map<String, dynamic>? queryParameters;
      if (beforeMessageId != null && beforeMessageId.isNotEmpty) {
        queryParameters = <String, dynamic>{
          'before_id': beforeMessageId,
          'limit': limit ?? 50,
        };
      } else {
        final qp = <String, dynamic>{};
        if (afterMessageId != null && afterMessageId.isNotEmpty) {
          qp['after_id'] = afterMessageId;
        }
        if (updatedAfter != null && updatedAfter.isNotEmpty) {
          qp['updated_after'] = updatedAfter;
        }
        queryParameters = qp.isEmpty ? null : qp;
      }

      final response = await dio.get(
        '/api/chat/conversations/$conversationId',
        queryParameters: queryParameters,
      );

      Map<String, dynamic>? root;
      if (response.data is Map<String, dynamic>) {
        root = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is Map) {
        root = Map<String, dynamic>.from(response.data as Map);
      }

      final data = root != null ? root['data'] : response.data;
      final List list = (data is List) ? data : <dynamic>[];
      final messages = list
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      return ChatMessagesFetchResult(
        messages: messages,
        partnerLastSeenMessageId: _parsePartnerLastSeenMessageId(root),
      );
    } on DioException {
      // Ici on renvoi directement l'erreur Dio
      rethrow;
    } catch (_) {
      // Autre type d'erreur
      throw Exception('chat.remote.fetchFailed');
    }
  }

  Future<DailyQuestionModel> fetchDailyQuestion(String conversationId) async {
    throw UnimplementedError('Daily questions are not supported by the unified Laravel chat API');
  }

  /// Premier message sans [conversation_id] : crée la conversation support et enregistre le message.
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
  }) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);
    final rid = int.tryParse(recipientUserId.trim());
    if (rid == null || rid < 1) {
      throw Exception('chat.remote.invalidRecipient');
    }
    final String? mediaUrlForApi = mediaUrl == null || mediaUrl.trim().isEmpty
        ? null
        : (MediaPathUtils.normalizeStoredMediaPath(mediaUrl.trim()) ?? mediaUrl.trim());
    final data = <String, dynamic>{
      'recipient_user_id': rid,
      'type': type,
      if (content != null) 'content': content,
      if (mediaType != null) 'media_type': mediaType,
      if (mediaUrlForApi != null) 'media_url': mediaUrlForApi,
      if (mediaWidth != null) 'media_width': mediaWidth,
      if (mediaHeight != null) 'media_height': mediaHeight,
      if (blurhash != null) 'blurhash': blurhash,
      if (metadata != null) 'metadata': metadata,
      if (clientId != null && clientId.trim().isNotEmpty) 'client_id': clientId.trim(),
    };
    final response = await dio.post<Map<String, dynamic>>(
      '/api/chat/messages/create-and-send',
      data: data,
    );
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        response.data != null) {
      return Map<String, dynamic>.from(response.data!);
    }
    throw Exception('chat.remote.createAndSendFailed');
  }

  Future<Map<String, dynamic>> uploadMedia(
    String filePath, {
    String? originalFileName,
  }) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    final uploadName = _chatUploadFileName(filePath, originalFileName);
    final contentType = _chatUploadContentType(uploadName, filePath);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: uploadName,
        contentType: contentType,
      ),
    });

    try {
      final response =
          await dio.post<dynamic>('/api/chat/messages/upload', data: formData);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      final body = response.data;
      print(
        '[DEBUG] Échec envoi chat : ${response.statusCode} - ${body is String ? body : body?.toString()}',
      );
    } on DioException catch (e) {
      final res = e.response;
      final body = res?.data;
      print(
        '[DEBUG] Échec envoi chat : ${res?.statusCode} - ${body is String ? body : body?.toString()}',
      );
      rethrow;
    }

    throw Exception('chat.remote.uploadFailed');
  }
}