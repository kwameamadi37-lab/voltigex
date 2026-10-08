import 'package:voltigex/features/dashboard/domain/entities/profile_user_entity.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.user);

  final ProfileUserEntity user;
}

class ProfileSubmittingContact extends ProfileState {}

class ProfileSubmittingIdentity extends ProfileState {}

class ProfileSubmittingPassword extends ProfileState {}

class ProfileSubmittingAddress extends ProfileState {}

class ProfileLogoutLoading extends ProfileState {}

class ProfileLogoutSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  ProfileError(this.message);

  final String message;
}
