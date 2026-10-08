/// Carte affichée sur l’écran Cartes (`card_type` API : `gold` | `diamond` | `platinum`).
class CardEntity {
  const CardEntity({
    required this.id,
    required this.holderName,
    required this.numberDisplay,
    required this.last4,
    required this.cvc,
    required this.expiryDisplay,
    required this.balance,
    required this.cardType,
    required this.isActive,
    required this.isPending,
    required this.isFrozen,
  });

  final String id;
  final String holderName;
  /// Ex. `4532 1234 5678 3642`
  final String numberDisplay;
  final String last4;
  final String cvc;
  /// Ex. `01/2030`
  final String expiryDisplay;
  final double balance;
  /// Valeur API `card_amount` (affichage solde carte).
  /// `gold` | `diamond` | `platinum` (normalisé côté [CardModel]).
  final String cardType;
  final bool isActive;
  final bool isPending;
  final bool isFrozen;

  CardEntity copyWith({
    String? id,
    String? holderName,
    String? numberDisplay,
    String? last4,
    String? cvc,
    String? expiryDisplay,
    double? balance,
    String? cardType,
    bool? isActive,
    bool? isPending,
    bool? isFrozen,
  }) {
    return CardEntity(
      id: id ?? this.id,
      holderName: holderName ?? this.holderName,
      numberDisplay: numberDisplay ?? this.numberDisplay,
      last4: last4 ?? this.last4,
      cvc: cvc ?? this.cvc,
      expiryDisplay: expiryDisplay ?? this.expiryDisplay,
      balance: balance ?? this.balance,
      cardType: cardType ?? this.cardType,
      isActive: isActive ?? this.isActive,
      isPending: isPending ?? this.isPending,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

}
