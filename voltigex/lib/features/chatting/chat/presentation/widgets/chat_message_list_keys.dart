import 'package:flutter/material.dart';
import 'package:voltigex/features/chatting/chat/presentation/widgets/chat_list_layout.dart';

/// Clés stables pour le recyclage ListView (id serveur ou client_id pour les pending).
Key chatListItemStableKey(ChatListItem item, int index) {
  if (item.isDate) {
    return ValueKey<String>('date:$index:${item.dateLabel}');
  }
  final m = item.message!;
  if (m.id.isNotEmpty) {
    return ValueKey<String>('msg:${m.id}');
  }
  if (m.clientId.isNotEmpty) {
    return ValueKey<String>('client:${m.clientId}');
  }
  return ValueKey<String>('fallback:$index:${m.createdAt}:${m.senderId}');
}
