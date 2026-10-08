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

class AddressVerificationPage extends StatefulWidget {
  const AddressVerificationPage({super.key});

  @override
  State<AddressVerificationPage> createState() =>
      _AddressVerificationPageState();
}

class _AddressVerificationPageState extends State<AddressVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressLineController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileData());
  }

  @override
  void dispose() {
    _addressLineController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _syncFromUser(ProfileLoaded state) {
    final u = state.user;
    if (_addressLineController.text != u.addressLine) {
      _addressLineController.text = u.addressLine;
    }
    if (_countryController.text != u.country) {
      _countryController.text = u.country;
    }
    if (_cityController.text != u.city) {
      _cityController.text = u.city;
    }
    if (_zipController.text != u.postalCode) {
      _zipController.text = u.postalCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              c is ProfileLoaded && p is ProfileSubmittingAddress,
          listener: (context, state) {
            _syncFromUser(state as ProfileLoaded);
            final t = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              t.addressSavedSnackbarBody,
              type: TopSnackBarType.success,
              title: t.addressSavedSnackbarTitle,
            );
            Navigator.of(context).pop();
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
              (p is ProfileSubmittingAddress ||
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
          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                      l10n.addressVerificationTitle,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: DefaultColors.blackColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                             
                              BuildLabeledTextField(
                                label: l10n.fieldCountry,
                                hintText: '',
                                controller: _countryController,
                                maxLines: 1,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? l10n.formValidatorRequired
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              BuildLabeledTextField(
                                label: l10n.fieldCity,
                                hintText: '',
                                controller: _cityController,
                                maxLines: 1,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? l10n.formValidatorRequired
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              BuildLabeledTextField(
                                label: l10n.fieldStreet,
                                hintText: '',
                                controller: _addressLineController,
                                maxLines: 2,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? l10n.formValidatorRequired
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              BuildLabeledTextField(
                                label: l10n.fieldPostalCode,
                                hintText: '',
                                controller: _zipController,
                                maxLines: 1,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? l10n.formValidatorRequired
                                        : null,
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<ProfileBloc, ProfileState>(
                                buildWhen: (p, c) =>
                                    c is ProfileSubmittingAddress ||
                                    p is ProfileSubmittingAddress,
                                builder: (context, state) {
                                  final busy =
                                      state is ProfileSubmittingAddress;
                                  return SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: busy
                                          ? null
                                          : () {
                                              if (!(_formKey.currentState
                                                      ?.validate() ??
                                                  false)) {
                                                return;
                                              }
                                              context
                                                  .read<ProfileBloc>()
                                                  .add(
                                                    UpdateAddressSubmitted(
                                                      addressLine:
                                                          _addressLineController
                                                              .text
                                                              .trim(),
                                                      country:
                                                          _countryController
                                                              .text
                                                              .trim(),
                                                      city: _cityController
                                                          .text
                                                          .trim(),
                                                      zipCode: _zipController
                                                          .text
                                                          .trim(),
                                                    ),
                                                  );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            DefaultColors.blueBackground,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: busy
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: loader(
                                                      compact: true,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  l10n.formButtonSaving,
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              l10n.formButtonSave,
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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
