import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class AddMoneyToCardUseCase {
  AddMoneyToCardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<CardEntity>> call({
    required String cardId,
    required double amount,
  }) {
    return _repository.updateCardStatus(
      cardId: cardId,
      balanceDelta: amount,
    );
  }
}
