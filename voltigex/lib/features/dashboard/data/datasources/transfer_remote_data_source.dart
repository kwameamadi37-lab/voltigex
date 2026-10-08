import 'package:dio/dio.dart';
import 'package:voltigex/core/api/api_endpoints.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/network/dio_client.dart';
import 'package:voltigex/features/dashboard/domain/entities/make_transfer_params.dart';
import 'package:voltigex/features/dashboard/data/models/transfer_model.dart';
import 'package:voltigex/features/dashboard/domain/entities/recent_recipient_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/recent_recipients_page.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

/// Résultat de `POST /api/virements` (création).
class CreatedVirementResult {
  const CreatedVirementResult({required this.id, this.slug});

  final int id;
  final String? slug;
}

/// Appels API virements (Sanctum).
class TransferRemoteDataSource {
  TransferRemoteDataSource();

  Dio get _dio =>
      DioClient().createDio(baseUrl: Constants.backendServerAddress);

  static String? parseSupportSlugFromJson(dynamic data) {
    if (data is! Map) return null;
    final m = Map<String, dynamic>.from(data);
    final raw = m['slug'] ?? m['support_slug'];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  String messageFromDioException(DioException e) {
    final d = e.response?.data;
    if (d is Map<String, dynamic>) {
      return _messageFromBody(d);
    }
    if (d is Map) {
      return _messageFromBody(Map<String, dynamic>.from(d));
    }
    final m = e.message?.trim();
    return m != null && m.isNotEmpty ? m : 'Erreur réseau';
  }

  String _messageFromBody(Map<String, dynamic>? body) {
    if (body == null) return 'Erreur réseau';
    final m = body['message'];
    if (m != null && m.toString().trim().isNotEmpty) return m.toString();
    final errs = body['errors'];
    if (errs is Map) {
      for (final v in errs.values) {
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v is String && v.isNotEmpty) return v;
      }
    }
    return 'Erreur serveur';
  }

  String _ibanForApi(String raw) =>
      raw.replaceAll(RegExp(r'\s'), '').toUpperCase();

