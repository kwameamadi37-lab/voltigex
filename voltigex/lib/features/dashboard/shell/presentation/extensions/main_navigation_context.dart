import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_cubit.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_state.dart';

extension MainNavigationContextX on BuildContext {
  MainNavigationCubit get mainNavigation => read<MainNavigationCubit>();

  /// Bascule vers l’onglet Chat et charge la conversation (depuis n’importe quel écran sous [MaterialApp]).
  void openConversationInMainChatTab({
    required String conversationId,
    required String mate,
    String? profilePhotoUrl,
    String? participantRole,
  }) {
    read<MainNavigationCubit>().openChatTab(
      conversationId: conversationId,
      mate: mate,
      profilePhotoUrl: profilePhotoUrl,
      participantRole: participantRole,
    );
  }

  /// Change l’onglet du shell principal (indices : [MainNavigationState.tabHome] … [MainNavigationState.tabChat]).
  void selectMainTab(int index) {
    read<MainNavigationCubit>().selectTab(index);
  }
}
