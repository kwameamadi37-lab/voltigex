import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

/// Ligne `historiques` (voir `api_doc` §10.9) ou objet équivalent dans `GET /api/user/dashboard`.
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.titre,
    required this.montant,
    required this.type,
    required this.dateTransaction,
    this.progressPercent,
    this.virementStatut,
  });

  final String id;
  final String titre;
  final String montant;
  final String type;
  final String dateTransaction;
  final double? progressPercent;
  final String? virementStatut;

  factory TransactionModel.fromHistoriqueJson(Map<String, dynamic> json) {
    final pctRaw = json['pourcentage'];
    double? pct;
    if (pctRaw is num) {
      pct = pctRaw.toDouble();
    } else if (pctRaw != null) {
      pct = double.tryParse(pctRaw.toString());
    }

    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      montant: (json['montant'] ?? '0').toString(),
      type: (json['type'] ?? '').toString(),
      dateTransaction: (json['date_transaction'] ?? '').toString(),
      progressPercent: pct,
      virementStatut: json['virement_statut']?.toString(),
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

  static bool historiqueIsDeposit(String type, String titre) {
    final t = type.toLowerCase().trim();
    final title = titre.toLowerCase();

    if (t == 'depot' || t == 'deposit') return true;

    if (title.contains('accredito') ||
        title.contains('activation carte') ||
        title.contains('activation de carte') ||
        title.contains('crédit compte') ||
        title.contains('credit compte') ||
        (title.contains('crédit') && title.contains('compte')) ||
        (title.contains('credit') && title.contains('compte'))) {
      return true;
    }

    if (title.contains('virement') ||
        title.contains('transfert') ||
        title.contains(' vers ')) {
      return false;
    }

    if (t == 'credit') return false;
    if (t == 'debit') {
      return title.contains('accredito') ||
          title.contains('depot') ||
          title.contains('dépôt');
    }

    return t.contains('entr') ||
        t.contains('reçu') ||
        t.contains('recu') ||
        t.contains('depot');
  }

  TransactionEntity toEntity() {
    final raw = montant.replaceAll(' ', '').replaceAll(',', '.');
    final amt = double.tryParse(raw) ?? 0;
    final incoming = historiqueIsDeposit(type, titre);
    return TransactionEntity(
      id: id,
      receiver: titre.isNotEmpty ? titre : '—',
      isIncoming: incoming,
      amount: amt.abs(),
      date: dateTransaction,
      status: 'REUSSI',
      progressPercent: progressPercent,
      apiStatut: virementStatut ?? type,
      supportSlug: null,
    );
  }
}
