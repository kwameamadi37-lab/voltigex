import 'package:voltigex/features/chatting/chat/domain/entiies/message_entity.dart';

/// Utilitaires pour la synchro incrémentale (`after_id`, `updated_after`).
class ChatDeltaSync {
  ChatDeltaSync._();

  /// Dernière date de mise à jour connue en cache (max `updated_at` / `created_at`), pour l’API.
  static String? newestUpdatedAtIso(Iterable<MessageEntity> messages) {
    DateTime? max;
    for (final m in messages) {
      final raw = m.updatedAt.isNotEmpty ? m.updatedAt : m.createdAt;
      if (raw.isEmpty) continue;
      final dt = DateTime.tryParse(raw);
      if (dt == null) continue;
      if (max == null || dt.isAfter(max)) {
        max = dt;
      }
    }
    return max?.toUtc().toIso8601String();
  }

  /// Plus grand `id` serveur numérique présent dans la liste (ignore brouillons sans id).
  static String? newestNumericServerMessageId(Iterable<MessageEntity> messages) {
    int? maxId;
    for (final m in messages) {
      if (m.id.isEmpty) continue;
      final v = int.tryParse(m.id);
      if (v != null && (maxId == null || v > maxId)) {
        maxId = v;
      }
    }
    return maxId?.toString();
  }

  /// Plus petit `id` serveur numérique (pagination « avant » ce message).
  static String? oldestNumericServerMessageId(Iterable<MessageEntity> messages) {
    int? minId;
    for (final m in messages) {
      if (m.id.isEmpty) continue;
      final v = int.tryParse(m.id);
      if (v != null && (minId == null || v < minId)) {
        minId = v;
      }
    }
    return minId?.toString();
  }
}
