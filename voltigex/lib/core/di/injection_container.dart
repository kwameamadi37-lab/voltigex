import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/locale/locale_cubit.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:voltigex/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:voltigex/features/auth/domain/repositories/auth_repository.dart';
import 'package:voltigex/features/auth/domain/usecases/login_use_case.dart';
import 'package:voltigex/features/auth/domain/usecases/logout_use_case.dart';
import 'package:voltigex/features/auth/domain/usecases/register_use_case.dart';
import 'package:voltigex/features/chatting/chat/data/datasources/messages_remote_data_source.dart';
import 'package:voltigex/features/chatting/chat/data/repositories/message_repository_impl.dart';
import 'package:voltigex/features/chatting/chat/domain/repositories/messages_repository.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/create_conversation_and_send_message_use_case.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/mark_messages_as_read_use_case.dart';
import 'package:voltigex/features/chatting/chat/domain/usecases/upload_message_media_use_case.dart';
import 'package:voltigex/features/chatting/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:voltigex/features/chatting/conversation/data/repositories/conversations_repository_impl.dart';
import 'package:voltigex/features/chatting/conversation/domain/repositories/conversations_repository.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/fetch_chat_contacts_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/get_or_create_conversation_with_user_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/search_conversations_use_case.dart';
import 'package:voltigex/features/dashboard/data/datasources/card_local_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/card_remote_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/dashboard_mock_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/home_local_data_source.dart';
import 'package:voltigex/features/dashboard/data/datasources/home_remote_data_source.dart';
import 'package:voltigex/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:voltigex/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:voltigex/features/dashboard/domain/usecases/activate_card_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/add_money_to_card_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/delete_card_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/fetch_dashboard_data_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/toggle_card_freeze_use_case.dart';
import 'package:voltigex/features/dashboard/cards/presentation/bloc/cards_bloc.dart';
import 'package:voltigex/features/dashboard/home/presentation/bloc/home_bloc.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfers_history_bloc.dart';
import 'package:voltigex/features/dashboard/data/datasources/profile_remote_data_source.dart';
import 'package:voltigex/features/dashboard/data/repositories/profile_repository_impl.dart';
import 'package:voltigex/features/dashboard/domain/repositories/profile_repository.dart';
import 'package:voltigex/features/dashboard/domain/usecases/get_profile_user_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/logout_user_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_address_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_contact_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_identity_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_password_use_case.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_bloc.dart';
import 'package:voltigex/features/dashboard/data/datasources/transfer_remote_data_source.dart';
import 'package:voltigex/features/dashboard/data/repositories/transfer_repository_impl.dart';
import 'package:voltigex/features/dashboard/domain/repositories/transfer_repository.dart';
import 'package:voltigex/features/dashboard/domain/usecases/make_transfer_use_case.dart';
import 'package:voltigex/features/dashboard/transfer/presentation/bloc/transfer_bloc.dart';

final GetIt sl = GetIt.instance;

void setupDependencies(Locale initialAppLocale) {
  sl.registerSingleton<LocaleCubit>(LocaleCubit(initialAppLocale));

  const String baseUrl = Constants.backendServerAddress;

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(baseUrl: baseUrl),
  );
  sl.registerLazySingleton<ConversationsRemoteDataSource>(
    () => ConversationsRemoteDataSource(baseUrl: baseUrl),
  );
  sl.registerLazySingleton<MessagesRemoteDataSource>(
    () => MessagesRemoteDataSource(baseUrl: baseUrl),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<ConversationsRepository>(
    () => ConversationsRepositoryImpl(conversationsRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<MessagesRepository>(
    () => MessagesRepositoryImpl(remoteDataSource: sl()),
  );

  // Dashboard (mock cartes + API accueil)
  sl.registerLazySingleton<DashboardMockDataSource>(DashboardMockDataSource.new);
  sl.registerLazySingleton<HomeRemoteDataSource>(HomeRemoteDataSource.new);
  sl.registerLazySingleton<HomeLocalDataSource>(HomeLocalDataSource.new);
  sl.registerLazySingleton<CardRemoteDataSource>(CardRemoteDataSource.new);
  sl.registerLazySingleton<CardLocalDataSource>(CardLocalDataSource.new);
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      sl<DashboardMockDataSource>(),
      sl<HomeRemoteDataSource>(),
      sl<HomeLocalDataSource>(),
      sl<CardRemoteDataSource>(),
      sl<CardLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => FetchDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => ToggleCardFreezeUseCase(sl()));
  sl.registerLazySingleton(() => AddMoneyToCardUseCase(sl()));
  sl.registerLazySingleton(() => ActivateCardUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCardUseCase(sl()));
  sl.registerLazySingleton(
    () => HomeBloc(dashboardRepository: sl()),
  );
  sl.registerLazySingleton(
    () => CardsBloc(
      dashboardRepository: sl(),
      toggleCardFreezeUseCase: sl(),
      addMoneyToCardUseCase: sl(),
      activateCardUseCase: sl(),
      deleteCardUseCase: sl(),
    ),
  );

  // Transfer (API Laravel)
  sl.registerLazySingleton<TransferRemoteDataSource>(TransferRemoteDataSource.new);
  sl.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(sl<TransferRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => MakeTransferUseCase(sl()));
  sl.registerFactory(
    () => TransferBloc(
      makeTransferUseCase: sl(),
      homeBloc: sl(),
    ),
  );
  sl.registerFactory(
    () => TransfersHistoryBloc(dashboardRepository: sl()),
  );

  // Use cases (auth & messagerie)
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));

  // Profile (API Laravel + [LogoutUseCase])
  sl.registerLazySingleton<ProfileRemoteDataSource>(ProfileRemoteDataSource.new);
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetProfileUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateContactUseCase(sl()));
  sl.registerLazySingleton(() => UpdateIdentityUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAddressUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUserUseCase(sl()));
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUserUseCase: sl(),
      updateContactUseCase: sl(),
      updateIdentityUseCase: sl(),
      updatePasswordUseCase: sl(),
      updateAddressUseCase: sl(),
      logoutUserUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => FetchConversationsUseCase(sl()));
  sl.registerLazySingleton(() => FetchChatContactsUseCase(sl()));
  sl.registerLazySingleton(() => SearchConversationsUseCase(sl()));
  sl.registerLazySingleton(
    () => FetchMessagesUseCase(messagesRepository: sl()),
  );
  sl.registerLazySingleton(
    () => UploadMessageMediaUseCase(messagesRepository: sl()),
  );
  sl.registerLazySingleton(
    () => CreateConversationAndSendMessageUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => CheckOrCreateConversationUseCase(conversationsRepository: sl()),
  );
  sl.registerLazySingleton(
    () => GetOrCreateConversationWithUserUseCase(conversationsRepository: sl()),
  );
  sl.registerLazySingleton(
    () => MarkMessagesAsReadUseCase(messagesRepository: sl()),
  );

  // Socket service
  sl.registerLazySingleton<SocketService>(() => SocketService());
}
