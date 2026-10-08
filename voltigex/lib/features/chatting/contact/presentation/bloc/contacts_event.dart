import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';

abstract class ContactsEvent {}

class FetchContactsEvent extends ContactsEvent{}

class CheckOrCreateConversationEvent extends ContactsEvent{
  final String contactId;
  final ContactEntity contact;

  CheckOrCreateConversationEvent(this.contactId, this.contact);
}

class AddContactEvent extends ContactsEvent{
  final String email;

  AddContactEvent(this.email);
}

class LoadRecentContactsEvent extends ContactsEvent{}
