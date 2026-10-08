import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class ToggleCardFreezeUseCase {
  ToggleCardFreezeUseCase(this._repository);

  final DashboardRepository _repository;

  Future<List<CardEntity>> call({
    required bool currentlyFrozen,
  }) {
    return _repository.setCardFreezeRemote(!currentlyFrozen);
  }
}
