import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/sent_read_receipt_ui.dart';

/// Logique d’accusé « Vu » sous les bulles **envoyées uniquement** (ne pas appeler pour les
/// messages reçus). Une seule ancre avatar (`message.id == partnerLastSeenMessageId`), le reste
/// en traînée ou coche distribué — l’ancre reste sur ce message tant que le repère ne change pas.
SentReadReceiptUi resolveSentReadReceiptForOutgoingMessage({
  required MessageEntity msg,
  required String? partnerLastSeenMessageId,
}) {
  if (msg.isSaved == null) return SentReadReceiptUi.sending;
  if (msg.isSaved == 0) return SentReadReceiptUi.sendFailed;

  final partner = partnerLastSeenMessageId?.trim();
  final mid = msg.id.trim();
  if (partner != null && partner.isNotEmpty && mid.isNotEmpty) {
    if (mid == partner) {
      return SentReadReceiptUi.readRecipientAvatar;
    }
    final midN = int.tryParse(mid);
    final partnerN = int.tryParse(partner);
    if (midN != null && partnerN != null && midN < partnerN) {
      return SentReadReceiptUi.readTrailShrink;
    }
  }

  if (msg.isRead == 1) return SentReadReceiptUi.none;
  if (msg.isRead == 0) return SentReadReceiptUi.deliveredCheck;
  return SentReadReceiptUi.none;
}

/// `true` uniquement pour le message dont l’id est le repère « dernier lu par le partenaire ».
bool isPartnerReadAvatarAnchor(
  MessageEntity message,
  String? partnerLastSeenMessageId,
) {
  final p = partnerLastSeenMessageId?.trim() ?? '';
  final m = message.id.trim();
  return p.isNotEmpty && m.isNotEmpty && m == p;
}
