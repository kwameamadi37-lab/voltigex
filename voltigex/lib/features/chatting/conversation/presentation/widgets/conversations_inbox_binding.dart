import 'package:flutter/material.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/chatting/conversation/presentation/conversations_inbox_coordinator.dart';

/// Abonnement global au canal Pusher inbox : met à jour [ConversationsBloc] + Hive même hors liste.
class ConversationsInboxBinding extends StatefulWidget {
  const ConversationsInboxBinding({super.key, required this.child});

  final Widget child;

  @override
  State<ConversationsInboxBinding> createState() => _ConversationsInboxBindingState();
}

class _ConversationsInboxBindingState extends State<ConversationsInboxBinding> {
  String? _subscribedUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = SessionController.instance.userId;
    if (uid == null || uid.isEmpty) {
      if (_subscribedUid != null) {
        _subscribedUid = null;
        WidgetsBinding.instance.addPostFrameCallback((_) => _unsubscribeInbox());
      }
      return;
    }
    if (uid != _subscribedUid) {
      _subscribedUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) => _subscribe(uid));
    }
  }

  Future<void> _subscribe(String uid) async {
    if (!mounted) return;
    await SocketService().subscribeUserInbox(
      uid,
      ConversationsInboxCoordinator.onInboxPusherData,
    );
  }

  Future<void> _unsubscribeInbox() async {
    if (!mounted) return;
    await SocketService.instance.unsubscribeUserInbox();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
