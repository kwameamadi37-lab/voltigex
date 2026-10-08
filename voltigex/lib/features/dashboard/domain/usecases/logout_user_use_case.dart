import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:voltigex/features/auth/domain/usecases/logout_use_case.dart';
import 'package:voltigex/features/chatting/conversation/data/local/conversations_inbox_cache.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_conversation_storage.dart';
import 'package:voltigex/core/network/socket_service.dart';

/// Orchestration déconnexion (équivalent métier à [AuthBloc._onLogout]) pour le module Profil.
class LogoutUserUseCase {
  LogoutUserUseCase(this._logoutUseCase);

  final LogoutUseCase _logoutUseCase;

  Future<void> call() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _logoutUseCase.call(fcmToken);
        await FirebaseMessaging.instance.deleteToken();
      }
    } finally {
      try {
        await SocketService.instance.disconnect();
        await ConversationsInboxCache.instance.clear();
        await SupportConversationStorage.clear();
      } catch (_) {}
    }
  }
}
