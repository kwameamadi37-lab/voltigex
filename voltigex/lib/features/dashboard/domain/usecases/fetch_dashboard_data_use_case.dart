import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardViewData {
  const DashboardViewData({
    required this.cards,
    required this.transactions,
    required this.availableAccountBalance,
    this.currencySymbol = '€',
  });

  final List<CardEntity> cards;
  final List<TransactionEntity> transactions;
  final double availableAccountBalance;
  final String currencySymbol;
}

class FetchDashboardDataUseCase {
  FetchDashboardDataUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardViewData> call() async {
    final cards = await _repository.getCards();
    final transactions = await _repository.getTransactions();
    final w = await _repository.fetchWalletBalanceRemote();
    return DashboardViewData(
      cards: cards,
      transactions: transactions,
      availableAccountBalance: w.balance,
      currencySymbol: w.currencySymbol,
    );
  }
}
