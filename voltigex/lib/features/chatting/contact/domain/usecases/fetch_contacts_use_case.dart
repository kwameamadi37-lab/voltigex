
import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';
import 'package:voltigex/features/chatting/contact/domain/repositories/contacts_repository.dart';

class FetchContactsUseCase {
  final ContactsRepository contactsRepository;

  FetchContactsUseCase({required this.contactsRepository});

  Future<List<ContactEntity>> call() async {
    return contactsRepository.fetchContacts();
  }
}