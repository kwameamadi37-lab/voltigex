import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:voltigex/core/widgets/custom_user_avatar.dart';
import 'package:voltigex/l10n/app_localizations.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/features/dashboard/home/presentation/constants/home_dashboard_constants.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/make_transfer_page.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/transfers_history_page.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_bloc.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_event.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_state.dart';
import 'package:voltigex/features/dashboard/home/presentation/pages/notifications_page.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_cubit.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_state.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_chat_tab_opener.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/empty_transaction_state.dart';
import 'package:voltigex/features/dashboard/shared/presentation/widgets/transaction_amount_style.dart';

/// Fond d’accueil : gris très clair, proche du blanc (style minimaliste).
const Color _kHomeBackground = Color(0xFFF5F6F8);

String _homeNumberFormatLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'fr':
      return 'fr_FR';
    case 'es':
      return 'es_ES';
    case 'de':
      return 'de_DE';
    case 'en':
    default:
      return 'en_US';
  }
}

NumberFormat _homeMoneyFormat(BuildContext context, String symbol) {
  final tag = _homeNumberFormatLocale(Localizations.localeOf(context));
  return NumberFormat.currency(
    locale: tag,
    symbol: symbol,
    decimalDigits: 2,
  );
}

/// Accueil : données via [HomeBloc] (solde + transactions globales).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (SessionController.instance.isAdminSupport) {
      return const _AdminSupportHomeGate();
    }
    return const _HomeDashboardBody();
  }
}

class _AdminSupportHomeGate extends StatefulWidget {
  const _AdminSupportHomeGate();

  @override
  State<_AdminSupportHomeGate> createState() => _AdminSupportHomeGateState();
}

class _AdminSupportHomeGateState extends State<_AdminSupportHomeGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/conversationPage',
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kHomeBackground,
      body: loader(),
    );
  }
}

