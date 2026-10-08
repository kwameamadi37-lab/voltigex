import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

sealed class TransferState {}

class TransferInitial extends TransferState {}

class TransferSubmitting extends TransferState {
  TransferSubmitting({this.progressPercent = 0});

  /// 0–100, aligné sur `virements.pourcentage` (API).
  final double progressPercent;
}

class TransferSuccess extends TransferState {
  TransferSuccess(this.transaction);

  final TransactionEntity transaction;
}

class TransferFailure extends TransferState {
  TransferFailure(
    this.message, {
    this.supportSlug,
    this.finalProgressPercent = 0,
  });

  final String message;
  /// Identifiant support (format XXXX-XXXX) renvoyé par l’API quand disponible.
  final String? supportSlug;

  /// Dernier `pourcentage` connu avant l’échec (pour caler la jauge + le suspense).
  final double finalProgressPercent;
}
