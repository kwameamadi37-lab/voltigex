import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/network/connectivity_event.dart';
import 'package:voltigex/core/network/connectivity_state.dart';

export 'connectivity_event.dart';
export 'connectivity_state.dart';

/// Bloc global : état réseau (haut niveau) à partir de [connectivity_plus].
///
/// Le plugin applique déjà un [Stream.distinct] sur les listes ; ici on ajoute
/// un [debounce] de 500 ms sur les transitions et un filtre sur le résultat
/// agrégé pour éviter les événements inutiles.
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);
    unawaited(_start());
  }

  /// Hydratation puis abonnement pour éviter une course avec le premier événement du stream.
  Future<void> _start() async {
    await _hydrateInitial();
    if (isClosed) return;
    // Le plugin applique déjà distinct sur les listes ; on distingue ici l’agrégat [ConnectivityResult].
    _subscription = Connectivity()
        .onConnectivityChanged
        .map(_primaryFromList)
        .distinct()
        .listen(_onDebouncedPrimary);
  }

  StreamSubscription<ConnectivityResult>? _subscription;
  Timer? _debounce;
  ConnectivityResult? _lastEmittedPrimary;

  /// Accès rapide depuis l’UI : `context.read<ConnectivityBloc>().isOnline`.
  bool get isOnline => state.isOnline;

  static ConnectivityResult _primaryFromList(List<ConnectivityResult> list) {
    if (list.isEmpty || list.every((e) => e == ConnectivityResult.none)) {
      return ConnectivityResult.none;
    }
    if (list.contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (list.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }
    if (list.contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;
    return list.firstWhere(
      (e) => e != ConnectivityResult.none,
      orElse: () => ConnectivityResult.none,
    );
  }

  static ConnectivityState _mapResultToState(ConnectivityResult r) {
    switch (r) {
      case ConnectivityResult.none:
        return const ConnectivityOffline();
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return const ConnectivityOnline(ConnectivityTransport.wifi);
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
      case ConnectivityResult.bluetooth:
        return const ConnectivityOnline(ConnectivityTransport.mobile);
    }
  }

  Future<void> _hydrateInitial() async {
    try {
      final list = await Connectivity().checkConnectivity();
      _emitInitialPrimary(_primaryFromList(list));
    } catch (_) {
      // Laisse [ConnectivityInitial] si la plateforme échoue.
    }
  }

  void _onDebouncedPrimary(ConnectivityResult primary) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_lastEmittedPrimary == primary) return;
      _lastEmittedPrimary = primary;
      add(ConnectivityChanged(primary));
    });
  }

  void _emitInitialPrimary(ConnectivityResult primary) {
    _debounce?.cancel();
    if (_lastEmittedPrimary == primary) return;
    _lastEmittedPrimary = primary;
    add(ConnectivityChanged(primary));
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(_mapResultToState(event.result));
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
