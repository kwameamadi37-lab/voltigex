import 'package:voltigex/features/dashboard/data/datasources/card_local_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/card_remote_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/dashboard_mock_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/home_local_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/home_remote_data_source.dart';
import 'package:voltigex/features/dashboard/data/models/card_model.dart';
import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/home_cached_snapshot.dart';
import 'package:voltigex/features/dashboard/domain/entities/home_profile_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(
    this._mock,
    this._remote,
    this._local,
    this._cardRemote,
    this._cardLocal,
  );

  final DashboardMockDataSource _mock;
  final HomeRemoteDataSource _remote;
  final HomeLocalDataSource _local;
  final CardRemoteDataSource _cardRemote;
  final CardLocalDataSource _cardLocal;

  static const _kSimulatedLatency = Duration(milliseconds: 120);

  CardEntity _entity(CardModel m) => m.toEntity();

  @override
  Future<CardEntity?> loadCachedCardEntity() async {
    final c = await _cardLocal.read();
    return c == null ? null : _entity(c);
  }

  @override
  Future<List<CardEntity>> refreshCardsFromRemote() async {
    final m = await _cardRemote.getCardDetails();
    await _cardLocal.write(m);
    return [_entity(m)];
  }

  @override
  Future<List<CardEntity>> getCards() async {
    try {
      return await refreshCardsFromRemote();
    } catch (_) {
      final c = await _cardLocal.read();
      if (c != null) return [_entity(c)];
      rethrow;
    }
  }

  @override
  Future<List<CardEntity>> activateCardRemote({
    required String cardNumber,
    required String dateExp,
    required String cvv,
  }) async {
    final m = await _cardRemote.activateCard(
      cardNumber: cardNumber,
      dateExp: dateExp,
      cvv: cvv,
    );
    await _cardLocal.write(m);
    return [_entity(m)];
  }

  @override
  Future<List<CardEntity>> setCardFreezeRemote(bool freeze) async {
    final m = await _cardRemote.toggleFreeze(freeze: freeze);
    await _cardLocal.write(m);
    return [_entity(m)];
  }

  @override
  Future<void> deleteCardRemote() async {
    await _cardRemote.deleteCard();
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await _remote.getRecentTransactions();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<CardEntity>> updateCardStatus({
    required String cardId,
    bool? isActive,
    bool? isFrozen,
    double? balanceDelta,
  }) async {
    await Future<void>.delayed(_kSimulatedLatency);
    _mock.applyCardUpdate(
      cardId: cardId,
      isActive: isActive,
      isFrozen: isFrozen,
      balanceDelta: balanceDelta,
    );
    return refreshCardsFromRemote();
  }

  @override
  Future<HomeCachedSnapshot?> loadHomeCachedSnapshot() async {
    final profileModel = await _local.readProfile();
    final txModels = await _local.readTransactions();
    if (profileModel == null || txModels == null) return null;
    return HomeCachedSnapshot(
      profile: profileModel.toEntity(),
      transactions: txModels.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<HomeProfileEntity> fetchHomeProfileRemote() async {
    final m = await _remote.getUserProfile();
    return m.toEntity();
  }

  @override
  Future<List<TransactionEntity>> fetchHomeTransactionsRemote() async {
    final models = await _remote.getRecentTransactions();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<({double balance, String currencySymbol})> fetchWalletBalanceRemote() {
    return _remote.getWalletBalance();
  }

  @override
  Future<({HomeProfileEntity profile, List<TransactionEntity> transactions})>
      refreshHomeProfileAndTransactionsRemote() async {
    final profileModel = await _remote.getUserProfile();
    final txModels = await _remote.getRecentTransactions();
    await _local.writeProfile(profileModel);
    await _local.writeTransactions(txModels);
    return (
      profile: profileModel.toEntity(),
      transactions: txModels.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<({
    List<TransactionEntity> items,
    bool hasMore,
    String currencySymbol,
  })>
      fetchTransactionsHistoryPage({
    int limit = 25,
    int offset = 0,
  }) async {
    final page = await _remote.fetchTransactionsHistoryPage(
      limit: limit,
      offset: offset,
    );
    return (
      items: page.items.map((e) => e.toEntity()).toList(),
      hasMore: page.hasMore,
      currencySymbol: page.currencySymbol,
    );
  }
}
