import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfers_history_event.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfers_history_state.dart';

class TransfersHistoryBloc
    extends Bloc<TransfersHistoryEvent, TransfersHistoryState> {
  TransfersHistoryBloc({required DashboardRepository dashboardRepository})
      : _repository = dashboardRepository,
        super(TransfersHistoryInitial()) {
    on<LoadTransfersHistoryInitial>(_onInitial);
    on<LoadMoreTransactions>(_onLoadMore);
  }

  static const int _pageSize = 25;

  final DashboardRepository _repository;

  static const int _minLoadingVisibleMs = 1200;

  Future<void> _onInitial(
    LoadTransfersHistoryInitial event,
    Emitter<TransfersHistoryState> emit,
  ) async {
    emit(TransfersHistoryLoading());
    final sw = Stopwatch()..start();
    try {
      final r = await _repository.fetchTransactionsHistoryPage(
        limit: _pageSize,
        offset: 0,
      );
      final left = _minLoadingVisibleMs - sw.elapsedMilliseconds;
      if (left > 0) {
        await Future<void>.delayed(Duration(milliseconds: left));
      }
      emit(
        TransfersHistoryLoaded(
          transactions: r.items,
          hasMore: r.hasMore,
          currencySymbol: r.currencySymbol,
        ),
      );
    } catch (e) {
      final left = _minLoadingVisibleMs - sw.elapsedMilliseconds;
      if (left > 0) {
        await Future<void>.delayed(Duration(milliseconds: left));
      }
      emit(TransfersHistoryError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreTransactions event,
    Emitter<TransfersHistoryState> emit,
  ) async {
    final s = state;
    if (s is! TransfersHistoryLoaded || !s.hasMore || s.loadMoreInProgress) {
      return;
    }
    emit(s.copyWith(loadMoreInProgress: true));
    try {
      final r = await _repository.fetchTransactionsHistoryPage(
        limit: _pageSize,
        offset: s.transactions.length,
      );
      emit(
        TransfersHistoryLoaded(
          transactions: [...s.transactions, ...r.items],
          hasMore: r.hasMore,
          currencySymbol: r.currencySymbol,
          loadMoreInProgress: false,
        ),
      );
    } catch (_) {
      emit(s.copyWith(loadMoreInProgress: false));
    }
  }
}
