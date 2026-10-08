import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/empty_transaction_state.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/transaction_amount_style.dart';
import 'package:intl/intl.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfers_history_bloc.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfers_history_event.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfers_history_state.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Aligné sur le fond clair du dashboard ([HomePage]).
const Color _kHistoryScaffoldBg = Color(0xFFF5F6F8);
const Color _kTextPrimary = Color(0xFF111827);

/// Historique paginé (25 par page, réseau à chaque ouverture — voir [TransfersHistoryBloc]).
class TransfersHistoryPage extends StatelessWidget {
  const TransfersHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransfersHistoryBloc>()..add(LoadTransfersHistoryInitial()),
      child: const _TransfersHistoryView(),
    );
  }
}

class _TransfersHistoryView extends StatelessWidget {
  const _TransfersHistoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kHistoryScaffoldBg,
      resizeToAvoidBottomInset: true,
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
                l10n.transfersHistoryTitle,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<TransfersHistoryBloc, TransfersHistoryState>(
                builder: (context, state) {
                  if (state is TransfersHistoryInitial ||
                      state is TransfersHistoryLoading) {
                    return loader();
                  }
                  if (state is TransfersHistoryError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context
                                  .read<TransfersHistoryBloc>()
                                  .add(LoadTransfersHistoryInitial()),
                              child: Text(l10n.buttonRetry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final loaded = state as TransfersHistoryLoaded;
                  if (loaded.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: EmptyTransactionState(
                          message: l10n.transfersHistoryEmpty,
                          variant: EmptyTransactionVariant.embedded,
                        ),
                      ),
                    );
                  }

                  final showVoirPlus = loaded.transactions.length >= 25 &&
                      loaded.hasMore;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _listVirements(
                          context,
                          loaded.transactions,
                          loaded.currencySymbol,
                        ),
                        if (showVoirPlus) ...[
                          const SizedBox(height: 12),
                          if (loaded.loadMoreInProgress)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: loader(compact: true),
                                  ),
                                ),
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () => context
                                    .read<TransfersHistoryBloc>()
                                    .add(LoadMoreTransactions()),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: DefaultColors.blueBackground,
                                        size: 20,
                                      ),
                                      Text(
                                        l10n.transferSeeMore,
                                        style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13.5,
                                            color: DefaultColors.blueBackground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _listVirements(
  BuildContext context,
  List<TransactionEntity> transfers,
  String currencySymbol,
) {
  final money = NumberFormat.currency(
    locale: Localizations.localeOf(context).toString(),
    symbol: currencySymbol,
    decimalDigits: 2,
  );

  return Column(
    children: transfers.map((transfer) {
      final isDeposit = TransactionAmountStyle.isDeposit(transfer);
      final pct = transfer.progressPercent;
      final showPct = !isDeposit && pct != null;
      final amountColor = TransactionAmountStyle.amountColor(transfer);
      final amountText = TransactionAmountStyle.formattedAmount(
        transfer,
        (v) => money.format(v),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    transfer.receiver,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  TransactionAmountStyle.listIcon(transfer),
                  color: TransactionAmountStyle.iconColor(transfer),
                  size: 28,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amountText,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: amountColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isDeposit ? 'Dépôt' : 'Virement',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.5,
                          color: TransactionAmountStyle.subtitleColor(transfer),
                        ),
                      ),
                    ),
                    if (showPct) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${pct.round()} %',
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: DefaultColors.blueBackground,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  transfer.date,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      color: DefaultColors.black2Color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList(),
  );
}
