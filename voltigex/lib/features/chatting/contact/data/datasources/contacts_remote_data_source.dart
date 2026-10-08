
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/features/chatting/contact/data/models/contact_model.dart';
import 'package:http/http.dart' as http;

class ContactsRemoteDataSource {
  // final String baseUrl = BackendServer.address;
  final String baseUrl;
  final _storage = FlutterSecureStorage();

  ContactsRemoteDataSource({required this.baseUrl});

  Future<List<ContactModel>> fetchContacts() async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    final response = await dio.get('/api/contacts');
    if(response.statusCode == 200){
      List data = response.data;
      return data.map((json) => ContactModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Contacts');
    }
  }

  Future<void> addContacts({required String email}) async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    final response = await dio.post(
        '/api/contacts',
        data: jsonEncode({'contactEmail': email}),
    );
    if(response.statusCode != 201){
      throw Exception('Failed to add Contacts');
    }
  }

  Future<List<ContactModel>> fetchRecentContacts() async {
    final dio = DioClient().createDio(baseUrl: baseUrl);

    final response = await dio.get('/api/contacts/recent',);

    if(response.statusCode == 201) {
      List data = response.data;
      return data.map((json) => ContactModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch recent contacts');
    }
  }
}