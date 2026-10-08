import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class ActivateCardUseCase {
  ActivateCardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<CardEntity>> call({
    required String cardNumber,
    required String dateExp,
    required String cvv,
  }) {
    return _repository.activateCardRemote(
      cardNumber: cardNumber,
      dateExp: dateExp,
      cvv: cvv,
    );
  }
}
