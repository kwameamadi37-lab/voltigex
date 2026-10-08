import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/features/dashboard/domain/exceptions/transfer_operation_exception.dart';
import 'package:voltigex/features/dashboard/domain/usecases/make_transfer_use_case.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_bloc.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_event.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_event.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required MakeTransferUseCase makeTransferUseCase,
    HomeBloc? homeBloc,
  })  : _makeTransferUseCase = makeTransferUseCase,
        _homeBloc = homeBloc,
        super(TransferInitial()) {
    on<SubmitTransferRequested>(_onSubmit);
    on<TransferUiReset>(_onReset);
  }

  final MakeTransferUseCase _makeTransferUseCase;
  final HomeBloc? _homeBloc;

  Future<void> _onSubmit(
    SubmitTransferRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransferSubmitting(progressPercent: 0));
    var lastProgress = 0.0;
    try {
      final tx = event.retryVirementId != null
          ? await _makeTransferUseCase.retry(
              virementId: event.retryVirementId!,
              validationCode: event.validationCode ?? '',
              onProgress: (p) {
                lastProgress = p;
                emit(TransferSubmitting(progressPercent: p));
              },
            )
          : await _makeTransferUseCase(
              event.params,
              onProgress: (p) {
                lastProgress = p;
                emit(TransferSubmitting(progressPercent: p));
              },
            );
      emit(TransferSuccess(tx));
      _homeBloc?.add(FetchHomeData());
    } catch (e) {
      if (e is TransferOperationException) {
        emit(TransferFailure(
          e.message,
          supportSlug: e.supportSlug,
          finalProgressPercent: lastProgress,
        ));
      } else {
        emit(TransferFailure(
          _transferErrorMessage(e),
          supportSlug: _supportSlugFromDio(e),
          finalProgressPercent: lastProgress,
        ));
      }
    }
  }

  String? _supportSlugFromDio(Object e) {
    if (e is! DioException) return null;
    final d = e.response?.data;
    if (d is! Map) return null;
    final raw = d['slug'] ?? d['support_slug'];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  String _transferErrorMessage(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map<String, dynamic>) {
        final m = d['message']?.toString();
        if (m != null && m.trim().isNotEmpty) return m.trim();
        final errs = d['errors'];
        if (errs is Map) {
          for (final v in errs.values) {
            if (v is List && v.isNotEmpty) return v.first.toString();
            if (v is String && v.isNotEmpty) return v;
          }
        }
      }
      final raw = (e.message ?? 'Erreur réseau').trim();
      if (raw.toLowerCase().contains('code de confirmation invalide')) {
        return 'Veuillez vérifier le code entré';
      }
      return raw;
    }
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  void _onReset(TransferUiReset event, Emitter<TransferState> emit) {
    emit(TransferInitial());
  }
}
