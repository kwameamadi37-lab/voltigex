abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;

  AuthSuccess({required this.message});
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
}

class LogoutSuccess extends AuthState {
  final String message;

  LogoutSuccess({required this.message});
}

class LogoutLoading extends AuthState {}