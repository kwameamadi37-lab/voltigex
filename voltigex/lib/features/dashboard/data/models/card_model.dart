import 'package:voltigex/features/dashboard/domain/entities/card_entity.dart';

/// Données carte issues de `GET /api/user/card-details` (ou cache Hive).
class CardModel {
  CardModel({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardActive,
    required this.cardPending,
    required this.cardFrozen,
    required this.holderName,
    required this.last4,
    required this.cardAmount,
    required this.cardType,
  });

  final String id;
  final String cardNumber;
  /// Format `MM/YY` (aligné activation API).
  final String expiryDate;
  final String cvv;
  final bool cardActive;
  final bool cardPending;
  final bool cardFrozen;
  final String holderName;
  final String last4;
  final double cardAmount;
  /// `gold` | `diamond` | `platinum`
  final String cardType;

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final rawNum = (json['card_number'] ?? '').toString().replaceAll(RegExp(r'\s'), '');
    final last4FromApi = (json['last4'] ?? '').toString().trim();
    final last4 = last4FromApi.isNotEmpty
        ? last4FromApi
        : (rawNum.length >= 4 ? rawNum.substring(rawNum.length - 4) : rawNum);

    return CardModel(
      id: (json['id'] ?? '').toString(),
      cardNumber: rawNum,
      expiryDate: (json['date_exp'] ?? json['expiryDate'] ?? '').toString().trim(),
      cvv: (json['cvv'] ?? '').toString(),
      cardActive: _parseBool(json['card_active'] ?? json['cardActive']),
      cardPending: _parseBool(json['card_pending'] ?? json['cardPending']),
      cardFrozen: _parseBool(json['card_frozen'] ?? json['cardFrozen']),
      holderName: (json['holder_name'] ?? json['holderName'] ?? 'Titulaire').toString().trim(),
      last4: last4,
      cardAmount: _parseDouble(json['card_amount'] ?? json['cardAmount']),
      cardType: _normalizeCardType(json['card_type'] ?? json['cardType']),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v is num) return v.toDouble();
    final s = v?.toString().replaceAll(' ', '').replaceAll(',', '.') ?? '';
    return double.tryParse(s) ?? 0;
  }

  static String _normalizeCardType(dynamic v) {
    final s = (v ?? 'platinum').toString().toLowerCase().trim();
    if (s.contains('gold')) return 'gold';
    if (s.contains('diamond')) return 'diamond';
    return 'platinum';
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase() ?? '';
    return s == '1' || s == 'true';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'card_number': cardNumber,
        'date_exp': expiryDate,
        'cvv': cvv,
        'card_active': cardActive,
        'card_pending': cardPending,
        'card_frozen': cardFrozen,
        'holder_name': holderName,
        'last4': last4,
        'card_amount': cardAmount,
        'card_type': cardType,
      };

  /// Affichage type `4532 1234 5678 3642`
  String get numberSpaced {
    final d = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return '';
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  /// `MM/YY` → `MM/20YY` pour l’UI (comme le mock).
  String get expiryDisplayLong {
    final t = expiryDate.trim();
    final parts = t.split(RegExp(r'[/\-]'));
    if (parts.length >= 2) {
      final mm = parts[0].padLeft(2, '0');
      var yy = parts[1];
      if (yy.length == 2) {
        final y = int.tryParse(yy) ?? 0;
        return '$mm/${2000 + y}';
      }
      return t.contains('/') ? t : '$mm/$yy';
    }
    return t;
  }

  CardEntity toEntity() {
    return CardEntity(
      id: id,
      holderName: holderName.isEmpty ? 'Titulaire' : holderName,
      numberDisplay: numberSpaced,
      last4: last4,
      cvc: cvv,
      expiryDisplay: expiryDisplayLong,
      balance: cardAmount,
      cardType: cardType,
      isActive: cardActive,
      isPending: cardPending,
      isFrozen: cardFrozen,
    );
  }
}
