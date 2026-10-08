import 'package:flutter/material.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/core/widgets/custom_user_avatar.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/sent_read_receipt_ui.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Icône d’échec d’envoi : à utiliser **uniquement** dans [ChatMessengerReadReceiptSlot]
/// ([SentReadReceiptUi.sendFailed]), sous la bulle à la place de la coche.
class ChatSendFailureIcon extends StatelessWidget {
  const ChatSendFailureIcon({super.key});

  static const double size = 18;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error_sharp,
      color: Colors.red,
      size: size,
    );
  }
}

/// Pastille de statut d’envoi / lecture façon Messenger (photo sur le dernier lu).
///
/// L’avatar [readRecipientAvatar] ne s’affiche que si [messageId] == [effectivePartnerLastSeenMessageId]
/// (l’appelant doit fournir l’id effectif, y compris secours liste — construit dans `chat_list_layout`.)
class ChatMessengerReadReceiptSlot extends StatelessWidget {
  const ChatMessengerReadReceiptSlot({
    super.key,
    required this.ui,
    this.profilePhotoUrl,
    this.participantRole,
    required this.switchKey,
    this.messageId,
    this.effectivePartnerLastSeenMessageId,
    /// Même tag sur l’ancre « lu » pour un [Hero] entre deux bulles (évite le saut visuel).
    this.readReceiptHeroTag,
    this.messageIsRead,
    this.onRetrySendFailed,
    this.isRetryingSend = false,
  });

  final SentReadReceiptUi ui;
  final String? profilePhotoUrl;
  final String? participantRole;
  /// [ValueKey] pour [AnimatedSwitcher] (ex. `${message.id}_${ui.name}`).
  final String switchKey;
  /// Id du message courant.
  final String? messageId;
  /// Repère « dernier message vu par le partenaire » : avatar **uniquement** si égal à [messageId].
  final String? effectivePartnerLastSeenMessageId;
  final String? readReceiptHeroTag;
  /// `1` = message déjà lu par le partenaire : slot vide sauf [readRecipientAvatar] si [messageId] == [effectivePartnerLastSeenMessageId].
  final int? messageIsRead;
  /// Tap sur l’icône d’échec : renvoi via [RetrySendMessageEvent] (chat).
  final VoidCallback? onRetrySendFailed;
  /// Affiche un loader à la place de l’icône rouge pendant un renvoi.
  final bool isRetryingSend;

  static const double _slot = 18;

  @override
  Widget build(BuildContext context) {
    if (ui == SentReadReceiptUi.readTrailShrink) {
      return const SizedBox.shrink();
    }
    if (ui == SentReadReceiptUi.sendFailed) {
      final showRetryLoader = isRetryingSend;
      return SizedBox(
        width: 22,
        height: 22,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<String>('${switchKey}_retry_$showRetryLoader'),
            child: Align(
              alignment: Alignment.center,
              child: showRetryLoader
                  ? loader(
                      compact: true,
                      color: Colors.grey.shade700,
                      size: 14,
                    )
                  : onRetrySendFailed != null
                      ? Tooltip(
                          message: AppLocalizations.of(context)!.chatSendRetryTooltip,
                          child: GestureDetector(
                            onTap: onRetrySendFailed,
                            behavior: HitTestBehavior.opaque,
                            child: const ChatSendFailureIcon(),
                          ),
                        )
                      : const ChatSendFailureIcon(),
            ),
          ),
        ),
      );
    }
    // Lu par le partenaire : aucune coche grise ni autre pastille — seul l’avatar sur le message « dernier vu ».
    if (messageIsRead == 1) {
      if (ui != SentReadReceiptUi.readRecipientAvatar) {
        return const SizedBox.shrink();
      }
      final p = effectivePartnerLastSeenMessageId?.trim();
      final m = messageId?.trim() ?? '';
      if (p == null || p.isEmpty || m != p) {
        return const SizedBox.shrink();
      }
    } else if (ui == SentReadReceiptUi.readRecipientAvatar) {
      final p = effectivePartnerLastSeenMessageId?.trim();
      final m = messageId?.trim() ?? '';
      if (p == null || p.isEmpty || m != p) {
        return const SizedBox.shrink();
      }
    }
    return SizedBox(
      width: _slot,
      height: _slot,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.4, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(switchKey),
          child: Align(
            alignment: Alignment.center,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (messageIsRead == 1 && ui != SentReadReceiptUi.readRecipientAvatar) {
      return const SizedBox.shrink();
    }
    switch (ui) {
      case SentReadReceiptUi.readRecipientAvatar:
        final avatar = CustomUserAvatar(
          profilePhotoUrl: profilePhotoUrl,
          role: participantRole,
          radius: 7,
        );
        final tag = readReceiptHeroTag?.trim();
        if (tag != null && tag.isNotEmpty) {
          return Hero(
            tag: tag,
            transitionOnUserGestures: true,
            child: avatar,
          );
        }
        return avatar;
      case SentReadReceiptUi.deliveredCheck:
        return Icon(
          Icons.done_rounded,
          size: 15,
          color: Colors.grey.shade600,
        );
      case SentReadReceiptUi.sending:
        return loader(
          compact: true,
          color: Colors.grey.shade700,
          size: 14,
        );
      case SentReadReceiptUi.sendFailed:
        return const ChatSendFailureIcon();
      case SentReadReceiptUi.none:
        return const SizedBox(width: 14, height: 14);
      case SentReadReceiptUi.readTrailShrink:
        return const SizedBox.shrink();
    }
  }
}
