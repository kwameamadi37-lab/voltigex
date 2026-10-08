import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/locale/app_locale_storage.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_bloc.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_event.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_state.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_event.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_cubit.dart';
import 'package:voltigex/l10n/app_localizations.dart';

/// ----------------------------------------------------------------------------
/// 🔴 HANDLER D'ARRIÈRE-PLAN (OBLIGATOIREMENT TOP-LEVEL)
/// ----------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialisation obligatoire de Firebase dans cet isolate isolé
  await Firebase.initializeApp();

  // debugPrint('[fcm_background] Message reçu: ${message.messageId}');

  if (message.data.isNotEmpty) {
    final FlutterLocalNotificationsPlugin backgroundNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel backgroundChannel = AndroidNotificationChannel(
      'chat_channel_id',
      'Messages',
      description: 'Canal pour les notifications de messagerie',
      importance: Importance.max,
    );

    await backgroundNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(backgroundChannel);

    final title = message.notification?.title ??
        message.data['senderName']?.toString() ??
        'Support';
    final body = message.notification?.body ??
        message.data['content']?.toString() ??
        'Nouveau message';

    await backgroundNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          backgroundChannel.id,
          backgroundChannel.name,
          channelDescription: backgroundChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// SERVICE DE NOTIFICATION
/// ----------------------------------------------------------------------------
class NotificationService {
  static NotificationService? _instance;

  /// Enregistrement FCM après login / restauration de session.
  static Future<void> registerTokenAfterAuth() async {
    await _instance?.syncFcmTokenWithBackend();
  }

  final GlobalKey<NavigatorState> navigatorKey;

  NotificationService({required this.navigatorKey}) {
    _instance = this;
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Cache des messages regroupés par conversation
  Map<String, List<Map<String, String>>> userMessages = {};

  Future<AppLocalizations> _resolveL10n() async {
    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      return AppLocalizations.of(ctx)!;
    }
    final locale = await AppLocaleStorage.readInitial();
    return lookupAppLocalizations(locale);
  }

  Future<String> _getOrDownloadUserImage(String url, String userId) async {
    if (url.isEmpty) return '';
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = '${dir.path}/user_$userId.png';
    final File file = File(filePath);

    if (await file.exists()) {
      return filePath;
    }

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<String?> getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor;
      } else {
        return null;
      }
    } catch (e) {
      // debugPrint('[device_id_error] $e');
      return null;
    }
  }

  Future<void> syncFcmTokenWithBackend() async {
    if (SessionController.instance.isAdminSupport) return;

    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${Constants.backendServerAddress}/api/user/fcm-token'),
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device_type': Platform.isAndroid
              ? 'android'
              : (Platform.isIOS ? 'ios' : 'web'),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 400) {
        debugPrint(
          '[fcm_token] API ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[fcm_token_send_error] $e');
    }
  }

  /// Initialisation complète de FCM
  Future<void> initFCM() async {
    // 1. Enregistrement du Handler d'arrière-plan FCM
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await syncFcmTokenWithBackend();

    _firebaseMessaging.onTokenRefresh.listen((_) {
      syncFcmTokenWithBackend();
    });

    // 4. Configuration Notifications Locales Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null) return;
        _handleNotificationClick(response.payload!);
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_channel_id',
      'Messages',
      description: 'Canal pour les notifications de messagerie',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 5. Réception de messages en Premier Plan (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (SessionController.instance.isAdminSupport) return;

      final data = Map<String, dynamic>.from(message.data);
      final conversationId = (data['conversation_id'] ??
              data['conversationId'] ??
              '')
          .toString();

      final senderId = (data['sender_id'] ?? data['senderId'] ?? '')
          .toString();
      final senderName = message.notification?.title?.toString() ??
          data['senderName']?.toString() ??
          'Support';
      final content = message.notification?.body?.toString() ??
          data['content']?.toString() ??
          '';

      await showMessagingStyleNotification(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderImage: data['senderImage']?.toString() ?? '',
        content: content.isNotEmpty ? content : 'Nouveau message',
        data: data,
      );

      if (conversationId.isNotEmpty) {
        _requestConversationsRefresh();
        _requestChatDeltaSync(conversationId);
      }
    });

    // 6. Clic sur notification quand l'app était en arrière-plan (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // debugPrint('[fcm_opened_background] ${message.data}');
      _navigateToChatPage(message.data);
      _requestConversationsRefresh();
    });

    // 7. Clic sur notification quand l'app était complètement fermée (Terminated)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // debugPrint('[fcm_opened_terminated] ${message.data}');
        _navigateToChatPage(message.data);
        _requestConversationsRefresh();
      }
    });
  }

  /// Affichage de la notification stylisée
  Future<void> showMessagingStyleNotification({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String content,
    required Map data,
  }) async {
    final l10n = await _resolveL10n();

    userMessages[conversationId] = (userMessages[conversationId] ?? [])
      ..add({
        'sender': senderName,
        'content': content,
        'image': senderImage,
      });

    final String senderImagePath =
        await _getOrDownloadUserImage(senderImage, senderId);

    final List<Message> androidMessages = userMessages[conversationId]!
        .map(
          (msg) => Message(
            msg['content']!,
            DateTime.now(),
            Person(
              name: msg['sender'],
              icon: senderImagePath.isNotEmpty
                  ? BitmapFilePathAndroidIcon(senderImagePath)
                  : null,
            ),
          ),
        )
        .toList();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      l10n.notificationChannelMessagesTitle,
      channelDescription: l10n.notificationChannelMessagesDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      styleInformation: MessagingStyleInformation(
        Person(
          name: senderName,
          icon: senderImagePath.isNotEmpty
              ? BitmapFilePathAndroidIcon(senderImagePath)
              : null,
        ),
        messages: androidMessages,
        groupConversation: false,
      ),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final notifId = conversationId.hashCode;

    await flutterLocalNotificationsPlugin.show(
      notifId,
      senderName,
      content,
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  void _requestConversationsRefresh() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    try {
      ctx.read<ConversationsBloc>().add(FetchConversationsEvent());
    } catch (_) {}
  }

  void _requestChatDeltaSync(String conversationId) {
    final cid = conversationId.trim();
    if (cid.isEmpty) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    try {
      final chatState = ctx.read<ChatBloc>().state;
      // Évite un rechargement complet qui efface les brouillons / désordonne le fil.
      if (chatState is ChatLoadedState && chatState.deltaSyncInProgress) {
        return;
      }
      final uid = SessionController.instance.userId ?? '';
      ctx.read<ChatBloc>().add(
            LoadMessagesEvent(
              cid,
              currentUserId: uid.isNotEmpty ? uid : null,
            ),
          );
    } catch (_) {}
  }

  void _handleNotificationClick(String payload) {
    try {
      final data = jsonDecode(payload);
      _navigateToChatPage(data);
    } catch (e) {
      // debugPrint('[notification_payload_decode_error] $e');
    }
  }

  void _navigateToChatPage(Map data) {
    final conversationId =
        (data['conversation_id'] ?? data['conversationId'] ?? '').toString();
    final mate = (data['senderName'] ?? '').toString();
    final rawSenderImage = (data['senderImage'] ?? '').toString().trim();
    final profilePhotoUrl = rawSenderImage.isEmpty ? null : rawSenderImage;
    final roleRaw = (data['senderRole'] ?? '').toString().trim();
    final participantRole = roleRaw.isEmpty ? null : roleRaw;

    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    if (SessionController.instance.isAdminSupport) return;

    final l10n = AppLocalizations.of(ctx)!;

    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ctx.read<MainNavigationCubit>().openChatTab(
          conversationId: conversationId,
          mate: l10n.conversationsTitleSupport,
          profilePhotoUrl: profilePhotoUrl,
          participantRole: participantRole,
        );
  }
}