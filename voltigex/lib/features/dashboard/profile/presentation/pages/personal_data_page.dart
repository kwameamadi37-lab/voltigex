import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_bloc.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_state.dart';
import 'package:voltigex/l10n/app_localizations.dart';
import 'package:voltigex/features/dashboard/profile/presentation/localization/profile_error_localizer.dart';

/// Coordonnées : e-mail et téléphone (PUT /api/user/contact).
class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileData());
  }

  @override
  void dispose() {
    _mailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncFromUser(ProfileLoaded state) {
    final u = state.user;
    if (_mailController.text != u.email) {
      _mailController.text = u.email;
    }
    if (_phoneController.text != u.phone) {
      _phoneController.text = u.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              c is ProfileLoaded && p is ProfileSubmittingContact,
          listener: (context, state) {
            _syncFromUser(state as ProfileLoaded);
            final t = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              t.personalDataUpdatedSnackbarBody,
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
              (p is ProfileSubmittingContact ||
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
          final loading = state is ProfileLoading;
          final submitting = state is ProfileSubmittingContact;
          final l10n = AppLocalizations.of(context)!;

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
                      l10n.personalDataTitle,
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
                                l10n.personalDataContactsSection,
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
                                label: l10n.personalDataPhoneLabel,
                                hintText: '',
                                controller: _phoneController,
                                inputType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.formValidatorFillField;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              BuildLabeledTextField(
                                label: l10n.personalDataEmailLabel,
                                hintText: '',
                                controller: _mailController,
                                inputType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.formValidatorFillField;
                                  }
                                  final v = value.trim();
                                  if (!RegExp(
                                    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                                  ).hasMatch(v)) {
                                    return l10n.formValidatorEmailInvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 25),
                              FormsButton(
                                text: submitting
                                    ? l10n.formButtonUpdating
                                    : l10n.formButtonUpdate,
                                isBusy: submitting,
                                onPressed: () {
                                        if (!(_formKey.currentState
                                                ?.validate() ??
                                            false)) {
                                          return;
                                        }
                                        context.read<ProfileBloc>().add(
                                              UpdateContactSubmitted(
                                                email: _mailController.text
                                                    .trim(),
                                                phone: _phoneController.text
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
