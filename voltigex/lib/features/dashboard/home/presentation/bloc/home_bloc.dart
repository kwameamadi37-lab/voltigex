import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/features/dashboard/domain/entities/home_profile_entity.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_event.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required DashboardRepository dashboardRepository})
      : _repository = dashboardRepository,
        super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  final DashboardRepository _repository;

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    final cached = await _repository.loadHomeCachedSnapshot();

    if (cached != null) {
      emit(
        HomeLoaded(
          profile: cached.profile,
          transactions: cached.transactions,
          balance: null,
          balanceLoading: true,
          currencySymbol: '€',
        ),
      );
    } else {
      emit(HomeLoading());
    }

    double? balance;
    var currency = '€';

    try {
      final w = await _repository.fetchWalletBalanceRemote();
      balance = w.balance;
      currency = w.currencySymbol;
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('HomeBloc solde: $e\n$st');
        return true;
      }());
      if (cached == null) {
        emit(HomeError(e.toString()));
        return;
      }
      emit(
        HomeLoaded(
          profile: cached.profile,
          transactions: cached.transactions,
          balance: null,
          balanceLoading: false,
          currencySymbol: '€',
          warningMessage: _shortError(e),
        ),
      );
    }

    if (cached != null && balance != null) {
      emit(
        HomeLoaded(
          profile: cached.profile,
          transactions: cached.transactions,
          balance: balance,
          balanceLoading: false,
          currencySymbol: currency,
        ),
      );
    } else if (cached == null && balance != null) {
      emit(
        HomeLoaded(
          profile: const HomeProfileEntity(displayName: 'Client', photoUrl: null, role: null),
          transactions: const [],
          balance: balance,
          balanceLoading: false,
          currencySymbol: currency,
        ),
      );
    }

    try {
      final fresh = await _repository.refreshHomeProfileAndTransactionsRemote();
      emit(
        HomeLoaded(
          profile: fresh.profile,
          transactions: fresh.transactions,
          balance: balance,
          balanceLoading: false,
          currencySymbol: currency,
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('HomeBloc refresh profil/tx: $e\n$st');
        return true;
      }());
      final prev = state;
      if (prev is HomeLoaded) {
        emit(prev.copyWith(warningMessage: _shortError(e)));
      } else if (cached != null) {
        emit(
          HomeLoaded(
            profile: cached.profile,
            transactions: cached.transactions,
            balance: balance,
            balanceLoading: false,
            currencySymbol: currency,
            warningMessage: _shortError(e),
          ),
        );
      }
    }
  }

  String _shortError(Object e) {
    final s = e.toString();
    if (s.length > 120) return '${s.substring(0, 117)}…';
    return s;
  }
}
