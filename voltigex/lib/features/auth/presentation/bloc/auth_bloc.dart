import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/core/network/socket_service.dart';
import 'package:voltigex/features/chatting/conversation/data/local/conversations_inbox_cache.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/core/di/injection_container.dart';
import 'package:voltigex/features/auth/domain/usecases/login_use_case.dart';
import 'package:voltigex/features/auth/domain/usecases/logout_use_case.dart';
import 'package:voltigex/features/auth/domain/usecases/register_use_case.dart';
import 'package:voltigex/features/chatting/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_conversation_storage.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_event.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_state.dart';
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUserCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final SocketService _socketService = SocketService();

  AuthBloc({required this.registerUserCase, required this.loginUseCase, required this.logoutUseCase}) : super(AuthInitial()){
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit ) async {
    emit(AuthLoading());
    try {
      await registerUserCase.call(event.username, event.email, event.password);
      emit(AuthSuccess(message: 'auth.success.register'));
    } catch (e) {
      emit(AuthFailure(error: 'auth.error.registerFailed'));
      emit(AuthInitial());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit ) async {
    emit(AuthLoading());

    try {
      final user = await loginUseCase.call(event.email, event.password);

      final session = SessionController.instance;
      session.setSession(user.id, user.token, role: user.role);

      await _socketService.initSocket(forceReconnect: true);
      await _persistSupportConversationIdIfClient();
      emit(AuthSuccess(message: 'auth.success.login'));

    } catch (e) {
      emit(AuthFailure(error: 'auth.error.loginFailed'));
      emit(AuthInitial());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(LogoutLoading());

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await logoutUseCase.call(fcmToken);
        await FirebaseMessaging.instance.deleteToken();
      }
      emit(LogoutSuccess(message: 'auth.success.logout'));
    } catch (e) {
      emit(AuthFailure(error: 'auth.error.logoutFailed'));
    } finally {
      try {
        await SocketService.instance.disconnect();
        await ConversationsInboxCache.instance.clear();
        await SupportConversationStorage.clear();
      } catch (_) {}
    }
  }

  /// Stocke l’UUID conversation Support pour l’onglet Chat au démarrage (clients uniquement).
  Future<void> _persistSupportConversationIdIfClient() async {
    final session = SessionController.instance;
    if (session.isAdminSupport) return;
    try {
      final useCase = sl<CheckOrCreateConversationUseCase>();
      final id = (await useCase.call(contactId: Constants.supportAdminId)).trim();
      if (id.isNotEmpty) {
        await SupportConversationStorage.saveId(id);
      }
    } catch (_) {}
  }

}