import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltigex/core/constants.dart';

class SessionController {
  SessionController._internal();

  static final SessionController _instance = SessionController._internal();
  static SessionController get instance => _instance;

  String? userId;
  String? token;
  String? role;
  // DateTime? expiryDate;

  /// Admin support : ID connu (Constants) ou rôle admin côté API.
  bool get isAdminSupport {
    if (userId == null) return false;
    
    // return userId == Constants.supportAdminId || (role ?? '') == 'admin';
    return  (role ?? '').toLowerCase() == 'admin';
  }

  // bool get isSessionActive {
  //   if (token == null) return false;
  //   return DateTime.now().isBefore(expiryDate!);
  // }

  void setSession(String userId, String token, {String? role}) async {
    this.userId = userId;
    this.token = token;
    this.role = role;

    const storage = FlutterSecureStorage();
    await storage.write(key: "userId", value: userId);
    await storage.write(key: "token", value: token);
    if (role != null && role.isNotEmpty) {
      await storage.write(key: "role", value: role);
    } else {
      await storage.delete(key: "role");
    }
  }

  Future<void> loadSession() async {
    const storage = FlutterSecureStorage();
    final response = await Future.wait([
      storage.read(key: "userId"),
      storage.read(key: "token"),
      storage.read(key: "role"),
    ]);

    // Sanctum personal access tokens are not JWTs; we can't decode expiry client-side.
    if (response[1] != null && response[1]!.isNotEmpty) {
      userId = response[0];
      token = response[1];
      role = response[2];
    } else {
      // la session a expiré
      clearSession();
    }
  }

  void clearSession() async {
    userId = null;
    token = null;
    role = null;

    const storage = FlutterSecureStorage();
    await Future.wait([
      storage.delete(key: "userId"),
      storage.delete(key: "token"),
      storage.delete(key: "role"),
    ]);
  }

}