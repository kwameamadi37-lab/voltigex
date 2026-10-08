import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class ActivateCardUseCase {
  ActivateCardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<CardEntity>> call({
    required String cardHolder,
    required String cardNumber,
    required String dateExp,
    required String cvv,
    required String cardType,
  }) {
    return _repository.activateCardRemote(
      cardHolder: cardHolder,
      cardNumber: cardNumber,
      dateExp: dateExp,
      cvv: cvv,
      cardType: cardType,
    );
  }
}
