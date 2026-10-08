import 'package:flutter/material.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

/// Affichage montant / couleur pour l’historique (dépôt vs virement).
class TransactionAmountStyle {
  TransactionAmountStyle._();

  static bool isDeposit(TransactionEntity t) => t.isIncoming;

  static Color amountColor(TransactionEntity t) {
    if (isDeposit(t)) return const Color(0xFF16A34A);
    return const Color(0xFF111827);
  }

  static Color iconColor(TransactionEntity t) {
    if (isDeposit(t)) return const Color(0xFF16A34A);
    return const Color(0xFF1E3A8A);
  }

  static IconData listIcon(TransactionEntity t) {
    if (isDeposit(t)) return Icons.add_circle_outline_rounded;
    return Icons.arrow_upward_rounded;
  }

  static String formattedAmount(
    TransactionEntity t,
    String Function(double) formatMoney,
  ) {
    final base = formatMoney(t.amount);
    if (isDeposit(t)) return '+$base';
    return '-$base';
  }
}
