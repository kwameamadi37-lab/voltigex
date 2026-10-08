import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';
import 'package:voltigex/features/chatting/conversation/domain/entities/conversation_entity.dart';

abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<ContactEntity> contacts;

  ContactsLoaded(this.contacts);

}

class ContactsError extends ContactsState {
  final String message;

  ContactsError(this.message);

}

class ContactAdded extends ContactsState {}

class ConversationReady extends ContactsState {
  final String conversationId;
  final ContactEntity contact;

  ConversationReady({required this.conversationId, required this.contact});
}

class RecentContactsLoaded extends ContactsState {
  final List<ContactEntity> recentContacts;

  RecentContactsLoaded(this.recentContacts);
}