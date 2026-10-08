import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/dashboard/domain/entities/profile_user_entity.dart';
import 'package:voltigex/features/dashboard/domain/usecases/get_profile_user_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/logout_user_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_address_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_contact_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_identity_use_case.dart';
import 'package:voltigex/features/dashboard/domain/usecases/update_password_use_case.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUserUseCase getProfileUserUseCase,
    required UpdateContactUseCase updateContactUseCase,
    required UpdateIdentityUseCase updateIdentityUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required UpdateAddressUseCase updateAddressUseCase,
    required LogoutUserUseCase logoutUserUseCase,
  })  : _getProfileUserUseCase = getProfileUserUseCase,
        _updateContactUseCase = updateContactUseCase,
        _updateIdentityUseCase = updateIdentityUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
        _updateAddressUseCase = updateAddressUseCase,
        _logoutUserUseCase = logoutUserUseCase,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<FetchProfileData>(_onFetchProfileData);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateContactSubmitted>(_onUpdateContactSubmitted);
    on<UpdateIdentitySubmitted>(_onUpdateIdentitySubmitted);
    on<UpdatePasswordSubmitted>(_onUpdatePasswordSubmitted);
    on<UpdateAddressSubmitted>(_onUpdateAddressSubmitted);
  }

  ProfileUserEntity? _lastUser;

  final GetProfileUserUseCase _getProfileUserUseCase;
  final UpdateContactUseCase _updateContactUseCase;
  final UpdateIdentityUseCase _updateIdentityUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final UpdateAddressUseCase _updateAddressUseCase;
  final LogoutUserUseCase _logoutUserUseCase;

  static final RegExp _emailRe = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _passwordStrength = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) =>
      _reloadFromApi(emit);

  Future<void> _onFetchProfileData(
    FetchProfileData event,
    Emitter<ProfileState> emit,
  ) =>
      _reloadFromApi(emit);

  Future<void> _reloadFromApi(Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await _getProfileUserUseCase();
      _lastUser = user;
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErr(e)));
      final u = _lastUser;
      if (u != null) {
        emit(ProfileLoaded(u));
      }
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLogoutLoading());
    try {
      await _logoutUserUseCase();
      SessionController.instance.clearSession();
      emit(ProfileLogoutSuccess());
    } catch (e) {
      emit(ProfileError(_formatErr(e)));
      final u = _lastUser;
      if (u != null) {
        emit(ProfileLoaded(u));
      }
    }
  }

  Future<void> _onUpdateContactSubmitted(
    UpdateContactSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileSubmittingContact) return;
    final current = state is ProfileLoaded ? (state as ProfileLoaded).user : _lastUser;
    if (current == null) return;

    final email = event.email.trim();
    final phone = event.phone.trim();
    if (email.isEmpty || phone.isEmpty) {
      emit(ProfileError('profile.error.contactRequired'));
      emit(ProfileLoaded(current));
      return;
    }
    if (!_emailRe.hasMatch(email)) {
      emit(ProfileError('profile.error.invalidEmail'));
      emit(ProfileLoaded(current));
      return;
    }

    emit(ProfileSubmittingContact());
    try {
      await _updateContactUseCase(email: email, phone: phone);
      final user = await _getProfileUserUseCase();
      _lastUser = user;
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErr(e)));
      emit(ProfileLoaded(current));
    }
  }

  Future<void> _onUpdateIdentitySubmitted(
    UpdateIdentitySubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileSubmittingIdentity) return;
    final current = state is ProfileLoaded ? (state as ProfileLoaded).user : _lastUser;
    if (current == null) return;

    final nom = event.nom.trim();
    final prenom = event.prenom.trim();
    if (nom.isEmpty || prenom.isEmpty) {
      emit(ProfileError('profile.error.identityRequired'));
      emit(ProfileLoaded(current));
      return;
    }

    emit(ProfileSubmittingIdentity());
    try {
      await _updateIdentityUseCase(
        nom: nom,
        prenom: prenom,
        dateNaissance: event.dateNaissance,
        nationalite: event.nationalite,
        numeroIdentification: event.numeroIdentification,
      );
      final user = await _getProfileUserUseCase();
      _lastUser = user;
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErr(e)));
      emit(ProfileLoaded(current));
    }
  }

  Future<void> _onUpdatePasswordSubmitted(
    UpdatePasswordSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileSubmittingPassword) return;
    final current = state is ProfileLoaded ? (state as ProfileLoaded).user : _lastUser;
    if (current == null) return;

    if (event.newPassword != event.confirmPassword) {
      emit(ProfileError('profile.error.passwordsMismatch'));
      emit(ProfileLoaded(current));
      return;
    }
    if (!_passwordStrength.hasMatch(event.newPassword)) {
      emit(ProfileError('profile.error.passwordWeak'));
      emit(ProfileLoaded(current));
      return;
    }

    emit(ProfileSubmittingPassword());
    try {
      await _updatePasswordUseCase(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      final user = await _getProfileUserUseCase();
      _lastUser = user;
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErr(e)));
      emit(ProfileLoaded(current));
    }
  }

  Future<void> _onUpdateAddressSubmitted(
    UpdateAddressSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileSubmittingAddress) return;
    final current = state is ProfileLoaded ? (state as ProfileLoaded).user : _lastUser;
    if (current == null) return;

    final line = event.addressLine.trim();
    final city = event.city.trim();
    final zip = event.zipCode.trim();
    final country = event.country.trim();
    if (line.isEmpty || city.isEmpty || zip.isEmpty || country.isEmpty) {
      emit(ProfileError('profile.error.addressRequired'));
      emit(ProfileLoaded(current));
      return;
    }

    emit(ProfileSubmittingAddress());
    try {
      await _updateAddressUseCase(
        addressLine: line,
        country: country,
        city: city,
        zipCode: zip,
      );
      final user = await _getProfileUserUseCase();
      _lastUser = user;
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_formatErr(e)));
      emit(ProfileLoaded(current));
    }
  }

  String _formatErr(Object e) {
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}
