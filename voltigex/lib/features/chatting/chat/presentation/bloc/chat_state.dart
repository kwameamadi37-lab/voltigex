import 'package:voltigex/features/chatting/chat/domain/entiies/chat_message.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/daily_question_entity.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

abstract class ChatState {
  /// Dernier message envoyé par l’utilisateur courant et lu par le correspondant ([ChatLoadedState] seulement).
  String? get lastReadMessageId => null;
}

class ChatLoadingState extends ChatState{}

class ChatLoadedState extends ChatState {
  final List<MessageEntity> messages;
  final String currentUserId;
  /// Synchro delta en cours (barre discrète en tête du chat).
  final bool deltaSyncInProgress;
  /// Dernier fetch API (delta ou complet) a échoué alors qu’un cache était affiché.
  final bool syncFailed;
  /// Chargement d’une page « avant » (pagination infinie).
  final bool loadingOlderMessages;
  /// Repère serveur : dernier message **vous** que le partenaire a lu ([GET …/conversations/{id}]).
  final String? partnerLastSeenMessageId;
  /// `clientId` des messages pour lesquels un renvoi est en cours (icône loader à la place de l’erreur).
  final Set<String> retryingSendClientIds;
  /// Partenaire en train d’écrire (signal socket live).
  final bool isPartnerTyping;

  ChatLoadedState(
    this.messages, {
    required this.currentUserId,
    this.deltaSyncInProgress = false,
    this.syncFailed = false,
    this.loadingOlderMessages = false,
    this.partnerLastSeenMessageId,
    this.retryingSendClientIds = const <String>{},
    this.isPartnerTyping = false,
  });

  /// Copie pour une **nouvelle** instance d’état (ex. après socket). Si [replacePartnerLastSeenMessageId]
  /// est vrai, [partnerLastSeenMessageId] remplace la valeur y compris lorsqu’elle est `null`.
  ChatLoadedState copyWith({
    List<MessageEntity>? messages,
    String? currentUserId,
    bool? deltaSyncInProgress,
    bool? syncFailed,
    bool? loadingOlderMessages,
    String? partnerLastSeenMessageId,
    bool replacePartnerLastSeenMessageId = false,
    Set<String>? retryingSendClientIds,
    bool? isPartnerTyping,
  }) {
    return ChatLoadedState(
      messages ?? List<MessageEntity>.from(this.messages),
      currentUserId: currentUserId ?? this.currentUserId,
      deltaSyncInProgress: deltaSyncInProgress ?? this.deltaSyncInProgress,
      syncFailed: syncFailed ?? this.syncFailed,
      loadingOlderMessages: loadingOlderMessages ?? this.loadingOlderMessages,
      partnerLastSeenMessageId: replacePartnerLastSeenMessageId
          ? partnerLastSeenMessageId
          : (partnerLastSeenMessageId ?? this.partnerLastSeenMessageId),
      retryingSendClientIds:
          retryingSendClientIds ?? Set<String>.from(this.retryingSendClientIds),
      isPartnerTyping: isPartnerTyping ?? this.isPartnerTyping,
    );
  }

  @override
  String? get lastReadMessageId => computeLastReadSentMessageId(
        messages,
        currentUserId: currentUserId,
        partnerLastSeenMessageId: partnerLastSeenMessageId,
      );
}

class ChatErrorState extends ChatState{
  final String message;
  /// Erreur réseau (Dio), Pusher ([PlatformException]), etc.
  final Object? error;

  ChatErrorState(this.message, [this.error]);
}

class ChatDailyQuestionLoadedState extends ChatState{
  final DailyQuestionEntity dailyQuestion;
  ChatDailyQuestionLoadedState(this.dailyQuestion);
}