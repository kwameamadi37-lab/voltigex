import 'package:voltigex/features/chatting/contact/data/datasources/contacts_remote_data_source.dart';
import 'package:voltigex/features/chatting/contact/domain/entities/contact_entity.dart';
import 'package:voltigex/features/chatting/contact/domain/repositories/contacts_repository.dart';

class ContactRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDataSource remoteDataSource;

  ContactRepositoryImpl({required this.remoteDataSource});


  @override
  Future<void> addContact({required String email}) async {
    await remoteDataSource.addContacts(email: email);
  }

  @override
  Future<List<ContactEntity>> fetchContacts() async {
    return await remoteDataSource.fetchContacts();
  }

  @override
  Future<List<ContactEntity>> getRecentContacts() async{
    return await remoteDataSource.fetchRecentContacts();
  }

}