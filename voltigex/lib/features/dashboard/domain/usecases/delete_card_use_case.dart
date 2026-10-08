import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';

class DeleteCardUseCase {
  DeleteCardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<void> call() => _repository.deleteCardRemote();
}
