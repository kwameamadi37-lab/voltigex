import 'package:flutter/foundation.dart';

/// Métadonnées affichées dans l’onglet Chat (conversation unique à la fois).
@immutable
class MainChatTabTarget {
  final String conversationId;
  final String mate;
  final String? profilePhotoUrl;
  final String? participantRole;

  const MainChatTabTarget({
    required this.conversationId,
    required this.mate,
    this.profilePhotoUrl,
    this.participantRole,
  });

  static const empty = MainChatTabTarget(
    conversationId: '',
    mate: '',
    profilePhotoUrl: null,
    participantRole: null,
  );

  bool get isOpen => conversationId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is MainChatTabTarget &&
        other.conversationId == conversationId &&
        other.mate == mate &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.participantRole == participantRole;
  }

  @override
  int get hashCode =>
      Object.hash(conversationId, mate, profilePhotoUrl, participantRole);
}

@immutable
class MainNavigationState {
  /// Index dans [MainScreen] IndexedStack.
  final int currentIndex;

  /// Conversation active dans l’onglet Chat.
  final MainChatTabTarget chatTarget;

  const MainNavigationState({
    this.currentIndex = 0,
    this.chatTarget = MainChatTabTarget.empty,
  });

  static const int tabHome = 0;
  static const int tabCards = 1;
  static const int tabProfil = 2;
  static const int tabChat = 3;

  MainNavigationState copyWith({
    int? currentIndex,
    MainChatTabTarget? chatTarget,
  }) {
    return MainNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      chatTarget: chatTarget ?? this.chatTarget,
    );
  }
}
