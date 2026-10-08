import 'package:voltigex/features/chatting/chat/domain/entiies/chat_message.dart';
import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

/// Écart maximal entre deux messages consécutifs du même auteur pour rester dans le même bloc visuel.
/// Aligné sur [kMessengerShowTimestampGapSeconds] (cohérence bulles / timestamps).
const Duration kChatTightGroupMaxGap =
    Duration(seconds: kMessengerShowTimestampGapSeconds);

/// [nextChronological] : message suivant dans l’ordre chronologique (plus récent), ou `null` si [current] est le dernier.
///
/// Afficher l’heure si le suivant est absent, d’un autre auteur, ou assez loin dans le temps ;
/// sinon le suivant porte l’info temporelle pour le groupe.
bool chatMessageShowTimestamp(
  MessageEntity current,
  MessageEntity? nextChronological,
) {
  final next = nextChronological;
  if (next == null) return true;
  if (next.senderId != current.senderId) return true;
  final t0 = DateTime.tryParse(current.createdAt);
  final t1 = DateTime.tryParse(next.createdAt);
  if (t0 == null || t1 == null) return true;
  if (t1.difference(t0) >= kChatTightGroupMaxGap) return true;
  return false;
}
