import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/features/chatting/contact/domain/usecases/add_contacts_use_case.dart';
import 'package:voltigex/features/chatting/contact/domain/usecases/fetch_contacts_use_case.dart';
import 'package:voltigex/features/chatting/contact/domain/usecases/fetch_recent_contacts_use_case.dart';
import 'package:voltigex/features/chatting/contact/presentation/bloc/contacts_event.dart';
import 'package:voltigex/features/chatting/contact/presentation/bloc/contacts_state.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/check_or_create_conversation_use_case.dart';


class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FetchContactsUseCase fetchContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final CheckOrCreateConversationUseCase checkOrCreateConversationUseCase;
  final FetchRecentContactsUseCase fetchRecentContactsUseCase;

  ContactsBloc({
    required this.fetchContactsUseCase,
    required this.addContactUseCase,
    required this.checkOrCreateConversationUseCase,
    required this.fetchRecentContactsUseCase
  }) : super(ContactsInitial()) {
    on<FetchContactsEvent>(_onFetchContacts);
    on<CheckOrCreateConversationEvent>(_onCheckOrCreateConversation);
    on<AddContactEvent>(_onAddContact);
    on<LoadRecentContactsEvent>(_onLoadRecentContacts);
  }


  Future<void> _onLoadRecentContacts(LoadRecentContactsEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());

    try{
      final recentContacts = await fetchRecentContactsUseCase();
      emit(RecentContactsLoaded(recentContacts));
    } catch(error){
      emit(ContactsError('Failed to load recent contacts'));
    }
  }

  Future<void> _onFetchContacts(FetchContactsEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      final contacts = await fetchContactsUseCase();
      emit(ContactsLoaded(contacts));
    } catch (error) {
      emit(ContactsError('Failed to fetch contacts'));
    }
  }

  Future<void> _onAddContact(AddContactEvent event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      await addContactUseCase(email: event.email);
      emit(ContactAdded());
      add(FetchContactsEvent());
    } catch (error) {
      emit(ContactsError('Failed to add contact'));
    }
  }

  Future<void> _onCheckOrCreateConversation(CheckOrCreateConversationEvent event, Emitter<ContactsState> emit) async {
    try{
      emit(ContactsLoading());
      final conversationId = await checkOrCreateConversationUseCase(contactId: event.contactId);
      emit(ConversationReady(conversationId: conversationId, contact: event.contact));
    } catch(error) {
      emit(ContactsError('Failed to start conversation'));
    }
  }
}
