/// Erreur métier virement avec identifiant support optionnel (slug API).
class TransferOperationException implements Exception {
  TransferOperationException(this.message, {this.supportSlug});

  final String message;
  final String? supportSlug;

  @override
  String toString() => message;
}
