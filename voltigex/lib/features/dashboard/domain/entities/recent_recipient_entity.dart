/// Bénéficiaire dérivé d’un virement passé (liste « Bénéficiaire récent »).
class RecentRecipientEntity {
  const RecentRecipientEntity({
    required this.virementId,
    this.slug,
    required this.holderName,
    required this.firstName,
    required this.lastName,
    required this.bankName,
    required this.iban,
    required this.amount,
    required this.status,
    required this.progressPercent,
    this.bic,
    this.currentCode,
  });

  final int virementId;
  final String? slug;
  final String holderName;
  final String firstName;
  final String lastName;
  final String bankName;
  final String iban;
  final double amount;
  final String status;
  final double progressPercent;
  final String? bic;
  final String? currentCode;

  /// Tant qu’aucun virement n’est considéré comme réellement réussi : pas de ligne « réussie » en liste.
  bool get isCompleted => false;

  /// Statut final API (`termine` / `terminé`) : pas de réessai ni d’ouverture du formulaire depuis la liste.
  bool get isTerminalClosed {
    final s = status.toLowerCase().trim();
    return s == 'termine' || s == 'terminé';
  }

  /// Libellé dans l’onglet Récents (aucune ligne « réussie » pour l’instant).
  String get listOutcomeLabel => 'Non effectué';
}
