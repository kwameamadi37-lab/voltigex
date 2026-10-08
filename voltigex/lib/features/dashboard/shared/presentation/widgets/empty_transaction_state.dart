import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';

/// Variante d’affichage : contenu seul (carte parente) ou carte blanche autonome (onglet Cartes).
enum EmptyTransactionVariant {
  /// Dans une carte existante (accueil, historique intégré).
  embedded,

  /// Bloc blanc avec ombre (comme l’historique carte sur la page Cartes).
  standaloneCard,
}

/// État vide commun : globe + texte (transactions).
class EmptyTransactionState extends StatelessWidget {
  const EmptyTransactionState({
    super.key,
    required this.message,
    this.variant = EmptyTransactionVariant.embedded,
  });

  final String message;
  final EmptyTransactionVariant variant;

  @override
  Widget build(BuildContext context) {
    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.public_rounded,
          size: 72,
          color: DefaultColors.blueBackground,
        ),
        const SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );

    switch (variant) {
      case EmptyTransactionVariant.embedded:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: inner,
        );
      case EmptyTransactionVariant.standaloneCard:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: inner,
        );
    }
  }
}
