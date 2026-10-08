import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/core/widgets/conversation_time_ago.dart';
import 'package:voltigex/core/widgets/profile_avatar.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_event.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_state.dart';
import 'package:voltigex/features/chatting/chat/presentation/pages/chat_page.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:voltigex/features/chatting/conversation/presentation/conversations_inbox_coordinator.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_event.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_state.dart';
import 'package:voltigex/features/chatting/conversation/presentation/widgets/active_contact_avatar.dart';
import 'package:voltigex/features/chatting/conversation/presentation/widgets/typing_dots_indicator.dart';
import 'package:voltigex/l10n/app_localizations.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> with WidgetsBindingObserver {
  bool _creatingSupportConversation = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _lastTypingWatchIds = [];

  bool get _isAdmin => SessionController.instance.isAdminSupport;

  @override
  void initState() {
    super.initState();

    // Enregistrer l'observateur de cycle de vie
    WidgetsBinding.instance.addObserver(this);
    
    // Charger les conversations initiales
    BlocProvider.of<ConversationsBloc>(context).add(FetchConversationsEvent());
  }

  @override
  void dispose() {
    // Retirer l'observateur à la destruction de la page
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    _searchController.dispose();
    unawaited(SocketService.instance.clearTypingWatchForConversations());
    super.dispose();
  }

  // Détecter le retour au premier plan (AppLifecycleState.resumed)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reconnecter les Websockets/Pusher si déconnectés pendant la mise en veille
      SocketService.instance.reconnectIfNeeded(); 

      // 2. Re-souscrire au canal inbox de l'utilisateur courant
      final userId = SessionController.instance.userId;
      if (userId != null) {
        SocketService.instance.subscribeUserInbox(
          userId,
          ConversationsInboxCoordinator.onInboxPusherData,
        );
      }
      
      // Forcer la synchronisation et recharger les conversations
      if (mounted) {
        context.read<ConversationsBloc>().add(
          FetchConversationsEvent(forceFullSync: true),
        );
      }
    }
  }

  Future<void> _refreshConversations() async {
    final bloc = BlocProvider.of<ConversationsBloc>(context);
    _searchController.clear();
    final done = bloc.stream.firstWhere(
      (s) => s is ConversationsLoaded || s is ConversationsError,
    );
    bloc.add(FetchConversationsEvent(forceFullSync: true));
    await done;
  }

  Future<void> _syncPusherSubscriptions(ConversationsLoaded state) async {
    final ids = state.conversations.map((e) => e.id).toList()..sort();
    final prev = List<String>.from(_lastTypingWatchIds)..sort();
    if (listEquals(ids, prev)) return;
    _lastTypingWatchIds = ids;
    await SocketService.instance.subscribePresenceApp();
    await SocketService.instance.setTypingWatchForConversations(ids);
  }

  String _shortFirstNameFromDisplay(String displayName) {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '?';
  }

  /// Pastille uniquement si en ligne ; alternance vert / jaune selon l’id (stable).
  Color? _presenceDotColorForUser(String userId, Set<String> onlineIds) {
    if (userId.isEmpty || !onlineIds.contains(userId)) return null;
    return userId.hashCode.abs() % 2 == 0
        ? const Color(0xFF22C55E)
        : const Color(0xFFEAB308);
  }

  Future<void> _openChatFromConversation(
    BuildContext context,
    ConversationEntity c,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ChatPage(
          conversationId: c.id,
          mate: c.participantName,
          profilePhotoUrl: c.participantProfilePhotoUrl,
          participantRole: c.participantRole,
        ),
      ),
    );

    if (!context.mounted) return;
    context.read<ConversationsBloc>().add(FetchConversationsEvent(forceFullSync: true));
  }

  /// Barre horizontale ou résultats de recherche : conversation existante ou chat vide (création au 1er envoi).
  Future<void> _openChatFromContact(
    BuildContext context,
    UserSearchResultItem r,
  ) async {
    final cid = r.conversationId?.trim();
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => cid != null && cid.isNotEmpty
            ? ChatPage(
                conversationId: cid,
                mate: r.displayName,
                profilePhotoUrl: r.profilePhotoUrl,
                participantRole: r.participantRole,
              )
            : ChatPage(
                conversationId: '',
                mate: r.displayName,
                profilePhotoUrl: r.profilePhotoUrl,
                participantRole: r.participantRole,
                recipientUserId: r.userId,
              ),
      ),
    );
    if (!context.mounted) return;
    context.read<ConversationsBloc>().add(FetchConversationsEvent());
  }

  Widget _buildSearchField(BuildContext context) {
    return ListenableBuilder(
      listenable: _searchController,
      builder: (context, _) {
        return BlocBuilder<ConversationsBloc, ConversationsState>(
          buildWhen: (prev, curr) =>
              prev is ConversationsLoaded != curr is ConversationsLoaded ||
              (curr is ConversationsLoaded &&
                  prev is ConversationsLoaded &&
                  prev.isSearchLoading != curr.isSearchLoading),
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            final searching = state is ConversationsLoaded && state.isSearchLoading;
            final hasText = _searchController.text.isNotEmpty;
            return TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                context.read<ConversationsBloc>().add(SearchConversationsEvent(value));
              },
              style: GoogleFonts.inter(
                fontSize: 15,
                color: DefaultColors.blackColor,
              ),
              decoration: InputDecoration(
                hintText: l10n.conversationsSearchHint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: DefaultColors.greyText.withValues(alpha: 0.75),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: DefaultColors.greyText.withValues(alpha: 0.75),
                  size: 22,
                ),
                suffixIcon: searching
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: loader(compact: true),
                          ),
                        ),
                      )
                    : hasText
                        ? IconButton(
                            tooltip: l10n.conversationsClearTooltip,
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                              final bloc = context.read<ConversationsBloc>();
                              bloc.add(ResetUserSearchUiEvent());
                              bloc.add(FetchConversationsEvent(forceFullSync: true));
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: DefaultColors.greyText.withValues(alpha: 0.85),
                              size: 22,
                            ),
                          )
                        : null,
                filled: true,
                fillColor: DefaultColors.receiverMessage,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: DefaultColors.blueBackground.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: DefaultColors.blueBackground.withValues(alpha: 0.35)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAdmin ? l10n.conversationsTitleSupport : l10n.conversationsTitleMessages,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: DefaultColors.blueBackground,
                fontWeight: FontWeight.w900,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is LogoutSuccess) {
                final session = SessionController.instance;
                session.clearSession();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                    (route) => false,
                  );
                });
              } else if (state is LogoutLoading) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: softLoader(),
                );
              }
              return IconButton(
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                },
                icon: SvgPicture.asset(
                  "assets/images/svg/deconnexion.svg",
                  colorFilter: const ColorFilter.mode(DefaultColors.blueBackground, BlendMode.srcIn),
                  semanticsLabel: l10n.conversationsLogoutSemantics,
                  width: 24.5,
                ),
              );
            },
          )
        ],
      ),
      body: BlocListener<ConversationsBloc, ConversationsState>(
        listenWhen: (p, c) => c is ConversationsLoaded,
        listener: (context, state) {
          if (state is ConversationsLoaded) {
            unawaited(_syncPusherSubscriptions(state));
          }
        },
        child: BlocBuilder<ConversationsBloc, ConversationsState>(
          builder: (context, state) {
            if (state is ConversationsLoading) {
              return Center(child: loader());
            }
            if (state is ConversationsError) {
              return Center(child: Text(state.message));
            }
            if (state is ConversationsLoaded) {
              final list = List<ConversationEntity>.from(state.conversations);
              final l10nBloc = AppLocalizations.of(context)!;
              return RefreshIndicator(
                onRefresh: _refreshConversations,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildSearchField(context),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: _buildPresenceStrip(state),
                      ),
                    ),
                    ..._sliverMainList(context, state, list, l10nBloc),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPresenceStrip(ConversationsLoaded state) {
    final strip = state.allContacts;
    if (strip.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      primary: false,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: strip.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, i) {
        final c = strip[i];
        return GestureDetector(
          onTap: () => _openChatFromContact(context, c),
          child: ActiveContactAvatar(
            profilePhotoUrl: c.profilePhotoUrl,
            participantRole: c.participantRole,
            firstName: _shortFirstNameFromDisplay(c.displayName),
            presenceIndicatorColor: _presenceDotColorForUser(c.userId, state.onlineUserIds),
            size: 52,
          ),
        );
      },
    );
  }

  List<Widget> _sliverMainList(
    BuildContext context,
    ConversationsLoaded state,
    List<ConversationEntity> filtered,
    AppLocalizations l10n,
  ) {
    final userResults = state.userSearchResults;
    if (userResults != null) {
      if (userResults.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                l10n.conversationsNoUserFound,
                style: GoogleFonts.inter(
                  color: DefaultColors.greyText,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ];
      }
      return [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final r = userResults[index];
              return GestureDetector(
                key: ValueKey<String>('contact_${r.userId}'),
                onTap: () => _openChatFromContact(context, r),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  leading: ProfileAvatar(
                    profilePhotoUrl: r.profilePhotoUrl,
                    participantRole: r.participantRole,
                    radius: 20,
                  ),
                  title: Text(
                    r.displayName,
                    style: TextStyle(
                      color: DefaultColors.blackColor.withValues(alpha: 0.75),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: r.email != null && r.email!.isNotEmpty
                      ? Text(
                          r.email!,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Icon(
                    r.conversationId != null && r.conversationId!.trim().isNotEmpty
                        ? Icons.chat_bubble_outline
                        : Icons.person_add_alt_1_outlined,
                    size: 20,
                    color: DefaultColors.blueBackground,
                  ),
                ),
              );
            },
            childCount: userResults.length,
          ),
        ),
      ];
    }

    if (state.conversations.isEmpty) {
      if (_isAdmin) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.conversationsEmptyAdmin,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ];
      }
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.conversationsEmptyClient,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _creatingSupportConversation ? null : _contactSupport,
                    icon: _creatingSupportConversation
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: loader(compact: true, size: 18),
                            ),
                          )
                        : const Icon(Icons.support_agent),
                    label: Text(l10n.conversationsContactSupport),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              l10n.conversationsNoSearchResults,
              style: GoogleFonts.inter(
                color: DefaultColors.greyText,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final conversation = filtered[index];
            final typing = state.typingConversationIds.contains(conversation.id);
            return GestureDetector(
              key: ValueKey<String>('conv_${conversation.id}'),
              onTap: () => _openChatFromConversation(context, conversation),
              child: _buildMessageTile(
                l10n,
                conversation.participantName,
                conversation.participantProfilePhotoUrl,
                conversation.participantRole,
                conversation.lastMessageType,
                conversation.lastMessageContent,
                conversation.lastMessageMediaType,
                conversation.lastMessageTime,
                conversation.unreadCount.toString(),
                showTyping: typing,
              ),
            );
          },
          childCount: filtered.length,
        ),
      ),
    ];
  }

  Future<void> _contactSupport() async {
    setState(() {
      _creatingSupportConversation = true;
    });

    try {
      final useCase = sl<CheckOrCreateConversationUseCase>();
      final conversationId = await useCase.call(contactId: Constants.supportAdminId);

      if (!mounted) return;

      BlocProvider.of<ConversationsBloc>(context).add(FetchConversationsEvent());

      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ChatPage(
            conversationId: conversationId,
            mate: AppLocalizations.of(context)!.conversationsTitleSupport,
            profilePhotoUrl: null,
            participantRole: 'admin',
          ),
        ),
      );

      if (!mounted) return;
      BlocProvider.of<ConversationsBloc>(context).add(FetchConversationsEvent());
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      TopSnackBar.show(
        context,
        t.conversationsSupportError,
        type: TopSnackBarType.error,
        title: t.conversationsSupportSnackTitle,
      );
    } finally {
      if (mounted) {
        setState(() {
          _creatingSupportConversation = false;
        });
      }
    }
  }

  Widget _buildMessageTile(
    AppLocalizations l10n,
    String name,
    String? profilePhotoUrl,
    String? participantRole,
    String messageType,
    String? content,
    String? mediaType,
    DateTime lastMessageTime,
    String unreadCount, {
    bool showTyping = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: ProfileAvatar(
        profilePhotoUrl: profilePhotoUrl,
        participantRole: participantRole,
        radius: 20,
      ),
      title: Text(
        name,
        style: TextStyle(
          color: DefaultColors.blackColor.withValues(alpha: 0.75),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: showTyping
          ? const TypingDotsIndicator()
          : messageType.toUpperCase() == "MEDIA"
              ? Row(
                  children: [
                    Text(
                      mediaType!.toUpperCase().contains('IMAGE')
                          ? l10n.messagePreviewImage
                          : mediaType.toUpperCase().contains('AUDIO')
                              ? l10n.messagePreviewAudio
                              : mediaType.toUpperCase().contains('VIDEO')
                                  ? l10n.messagePreviewVideo
                                  : mediaType.toUpperCase().contains('DOCUMENT')
                                      ? l10n.messagePreviewDocument
                                      : l10n.messagePreviewMedia,
                      style: GoogleFonts.inter(
                        color: Colors.blue.shade400,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  ],
                )
              : Text(
                  content ?? '',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          unreadCount != "0"
              ? Badge(
                  backgroundColor: Colors.blue.shade800,
                  label: Text(
                    unreadCount,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox(height: 16.5),

          ConversationTimeAgo(
            utcTime: lastMessageTime,
            style: TextStyle(color: DefaultColors.blackColor.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }
}
