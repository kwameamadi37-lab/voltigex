import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';
import 'package:voltigex/features/dashboard/domain/entities/recent_recipients_page.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

abstract class TransferRepository {
  /// Crée un nouveau virement et renvoie le palier initial de progression.
  Future<TransactionEntity> submitTransfer(
    MakeTransferParams params, {
    void Function(double progressPercent)? onProgress,
  });

  /// Réessaie un virement existant avec code de validation utilisateur.
  Future<TransactionEntity> retryTransfer({
    required int virementId,
    required String validationCode,
    void Function(double progressPercent)? onProgress,
  });

  /// [page] et [perPage] : pagination Laravel (`next_page_url`, `last_page`, etc.).
  Future<RecentRecipientsPage> fetchRecentRecipients({
    int page = 1,
    int perPage = 25,
  });
}
