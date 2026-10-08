import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/core/network/notification_service.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_bloc.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_event.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_state.dart';
import 'package:voltigex/features/dashboard/cards/presentation/pages/cards_page.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_bloc.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_event.dart';
import 'package:voltigex/features/dashboard/home/presentation/pages/home_page.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_bloc.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/settings_page.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_bloc.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_event.dart';
import 'package:voltigex/features/chatting/chat/presentation/pages/chat_page.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_cubit.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_state.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Shell principal : onglets persistants via [IndexedStack]. Les onglets **Accueil**, **Cartes**
/// et **Paramètres** encapsulent chacun un [Navigator] pour les pushes avec `rootNavigator: false`
/// sous la barre du bas ([PopScope] : retour matériel dépile d’abord la pile de l’onglet).
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _lastNavIndex = -1;
  bool _syncedLastIndex = false;

  /// Mutation carte alors que l’onglet Accueil n’était pas visible : [FetchHomeData] au retour sur Accueil.
  bool _pendingHomeWalletSync = false;

  /// Pile locale de l’onglet Accueil ([HomePage] + routes poussées avec `rootNavigator: false`).
  final GlobalKey<NavigatorState> _homeTabNavigatorKey = GlobalKey<NavigatorState>();

  /// Pile locale de l’onglet Cartes (ex. [TransfersHistoryPage] avec barre du bas visible).
  final GlobalKey<NavigatorState> _cardsTabNavigatorKey = GlobalKey<NavigatorState>();

  /// Pile locale de l’onglet Paramètres ([SettingsPage] + sous-pages).
  final GlobalKey<NavigatorState> _profileTabNavigatorKey = GlobalKey<NavigatorState>();

  /// Delta sync API déjà déclenché cette session pour cette conversation (onglet Chat).
  final Set<String> _sessionChatApiSyncedIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapDefaultSupportChat();
      if (!SessionController.instance.isAdminSupport) {
        NotificationService.registerTokenAfterAuth();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_syncedLastIndex) {
      _lastNavIndex = context.read<MainNavigationCubit>().state.currentIndex;
      _syncedLastIndex = true;
    }
  }

  GlobalKey<NavigatorState>? _navigatorKeyForTab(int index) {
    switch (index) {
      case MainNavigationState.tabHome:
        return _homeTabNavigatorKey;
      case MainNavigationState.tabCards:
        return _cardsTabNavigatorKey;
      case MainNavigationState.tabProfil:
        return _profileTabNavigatorKey;
      default:
        return null;
    }
  }

  /// Bouton retour système : dépile l’onglet courant si possible, sinon Paramètres/Chat → Accueil,
  /// sinon sortie de l’app.
  void _handleMainShellPopAttempt(BuildContext context) {
    if (!mounted) return;
    final navCubit = context.read<MainNavigationCubit>();
    final idx = navCubit.state.currentIndex;

    final nested = _navigatorKeyForTab(idx)?.currentState;
    if (nested != null && nested.canPop()) {
      nested.pop();
      return;
    }

    if (idx == MainNavigationState.tabProfil) {
      navCubit.selectTab(MainNavigationState.tabHome);
      return;
    }

    if (idx == MainNavigationState.tabChat) {
      navCubit.selectTab(MainNavigationState.tabHome);
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardsBloc, CardsState>(
      listenWhen: (prev, curr) {
        if (curr is! CardsLoaded || prev is! CardsLoaded) return false;
        return curr.walletSyncGeneration > prev.walletSyncGeneration;
      },
      listener: (context, state) {
        final nav = context.read<MainNavigationCubit>().state;
        if (nav.currentIndex == MainNavigationState.tabHome) {
          context.read<HomeBloc>().add(FetchHomeData());
        } else {
          setState(() => _pendingHomeWalletSync = true);
        }
      },
      child: BlocConsumer<MainNavigationCubit, MainNavigationState>(
      listenWhen: (prev, curr) =>
          prev.currentIndex != curr.currentIndex ||
          prev.chatTarget != curr.chatTarget,
      listener: (context, state) {
        const chatIdx = MainNavigationState.tabChat;
        if (_lastNavIndex == chatIdx && state.currentIndex != chatIdx) {
          context.read<ChatBloc>().add(ChatConversationUiClosedEvent());
        }

        if (state.currentIndex == MainNavigationState.tabCards &&
            _lastNavIndex != MainNavigationState.tabCards) {
          context.read<CardsBloc>().add(RefreshCardsData(forceRefresh: false));
        }

        _lastNavIndex = state.currentIndex;

        if (state.currentIndex == MainNavigationState.tabHome &&
            _pendingHomeWalletSync) {
          _pendingHomeWalletSync = false;
          context.read<HomeBloc>().add(FetchHomeData());
        }

        _requestChatDeltaSyncAfterFrame(context, state);
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, dynamic result) {
            if (didPop) return;
            _handleMainShellPopAttempt(context);
          },
          child: Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: [
              Navigator(
                key: _homeTabNavigatorKey,
                onGenerateInitialRoutes: (_, __) => [
                  MaterialPageRoute<void>(
                    builder: (_) => const HomePage(),
                  ),
                ],
              ),
              Navigator(
                key: _cardsTabNavigatorKey,
                onGenerateInitialRoutes: (_, __) => [
                  MaterialPageRoute<void>(
                    builder: (_) => const CardsPage(),
                  ),
                ],
              ),
              BlocProvider(
                create: (_) => sl<ProfileBloc>()..add(LoadProfile()),
                child: Navigator(
                  key: _profileTabNavigatorKey,
                  onGenerateInitialRoutes: (_, __) => [
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfilPage(),
                    ),
                  ],
                ),
              ),
              _MainChatTabSlot(target: state.chatTarget),
            ],
          ),
          bottomNavigationBar: NavigationBar(
                selectedIndex: state.currentIndex,
                // labelTextStyle: GoogleFonts.inter(
                //   textStyle: TextStyle(
                //     fontSize: 12.5,
                //     color: DefaultColors.blackColor,
                //   ),
                // ),
                onDestinationSelected: (i) {
                  context.read<MainNavigationCubit>().selectTab(i);
                },
                indicatorColor: Colors.transparent,
                backgroundColor: Colors.white,
                destinations: [
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      'assets/images/svg/accueil.svg',
                      width: 18,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/svg/accueil.svg',
                      width: 18,
                      colorFilter: const ColorFilter.mode(DefaultColors.blackColor, BlendMode.srcIn),
                    ),
                    label: l10n.navHome,
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      'assets/images/svg/carte-de-credit.svg',
                      width: 20,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/svg/carte-de-credit.svg',
                      width: 20,
                      colorFilter: const ColorFilter.mode(DefaultColors.blackColor, BlendMode.srcIn),
                    ),
                    label: l10n.navCards,
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      'assets/images/svg/settings.svg',
                      width: 18,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/svg/settings.svg',
                      width: 18,
                      colorFilter: const ColorFilter.mode(DefaultColors.blackColor, BlendMode.srcIn),
                    ),
                    label: l10n.navSettings,
                    tooltip: l10n.navSettingsTooltip,
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      'assets/images/svg/bulles-de-chat.svg',
                      width: 18,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    ),
                    selectedIcon: SvgPicture.asset(
                      'assets/images/svg/bulles-de-chat.svg',
                      width: 18,
                      colorFilter: const ColorFilter.mode(DefaultColors.blackColor, BlendMode.srcIn),
                    ),
                    label: l10n.navSupport,
                  ),
                ],
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
            ),
        );
      },
    ),
    );
  }

  /// Session client : conversation Support par défaut + hydrate cache + delta API en arrière-plan.
  Future<void> _bootstrapDefaultSupportChat() async {
    if (!mounted) return;
    final session = SessionController.instance;
    if (session.token == null || session.token!.isEmpty) return;
    if (session.isAdminSupport) return;

    final navCubit = context.read<MainNavigationCubit>();
    await navCubit.applyDefaultSupportChatTargetIfNeeded();
    if (!mounted) return;

    final target = navCubit.state.chatTarget;
    if (!target.isOpen) return;

    final cid = target.conversationId.trim();
    final uid = session.userId ?? '';
    final chatBloc = context.read<ChatBloc>();

    chatBloc.add(
      HydrateChatFromCacheEvent(
        cid,
        currentUserId: uid.isNotEmpty ? uid : null,
      ),
    );

    if (!_sessionChatApiSyncedIds.contains(cid)) {
      _sessionChatApiSyncedIds.add(cid);
      chatBloc.add(
        LoadMessagesEvent(
          cid,
          currentUserId: uid.isNotEmpty ? uid : null,
        ),
      );
    }
  }

  /// Après [HydrateChatFromCacheEvent] (post-frame ChatPage), lance une seule fois par
  /// conversation la sync API ([LoadMessagesEvent]) lorsque l’onglet Chat est actif.
  void _requestChatDeltaSyncAfterFrame(
    BuildContext context,
    MainNavigationState state,
  ) {
    if (state.currentIndex != MainNavigationState.tabChat) return;
    if (!state.chatTarget.isOpen) return;
    final cid = state.chatTarget.conversationId.trim();
    if (cid.isEmpty) return;
    if (_sessionChatApiSyncedIds.contains(cid)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final nav = context.read<MainNavigationCubit>().state;
      if (nav.currentIndex != MainNavigationState.tabChat) return;
      if (!nav.chatTarget.isOpen || nav.chatTarget.conversationId.trim() != cid) {
        return;
      }
      if (_sessionChatApiSyncedIds.contains(cid)) return;
      _sessionChatApiSyncedIds.add(cid);
      final uid = SessionController.instance.userId ?? '';
      context.read<ChatBloc>().add(
            LoadMessagesEvent(
              cid,
              currentUserId: uid.isNotEmpty ? uid : null,
            ),
          );
    });
  }
}

class _MainChatTabSlot extends StatelessWidget {
  final MainChatTabTarget target;

  const _MainChatTabSlot({required this.target});

  @override
  Widget build(BuildContext context) {
    if (!target.isOpen) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.chatTabPlaceholder,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.35,
              ),
            ),
          ),
        ),
      );
    }

    return ChatPage(
      key: ValueKey<String>(target.conversationId),
      conversationId: target.conversationId,
      mate: target.mate,
      profilePhotoUrl: target.profilePhotoUrl,
      participantRole: target.participantRole,
    );
  }
}
