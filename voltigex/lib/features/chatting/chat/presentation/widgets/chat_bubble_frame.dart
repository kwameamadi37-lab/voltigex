import 'package:flutter/material.dart';

/// Cadre commun : alignement fixe dès le premier layout + largeur max pour éviter l’étirement plein écran.
///
/// Les coins arrondis de la bulle ne sont **pas** définis ici : le parent applique [BorderRadius] sur le
/// contenu (texte / média) ; la politique d’emboîtement (4 px / 20 px) est calculée dans
/// `buildChatListItems` (`chat_list_layout.dart`).
class ChatBubbleFrame extends StatelessWidget {
  final bool isMe;
  final Widget child;

  const ChatBubbleFrame({
    super.key,
    required this.isMe,
    required this.child,
  });

  static double maxBubbleWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth(context)),
        child: child,
      ),
    );
  }
}