  /// `POST /api/virements` — retourne l’id et le slug public de suivi.
  Future<CreatedVirementResult> createVirement(
    MakeTransferParams params,
  ) async {
    final titulaire = params.apiTitulaire;
    if (titulaire.isEmpty) {
      throw StateError('Titulaire requis');
    }
    final iban = _ibanForApi(params.iban);
    final bic = params.bic.trim();
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.virementsCreate,
      data: <String, dynamic>{
        'titulaire': titulaire.length > 50
            ? titulaire.substring(0, 50)
            : titulaire,
        'nombanque': params.bankName.trim(),
        'nom': params.lastName.trim(),
        'prenom': params.firstName.trim(),
        'iban': iban,
        if (bic.isNotEmpty) 'bic': bic,
        'montant': params.amount,
      },
      options: Options(
        headers: const {'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Réponse vide',
      );
    }
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: _messageFromBody(body),
        response: response,
      );
    }
    final id = body['virement_id'] ?? body['data']?['virement_id'];
    final int parsedId;
    if (id is int) {
      parsedId = id;
    } else if (id is num) {
      parsedId = id.toInt();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Réponse virement invalide (id manquant)',
      );
    }
    final slug = parseSupportSlugFromJson(body);
    return CreatedVirementResult(id: parsedId, slug: slug);
  }

  /// `GET /api/virements/{id}/progress` — ligne [Virement] (pourcentage, code, etc.).
  Future<Map<String, dynamic>> fetchVirementRow(int virementId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.virementProgress(virementId),
      options: Options(
        headers: const {'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Réponse vide',
      );
    }
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: _messageFromBody(body),
        response: response,
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Format virement invalide',
      );
    }
    return data;
  }

  /// `POST /api/virements/{id}/confirm` — fait avancer [pourcentage] côté serveur.
  Future<int> confirmVirementStep(int virementId, String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.virementConfirm(virementId),
      data: <String, dynamic>{'code': code},
      options: Options(
        headers: const {'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Réponse vide',
      );
    }
    if (body['success'] != true) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: _messageFromBody(body),
        response: response,
      );
    }
    final p = body['progress'];
    if (p is int) return p;
    if (p is num) return p.toInt();
    if (p is String) {
      final parsed = int.tryParse(p.trim());
      if (parsed != null) return parsed;
      final asDouble = double.tryParse(p.trim().replaceAll(',', '.'));
      if (asDouble != null) return asDouble.toInt();
    }
    return 0;
  }

  /// Dernière ligne connue → entité historique.
  TransactionEntity transactionFromVirementRow(
    Map<String, dynamic> row,
    int virementId,
  ) {
    final bank = row['nombanque']?.toString() ?? '';
    final amount = row['montant'];
    final statut = row['statut']?.toString() ?? '';
    final ok =
        statut == 'termine' ||
        (row['pourcentage'] is num && (row['pourcentage'] as num) >= 99);
    final created = row['created_at']?.toString();
    final dateStr = created != null && created.isNotEmpty
        ? created
        : DateTime.now().toIso8601String();
    final pct = row['pourcentage'];
    final progressPercent = pct is num
        ? pct.toDouble()
        : double.tryParse('${pct ?? ''}'.trim().replaceAll(',', '.'));
    final statutNorm = statut.toString().trim().toLowerCase();
    final slugRaw = row['slug']?.toString().trim() ?? '';
    final supportSlug = slugRaw.isEmpty ? null : slugRaw;
    return TransactionEntity(
      id: virementId.toString(),
      receiver: bank,
      isIncoming: false,
      amount: amount is num
          ? amount.toDouble()
          : double.tryParse('$amount') ?? 0,
      date: dateStr,
      status: ok ? 'REUSSI' : 'ECHEC',
      progressPercent: progressPercent,
      apiStatut: statutNorm.isEmpty ? null : statutNorm,
      supportSlug: supportSlug,
    );
  }

  static int _asInt(dynamic v, [int fallback = 1]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v'.trim()) ?? fallback;
  }

  static bool _paginatorHasMore(Map<String, dynamic> meta, int itemCount) {
    final next = meta['next_page_url'];
    if (next != null &&
        next.toString().trim().isNotEmpty &&
        next.toString().toLowerCase() != 'null') {
      return true;
    }
    final cur = _asInt(meta['current_page'], 1);
    final last = _asInt(meta['last_page'], 1);
    if (last > cur) return true;
    final perPage = _asInt(meta['per_page'], 25);
    final total = meta['total'];
    if (total is num && perPage > 0 && itemCount >= perPage) {
      return itemCount < total.toInt();
    }
    return false;
  }

  /// Virements récents (`GET /api/user/virements`) : une ligne par virement, pas une par IBAN.
  Future<RecentRecipientsPage> fetchRecentRecipients({
    int page = 1,
    int perPage = 25,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.userVirements,
      queryParameters: <String, dynamic>{'page': page, 'per_page': perPage},
      options: Options(
        headers: const {'Accept': 'application/json'},
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final body = response.data;
    if (body == null || body['success'] != true) {
      return RecentRecipientsPage(
        items: const [],
        hasMore: false,
        currentPage: page,
        perPage: perPage,
      );
    }
    final payload = body['data'];
    List<dynamic> rawList;
    Map<String, dynamic>? meta;
    if (payload is List) {
      rawList = payload;
    } else if (payload is Map) {
      meta = Map<String, dynamic>.from(payload);
      final inner = meta['data'];
      rawList = inner is List ? inner : <dynamic>[];
    } else {
      rawList = <dynamic>[];
    }
    final out = <RecentRecipientEntity>[];
    for (final e in rawList) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final iban = m['iban']?.toString().trim() ?? '';
      if (iban.isEmpty) continue;
      out.add(TransferModel.fromVirementMap(m).toEntity().toRecentRecipient());
    }
    final currentPage = meta != null
        ? _asInt(meta['current_page'], page)
        : page;
    final resolvedPerPage = meta != null
        ? _asInt(meta['per_page'], perPage)
        : perPage;
    final hasMore = meta != null
        ? _paginatorHasMore(meta, out.length)
        : (out.length >= perPage);
    return RecentRecipientsPage(
      items: out,
      hasMore: hasMore,
      currentPage: currentPage,
      perPage: resolvedPerPage,
    );
  }
}
