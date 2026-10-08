import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/chat_message.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/sent_read_receipt_ui.dart';

/// Marge **top** sur la bulle uniquement : **identique** pour TEXTE et MÉDIA (image/PDF) dans le même groupe ([compactTop] → 2 px).
const double kChatBubbleTightTopMargin = 2.0;
const double kChatBubbleLooseTopMargin = 8.0;

/// Une ligne d’affichage : soit un badge de date, soit un message avec métadonnées de groupe (style Telegram).
@immutable
class ChatListItem {
  final String? dateLabel;
  final MessageEntity? message;
  final bool isSent;
  final bool isBot;
  final bool showAvatarAndName;
  /// Message chronologiquement après [message] (plus récent), même conversation triée.
  final MessageEntity? nextMessageChronological;
  final bool compactTop;
  final BorderRadius bubbleRadius;
  /// Statut d’affichage sous bulle « moi » (Messenger).
  final SentReadReceiptUi sentReadReceipt;
  /// Heure sous la bulle : [messengerShowTimestampForNewerVsOlder] sur l’ordre d’affichage inversé.
  final bool showTimestamp;
  /// Marge au-dessus de la bulle seule ([kChatBubbleTightTopMargin] si groupe serré, sinon [kChatBubbleLooseTopMargin]).
  final double bubbleTopMargin;

  const ChatListItem.date(this.dateLabel)
      : message = null,
        isSent = false,
        isBot = false,
        showAvatarAndName = false,
        nextMessageChronological = null,
        compactTop = false,
        bubbleRadius = BorderRadius.zero,
        sentReadReceipt = SentReadReceiptUi.none,
        showTimestamp = false,
        bubbleTopMargin = 0;

  const ChatListItem.message({
    required this.message,
    required this.isSent,
    required this.isBot,
    required this.showAvatarAndName,
    required this.nextMessageChronological,
    required this.compactTop,
    required this.bubbleRadius,
    required this.sentReadReceipt,
    required this.showTimestamp,
    required this.bubbleTopMargin,
  }) : dateLabel = null;

  bool get isDate => dateLabel != null;
}

