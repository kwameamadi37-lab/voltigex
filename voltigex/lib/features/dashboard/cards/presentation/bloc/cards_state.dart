import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';

sealed class CardsState {}

class CardsInitial extends CardsState {}

class CardsLoading extends CardsState {}

class CardsLoaded extends CardsState {
  CardsLoaded({
    required this.cards,
    this.walletSyncGeneration = 0,
    this.cardActionLoading = false,
    this.cardsActivationDemandSucess = false,
  });

  final List<CardEntity> cards;

  /// Incrémenté après gel, suppression, activation, crédit mock — notifie MainScreen (solde accueil).
  final int walletSyncGeneration;

  /// Gel / suppression en cours (évite double tap + loader sur la carte).
  final bool cardActionLoading;

  final bool cardsActivationDemandSucess;

  CardEntity? get primaryCard => cards.isEmpty ? null : cards.first;

  CardsLoaded copyWith({
    List<CardEntity>? cards,
    int? walletSyncGeneration,
    bool? cardActionLoading,
    bool? cardsActivationDemandSucess,
  }) {
    return CardsLoaded(
      cards: cards ?? this.cards,
      walletSyncGeneration: walletSyncGeneration ?? this.walletSyncGeneration,
      cardActionLoading: cardActionLoading ?? this.cardActionLoading,
      cardsActivationDemandSucess: cardsActivationDemandSucess ?? this.cardsActivationDemandSucess,
    );
  }
}

// class CardsActivationDemandSucess extends CardsState {
//   CardsActivationDemandSucess({
//     required this.cards,
//     this.walletSyncGeneration = 0,
//     this.cardActionLoading = false,
//   });

//   final List<CardEntity> cards;

//   /// Incrémenté après gel, suppression, activation, crédit mock — notifie MainScreen (solde accueil).
//   final int walletSyncGeneration;

//   /// Gel / suppression en cours (évite double tap + loader sur la carte).
//   final bool cardActionLoading;

//   CardEntity? get primaryCard => cards.isEmpty ? null : cards.first;

//   CardsLoaded copyWith({
//     List<CardEntity>? cards,
//     int? walletSyncGeneration,
//     bool? cardActionLoading,
//   }) {
//     return CardsLoaded(
//       cards: cards ?? this.cards,
//       walletSyncGeneration: walletSyncGeneration ?? this.walletSyncGeneration,
//       cardActionLoading: cardActionLoading ?? this.cardActionLoading,
//     );
//   }
// }

// class CardsActivationDemandError extends CardsState {
//   CardsActivationDemandError({
//     required this.cards,
//     this.walletSyncGeneration = 0,
//     this.cardActionLoading = false,
//   });

//   final List<CardEntity> cards;

//   /// Incrémenté après gel, suppression, activation, crédit mock — notifie MainScreen (solde accueil).
//   final int walletSyncGeneration;

//   /// Gel / suppression en cours (évite double tap + loader sur la carte).
//   final bool cardActionLoading;

//   CardEntity? get primaryCard => cards.isEmpty ? null : cards.first;

//   CardsLoaded copyWith({
//     List<CardEntity>? cards,
//     int? walletSyncGeneration,
//     bool? cardActionLoading,
//   }) {
//     return CardsLoaded(
//       cards: cards ?? this.cards,
//       walletSyncGeneration: walletSyncGeneration ?? this.walletSyncGeneration,
//       cardActionLoading: cardActionLoading ?? this.cardActionLoading,
//     );
//   }
// }

class CardsError extends CardsState {
  CardsError(this.message);

  final String message;
}

class CardsActivationDemandError extends CardsState {
  CardsActivationDemandError();
}

class CardsActivationDemandSucess extends CardsState {
  CardsActivationDemandSucess();
}