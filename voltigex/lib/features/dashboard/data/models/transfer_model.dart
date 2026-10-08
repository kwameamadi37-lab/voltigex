import 'package:voltigex/features/dashboard/domain/entities/transfer_entity.dart';

/// Sérialisation d’une ligne `virements` depuis l’API.
class TransferModel {
  TransferModel._(this._entity);

  final TransferEntity _entity;

  TransferEntity toEntity() => _entity;

  /// Parse un map Laravel `virements.*` (champs snake / mixtes).
  factory TransferModel.fromVirementMap(Map<String, dynamic> m) {
    final idRaw = m['id'];
    final id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw') ?? 0;
    final amountRaw = m['montant'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse('$amountRaw') ?? 0;
    final progressRaw = m['pourcentage'];
    final pourcentage = progressRaw is num
        ? progressRaw.toDouble()
        : double.tryParse('${progressRaw ?? ''}'.trim().replaceAll(',', '.')) ??
            0;
    final statut = m['statut']?.toString().trim() ?? '';
    final codeRaw = m['code']?.toString().trim() ?? '';
    final holder = m['titulairebanque']?.toString().trim() ?? '';
    final apiFirstName = m['prenom']?.toString().trim() ?? '';
    final apiLastName = m['nom']?.toString().trim() ?? '';
    final nameParts =
        holder.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final firstName = apiFirstName.isNotEmpty
        ? apiFirstName
        : (nameParts.isEmpty ? '' : nameParts.first);
    final lastName = apiLastName.isNotEmpty
        ? apiLastName
        : (nameParts.length <= 1 ? '' : nameParts.sublist(1).join(' '));
    final bicRaw = m['bic']?.toString().trim() ?? '';
    final slugRaw = m['slug']?.toString().trim() ?? '';
    final slug = slugRaw.isEmpty ? null : slugRaw;

    return TransferModel._(
      TransferEntity(
        id: id,
        slug: slug,
        pourcentage: pourcentage,
        statut: statut,
        holderName: holder,
        firstName: firstName,
        lastName: lastName,
        bankName: m['nombanque']?.toString().trim() ?? '',
        iban: m['iban']?.toString().trim() ?? '',
        bic: bicRaw.isEmpty ? null : bicRaw,
        amount: amount,
        currentCode: codeRaw.isEmpty ? null : codeRaw,
      ),
    );
  }
}
