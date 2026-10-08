import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:voltigex/features/dashboard/domain/usecases/activate_card_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/add_money_to_card_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/delete_card_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/toggle_card_freeze_use_case.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_event.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_state.dart';

class CardsBloc extends Bloc<CardsEvent, CardsState> {
  CardsBloc({
    required DashboardRepository dashboardRepository,
    required ToggleCardFreezeUseCase toggleCardFreezeUseCase,
    required AddMoneyToCardUseCase addMoneyToCardUseCase,
    required ActivateCardUseCase activateCardUseCase,
    required DeleteCardUseCase deleteCardUseCase,
  })  : _repository = dashboardRepository,
        _toggleCardFreezeUseCase = toggleCardFreezeUseCase,
        _addMoneyToCardUseCase = addMoneyToCardUseCase,
        _activateCardUseCase = activateCardUseCase,
        _deleteCardUseCase = deleteCardUseCase,
        super(CardsInitial()) {
    on<FetchCardsData>(_onFetchCardsData);
    on<RefreshCardsData>(_onRefreshCardsData);
    on<ToggleCardFreeze>(_onToggleCardFreeze);
    on<AddMoneyToCard>(_onAddMoneyToCard);
    on<ActivateCard>(_onActivateCard);
    on<DeleteCard>(_onDeleteCard);
  }

  final DashboardRepository _repository;
  final ToggleCardFreezeUseCase _toggleCardFreezeUseCase;
  final AddMoneyToCardUseCase _addMoneyToCardUseCase;
  final ActivateCardUseCase _activateCardUseCase;
  final DeleteCardUseCase _deleteCardUseCase;

  /// Dernier chargement carte réussi (API + cache Hive mis à jour).
  DateTime? _lastCardsRemoteSuccessAt;

  static const Duration _cardsRemoteTtl = Duration(seconds: 30);

  void _markRemoteSuccess() {
    _lastCardsRemoteSuccessAt = DateTime.now();
  }

  Future<void> _onFetchCardsData(
    FetchCardsData event,
    Emitter<CardsState> emit,
  ) async {
    emit(CardsLoading());
    final cached = await _repository.loadCachedCardEntity();
    if (cached != null) {
      emit(
        CardsLoaded(
          cards: [cached],
          walletSyncGeneration: 0,
        ),
      );
    }
    try {
      final cards = await _repository.refreshCardsFromRemote();
      _markRemoteSuccess();
      emit(
        CardsLoaded(
          cards: cards,
          walletSyncGeneration: 0,
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('CardsBloc fetch: $e\n$st');
        return true;
      }());
      if (cached == null) {
        emit(CardsError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshCardsData(
    RefreshCardsData event,
    Emitter<CardsState> emit,
  ) async {
    final current = state;
    if (current is! CardsLoaded) {
      await _onFetchCardsData(FetchCardsData(), emit);
      return;
    }
    if (!event.forceRefresh) {
      final last = _lastCardsRemoteSuccessAt;
      if (last != null &&
          DateTime.now().difference(last) < _cardsRemoteTtl) {
        emit(current.copyWith());
        return;
      }
    }
    try {
      final cards = await _repository.refreshCardsFromRemote();
      _markRemoteSuccess();
      emit(
        CardsLoaded(
          cards: cards,
          walletSyncGeneration: current.walletSyncGeneration,
          cardActionLoading: current.cardActionLoading,
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('CardsBloc refresh: $e\n$st');
        return true;
      }());
      emit(current.copyWith());
    }
  }

  Future<void> _onToggleCardFreeze(
    ToggleCardFreeze event,
    Emitter<CardsState> emit,
  ) async {
    final current = state;
    if (current is! CardsLoaded) return;
    final card = current.primaryCard;
    if (card == null) return;
    emit(current.copyWith(cardActionLoading: true));
    try {
      final cards = await _toggleCardFreezeUseCase(
        currentlyFrozen: card.isFrozen,
      );
      _markRemoteSuccess();
      emit(
        CardsLoaded(
          cards: cards,
          walletSyncGeneration: current.walletSyncGeneration + 1,
          cardActionLoading: false,
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('CardsBloc freeze: $e\n$st');
        return true;
      }());
      emit(current.copyWith(cardActionLoading: false));
    }
  }

  Future<void> _onAddMoneyToCard(
    AddMoneyToCard event,
    Emitter<CardsState> emit,
  ) async {
    final current = state;
    if (current is! CardsLoaded) return;
    final card = current.primaryCard;
    if (card == null) return;
    try {
      final cards = await _addMoneyToCardUseCase(
        cardId: card.id,
        amount: event.amount,
      );
      _markRemoteSuccess();
      emit(
        CardsLoaded(
          cards: cards,
          walletSyncGeneration: current.walletSyncGeneration + 1,
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('CardsBloc add money: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> _onActivateCard(
    ActivateCard event,
    Emitter<CardsState> emit,
  ) async {
    final current = state;
    if (current is! CardsLoaded) return;
    final card = current.primaryCard;
    if (card == null) return;
    emit(current.copyWith(cardActionLoading: true));

    try {
      final exp = _normalizeExpiryForApi(event.dateExp);
      final cards = await _activateCardUseCase(
        cardNumber: event.cardNumber.replaceAll(RegExp(r'\s'), ''),
        dateExp: exp,
        cvv: event.cvv.trim(),
      );
      _markRemoteSuccess();

      // Émission du succès
      emit(
        CardsLoaded(
          cards: cards,
          walletSyncGeneration: current.walletSyncGeneration + 1,
          cardActionLoading: false,
          cardsActivationDemandSucess: true,
        ),
      );

      // Remet le booléen à false immédiatement pour éviter un re-déclenchement involontaire
      emit(
        (state as CardsLoaded).copyWith(
          cardsActivationDemandSucess: false,
        ),
      );
    } catch (e) {
      emit(CardsActivationDemandError());
      emit(current.copyWith(cardActionLoading: false));
    }
  }

  Future<void> _onDeleteCard(
    DeleteCard event,
    Emitter<CardsState> emit,
  ) async {
    final current = state;
    if (current is! CardsLoaded) return;
    emit(current.copyWith(cardActionLoading: true));
    try {
      await _deleteCardUseCase();
      final cards = await _repository.refreshCardsFromRemote();
      _markRemoteSuccess();
      emit(
        CardsLoaded(
          cards: cards,
          walletSyncGeneration: current.walletSyncGeneration + 1,
          cardActionLoading: false,
        ),
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('CardsBloc delete: $e\n$st');
        return true;
      }());
      emit(current.copyWith(cardActionLoading: false));
    }
  }

  /// API attend `MM/YY` (ex. `04/27`).
  String _normalizeExpiryForApi(String raw) {
    final t = raw.trim();
    final parts = t.split('/');
    if (parts.length >= 2) {
      final mm = parts[0].padLeft(2, '0');
      var y = parts[1].trim();
      if (y.length == 4) {
        y = y.substring(2);
      }
      return '$mm/$y';
    }
    return t;
  }
}
