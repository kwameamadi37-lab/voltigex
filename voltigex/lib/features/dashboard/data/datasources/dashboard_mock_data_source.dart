import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

/// Source unique des mocks dashboard (cartes ; solde accueil via API).
class DashboardMockDataSource {
  DashboardMockDataSource() {
    _cards = [
      const CardEntity(
        id: 'voltigex-1',
        holderName: 'JEAN DUPONT',
        numberDisplay: '4532 1234 5678 3642',
        last4: '3642',
        cvc: '847',
        expiryDisplay: '01/2030',
        balance: 3000,
        cardType: 'platinum',
        isActive: false,
        isFrozen: false,
        isPending: false
      ),
    ];
    _transactions = [
      const TransactionEntity(
        id: 't0',
        receiver: 'Jeanne Dupont',
        isIncoming: false,
        amount: 35.99,
        date: '15/05/2025',
        status: 'ECHOUE',
      ),
      const TransactionEntity(
        id: 't1',
        receiver: 'John Da',
        isIncoming: true,
        amount: 1500.00,
        date: '15/05/2025',
        status: 'REUSSI',
      ),
      const TransactionEntity(
        id: 't2',
        receiver: 'Sophie Martin',
        isIncoming: false,
        amount: 250.00,
        date: '15/05/2025',
        status: 'ECHOUE',
      ),
      const TransactionEntity(
        id: 't3',
        receiver: 'Bob Smith',
        isIncoming: true,
        amount: 750.50,
        date: '15/05/2025',
        status: 'REUSSI',
      ),
      const TransactionEntity(
        id: 't4',
        receiver: 'Amir El Ghali',
        isIncoming: false,
        amount: 35.99,
        date: '15/05/2025',
        status: 'ECHOUE',
      ),
      const TransactionEntity(
        id: 't5',
        receiver: 'George Bush',
        isIncoming: true,
        amount: 1500.00,
        date: '15/05/2025',
        status: 'REUSSI',
      ),
      const TransactionEntity(
        id: 't6',
        receiver: 'Dimitri Ndiaye',
        isIncoming: false,
        amount: 250.00,
        date: '15/05/2025',
        status: 'ECHOUE',
      ),
      const TransactionEntity(
        id: 't7',
        receiver: 'Amel North',
        isIncoming: true,
        amount: 750.50,
        date: '15/05/2025',
        status: 'REUSSI',
      ),
      const TransactionEntity(
        id: 't8',
        receiver: 'Toussaint Moustapha',
        isIncoming: false,
        amount: 35.99,
        date: '15/05/2025',
        status: 'ECHOUE',
      ),
      const TransactionEntity(
        id: 't9',
        receiver: 'Elisabeth Poulain',
        isIncoming: true,
        amount: 1500.00,
        date: '15/05/2025',
        status: 'REUSSI',
      ),
      const TransactionEntity(
        id: 't10',
        receiver: 'Charles Dupont',
        isIncoming: false,
        amount: 250.00,
        date: '15/05/2025',
        status: 'ECHOUE',
      ),
      const TransactionEntity(
        id: 't11',
        receiver: 'Mélanie Germain',
        isIncoming: true,
        amount: 750.50,
        date: '15/05/2025',
        status: 'REUSSI',
      ),
    ];
  }

  late List<CardEntity> _cards;
  late List<TransactionEntity> _transactions;

  List<CardEntity> get cardsSnapshot =>
      List<CardEntity>.unmodifiable(_cards.map((c) => _copyCard(c)));

  List<TransactionEntity> get transactionsSnapshot =>
      List<TransactionEntity>.unmodifiable(_transactions);

  CardEntity? cardById(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void applyCardUpdate({
    required String cardId,
    bool? isActive,
    bool? isFrozen,
    double? balanceDelta,
  }) {
    final i = _cards.indexWhere((c) => c.id == cardId);
    if (i < 0) return;
    final c = _cards[i];
    _cards[i] = c.copyWith(
      isActive: isActive,
      isFrozen: isFrozen,
      balance: balanceDelta != null ? c.balance + balanceDelta : null,
    );
  }

  CardEntity _copyCard(CardEntity c) => c.copyWith();
}
