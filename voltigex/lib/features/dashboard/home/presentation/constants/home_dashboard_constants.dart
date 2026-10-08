import 'package:flutter/material.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Tuile service sur l’accueil (données statiques, pas d’état local).
class HomeDashboardService {
  const HomeDashboardService({
    required this.id,
    required this.nom,
    required this.pageToGo,
    required this.iconPath,
    required this.color,
    required this.description,
  });

  /// Identifiant stable pour la navigation (ex. virement local).
  final String id;
  final String nom;
  final String pageToGo;
  final String iconPath;
  final Color color;
  final String description;
}

/// Carte « Suggérés pour vous » (carousel).
class HomeDashboardSuggestion {
  const HomeDashboardSuggestion({
    required this.nom,
    required this.iconPath,
  });

  final String nom;
  final String iconPath;
}

List<HomeDashboardSuggestion> buildHomeDashboardSuggestions(
  AppLocalizations l10n,
) {
  return [
    HomeDashboardSuggestion(
      nom: l10n.homeSuggestionInsurance,
      iconPath: 'insurance-services.png',
    ),
    HomeDashboardSuggestion(
      nom: l10n.homeSuggestionCredits,
      iconPath: 'pret.jpg',
    ),
    HomeDashboardSuggestion(
      nom: l10n.homeSuggestionSavings,
      iconPath: 'savings-account.png',
    ),
    HomeDashboardSuggestion(
      nom: l10n.homeSuggestionInvestments,
      iconPath: 'investment.png',
    ),
  ];
}

List<HomeDashboardService> buildHomeDashboardServices(AppLocalizations l10n) {
  return [
    HomeDashboardService(
      id: 'deposit',
      nom: l10n.homeServiceDepositTitle,
      // pageToGo: '/virementPage',
      pageToGo: '',
      iconPath: 'telecharger-le-bouton-circulaire.svg',
      color: const Color(0xFFF6F5FD),
      description: l10n.homeServiceDepositDescription,
    ),
    HomeDashboardService(
      id: 'transfer',
      nom: l10n.homeServiceTransferTitle,
      pageToGo: '',
      iconPath: 'retrait-dargent.svg',
      color: const Color(0xFFD9EADA),
      description: l10n.homeServiceTransferDescription,
    ),
    HomeDashboardService(
      id: 'cards',
      nom: l10n.homeServiceCardsTitle,
      pageToGo: '/cardPage',
      iconPath: 'paiement-par-carte-de-credit.svg',
      color: const Color(0xFFFFF9F1),
      description: l10n.homeServiceCardsDescription,
    ),
    HomeDashboardService(
      id: 'settings_profile',
      nom: l10n.homeServiceSettingsTitle,
      pageToGo: '/profilPage',
      iconPath: 'settings.svg',
      color: const Color.fromARGB(255, 255, 255, 255),
      description: l10n.homeServiceSettingsDescription,
    ),
  ];
}
