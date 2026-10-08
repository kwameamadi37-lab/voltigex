import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';
import 'package:voltigex/features/chatting/contact/domain/repositories/contacts_repository.dart';

class FetchRecentContactsUseCase {
  final ContactsRepository contactsRepository;

  FetchRecentContactsUseCase({required this.contactsRepository});

  Future<List<ContactEntity>> call() async {
    return await contactsRepository.getRecentContacts();
  }
}