class _HomeDashboardBody extends StatelessWidget {
  const _HomeDashboardBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (prev, curr) {
        if (curr is! HomeLoaded) return false;
        final msg = curr.warningMessage;
        if (msg == null || msg.isEmpty) return false;
        if (prev is HomeLoaded) return prev.warningMessage != msg;
        return true;
      },
      listener: (context, state) {
        if (state is HomeLoaded && state.warningMessage != null) {
          final t = AppLocalizations.of(context);
          TopSnackBar.show(
            context,
            state.warningMessage!,
            type: TopSnackBarType.error,
            title: t?.noticeTitle ?? 'Notice',
          );
        }
      },
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return Scaffold(
            backgroundColor: _kHomeBackground,
            body: loader(),
          );
        }
        if (state is HomeError) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: _kHomeBackground,
            body: Center(
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
                      onPressed: () =>
                          context.read<HomeBloc>().add(FetchHomeData()),
                      child: Text(l10n.buttonRetry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final loaded = state as HomeLoaded;
        final l10n = AppLocalizations.of(context)!;
        final homeServices = buildHomeDashboardServices(l10n);
        return Scaffold(
          backgroundColor: _kHomeBackground,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<HomeBloc>();
                bloc.add(FetchHomeData());
                await bloc.stream.firstWhere(
                  (s) =>
                      s is HomeError ||
                      (s is HomeLoaded && !s.balanceLoading),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _HomeProfileAvatar(
                                photoUrl: loaded.profile.photoUrl,
                                role: loaded.profile.role,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                loaded.profile.displayName,
                                style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 19,
                                    color: Color(0xFF111827),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => openSupportChatInMainTab(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: SvgPicture.asset(
                            'assets/images/svg/bulles-de-chat.svg',
                            width: 22,
                            colorFilter: const ColorFilter.mode(
                              DefaultColors.blackColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          tooltip: l10n.homeTooltipChat,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const NotificationsPage(),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: DefaultColors.blackColor,
                            size: 26,
                          ),
                          tooltip: l10n.homeTooltipNotifications,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeAvailableBalance,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (loaded.balanceLoading)
                          SizedBox(
                            height: 38,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: loader(compact: true),
                                ),
                              ),
                            ),
                          )
                        else if (loaded.balance != null)
                          Text(
                            _homeMoneyFormat(context, loaded.currencySymbol)
                                .format(loaded.balance!),
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 34,
                                color: DefaultColors.blackColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          )
                        else
                          Text(
                            '—',
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                                color: Colors.grey.shade500,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: Text(
                      l10n.homeWhatToday,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.5,
                          color: DefaultColors.greyText,
                        ),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.05,
                      children: List.generate(homeServices.length,
                          (index) {
                        final s = homeServices[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                _homeOnServiceTap(context, homeServices, index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 19, vertical: 0),
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/svg/${s.iconPath}',
                                    width: 30,
                                    colorFilter: ColorFilter.mode(
                                      DefaultColors.blackColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    s.nom,
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.5,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.description,
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.0,
                                        color: DefaultColors.buttonColor,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 35),
                  _homeOffresSpeciales(context),
                  const SizedBox(height: 32),
                  _homeRecentActivitiesSection(
                    context,
                    l10n,
                    loaded.transactions.take(5).toList(growable: false),
                    loaded.currencySymbol,
                  ),
                  const SizedBox(height: 25),
                  _homeSuggestions(context),
                  const SizedBox(height: 28),
                  _homeFraudAlertSection(context),
                  const SizedBox(height: 45),
                ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeProfileAvatar extends StatelessWidget {
  const _HomeProfileAvatar({required this.photoUrl, this.role});

  final String? photoUrl;
  final String? role;

  @override
  Widget build(BuildContext context) {
    return CustomUserAvatar(
      profilePhotoUrl: photoUrl,
      role: role,
      radius: 20,
      backgroundColor: Colors.grey.shade200,
    );
  }
}

void _homeOnServiceTap(
  BuildContext context,
  List<HomeDashboardService> services,
  int index,
) {
  final s = services[index];
  if (s.id == 'transfer') {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => sl<TransferBloc>(),
          child: const MakeTransferPage(),
        ),
      ),
    );
    return;
  }
  if (s.id == 'deposit') {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute<void>(
        builder: (_) => const TransfersHistoryPage(),
      ),
    );
    return;
  }
  final route = s.pageToGo.trim();
  if (route.isEmpty) return;
  if (route == '/profilPage') {
    context.read<MainNavigationCubit>().selectTab(MainNavigationState.tabProfil);
    return;
  }
  if (route == '/cardPage') {
    context.read<MainNavigationCubit>().selectTab(MainNavigationState.tabCards);
    return;
  }
  Navigator.of(context, rootNavigator: true).pushNamed(route);
}

/// Données issues du [HomeBloc], limitées aux 5 dernières entrées.
Widget _homeRecentActivitiesSection(
  BuildContext context,
  AppLocalizations l10n,
  List<TransactionEntity> recent,
  String currencySymbol,
) {
  return Container(
    decoration: BoxDecoration(
      color: DefaultColors.whiteText,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: DefaultColors.greyText.withValues(alpha: 0.15),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    margin: const EdgeInsets.symmetric(horizontal: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 22.0, vertical: 22.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.homeTransactionsSection,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.5,
                    color: DefaultColors.blackColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: false).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TransfersHistoryPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.homeSeeAll,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: DefaultColors.blueBackground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          EmptyTransactionState(
            message: l10n.homeEmptyTransactions,
            variant: EmptyTransactionVariant.embedded,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recent.length,
            itemBuilder: (context, i) {
              final t = recent[i];
              final amountColor = TransactionAmountStyle.amountColor(t);
              final amountText = TransactionAmountStyle.formattedAmount(
                t,
                (v) => _homeMoneyFormat(context, currencySymbol).format(v),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor:
                          DefaultColors.blueBackground.withValues(alpha: 0.1),
                      child: Icon(
                        TransactionAmountStyle.listIcon(t),
                        size: 22,
                        color: TransactionAmountStyle.iconColor(t),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.receiver,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.5,
                                color: Color(0xFF111827),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.date,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      amountText,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: amountColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    ),
  );
}

Widget _homeFraudFeatureTile({
  required IconData icon,
  required Color iconColor,
  required Color iconBackground,
  required String title,
  required String body,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF111827),
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12.5,
                  height: 1.45,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _homeFraudAlertSection(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  const radius = 24.0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeFraudAlertIntro,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _homeFraudFeatureTile(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    iconBackground: const Color(0xFFEDE9FE),
                    title: l10n.homeFraudAlertFeature1Title,
                    body: l10n.homeFraudAlertFeature1Body,
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  _homeFraudFeatureTile(
                    icon: Icons.lock_rounded,
                    iconColor: const Color(0xFF0369A1),
                    iconBackground: const Color(0xFFE0F2FE),
                    title: l10n.homeFraudAlertFeature2Title,
                    body: l10n.homeFraudAlertFeature2Body,
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  _homeFraudFeatureTile(
                    icon: Icons.radar_rounded,
                    iconColor: const Color(0xFF047857),
                    iconBackground: const Color(0xFFD1FAE5),
                    title: l10n.homeFraudAlertFeature3Title,
                    body: l10n.homeFraudAlertFeature3Body,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => openSupportChatInMainTab(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: DefaultColors.blueBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.homeFraudAlertCta,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    ),
  );
}

Widget _homeSuggestions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final suggestions = buildHomeDashboardSuggestions(l10n);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 22.0),
        child: Text(
          l10n.homeSuggestedForYou,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.5,
              color: Color(0xFF111827),
            ),
          ),
          textAlign: TextAlign.left,
        ),
      ),
      const SizedBox(height: 10),
      CarouselSlider(
        options: CarouselOptions(
          height: 140,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 2),
          enlargeCenterPage: true,
          enlargeFactor: 0,
          viewportFraction: 0.58,
        ),
        items: List.generate(suggestions.length, (index) {
          final sug = suggestions[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 210,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/${sug.iconPath}'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: const EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    color: DefaultColors.yellowBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sug.nom,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: DefaultColors.blackColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ),
    ],
  );
}

Widget _homeOffresSpeciales(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return SizedBox(
    width: double.infinity,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: DefaultColors.blueBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.credit_card_rounded,
                  size: 30.5,
                  color: DefaultColors.whiteText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homePromoTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17.5,
                            color: DefaultColors.whiteText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homePromoSubtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5,
                            color: DefaultColors.whiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 12,
            backgroundColor: DefaultColors.whiteText,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: DefaultColors.blueBackground,
            ),
          ),
        ],
      ),
    ),
  );
}
