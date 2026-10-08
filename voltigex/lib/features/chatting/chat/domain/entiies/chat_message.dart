import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

/// Alias domaine pour un message de conversation.
typedef ChatMessage = MessageEntity;

/// Compare les ids expéditeur / utilisateur courant (API int vs stockage string).
bool chatSenderIdsMatch(String? a, String? b) {
  final x = (a ?? '').trim();
  final y = (b ?? '').trim();
  if (x.isEmpty || y.isEmpty) return false;
  if (x == y) return true;
  final xn = int.tryParse(x);
  final yn = int.tryParse(y);
  return xn != null && yn != null && xn == yn;
}

bool messageIsFromCurrentUser(
  MessageEntity message,
  String currentUserId, {
  String botId = '00000000-0000-0000-0000-000000000000',
}) {
  if (message.senderId == botId) return false;
  return chatSenderIdsMatch(message.senderId, currentUserId);
}

/// Tri chronologique croissant avec repli sur l’id serveur puis [clientId].
int compareChatMessagesChronological(MessageEntity a, MessageEntity b) {
  final ta = DateTime.tryParse(a.createdAt.trim());
  final tb = DateTime.tryParse(b.createdAt.trim());
  if (ta != null && tb != null) {
    final c = ta.compareTo(tb);
    if (c != 0) return c;
  } else if (ta != null) {
    return 1;
  } else if (tb != null) {
    return -1;
  }

  final idA = int.tryParse(a.id.trim());
  final idB = int.tryParse(b.id.trim());
  if (idA != null && idB != null && idA != idB) {
    return idA.compareTo(idB);
  }
  if (idA != null && idB == null) return -1;
  if (idA == null && idB != null) return 1;

  return a.clientId.compareTo(b.clientId);
}

/// Seuil type Messenger : afficher l’heure sous la bulle si l’écart avec le message
/// immédiatement plus ancien dans l’ordre d’affichage ([ListView] `reverse: true`)
/// dépasse cette durée.
const int kMessengerShowTimestampGapSeconds = 120;

/// [newer] = message à l’index [i], [olderNeighborInDisplay] = premier message réel à [i+1]
/// (liste d’affichage du plus récent au plus ancien).
///
/// Affiche l’heure si l’écart est **≥** [kMessengerShowTimestampGapSeconds] ou si l’expéditeur change
/// (à partir de 120 s le groupe visuel « serré » est rompu côté liste).
bool messengerShowTimestampForNewerVsOlder(
  MessageEntity newer,
  MessageEntity? olderNeighborInDisplay,
) {
  if (olderNeighborInDisplay == null) return true;
  if (newer.senderId != olderNeighborInDisplay.senderId) return true;
  final tN = DateTime.tryParse(newer.createdAt)?.toUtc();
  final tO = DateTime.tryParse(olderNeighborInDisplay.createdAt)?.toUtc();
  if (tN == null || tO == null) return true;
  // Casser le groupe dès que l’écart atteint le seuil (cohérent avec _isTightVisualGroupPair : < 120 s).
  return tN.difference(tO).inSeconds >= kMessengerShowTimestampGapSeconds;
}

/// Id du dernier message **que vous avez envoyé** sur lequel afficher la photo « Vu »
/// (repère renvoyé par l’API : [partnerLastSeenMessageId], ou dérivé des [isRead] locaux).
///
/// Même règle pour admin ou client : on ne regarde que les messages dont l’expéditeur est
/// [currentUserId] et qui sont lus par le partenaire ([isRead] == 1).
String? computeLastReadSentMessageId(
  List<MessageEntity> messages, {
  required String currentUserId,
  String botId = '00000000-0000-0000-0000-000000000000',
  String? partnerLastSeenMessageId,
}) {
  if (currentUserId.isEmpty) return null;

  final target = partnerLastSeenMessageId?.trim();
  if (target != null && target.isNotEmpty) {
    for (final m in messages) {
      if (m.senderId != currentUserId || m.senderId == botId) continue;
      if (m.id != target) continue;
      if (m.isRead == 1) return m.id;
    }

    final targetNum = int.tryParse(target);
    if (targetNum != null && targetNum > 0) {
      MessageEntity? bestBelow;
      var bestN = -1;
      for (final m in messages) {
        if (m.senderId != currentUserId || m.senderId == botId) continue;
        if (m.isRead != 1) continue;
        if (m.id.isEmpty) continue;
        final n = int.tryParse(m.id) ?? -1;
        if (n <= targetNum && n > bestN) {
          bestN = n;
          bestBelow = m;
        }
      }
      if (bestBelow != null) return bestBelow.id;
    }
  }

  // Secours sans id API : dernier « lu » = plus grand id numérique parmi les messages envoyés par moi,
  // puis repli chronologique si les ids ne sont pas des entiers (ex. UUID).
  MessageEntity? bestByNumericId;
  var bestNumeric = -1;

  MessageEntity? bestChrono;
  DateTime? bestChronoAt;
  var bestChronoIdNum = -1;

  for (final m in messages) {
    if (m.senderId != currentUserId || m.senderId == botId) continue;
    if (m.isRead != 1) continue;
    if (m.id.isEmpty) continue;

    final n = int.tryParse(m.id);
    if (n != null && n > bestNumeric) {
      bestNumeric = n;
      bestByNumericId = m;
    }

    DateTime at;
    try {
      at = DateTime.parse(m.createdAt);
    } catch (_) {
      continue;
    }
    final mIdNum = int.tryParse(m.id) ?? -1;
    final replace = bestChrono == null ||
        at.isAfter(bestChronoAt!) ||
        (at == bestChronoAt && mIdNum > bestChronoIdNum);
    if (replace) {
      bestChrono = m;
      bestChronoAt = at;
      bestChronoIdNum = mIdNum;
    }
  }

  if (bestByNumericId != null) return bestByNumericId.id;
  return bestChrono?.id;
}
