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

class SecurityPasswordPage extends StatefulWidget {
  const SecurityPasswordPage({super.key});

  @override
  State<SecurityPasswordPage> createState() => _SecurityPasswordPageState();
}

class _SecurityPasswordPageState extends State<SecurityPasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _actualPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  /// Visibilité pour « Nouveau » et « Confirmer » (liées au même booléen).
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _actualPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              p is ProfileSubmittingPassword && c is ProfileLoaded,
          listener: (context, state) {
            _actualPasswordController.clear();
            _newPasswordController.clear();
            _confirmNewPasswordController.clear();
            final t = AppLocalizations.of(context)!;
            TopSnackBar.show(
              context,
              t.securityPasswordSuccessSnackbarBody,
              type: TopSnackBarType.success,
              title: t.securityPasswordSuccessSnackbarTitle,
              durationSeconds: 4,
            );
            Navigator.of(context).pop();
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (p, c) =>
              c is ProfileError &&
              ((p is ProfileSubmittingPassword) || (p is ProfileLoaded)),
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
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: DefaultColors.whiteText,
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
                    l10n.securityPasswordTitle,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: DefaultColors.blackColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            BuildLabeledTextField(
                              label: l10n.securityPasswordCurrentLabel,
                              hintText: '',
                              controller: _actualPasswordController,
                              obscureText: true,
                              maxLines: 1,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.formValidatorFillField;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            BuildLabeledTextField(
                              label: l10n.securityPasswordNewLabel,
                              hintText: '',
                              controller: _newPasswordController,
                              obscureText: !_isPasswordVisible,
                              maxLines: 1,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible =
                                        !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: DefaultColors.greyText,
                                  size: 22,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.formValidatorFillField;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            BuildLabeledTextField(
                              label: l10n.securityPasswordConfirmLabel,
                              hintText: '',
                              controller: _confirmNewPasswordController,
                              obscureText: !_isPasswordVisible,
                              maxLines: 1,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible =
                                        !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: DefaultColors.greyText,
                                  size: 22,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.formValidatorFillField;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 25),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              buildWhen: (p, c) =>
                                  c is ProfileSubmittingPassword ||
                                  p is ProfileSubmittingPassword,
                              builder: (context, state) {
                                final busy =
                                    state is ProfileSubmittingPassword;
                                return FormsButton(
                                  text: busy
                                      ? l10n.formButtonUpdating
                                      : l10n.securityPasswordUpdateButton,
                                  isBusy: busy,
                                  onPressed: () {
                                          if (!(formKey.currentState
                                                  ?.validate() ??
                                              false)) {
                                            return;
                                          }
                                          context.read<ProfileBloc>().add(
                                                UpdatePasswordSubmitted(
                                                  currentPassword:
                                                      _actualPasswordController
                                                          .text,
                                                  newPassword:
                                                      _newPasswordController
                                                          .text,
                                                  confirmPassword:
                                                      _confirmNewPasswordController
                                                          .text,
                                                ),
                                              );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
