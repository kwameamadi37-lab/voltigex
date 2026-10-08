import 'dart:convert';

import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {

  final String baseUrl;

  AuthRemoteDataSource({required this.baseUrl});

  Future<UserModel> login({required String email, required String password}) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    try{
      final response = await dio.post(
        '/api/auth/login',
        data: jsonEncode({'email': email, 'password': password}),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final user = Map<String, dynamic>.from(data['user'] as Map);
      user['token'] = data['token'];

      return UserModel.fromJson(user);

    } catch (_) {
      throw Exception('auth.remote.loginFailed');
    }
  }

  Future<UserModel> register({required String username, required String email, required String password}) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    try{
      final response = await dio.post(
          '/api/auth/register',
          data: jsonEncode({"username": username, "email": email, "password": password}),
      );

      return UserModel.fromJson(response.data['user']);
    } catch (_) {
      throw Exception('auth.remote.registerFailed');
    }
  }

  Future<void> logout(String fcmToken) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    try {
      await dio.post(
        '/api/auth/logout',
        data: {'fcm_token': fcmToken},
      );

    } catch (_) {
      // Ignore logout API error: local cleanup still proceeds.
    }
  }

}