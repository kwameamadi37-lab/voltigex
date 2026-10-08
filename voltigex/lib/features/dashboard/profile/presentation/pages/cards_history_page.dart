import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/empty_transaction_state.dart';
import 'package:voltigex/l10n/app_localizations.dart';

class CardsHistoryPage extends StatelessWidget {
  const CardsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor:  DefaultColors.whiteText,
                  foregroundColor: DefaultColors.blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.cardsHistoryTitle,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: DefaultColors.blackColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: EmptyTransactionState(
                  message: l10n.cardsHistoryEmpty,
                  variant: EmptyTransactionVariant.embedded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
