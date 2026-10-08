import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:voltigex/core/session_controller.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();


  final session = SessionController.instance;

  Dio createDio({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Ajout de l’intercepteur
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (session.token != null) {
            final tokenFcm = session.token;
            options.headers['Authorization'] = 'Bearer $tokenFcm';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final path = e.requestOptions.uri.path.toLowerCase();
            // 401 sur login / register = identifiants invalides, pas session expirée.
            // Ne pas appeler Get.offAllNamed : cela recrée LoginPage et vide les champs.
            final isAnonymousAuth = path.contains('auth/login') ||
                path.contains('auth/register');
            final authHeader = e.requestOptions.headers['Authorization'];
            final hadBearer = authHeader != null &&
                authHeader.toString().trim().isNotEmpty;

            if (!isAnonymousAuth && hadBearer) {
              session.clearSession();
              Get.offAllNamed('/login');
            }
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
