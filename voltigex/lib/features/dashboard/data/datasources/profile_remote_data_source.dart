import 'package:dio/dio.dart';
import 'package:voltigex/core/api/api_endpoints.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/features/dashboard/domain/entities/profile_user_entity.dart';

class ProfileApiException implements Exception {
  ProfileApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// API profil utilisateur (Sanctum).
class ProfileRemoteDataSource {
  ProfileRemoteDataSource();

  Dio get _dio => DioClient().createDio(baseUrl: Constants.backendServerAddress);

  ProfileUserEntity _userFromJson(Map<String, dynamic> m) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    final id = m['id'];
    final nomVal = s(m['nom']);
    final lastName = s(m['last_name']);
    final prenomVal = s(m['prenom']);
    final firstName = s(m['first_name']);
    final birth = s(m['birth_date']);
    final legacyBirth = s(m['date_naissance']);

    final photoRaw = m['profile_photo_url']?.toString().trim();
    final profilePhoto =
        photoRaw != null && photoRaw.isNotEmpty ? photoRaw : null;

    return ProfileUserEntity(
      userId: id == null ? '' : id.toString(),
      email: s(m['email']),
      phone: s(m['phone']),
      nom: nomVal.isNotEmpty ? nomVal : lastName,
      prenom: prenomVal.isNotEmpty ? prenomVal : firstName,
      alias: s(m['alias']),
      role: s(m['role']),
      profilePhotoUrl: profilePhoto,
      emailVerified: m['email_verified'] == true,
      phoneVerified: m['phone_verified'] == true,
      country: s(m['country']),
      city: s(m['city']),
      postalCode: s(m['postal_code']),
      addressLine: s(m['address_line']).isNotEmpty
          ? s(m['address_line'])
          : s(m['address']),
      dateNaissance: birth.isNotEmpty ? birth : legacyBirth,
      nationalite: s(m['nationalite']),
      numeroIdentification: s(m['numero_identification']),
    );
  }

  String _messageFromDio(DioException e) {
    final d = e.response?.data;
    if (d is Map) {
      final msg = d['message']?.toString().trim();
      if (msg != null && msg.isNotEmpty) return msg;
      final errs = d['errors'];
      if (errs is Map) {
        for (final v in errs.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String && v.isNotEmpty) return v;
        }
      }
    }
    return e.message?.trim().isNotEmpty == true
        ? e.message!.trim()
        : 'Erreur réseau';
  }

  Future<ProfileUserEntity> fetchMe() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.userMe);
      final m = res.data;
      if (m == null) {
        throw ProfileApiException('Réponse vide');
      }
      return _userFromJson(m);
    } on DioException catch (e) {
      throw ProfileApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> updateContact({
    required String email,
    required String phone,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.userContact,
        data: <String, dynamic>{'email': email, 'phone': phone},
      );
      if (res.data?['success'] != true) {
        throw ProfileApiException(
          res.data?['message']?.toString() ?? 'Échec de la mise à jour',
        );
      }
    } on DioException catch (e) {
      throw ProfileApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> updateIdentity({
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? nationalite,
    String? numeroIdentification,
  }) async {
    final dn = dateNaissance?.trim();
    final nat = nationalite?.trim();
    final nid = numeroIdentification?.trim();
    final body = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'first_name': prenom,
      'last_name': nom,
      if (dn != null && dn.isNotEmpty) 'birth_date': dn,
      if (dn != null && dn.isNotEmpty) 'date_naissance': dn,
      if (nat != null && nat.isNotEmpty) 'nationalite': nat,
      if (nid != null && nid.isNotEmpty) 'numero_identification': nid,
    };
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.userIdentity,
        data: body,
      );
      if (res.data?['success'] != true) {
        throw ProfileApiException(
          res.data?['message']?.toString() ?? 'Échec de la mise à jour',
        );
      }
    } on DioException catch (e) {
      throw ProfileApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> updateAddress({
    required String addressLine,
    required String city,
    required String postalCode,
    required String country,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.userAddress,
        data: <String, dynamic>{
          'address_line': addressLine,
          'city': city,
          'postal_code': postalCode,
          'country': country,
        },
      );
      if (res.data?['success'] != true) {
        throw ProfileApiException(
          res.data?['message']?.toString() ?? 'Échec de la mise à jour',
        );
      }
    } on DioException catch (e) {
      throw ProfileApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.userPassword,
        data: <String, dynamic>{
          'oldpass': currentPassword,
          'newpass': newPassword,
          'confpass': confirmPassword,
        },
      );
      if (res.data?['success'] != true) {
        throw ProfileApiException(
          res.data?['message']?.toString() ?? 'Échec de la mise à jour',
        );
      }
    } on DioException catch (e) {
      throw ProfileApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
