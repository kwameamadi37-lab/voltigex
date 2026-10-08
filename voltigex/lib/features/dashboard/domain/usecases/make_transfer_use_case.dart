import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';
import 'package:voltigex/features/dashboard/domain/repositories/transfer_repository.dart';

class MakeTransferUseCase {
  MakeTransferUseCase(this._repository);

  final TransferRepository _repository;

  Future<TransactionEntity> call(
    MakeTransferParams params, {
    void Function(double progressPercent)? onProgress,
  }) {
    return _repository.submitTransfer(params, onProgress: onProgress);
  }

  Future<TransactionEntity> retry({
    required int virementId,
    required String validationCode,
    void Function(double progressPercent)? onProgress,
  }) {
    return _repository.retryTransfer(
      virementId: virementId,
      validationCode: validationCode,
      onProgress: onProgress,
    );
  }
}
