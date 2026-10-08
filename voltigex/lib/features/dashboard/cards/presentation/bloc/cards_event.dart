sealed class CardsEvent {}

/// Charge le cache puis l’API (détails carte).
class FetchCardsData extends CardsEvent {}

/// Rafraîchissement API à l’entrée sur l’onglet Cartes (sans écran de chargement initial si déjà chargé).
/// [forceRefresh] : `true` (pull-to-refresh) ignore le TTL ; `false` respecte le cache 30 s.
class RefreshCardsData extends CardsEvent {
  RefreshCardsData({this.forceRefresh = false});

  final bool forceRefresh;
}

class ToggleCardFreeze extends CardsEvent {}

class AddMoneyToCard extends CardsEvent {
  AddMoneyToCard({this.amount = 100});

  final double amount;
}

/// Données saisies / préremplies pour `POST .../card/activate`.
class ActivateCard extends CardsEvent {
  ActivateCard({
    required this.cardNumber,
    required this.dateExp,
    required this.cvv,
  });

  final String cardNumber;
  final String dateExp;
  final String cvv;
}

class DeleteCard extends CardsEvent {}
