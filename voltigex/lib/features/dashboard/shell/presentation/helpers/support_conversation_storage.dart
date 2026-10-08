import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// UUID de la conversation « Support » (client), persisté pour l’onglet Chat au démarrage.
class SupportConversationStorage {
  SupportConversationStorage._();

  static const _key = 'support_conversation_id';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveId(String conversationId) async {
    final id = conversationId.trim();
    if (id.isEmpty) return;
    await _storage.write(key: _key, value: id);
  }

  static Future<String?> readId() => _storage.read(key: _key);

  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
