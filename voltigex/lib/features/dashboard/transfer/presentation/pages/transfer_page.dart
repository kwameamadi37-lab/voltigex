import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_chat_tab_opener.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/make_transfer_page.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/transfers_history_page.dart';
import 'package:voltigex/l10n/app_localizations.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: DefaultColors.scafoldColor,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            l10n.transferPageTitle,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20.5,
                color: DefaultColors.blackColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => openSupportChatInMainTab(context),
            icon: SvgPicture.asset(
              'assets/images/svg/bulle-2.svg',
              colorFilter: const ColorFilter.mode(DefaultColors.blackColor, BlendMode.srcIn),
              semanticsLabel: l10n.homeTooltipChat,
              width: 35.5,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/svg/virement (3).svg',
                  colorFilter: const ColorFilter.mode(DefaultColors.blueBackground, BlendMode.srcIn),
                  semanticsLabel: l10n.transferDoTransfer,
                  width: 21.5,
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<TransferBloc>(),
                          child: const MakeTransferPage(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n.transferDoTransfer,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17.0,
                        color: DefaultColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/svg/transfer-history.svg',
                  colorFilter: const ColorFilter.mode(DefaultColors.blueBackground, BlendMode.srcIn),
                  semanticsLabel: l10n.transferHistoryMenu,
                  width: 21.5,
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TransfersHistoryPage(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.transferHistoryMenu,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 17.0,
                        color: DefaultColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
