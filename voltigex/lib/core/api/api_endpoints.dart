/// Chemins relatifs à la base HTTP (ex. [Constants.backendServerAddress]) pour les appels `/api/...`.
/// Les clients [Dio] utilisent déjà `/api/auth/login` etc. — préfixe `/api` inclus ici pour cohérence.
abstract final class ApiEndpoints {
  static String userInfo(String userId) => '/api/user-info/$userId';

  /// Profil Sanctum (GET / PUT contact, identity, address, password).
  static const String userMe = '/api/user';
  static const String userContact = '/api/user/contact';
  static const String userIdentity = '/api/user/identity';
  static const String userAddress = '/api/user/address';
  static const String userPassword = '/api/user/password';

  static const String userDashboard = '/api/user/dashboard';

  /// Historique paginé (`limit`, `offset`) — pas de cache Hive côté app.
  static const String userTransactions = '/api/user/transactions';

  static const String userCardDetails = '/api/user/card-details';
  static const String userCardFreeze = '/api/user/card/freeze';
  static const String userCardDelete = '/api/user/card';

  static String userCardActivate(String userId) => '/api/user/$userId/card/activate';

  /// Activation carte (Sanctum) — enregistre numéro, type et met en attente admin.
  static const String cardActivate = '/api/card/activate';

  static const String userVirements = '/api/user/virements';

  static const String virementsCreate = '/api/virements';

  static String virementProgress(int id) => '/api/virements/$id/progress';

  static String virementConfirm(int id) => '/api/virements/$id/confirm';
}
