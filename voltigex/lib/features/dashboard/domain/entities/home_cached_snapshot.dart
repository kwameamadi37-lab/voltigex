import 'package:voltigex/features/dashboard/domain/entities/home_profile_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

/// Données persistées localement pour l’accueil (hors solde).
class HomeCachedSnapshot {
  const HomeCachedSnapshot({
    required this.profile,
    required this.transactions,
  });

  final HomeProfileEntity profile;
  final List<TransactionEntity> transactions;
}
