class Constants {
  static const String backendServerAddress = "http://192.168.100.8:8000";

  /// Même base que [backendServerAddress] — utilisée pour reconstruire les URLs médias affichées.
  static String get baseUrl => backendServerAddress;
  // ID numerique de l'admin support cote Laravel (users.id)
  static const String supportAdminId = "1";
  /// Clé publique Pusher (identique à PUSHER_APP_KEY dans dashboard-api/.env — sûre côté client).
  static const String pusherKey = "490845ff695998f3de67";
  /// Identique à PUSHER_APP_CLUSTER dans .env (ex. mt1, eu).
  static const String pusherCluster = "mt1";
  static const String conversationMessagesBox = "";
}

