import 'package:dio/dio.dart';
import 'package:voltigex/features/dashboard/data/datasources/transfer_remote_data_source.dart';
import 'package:voltigex/features/dashboard/domain/exceptions/transfer_operation_exception.dart';
import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';
import 'package:voltigex/features/dashboard/domain/entities/recent_recipients_page.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._remote);

  final TransferRemoteDataSource _remote;

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;
    return 0;
  }

  @override
  Future<RecentRecipientsPage> fetchRecentRecipients({
    int page = 1,
    int perPage = 25,
  }) {
    return _remote.fetchRecentRecipients(page: page, perPage: perPage);
  }

  @override
  Future<TransactionEntity> submitTransfer(
    MakeTransferParams params, {
    void Function(double progressPercent)? onProgress,
  }) async {
    onProgress?.call(0);
    final created = await _remote.createVirement(params);
    try {
      final row = await _remote.fetchVirementRow(created.id);
      final p = _asDouble(row['pourcentage']);
      onProgress?.call(p.clamp(0, 100).toDouble());
      return _remote.transactionFromVirementRow(row, created.id);
    } catch (e) {
      final slug =
          created.slug ??
          (e is DioException
              ? TransferRemoteDataSource.parseSupportSlugFromJson(
                  e.response?.data,
                )
              : null);
      final msg = e is DioException
          ? _remote.messageFromDioException(e)
          : e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      throw TransferOperationException(msg, supportSlug: slug);
    }
  }

  @override
  Future<TransactionEntity> retryTransfer({
    required int virementId,
    required String validationCode,
    void Function(double progressPercent)? onProgress,
  }) async {
    onProgress?.call(0);
    try {
      final progress = await _remote.confirmVirementStep(
        virementId,
        validationCode.trim(),
      );
      onProgress?.call(progress.toDouble().clamp(0, 100));
      final row = await _remote.fetchVirementRow(virementId);
      return _remote.transactionFromVirementRow(row, virementId);
    } catch (e) {
      if (e is DioException) {
        throw TransferOperationException(
          _remote.messageFromDioException(e),
          supportSlug: TransferRemoteDataSource.parseSupportSlugFromJson(
            e.response?.data,
          ),
        );
      }
      rethrow;
    }
  }
}
