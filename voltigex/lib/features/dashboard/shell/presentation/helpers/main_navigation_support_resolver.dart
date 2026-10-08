import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/locale/app_locale_storage.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/features/chatting/conversation/data/local/conversations_inbox_cache.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_conversation_storage.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Résout l’UUID de la conversation support : stockage sécurisé → cache inbox → API.
class MainNavigationSupportResolver {
  MainNavigationSupportResolver._();

  static Future<String?> resolveSupportConversationId() async {
    final stored = await SupportConversationStorage.readId();
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }

    await ConversationsInboxCache.ensureReady();
    final inbox = await ConversationsInboxCache.readList();
    final locale = await AppLocaleStorage.readInitial();
    final supportName = lookupAppLocalizations(locale).conversationsTitleSupport.trim().toLowerCase();
    for (final c in inbox) {
      if (c.id.trim().isEmpty) continue;
      final role = (c.participantRole ?? '').trim().toLowerCase();
      if (role == 'admin' || c.participantName.trim().toLowerCase() == supportName) {
        await SupportConversationStorage.saveId(c.id);
        return c.id.trim();
      }
    }

    if (SessionController.instance.isAdminSupport) {
      return null;
    }

    try {
      final useCase = sl<CheckOrCreateConversationUseCase>();
      final id = (await useCase.call(contactId: Constants.supportAdminId)).trim();
      if (id.isEmpty) return null;
      await SupportConversationStorage.saveId(id);
      return id;
    } catch (_) {
      return null;
    }
  }
}
