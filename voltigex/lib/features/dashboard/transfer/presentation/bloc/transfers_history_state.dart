import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

sealed class TransfersHistoryState {}

final class TransfersHistoryInitial extends TransfersHistoryState {}

final class TransfersHistoryLoading extends TransfersHistoryState {}

final class TransfersHistoryLoaded extends TransfersHistoryState {
  TransfersHistoryLoaded({
    required this.transactions,
    required this.hasMore,
    required this.currencySymbol,
    this.loadMoreInProgress = false,
  });

  final List<TransactionEntity> transactions;
  final bool hasMore;
  final String currencySymbol;
  final bool loadMoreInProgress;

  TransfersHistoryLoaded copyWith({
    List<TransactionEntity>? transactions,
    bool? hasMore,
    String? currencySymbol,
    bool? loadMoreInProgress,
  }) {
    return TransfersHistoryLoaded(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      loadMoreInProgress: loadMoreInProgress ?? this.loadMoreInProgress,
    );
  }
}

final class TransfersHistoryError extends TransfersHistoryState {
  TransfersHistoryError(this.message);
  final String message;
}
