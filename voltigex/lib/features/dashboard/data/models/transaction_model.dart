import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

/// Ligne `historiques` (voir `api_doc` §10.9) ou objet équivalent dans `GET /api/user/dashboard`.
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.titre,
    required this.montant,
    required this.type,
    required this.dateTransaction,
  });

  final String id;
  final String titre;
  final String montant;
  final String type;
  final String dateTransaction;

  factory TransactionModel.fromHistoriqueJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      montant: (json['montant'] ?? '0').toString(),
      type: (json['type'] ?? '').toString(),
      dateTransaction: (json['date_transaction'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'montant': montant,
        'type': type,
        'date_transaction': dateTransaction,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel.fromHistoriqueJson(json);

  TransactionEntity toEntity() {
    final raw = montant.replaceAll(' ', '').replaceAll(',', '.');
    final amt = double.tryParse(raw) ?? 0;
    final t = type.toLowerCase();
    final incoming = t.contains('credit') ||
        t.contains('entr') ||
        t.contains('reçu') ||
        t.contains('recu');
    return TransactionEntity(
      id: id,
      receiver: titre.isNotEmpty ? titre : '—',
      isIncoming: incoming,
      amount: amt.abs(),
      date: dateTransaction,
      status: type.isNotEmpty ? type : '—',
      apiStatut: null,
      supportSlug: null,
    );
  }
}
