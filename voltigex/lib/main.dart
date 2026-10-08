import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:voltigex/core/network/connectivity_bloc.dart';
import 'package:voltigex/core/network/notification_service.dart';
import 'package:voltigex/features/dashboard/home/presentation/pages/home_page.dart';
import 'package:voltigex/features/dashboard/shell/presentation/bloc/main_navigation_cubit.dart';
import 'package:voltigex/features/dashboard/shell/presentation/pages/main_screen.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/core/locale/app_locale_storage.dart';
import 'package:voltigex/core/locale/locale_cubit.dart';
import 'package:voltigex/l10n/app_localizations.dart';
import 'package:voltigex/features/dashboard/data/datasources/card_local_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/home_local_data_source.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/make_transfer_page.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/transfer_page.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/pages/transfers_history_page.dart';
import 'package:voltigex/features/chatting/chat/presentation/bloc/chat_bloc.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voltigex/features/auth/presentation/pages/login_page.dart';
import 'package:voltigex/features/auth/presentation/pages/register_page.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/fetch_chat_contacts_use_case.dart';
import 'package:voltigex/features/chatting/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:voltigex/features/chatting/conversation/presentation/pages/conversations_page.dart';
import 'package:voltigex/features/chatting/conversation/presentation/widgets/conversations_inbox_binding.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_bloc.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_event.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_bloc.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_bloc.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/settings_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voltigex/splash_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'firebase_options.dart';


void _registerWebViewPlatformIfNeeded() {
  if (WebViewPlatform.instance != null) return;
  if (Platform.isAndroid) {
    AndroidWebViewPlatform.registerWith();
  } else if (Platform.isIOS || Platform.isMacOS) {
    WebKitWebViewPlatform.registerWith();
  }
}

// Global NavigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


// test***********************

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
  
//   // Extraire les données envoyées par Laravel (SendChatMessageNotification.php)
//   final conversationId = message.data['conversation_id'];
//   final senderName = message.data['senderName'];

//   if (conversationId != null) {
//     // Déclencher le rafraîchissement local ou la mise à jour d'un coordinateur
//     ConversationsInboxCoordinator.onRemoteNotificationReceived(conversationId);
//   }
// }

// // Dans la méthode d'initialisation principal FCM :
// FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// test *******************

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerWebViewPlatformIfNeeded();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await HomeLocalDataSource.registerAdapterAndOpen();
  await CardLocalDataSource.registerAndOpen();

  // Initialisation des locales (dates + timeago)
  await Future.wait<void>([
    initializeDateFormatting('it_IT', null),
    initializeDateFormatting('fr_FR', null),
    initializeDateFormatting('en_US', null),
    initializeDateFormatting('es_ES', null),
    initializeDateFormatting('de_DE', null),
  ]);
  timeago.setLocaleMessages('it', timeago.ItMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());

  final initialAppLocale = await AppLocaleStorage.readInitial();

  // Setup des dépendances et services
  setupDependencies(initialAppLocale);
  // Pusher : ne pas connecter ici sans jeton — init après login (AuthBloc) ou session (Splash).

  // // ✅ Déclaration du handler FCM global (background/app fermée)
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  

  // ✅ Initialisation du service de notifications (foreground)
  final notificationService = NotificationService(navigatorKey: navigatorKey);
  await notificationService.initFCM();

  runApp(MyApp(
    navigatorKey: navigatorKey,
    notificationService: notificationService,
  ));
}



class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(
          value: sl<LocaleCubit>(),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (_) => ConnectivityBloc(),
        ),
        BlocProvider(
          create: (_) => AuthBloc(
            registerUserCase: sl(),
            loginUseCase: sl(),
            logoutUseCase: sl()
          ),
        ),
        BlocProvider(
          create: (_) => ConversationsBloc(
            fetchConversationsUseCase: sl(),
            fetchChatContactsUseCase: sl<FetchChatContactsUseCase>(),
            searchConversationsUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => ChatBloc(
            fetchMessagesUseCase: sl(),
            uploadMessageMediaUseCase: sl(),
            markMessagesAsReadUseCase: sl(),
            createConversationAndSendMessageUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => MainNavigationCubit(),
        ),
        BlocProvider(
          create: (_) {
            final bloc = sl<HomeBloc>();
            bloc.add(FetchHomeData());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = sl<CardsBloc>();
            bloc.add(FetchCardsData());
            return bloc;
          },
        ),
      ],
      child: ConversationsInboxBinding(
        child: BlocBuilder<LocaleCubit, Locale>(
          buildWhen: (a, b) => a != b,
          builder: (context, locale) {
            return GetMaterialApp(
              key: ValueKey(locale.languageCode),
              navigatorKey: navigatorKey,
              title: lookupAppLocalizations(locale).appTitle,
              theme: AppTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [
                Locale('it'),
                Locale('fr'),
                Locale('en'),
                Locale('es'),
                Locale('de'),
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                if (deviceLocale == null) return const Locale('it');
                for (final supported in supportedLocales) {
                  if (supported.languageCode == deviceLocale.languageCode) {
                    return supported;
                  }
                }
                return const Locale('it');
              },
              home: const SplashScreen(),
              routes: {
                '/homePage': (_) => const HomePage(),
                '/login': (_) => const LoginPage(),
                '/register': (_) => const RegisterPage(),
                '/navigationPage': (_) => const MainScreen(),
                '/transferPage': (_) => const TransferPage(),
                '/transfersHistoryPage': (_) => const TransfersHistoryPage(),
                '/makeTransferPage': (_) => BlocProvider(
                      create: (_) => sl<TransferBloc>(),
                      child: const MakeTransferPage(),
                    ),
                '/profilPage': (_) => BlocProvider(
                      create: (_) => sl<ProfileBloc>()..add(LoadProfile()),
                      child: const ProfilPage(),
                    ),
                '/conversationPage': (_) => const ConversationsPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
