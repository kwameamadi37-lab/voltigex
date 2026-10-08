import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/home_cached_snapshot.dart';
import 'package:voltigex/features/dashboard/domain/entities/home_profile_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

abstract class DashboardRepository {
  Future<List<CardEntity>> getCards();

  /// Cache Hive uniquement (affichage instantané).
  Future<CardEntity?> loadCachedCardEntity();

  /// Rechargement API + mise à jour du cache.
  Future<List<CardEntity>> refreshCardsFromRemote();

  Future<List<TransactionEntity>> getTransactions();

  /// Activation carte (vérif serveur).
  Future<List<CardEntity>> activateCardRemote({
    required String cardNumber,
    required String dateExp,
    required String cvv,
  });

  Future<List<CardEntity>> setCardFreezeRemote(bool freeze);

  Future<void> deleteCardRemote();

  /// Crédit mock carte (hors API) — conservé pour l’action « Ajouter ».
  Future<List<CardEntity>> updateCardStatus({
    required String cardId,
    bool? isActive,
    bool? isFrozen,
    double? balanceDelta,
  });

  /// Profil + transactions en cache (Hive), pour démarrage offline-first.
  Future<HomeCachedSnapshot?> loadHomeCachedSnapshot();

  Future<HomeProfileEntity> fetchHomeProfileRemote();

  Future<List<TransactionEntity>> fetchHomeTransactionsRemote();

  /// Solde temps réel — **aucun** cache ; toujours réseau.
  Future<({double balance, String currencySymbol})> fetchWalletBalanceRemote();

  /// Récupère profil + historiques, met à jour le cache local.
  Future<({HomeProfileEntity profile, List<TransactionEntity> transactions})>
      refreshHomeProfileAndTransactionsRemote();

  /// Historique paginé (réseau uniquement, **aucune** écriture Hive).
  Future<({
    List<TransactionEntity> items,
    bool hasMore,
    String currencySymbol,
  })>
      fetchTransactionsHistoryPage({
    int limit = 25,
    int offset = 0,
  });
}
