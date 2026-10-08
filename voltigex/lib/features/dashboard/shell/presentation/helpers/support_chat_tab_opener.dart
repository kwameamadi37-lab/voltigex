import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_cubit.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_conversation_storage.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// Résout la conversation support (API) puis bascule vers l’onglet Chat.
Future<void> openSupportChatInMainTab(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  if (SessionController.instance.role == 'admin') {
    if (!context.mounted) return;
    TopSnackBar.show(
      context,
      'Le raccourci « Chat » support est réservé aux comptes clients. '
      'Connectez-vous avec un compte utilisateur ou ouvrez Messages depuis le menu.',
      type: TopSnackBarType.error,
      title: 'Support',
      durationSeconds: 6,
    );
    return;
  }

  final rootNav = Navigator.of(context, rootNavigator: true);

  try {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => loader(),
    );

    final useCase = sl<CheckOrCreateConversationUseCase>();
    final result = await useCase.call(contactId: Constants.supportAdminId);
    final conversationId = result.toString().trim();
    if (conversationId.isEmpty) {
      throw Exception('ID de conversation vide');
    }

    await SupportConversationStorage.saveId(conversationId);

    rootNav.pop();
    if (!context.mounted) return;

    context.read<MainNavigationCubit>().openChatTab(
      conversationId: conversationId,
      mate: l10n.conversationsTitleSupport,
      profilePhotoUrl: null,
      participantRole: 'admin',
    );
  } catch (e) {
    if (rootNav.canPop()) {
      rootNav.pop();
    }
    if (!context.mounted) return;

    var message = 'Serveur indisponible';
    if (e is DioException) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (code == 403) {
        message = 'Accès refusé';
      } else if (code == 401) {
        message = 'Session expirée, reconnectez-vous.';
      }
    }

    TopSnackBar.show(
      context,
      message,
      type: TopSnackBarType.error,
      title: 'Erreur',
    );
  }
}
