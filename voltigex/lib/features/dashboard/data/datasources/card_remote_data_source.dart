import 'package:dio/dio.dart';
import 'package:voltigex/core/api/api_endpoints.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/dashboard/data/models/card_model.dart';

/// Appels API carte (Sanctum : [DioClient] ajoute `Authorization: Bearer`).
class CardRemoteDataSource {
  CardRemoteDataSource();

  Dio get _dio => DioClient().createDio(baseUrl: Constants.backendServerAddress);

  String get _userId {
    final id = SessionController.instance.userId;
    if (id == null || id.trim().isEmpty) {
      throw StateError('Session utilisateur absente');
    }
    return id.trim();
  }

  Future<CardModel> getCardDetails() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userCardDetails,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return _parseCardResponse(response);
  }

  Future<CardModel> toggleFreeze({required bool freeze}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.userCardFreeze,
      data: {'freeze': freeze},
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return _parseCardResponse(response);
  }

  Future<void> deleteCard() async {
    final response = await _dio.delete<Map<String, dynamic>>(
      ApiEndpoints.userCardDelete,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final body = response.data;
    if (body != null && body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body['message']?.toString() ?? 'Suppression impossible',
      );
    }
  }

  /// Activation : vérifie numéro / expiration / CVV côté serveur.
  Future<CardModel> activateCard({
    required String cardHolder,
    required String cardNumber,
    required String dateExp,
    required String cvv,
    required String cardType,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.cardActivate,
        data: {
          'card_holder': cardHolder.trim(),
          'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
          'expiry_date': dateExp,
          'cvv': cvv,
          'card_type': cardType.toLowerCase().trim(),
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );
      
      final body = response.data;

      if (body == null) {
        throw DioException(requestOptions: response.requestOptions, message: 'Réponse vide');
      }
      
      if (body['success'] != true) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: body['message']?.toString() ?? 'Activation refusée',
        );
      }
      
      return await getCardDetails();
    } catch (_) {
      throw Exception('Erreur d\'enregistrement de demande');
    }
  }

  CardModel _parseCardResponse(Response<Map<String, dynamic>> response) {
    final body = response.data;
    if (body == null) {
      throw DioException(requestOptions: response.requestOptions, message: 'Réponse vide');
    }
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body['message']?.toString() ?? 'Erreur carte',
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(requestOptions: response.requestOptions, message: 'Format carte invalide');
    }
    return CardModel.fromJson(data);
  }
}
