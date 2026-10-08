/// Indicateur sous bulle « moi » (Messenger) : rien / envoi / coché / photo du correspondant.
///
/// La coche [deliveredCheck] ne concerne **que** les messages non lus côté partenaire (`isRead == 0`) ;
/// le « Vu » est **uniquement** [readRecipientAvatar] (pas de coche sur l’égalité id / partenaire).
enum SentReadReceiptUi {
  /// Pas d’indicateur (ex. message lu mais pas le repère « dernier vu »).
  none,
  /// Distribué, partenaire n’a pas encore lu (`isRead == 0`). Pas lié à l’id « dernier vu ».
  deliveredCheck,
  /// Photo du partenaire : réservé au message dont l’id est exactement le repère « dernier vu » effectif.
  readRecipientAvatar,
  /// Encore en vol (pending).
  sending,
  /// Échec d’envoi (`isSaved == 0`) : icône rouge dans le slot (à la place de la coche), sans avatar.
  sendFailed,
  /// Message envoyé déjà couvert par un id de lecture plus récent : aucun slot (pas de traînée).
  readTrailShrink,
}
