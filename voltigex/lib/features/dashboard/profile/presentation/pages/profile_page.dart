import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_bloc.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_state.dart';
import 'package:voltigex/l10n/app_localizations.dart';
import 'package:voltigex/features/dashboard/profile/presentation/localization/profile_error_localizer.dart';

final DateFormat _kBirthDisplay = DateFormat('dd-MM-yyyy');
final DateFormat _kBirthApi = DateFormat('yyyy-MM-dd');

/// API renvoie [yyyy-MM-dd] ; affichage utilisateur [dd-MM-yyyy].
String _birthIsoToDisplay(String iso) {
  final t = iso.trim();
  if (t.isEmpty) return '';
  final d = DateTime.tryParse(t.length >= 10 ? t.substring(0, 10) : t);
  if (d == null) return t;
  return _kBirthDisplay.format(d);
}

/// Retourne `yyyy-MM-dd` pour l’API, ou `null` si vide / invalide.
String? _birthDisplayToIso(String display) {
  final t = display.trim();
  if (t.isEmpty) return null;
  try {
    final d = _kBirthDisplay.parseStrict(t);
    return _kBirthApi.format(d);
  } on FormatException {
    return null;
  }
}

/// Identité : nom, prénom, date de naissance, nationalité, n° identification (PUT /api/user/identity).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _nationaliteController = TextEditingController();
  final _numeroIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileData());
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _nationaliteController.dispose();
    _numeroIdController.dispose();
    super.dispose();
  }

  void _syncFromUser(ProfileLoaded state) {
    final u = state.user;
    if (_nomController.text != u.nom) _nomController.text = u.nom;
    if (_prenomController.text != u.prenom) _prenomController.text = u.prenom;
    final birthDisplay = _birthIsoToDisplay(u.dateNaissance);
    if (_dateNaissanceController.text != birthDisplay) {
      _dateNaissanceController.text = birthDisplay;
    }
    if (_nationaliteController.text != u.nationalite) {
      _nationaliteController.text = u.nationalite;
    }
    if (_numeroIdController.text != u.numeroIdentification) {
      _numeroIdController.text = u.numeroIdentification;
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    var initial = DateTime(now.year - 18, now.month, now.day);
    final raw = _dateNaissanceController.text.trim();
    if (raw.isNotEmpty) {
      try {
        initial = _kBirthDisplay.parseStrict(raw);
      } on FormatException {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) initial = parsed;
      }
    }
    final first = DateTime(now.year - 120);
    final last = now;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      locale: Localizations.localeOf(context),
      helpText: l10n.birthDateHelp,
      cancelText: l10n.buttonCancel,
      confirmText: l10n.buttonOk,
    );
    if (picked != null && mounted) {
      setState(() {
        _dateNaissanceController.text = _kBirthDisplay.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              c is ProfileLoaded && p is ProfileSubmittingIdentity,
          listener: (context, state) {
            _syncFromUser(state as ProfileLoaded);
            final t = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              t.profileUpdatedSuccess,
              type: TopSnackBarType.success,
              title: t.successTitle,
            );
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              c is ProfileLoaded &&
              (p is ProfileLoading || p is ProfileError),
          listener: (context, state) {
            _syncFromUser(state as ProfileLoaded);
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              c is ProfileError &&
              (p is ProfileSubmittingIdentity ||
                  p is ProfileLoading ||
                  p is ProfileLoaded ||
                  p is ProfileInitial),
          listener: (context, state) {
            final t = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              localizeProfileError(t, (state as ProfileError).message),
              type: TopSnackBarType.error,
              title: t.errorTitle,
            );
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final loading = state is ProfileLoading;
          final submitting = state is ProfileSubmittingIdentity;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: DefaultColors.blackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.profilePageTitle,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: DefaultColors.blackColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (loading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: loader(),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFd1d5db)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.profileIdentitySection,
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.5,
                                    color: DefaultColors.blackColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              BuildLabeledTextField(
                                label: l10n.profileFieldLastName,
                                hintText: '',
                                controller: _nomController,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? l10n.formValidatorRequired
                                        : null,
                              ),
                              const SizedBox(height: 15),
                              BuildLabeledTextField(
                                label: l10n.profileFieldFirstName,
                                hintText: '',
                                controller: _prenomController,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? l10n.formValidatorRequired
                                        : null,
                              ),
                              const SizedBox(height: 15),
                              BuildLabeledTextField(
                                label: l10n.profileFieldBirthDate,
                                hintText: l10n.profileBirthDateHint,
                                controller: _dateNaissanceController,
                                onTap: _pickBirthDate,
                                suffixIcon: IconButton(
                                  onPressed: _pickBirthDate,
                                  icon: Icon(
                                    Icons.calendar_today_outlined,
                                    color: DefaultColors.greyText,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return null;
                                  }
                                  if (_birthDisplayToIso(v) == null) {
                                    return l10n.profileBirthDateFormatError;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              BuildLabeledTextField(
                                label: l10n.profileFieldNationality,
                                hintText: '',
                                controller: _nationaliteController,
                              ),
                              const SizedBox(height: 15),
                              BuildLabeledTextField(
                                label: l10n.profileFieldIdNumber,
                                hintText: '',
                                controller: _numeroIdController,
                              ),
                              const SizedBox(height: 25),
                              FormsButton(
                                text: submitting
                                    ? l10n.formButtonUpdating
                                    : l10n.formButtonUpdate,
                                isBusy: submitting,
                                onPressed: () {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  context.read<ProfileBloc>().add(
                                        UpdateIdentitySubmitted(
                                          nom: _nomController.text.trim(),
                                          prenom:
                                              _prenomController.text.trim(),
                                          dateNaissance: _birthDisplayToIso(
                                            _dateNaissanceController.text,
                                          ),
                                          nationalite:
                                              _nationaliteController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _nationaliteController
                                                      .text
                                                      .trim(),
                                          numeroIdentification:
                                              _numeroIdController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _numeroIdController.text
                                                      .trim(),
                                        ),
                                      );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
