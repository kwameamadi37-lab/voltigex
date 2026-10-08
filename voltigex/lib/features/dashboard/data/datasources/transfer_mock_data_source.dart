import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';

class TransferMockDataSource {
  static const Duration simulatedWireDelay = Duration(seconds: 6);

  Future<TransactionEntity> submitTransfer(MakeTransferParams params) async {
    await Future<void>.delayed(simulatedWireDelay);
    throw Exception(
      "Nous n'avons pas pu traiter votre virement en raison d'une erreur. "
      'Veuillez vérifier vos informations et réessayer ou contacter l’assistance.',
    );
  }
}
