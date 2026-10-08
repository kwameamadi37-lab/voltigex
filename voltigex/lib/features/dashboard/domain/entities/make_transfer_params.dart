/// Données saisies pour un virement (écran « Effectuer un virement »).
class MakeTransferParams {
  const MakeTransferParams({
    required this.lastName,
    required this.firstName,
    required this.bankName,
    required this.iban,
    required this.bic,
    required this.amount,
    required this.executionDateRaw,
    required this.reason,
  });

  final String lastName;
  final String firstName;
  final String bankName;
  final String iban;
  final String bic;
  final double amount;
  final String executionDateRaw;
  final String reason;

  /// Champ `titulaire` attendu par l’API : nom du bénéficiaire, ou à défaut le nom de banque.
  String get apiTitulaire {
    final n = '$firstName $lastName'.trim();
    if (n.isNotEmpty) return n;
    return bankName.trim();
  }
}
