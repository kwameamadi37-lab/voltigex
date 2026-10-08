/// Mouvement affiché sur l’accueil / historiques (ex-virement mock [Transfer]).
class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.receiver,
    required this.isIncoming,
    required this.amount,
    required this.date,
    required this.status,
    this.progressPercent,
    this.apiStatut,
    this.supportSlug,
  });

  final String id;
  final String receiver;
  final bool isIncoming;
  final double amount;
  final String date;
  final String status;
  /// `virements.pourcentage` lorsque la ligne provient de l’API virement.
  final double? progressPercent;
  /// `virements.statut` brut (ex. `en_cours`, `termine`) depuis l’API.
  final String? apiStatut;
  /// Slug support XXXX-XXXX renvoyé par l’API.
  final String? supportSlug;
}
