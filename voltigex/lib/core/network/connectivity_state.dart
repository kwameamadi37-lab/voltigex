import 'package:flutter/foundation.dart' show immutable;

/// Sous-type de connexion lorsque [ConnectivityOnline].
enum ConnectivityTransport {
  wifi,
  mobile,
}

@immutable
abstract class ConnectivityState {
  const ConnectivityState();

  /// Indique si l’app considère le terminal comme ayant un accès réseau actif.
  bool get isOnline;
}

/// Avant la première lecture [Connectivity.checkConnectivity] / premier événement stream.
class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();

  @override
  bool get isOnline => false;
}

class ConnectivityOnline extends ConnectivityState {
  const ConnectivityOnline(this.transport);

  final ConnectivityTransport transport;

  @override
  bool get isOnline => true;
}

class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();

  @override
  bool get isOnline => false;
}
