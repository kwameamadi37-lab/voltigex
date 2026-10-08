sealed class TransfersHistoryEvent {}

/// Premier chargement (réseau, pas de cache local).
final class LoadTransfersHistoryInitial extends TransfersHistoryEvent {}

/// Page suivante (append).
final class LoadMoreTransactions extends TransfersHistoryEvent {}
