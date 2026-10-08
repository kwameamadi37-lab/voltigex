import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:voltigex/core/api/api_endpoints.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/dashboard/data/models/transaction_model.dart';
import 'package:voltigex/features/dashboard/data/models/user_profile_model.dart';

/// Appels API pour l’accueil (Sanctum : [DioClient] ajoute `Authorization: Bearer`).
class HomeRemoteDataSource {
  HomeRemoteDataSource();

  Dio get _dio => DioClient().createDio(baseUrl: Constants.backendServerAddress);

  String get _userId {
    final id = SessionController.instance.userId;
    if (id == null || id.trim().isEmpty) {
      throw StateError('Session utilisateur absente');
    }
    return id.trim();
  }

  /// Cache court pour éviter deux GET identiques dans la même frame (profil + solde).
  Map<String, dynamic>? _userInfoCache;
  DateTime? _userInfoCacheAt;

  Future<Map<String, dynamic>> _fetchUserRow() async {
    final now = DateTime.now();
    if (_userInfoCache != null &&
        _userInfoCacheAt != null &&
        now.difference(_userInfoCacheAt!) < const Duration(seconds: 2)) {
      return _userInfoCache!;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userInfo(_userId),
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );
    final body = response.data;
    if (body == null) throw DioException(requestOptions: response.requestOptions, message: 'Réponse vide');
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body['message']?.toString() ?? 'Erreur profil',
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(requestOptions: response.requestOptions, message: 'Format profil invalide');
    }
    _userInfoCache = data;
    _userInfoCacheAt = now;
    return data;
  }

  /// Nom, prénom, URL de photo (champs Laravel `nom`, `prenom`, médias optionnels).
  Future<UserProfileModel> getUserProfile() async {
    final row = await _fetchUserRow();
    return UserProfileModel.fromUserJson(row);
  }

  /// Solde compte + devise — **toujours** depuis l’API (aucun cache ici).
  Future<({double balance, String currencySymbol})> getWalletBalance() async {
    final row = await _fetchUserRow();
    final balance = UserProfileModel.fromUserJson(row).solde ?? 0;
    final devise = (row['devise'] ?? '€').toString();
    return (balance: balance, currencySymbol: devise);
  }

  /// Page d’historique (`GET /api/user/transactions`) — **hors cache Hive**.
  Future<({
    List<TransactionModel> items,
    bool hasMore,
    String currencySymbol,
  })>
      fetchTransactionsHistoryPage({
    int limit = 25,
    int offset = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userTransactions,
      queryParameters: <String, dynamic>{
        'limit': limit,
        'offset': offset,
      },
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );
    final body = response.data;
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Réponse vide',
      );
    }
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body['message']?.toString() ?? 'Erreur historique',
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return (items: <TransactionModel>[], hasMore: false, currencySymbol: '€');
    }
    final historiques = data['historiques'];
    final list = historiques is List
        ? historiques
            .map(
              (e) => TransactionModel.fromHistoriqueJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : <TransactionModel>[];
    final hasMore = data['has_more'] == true;
    final devise = (data['devise'] ?? '€').toString();
    return (
      items: list,
      hasMore: hasMore,
      currencySymbol: devise.isEmpty ? '€' : devise,
    );
  }

  /// Historique récent (table `historiques` agrégée dans `GET /api/user/dashboard`).
  Future<List<TransactionModel>> getRecentTransactions() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userDashboard,
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );
    final body = response.data;
    if (body == null) throw DioException(requestOptions: response.requestOptions, message: 'Réponse vide');
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: body['message']?.toString() ?? 'Erreur dashboard',
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return [];
    }
    final historiques = data['historiques'];
    if (historiques is! List) return [];
    return historiques
        .map((e) => TransactionModel.fromHistoriqueJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Sérialisation pour cache local.
  static String encodeTransactions(List<TransactionModel> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<TransactionModel> decodeTransactions(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
