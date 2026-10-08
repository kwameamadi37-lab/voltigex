import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';

abstract class ContactsRepository {
  Future<List<ContactEntity>> fetchContacts();
  Future<void> addContact({required String email});
  Future<List<ContactEntity>> getRecentContacts();

}