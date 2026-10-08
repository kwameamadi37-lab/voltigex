import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/chatting/chat/presentation/pages/chat_page.dart';
import 'package:voltigex/features/chatting/contact/presentation/bloc/contacts_event.dart';
import 'package:voltigex/features/chatting/contact/presentation/bloc/contacts_state.dart';
import 'package:voltigex/features/chatting/contact/presentation/bloc/contats_bloc.dart';
import 'package:voltigex/l10n/app_localizations.dart';
// import 'package:voltigex/features/contacts/presentation/bloc/contacts_bloc.dart';
// import 'package:voltigex/features/contacts/presentation/bloc/contacts_event.dart';
// import 'package:voltigex/features/contacts/presentation/bloc/contacts_state.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ContactsBloc>(context).add(FetchContactsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactsPageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
        ),
      ),
      body: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) async {
          final contactsBloc = BlocProvider.of<ContactsBloc>(context);

          if(state is ConversationReady) {
            var res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=>
                    ChatPage(
                      conversationId: state.conversationId,
                      mate: state.contact.username,
                      profilePhotoUrl: state.contact.profilePhotoUrl,
                      participantRole: state.contact.role,
                    )
                )
            );
            if(res == null){
              contactsBloc.add(FetchContactsEvent());
            }
          }
        },
        child: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state){
            if(state is ContactsLoading){
              return loader();
            }
            else if(state is ContactsLoaded) {
              if(state.contacts.isEmpty){
                return Center(
                  child: Text(
                    l10n.contactsEmptyState,
                    textAlign: TextAlign.center,
                  ),);
              }

              return ListView.builder(
                  itemCount: state.contacts.length,
                  itemBuilder: (context, index){
                    final contact = state.contacts[index];
                    return ListTile(
                      title: Text(contact.username),
                      subtitle: Text(contact.email),
                      textColor: Colors.white,
                      onTap: (){
                        BlocProvider.of<ContactsBloc>(context).add(CheckOrCreateConversationEvent(contact.id, contact),);
                      },
                    );
                  }
              );
            }
            else if(state is ContactsError) {
              return Center(child: Text(state.message),);
            }
            return Center(child: Text(l10n.contactsEmptySearch),);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context){
    final emailController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor:  Theme.of(dialogContext).scaffoldBackgroundColor,
          title: Text(l10n.contactsAddTitle,style: Theme.of(dialogContext).textTheme.bodyMedium,),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: l10n.contactsEmailHint,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(dialogContext);
                },
                child: Text(l10n.buttonCancel)
            ),
            ElevatedButton(
                onPressed: (){
                  final email = emailController.text.trim();
                  if(email.isNotEmpty) {
                    BlocProvider.of<ContactsBloc>(context).add(AddContactEvent(email));
                    Navigator.pop(dialogContext);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: DefaultColors.buttonColor,),
                child: Text(
                  l10n.contactsAddButton,
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                )
            )
          ],
        )
    );
  }
}