String formatChatDateLabel(
  DateTime date, {
  required String localeTag,
  required String todayLabel,
  required String yesterdayLabel,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(date.year, date.month, date.day);
  final diffDays = msgDay.difference(today).inDays;

  if (diffDays == 0) return todayLabel;
  if (diffDays == -1) return yesterdayLabel;
  return DateFormat.yMMMMd(localeTag).format(date);
}

const double _kBubbleRadiusMain = 20.0;
const double _kBubbleRadiusTightCorner = 4.0;

/// Bulle envoyée (droite) : [compactTop] → topRight serré ; [sameNext] (suivant même expéditeur, < 120 s) → bottomRight serré.
BorderRadius _bubbleRadiusSent({
  required bool compactTop,
  required bool sameNext,
}) {
  final tr = compactTop ? _kBubbleRadiusTightCorner : _kBubbleRadiusMain;
  final br = sameNext ? _kBubbleRadiusTightCorner : _kBubbleRadiusMain;
  return BorderRadius.only(
    topLeft: const Radius.circular(_kBubbleRadiusMain),
    topRight: Radius.circular(tr),
    bottomLeft: const Radius.circular(_kBubbleRadiusMain),
    bottomRight: Radius.circular(br),
  );
}

/// Bulle reçue (gauche) : logique miroir — [compactTop] → topLeft serré ; [sameNext] → bottomLeft serré.
BorderRadius _bubbleRadiusReceived({
  required bool compactTop,
  required bool sameNext,
}) {
  final tl = compactTop ? _kBubbleRadiusTightCorner : _kBubbleRadiusMain;
  final bl = sameNext ? _kBubbleRadiusTightCorner : _kBubbleRadiusMain;
  return BorderRadius.only(
    topLeft: Radius.circular(tl),
    topRight: const Radius.circular(_kBubbleRadiusMain),
    bottomLeft: Radius.circular(bl),
    bottomRight: const Radius.circular(_kBubbleRadiusMain),
  );
}

/// Même expéditeur et écart **strictement inférieur** à [kMessengerShowTimestampGapSeconds] (120 s) : rafale serrée.
bool _isTightVisualGroupPair(MessageEntity older, MessageEntity newer) {
  if (!chatSenderIdsMatch(older.senderId, newer.senderId)) return false;
  final tOld = DateTime.tryParse(older.createdAt)?.toUtc();
  final tNew = DateTime.tryParse(newer.createdAt)?.toUtc();
  if (tOld == null || tNew == null) return false;
  return tNew.difference(tOld).inSeconds < kMessengerShowTimestampGapSeconds;
}

/// [messages] : ordre chronologique croissant (plus ancien en premier).
List<MessageEntity> sortMessagesChronological(List<MessageEntity> messages) {
  final copy = List<MessageEntity>.from(messages);
  copy.sort(compareChatMessagesChronological);
  return copy;
}

MessageEntity? _previousNewerMessageInDisplayOrder(
  List<ChatListItem> displayNewestFirst,
  int fromIndex,
) {
  for (var j = fromIndex - 1; j >= 0; j--) {
    final x = displayNewestFirst[j];
    if (!x.isDate && x.message != null) return x.message;
  }
  return null;
}

List<ChatListItem> _applyMessengerShowTimestamps(
  List<ChatListItem> displayNewestFirst,
) {
  final out = <ChatListItem>[];
  for (var i = 0; i < displayNewestFirst.length; i++) {
    final it = displayNewestFirst[i];
    if (it.isDate) {
      out.add(it);
      continue;
    }
    // `displayNewestFirst` = ordre écran (du bas vers le haut) : index 0 = plus récent.
    // Messenger : on affiche l’heure uniquement sur le dernier message visuel du bloc
    // (le plus proche du bas de l’écran pour ce bloc).
    final previousNewer =
        _previousNewerMessageInDisplayOrder(displayNewestFirst, i);
    final isTightWithNewer =
        previousNewer != null && _isTightVisualGroupPair(it.message!, previousNewer);
    // Toujours afficher l’heure sur le message le plus récent du fil (bas de l’écran).
    final isNewestInThread = i == 0;
    final showTs = isNewestInThread || !isTightWithNewer;
    out.add(
      ChatListItem.message(
        message: it.message!,
        isSent: it.isSent,
        isBot: it.isBot,
        showAvatarAndName: it.showAvatarAndName,
        nextMessageChronological: it.nextMessageChronological,
        compactTop: it.compactTop,
        bubbleRadius: it.bubbleRadius,
        sentReadReceipt: it.sentReadReceipt,
        showTimestamp: showTs,
        bubbleTopMargin: it.bubbleTopMargin,
      ),
    );
  }
  return out;
}

/// Dernier message (chronologique) envoyé par [userId] avec [isRead] == 1, si la logique globale n’a pas d’id.
String? _fallbackLastReadSentMessageIdChronological(
  List<MessageEntity> sortedAscending,
  String userId,
  String botId,
) {
  for (var i = sortedAscending.length - 1; i >= 0; i--) {
    final m = sortedAscending[i];
    if (m.senderId != userId || m.senderId == botId) continue;
    if (m.isRead != 1) continue;
    final id = m.id.trim();
    if (id.isEmpty) continue;
    return id;
  }
  return null;
}

/// Résultat de [buildChatListItems] : liste affichée + id « dernier vu » effectif (secours si l’API n’a pas encore l’id global).
typedef ChatListBuildResult = ({
  List<ChatListItem> items,
  String? effectivePartnerLastSeenMessageId,
});

/// Construit les items pour [ListView.builder] avec [reverse: true] (plus récent en bas).
ChatListBuildResult buildChatListItems({
  required List<MessageEntity> messages,
  required String userId,
  required String botId,
  required String localeTag,
  required String todayLabel,
  required String yesterdayLabel,
  String? partnerLastSeenMessageId,
}) {
  if (messages.isEmpty) {
    return (items: <ChatListItem>[], effectivePartnerLastSeenMessageId: null);
  }

  final sorted = sortMessagesChronological(messages);

  // Repère API / socket : priorité absolue — l’avatar reste sur ce message même si de nouveaux
  // messages (reçus) arrivent après.
  final trimmedPartner = partnerLastSeenMessageId?.trim();
  String? effectivePartnerSeen =
      (trimmedPartner != null && trimmedPartner.isNotEmpty)
          ? trimmedPartner
          : computeLastReadSentMessageId(
              messages,
              currentUserId: userId,
              botId: botId,
            );
  effectivePartnerSeen = effectivePartnerSeen?.trim();
  if (effectivePartnerSeen == null || effectivePartnerSeen.isEmpty) {
    effectivePartnerSeen =
        _fallbackLastReadSentMessageIdChronological(sorted, userId, botId);
  }
  final chronological = <ChatListItem>[];

  String? lastDayKey;
  MessageEntity? prev;

  for (var i = 0; i < sorted.length; i++) {
    final msg = sorted[i];
    final local = DateTime.tryParse(msg.createdAt)?.toLocal() ?? DateTime.now();
    final dayKey = '${local.year}-${local.month}-${local.day}';
    if (dayKey != lastDayKey) {
      lastDayKey = dayKey;
      chronological.add(
        ChatListItem.date(
          formatChatDateLabel(
            local,
            localeTag: localeTag,
            todayLabel: todayLabel,
            yesterdayLabel: yesterdayLabel,
          ),
        ),
      );
    }

    final next = i + 1 < sorted.length ? sorted[i + 1] : null;
    final samePrev = prev != null && _isTightVisualGroupPair(prev, msg);
    final sameNext = next != null && _isTightVisualGroupPair(msg, next);

    final isBot = msg.senderId == botId;
    final isSent = messageIsFromCurrentUser(msg, userId, botId: botId);
    final sentReadReceipt = isSent
        ? resolveSentReadReceiptForOutgoingMessage(
            msg: msg,
            partnerLastSeenMessageId: effectivePartnerSeen,
          )
        : SentReadReceiptUi.none;

    /// Y a-t-il un message plus récent du même expéditeur dans la fenêtre 120 s ([sameNext]) ?
    final isLastInSenderGroup = !sameNext;

    final showAvatarName = !isSent && !isBot && !samePrev;
    final compactTop = samePrev;
    final bubbleTopMargin = compactTop
        ? kChatBubbleTightTopMargin
        : kChatBubbleLooseTopMargin;

    BorderRadius radius;
    if (isBot) {
      radius = isLastInSenderGroup
          ? BorderRadius.circular(16)
          : BorderRadius.circular(9);
    } else if (isSent) {
      radius = _bubbleRadiusSent(
        compactTop: compactTop,
        sameNext: sameNext,
      );
    } else {
      radius = _bubbleRadiusReceived(
        compactTop: compactTop,
        sameNext: sameNext,
      );
    }

    chronological.add(
      ChatListItem.message(
        message: msg,
        isSent: isSent,
        isBot: isBot,
        showAvatarAndName: showAvatarName,
        nextMessageChronological: next,
        compactTop: compactTop,
        bubbleRadius: radius,
        sentReadReceipt: sentReadReceipt,
        showTimestamp: false,
        bubbleTopMargin: bubbleTopMargin,
      ),
    );
    prev = msg;
  }

  return (
    items: _applyMessengerShowTimestamps(chronological.reversed.toList()),
    effectivePartnerLastSeenMessageId: effectivePartnerSeen,
  );
}
