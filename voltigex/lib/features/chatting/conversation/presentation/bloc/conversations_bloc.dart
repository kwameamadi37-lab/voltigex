import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/conversation/data/local/conversations_inbox_cache.dart';
import 'package:voltigex/features/chatting/conversation/data/models/conversation_model.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/user_search_result_item.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/fetch_chat_contacts_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/search_conversations_use_case.dart';
import 'package:voltigex/features/chatting/conversation/presentation/conversations_inbox_coordinator.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_event.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final FetchConversationsUseCase fetchConversationsUseCase;
  final FetchChatContactsUseCase fetchChatContactsUseCase;
  final SearchConversationsUseCase searchConversationsUseCase;

  final List<ConversationModel> _conversations = [];
  final Set<String> _onlineUserIds = {};
  final Set<String> _typingConversationIds = {};
  final Map<String, Timer> _typingTimers = {};
  /// Liste courante = résultats de recherche API (ne pas fusionner inbox Pusher tant que non réinitialisé).
  bool _searchActive = false;
  /// Barre horizontale : tous les contacts éligibles.
  List<UserSearchResultItem> _allContacts = [];
  /// Non null : résultats recherche — liste verticale uniquement.
  List<UserSearchResultItem>? _userSearchResults;

  ConversationsBloc({
    required this.fetchConversationsUseCase,
    required this.fetchChatContactsUseCase,
    required this.searchConversationsUseCase,
  }) : super(ConversationsInitial()) {
    ConversationsInboxCoordinator.attach(this);
    on<FetchConversationsEvent>(_onFetchConversations);
    on<SearchConversationsEvent>(
      _onSearchConversations,
      transformer: (events, mapper) => events.debounce(const Duration(milliseconds: 500)).asyncExpand(mapper),
    );
    on<ResetUserSearchUiEvent>(_onResetUserSearchUi);
    on<InboxPusherPatchEvent>(_onInboxPusherPatch);
    on<SyncConversationPreviewFromChatEvent>(_onSyncFromChat);
    on<PresenceMembersSnapshotEvent>(_onPresenceSnapshot);
    on<PresenceUserJoinedEvent>(_onPresenceJoined);
    on<PresenceUserLeftEvent>(_onPresenceLeft);
    on<RemoteTypingPingEvent>(_onRemoteTyping);
    on<TypingIndicatorTimeoutEvent>(_onTypingTimeout);
  }

  bool _searchLoadingFromState() {
    return state is ConversationsLoaded && (state as ConversationsLoaded).isSearchLoading;
  }

  void _emitLoaded(Emitter<ConversationsState> emit, {bool? isSearchLoading}) {
    emit(
      ConversationsLoaded(
        List<ConversationEntity>.from(_conversations),
        onlineUserIds: Set<String>.from(_onlineUserIds),
        typingConversationIds: Set<String>.from(_typingConversationIds),
        isSearchLoading: isSearchLoading ?? _searchLoadingFromState(),
        allContacts: List<UserSearchResultItem>.from(_allContacts),
        userSearchResults: _userSearchResults,
      ),
    );
  }

  void _onResetUserSearchUi(ResetUserSearchUiEvent event, Emitter<ConversationsState> emit) {
    _userSearchResults = null;
    _searchActive = false;
    _emitLoaded(emit, isSearchLoading: false);
  }

  @override
  Future<void> close() {
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    _typingTimers.clear();
    ConversationsInboxCoordinator.detach(this);
    return super.close();
  }

  DateTime? _maxUpdatedAt() {
    if (_conversations.isEmpty) return null;
    DateTime? max;
    for (final c in _conversations) {
      if (max == null || c.updatedAt.isAfter(max)) {
        max = c.updatedAt;
      }
    }
    return max;
  }

  void _sortConversations() {
    _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  String _apiLastMessageType(MessageEntity m) {
    final u = m.type.toUpperCase();
    return u == 'MEDIA' ? 'media' : 'text';
  }

  String? _apiListMediaType(MessageEntity m) {
    if (m.type.toUpperCase() != 'MEDIA') return null;
    final x = (m.mediaType ?? '').toLowerCase();
    if (x == 'image' || ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(x)) {
      return 'IMAGE';
    }
    if (x == 'video' || ['mp4', 'mov', 'avi', 'mkv'].contains(x)) {
      return 'VIDEO';
    }
    if (x == 'audio' || ['mp3', 'wav', 'aac'].contains(x)) {
      return 'AUDIO';
    }
    if (x == 'pdf' || x.contains('doc')) {
      return 'DOCUMENT';
    }
    return m.mediaType?.toUpperCase();
  }

  DateTime _messageTime(MessageEntity m) {
    return DateTime.tryParse(m.createdAt) ?? DateTime.now();
  }

  Future<void> _onSyncFromChat(
    SyncConversationPreviewFromChatEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    if (_searchActive) {
      return;
    }
    final idx = _conversations.indexWhere((c) => c.id == event.conversationId);
    if (idx == -1) {
      add(FetchConversationsEvent());
      return;
    }
    final cur = _conversations[idx];
    final m = event.lastMessage;
    final t = _messageTime(m);
    final next = cur.copyWithModel(
      lastMessageType: _apiLastMessageType(m),
      lastMessageContent: m.content,
      lastMessageMediaType: _apiListMediaType(m),
      lastMessageTime: t,
      updatedAt: t,
      unreadCount: 0,
    );
    _conversations[idx] = next;
    _sortConversations();
    await ConversationsInboxCache.writeList(_conversations);
    _emitLoaded(emit);
  }

  Future<void> _onPresenceSnapshot(
    PresenceMembersSnapshotEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    _onlineUserIds
      ..clear()
      ..addAll(event.userIds);
    if (state is ConversationsLoaded) {
      _emitLoaded(emit);
    }
  }

  Future<void> _onPresenceJoined(
    PresenceUserJoinedEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    if (event.userId.isEmpty) return;
    _onlineUserIds.add(event.userId);
    if (state is ConversationsLoaded) {
      _emitLoaded(emit);
    }
  }

  Future<void> _onPresenceLeft(
    PresenceUserLeftEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    _onlineUserIds.remove(event.userId);
    if (state is ConversationsLoaded) {
      _emitLoaded(emit);
    }
  }

  Future<void> _onRemoteTyping(
    RemoteTypingPingEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    if (event.conversationId.isEmpty) return;
    _typingTimers[event.conversationId]?.cancel();
    _typingConversationIds.add(event.conversationId);
    if (state is ConversationsLoaded) {
      _emitLoaded(emit);
    }
    _typingTimers[event.conversationId] = Timer(const Duration(seconds: 3), () {
      add(TypingIndicatorTimeoutEvent(event.conversationId));
    });
  }

  Future<void> _onTypingTimeout(
    TypingIndicatorTimeoutEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    _typingTimers.remove(event.conversationId)?.cancel();
    _typingConversationIds.remove(event.conversationId);
    if (state is ConversationsLoaded) {
      _emitLoaded(emit);
    }
  }

  Future<void> _onInboxPusherPatch(
    InboxPusherPatchEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    Map<String, dynamic>? map;
    try {
      if (event.rawData is String) {
        map = Map<String, dynamic>.from(jsonDecode(event.rawData as String) as Map);
      } else if (event.rawData is Map) {
        map = Map<String, dynamic>.from(event.rawData as Map);
      }
    } catch (_) {
      return;
    }
    if (map == null) return;

    if (_searchActive) {
      return;
    }

    final convId = map['conversation_id']?.toString();
    if (convId == null || convId.isEmpty) return;

    await ConversationsInboxCache.ensureReady();

    if (_conversations.isEmpty) {
      final cached = await ConversationsInboxCache.readList();
      if (cached.isNotEmpty) {
        _conversations.addAll(cached);
      }
    }

    if (_conversations.isEmpty) {
      add(FetchConversationsEvent());
      return;
    }

    final idx = _conversations.indexWhere((c) => c.id == convId);
    if (idx == -1) {
      add(FetchConversationsEvent());
      return;
    }

    final cur = _conversations[idx];
    final createdRaw = map['created_at'];
    final lastTime = createdRaw is String
        ? (DateTime.tryParse(createdRaw) ?? DateTime.now())
        : DateTime.now();
    final type = (map['type'] ?? 'text').toString();
    final content = map['content'] as String?;
    final rawMedia = map['media_type'];
    String? mediaType;
    if (rawMedia is String && rawMedia.isNotEmpty) {
      mediaType = rawMedia.toUpperCase();
    }
    final me = SessionController.instance.userId ?? '';
    final senderMap = map['sender'];
    final senderId = senderMap is Map ? senderMap['id']?.toString() : null;
    final fromOther = senderId != null && senderId.isNotEmpty && senderId != me;

    final next = cur.copyWithModel(
      lastMessageType: type,
      lastMessageContent: content,
      lastMessageMediaType: mediaType,
      lastMessageTime: lastTime,
      updatedAt: lastTime,
      unreadCount: fromOther ? cur.unreadCount + 1 : cur.unreadCount,
    );
    _conversations[idx] = next;
    _sortConversations();
    await ConversationsInboxCache.writeList(_conversations);

    if (state is! ConversationsError) {
      _emitLoaded(emit);
    }
  }

  Future<void> _onFetchConversations(
    FetchConversationsEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    await ConversationsInboxCache.ensureReady();

    if (_conversations.isEmpty) {
      final cached = await ConversationsInboxCache.readList();
      if (cached.isNotEmpty) {
        _conversations.addAll(cached);
        _emitLoaded(emit);
      }
    }

    final hadLoadedData = state is ConversationsLoaded;
    if (!hadLoadedData && _conversations.isEmpty) {
      emit(ConversationsLoading());
    }

    try {
      final bool fullSync = event.forceFullSync || _conversations.isEmpty;
      final DateTime? since = fullSync ? null : _maxUpdatedAt();

      // Chargement plein sans pull-to-refresh : évite d’afficher un Loaded obsolète pendant le fetch.
      if (fullSync && !event.forceFullSync) {
        emit(ConversationsLoading());
      }

      final raw = await fetchConversationsUseCase(
        since: since,
        forceFullSync: fullSync,
      );
      final incoming = raw.map((e) => e as ConversationModel).toList();

      if (event.forceFullSync) {
        // Pull-to-refresh : liste 100 % serveur, aucune fusion avec l’ancien cache mémoire.
        final fresh = List<ConversationModel>.from(incoming);
        _conversations
          ..clear()
          ..addAll(fresh);
        _sortConversations();
        try {
          final fetched = await fetchChatContactsUseCase();
          _allContacts = List<UserSearchResultItem>.from(fetched);
        } catch (_) {
          // Conserver la liste précédente en cas d’échec réseau.
        }
        _emitLoaded(emit, isSearchLoading: false);
        unawaited(ConversationsInboxCache.writeList(List<ConversationModel>.from(_conversations)));
        return;
      }

      if (fullSync) {
        _conversations
          ..clear()
          ..addAll(List<ConversationModel>.from(incoming));
      } else {
        final byId = {for (final c in _conversations) c.id: c};
        for (final u in incoming) {
          byId[u.id] = u;
        }
        _conversations
          ..clear()
          ..addAll(byId.values);
      }
      _sortConversations();
      await ConversationsInboxCache.writeList(_conversations);
      try {
        final fetched = await fetchChatContactsUseCase();
        _allContacts = List<UserSearchResultItem>.from(fetched);
      } catch (_) {
        // Conserver la liste précédente en cas d’échec réseau.
      }
      _emitLoaded(emit, isSearchLoading: false);
    } catch (error) {
      if (hadLoadedData || _conversations.isNotEmpty) {
        _emitLoaded(emit, isSearchLoading: false);
      } else {
        emit(ConversationsError('Erreur de chargement des conversations'));
      }
    }
  }

  Future<void> _onSearchConversations(
    SearchConversationsEvent event,
    Emitter<ConversationsState> emit,
  ) async {
    final q = event.query.trim();
    if (q.isEmpty) {
      _userSearchResults = null;
      _searchActive = false;
      add(FetchConversationsEvent(forceFullSync: true));
      return;
    }

    if (state is ConversationsLoaded) {
      _emitLoaded(emit, isSearchLoading: true);
    }

    try {
      final results = await searchConversationsUseCase(q);
      _userSearchResults = List<UserSearchResultItem>.from(results);
      _searchActive = true;
    } catch (_) {
      _emitLoaded(emit, isSearchLoading: false);
      return;
    }
    _emitLoaded(emit, isSearchLoading: false);
  }
}
