import 'package:voltigex/features/dashboard/domain/entities/recent_recipient_entity.dart';

/// Ligne `virements` (API) — inclut [pourcentage] pour le loader et l’UI.
class TransferEntity {
  const TransferEntity({
    required this.id,
    this.slug,
    required this.pourcentage,
    required this.statut,
    required this.holderName,
    required this.firstName,
    required this.lastName,
    required this.bankName,
    required this.iban,
    this.bic,
    required this.amount,
    this.currentCode,
  });

  final int id;
  /// Identifiant support public (XXXX-XXXX), ex. pour le contact administrateur.
  final String? slug;
  final double pourcentage;
  final String statut;
  final String holderName;
  final String firstName;
  final String lastName;
  final String bankName;
  final String iban;
  final String? bic;
  final double amount;
  final String? currentCode;

  RecentRecipientEntity toRecentRecipient() {
    return RecentRecipientEntity(
      virementId: id,
      slug: slug,
      holderName: holderName,
      firstName: firstName,
      lastName: lastName,
      bankName: bankName,
      iban: iban,
      bic: bic,
      amount: amount,
      status: statut,
      progressPercent: pourcentage,
      currentCode: currentCode,
    );
  }
}
