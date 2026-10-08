import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';

sealed class TransferEvent {}

class SubmitTransferRequested extends TransferEvent {
  SubmitTransferRequested(
    this.params, {
    this.retryVirementId,
    this.validationCode,
  });

  final MakeTransferParams params;
  final int? retryVirementId;
  final String? validationCode;
}

class TransferUiReset extends TransferEvent {}
