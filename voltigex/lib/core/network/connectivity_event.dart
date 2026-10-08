import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityEvent {}

/// Agrégat dérivé de la liste renvoyée par [Connectivity] (priorité wifi / ethernet > mobile > autres).
class ConnectivityChanged extends ConnectivityEvent {
  ConnectivityChanged(this.result);

  final ConnectivityResult result;
}
