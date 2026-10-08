import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/locale/app_locale_storage.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_state.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/main_navigation_support_resolver.dart';
import 'package:voltigex/l10n/app_localizations.dart';

class MainNavigationCubit extends Cubit<MainNavigationState> {
  MainNavigationCubit() : super(const MainNavigationState());

  Future<String> _supportLabel() async {
    final locale = await AppLocaleStorage.readInitial();
    return lookupAppLocalizations(locale).conversationsTitleSupport;
  }

  /// Client connecté : remplit [chatTarget] avec la conversation Support si encore vide.
  Future<void> applyDefaultSupportChatTargetIfNeeded() async {
    final session = SessionController.instance;
    if (session.token == null || session.token!.isEmpty) return;
    if (session.isAdminSupport) return;
    if (state.chatTarget.isOpen) return;

    final id = await MainNavigationSupportResolver.resolveSupportConversationId();
    if (id == null || id.isEmpty) return;

    emit(
      state.copyWith(
        chatTarget: MainChatTabTarget(
          conversationId: id,
          mate: await _supportLabel(),
          profilePhotoUrl: null,
          participantRole: 'admin',
        ),
      ),
    );
  }

  void selectTab(int index) {
    if (index < 0 || index > MainNavigationState.tabChat) return;
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
  }

  /// Ouvre l’onglet Chat sur une conversation (depuis l’accueil, une aide, etc.).
  void openChatTab({
    required String conversationId,
    required String mate,
    String? profilePhotoUrl,
    String? participantRole,
  }) {
    final id = conversationId.trim();
    if (id.isEmpty) return;
    emit(
      state.copyWith(
        currentIndex: MainNavigationState.tabChat,
        chatTarget: MainChatTabTarget(
          conversationId: id,
          mate: mate,
          profilePhotoUrl: profilePhotoUrl,
          participantRole: participantRole,
        ),
      ),
    );
  }
}
