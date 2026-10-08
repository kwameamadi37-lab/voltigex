import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/locale/locale_cubit.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/core/widgets/custom_user_avatar.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/language_selection_page.dart';
import 'package:voltigex/features/dashboard/shell/presentation/helpers/support_chat_tab_opener.dart';
import 'package:voltigex/l10n/app_localizations.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_bloc.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_event.dart';
import 'package:voltigex/features/dashboard/profile/presentation/bloc/profile_state.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/address_verification_page.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/cards_history_page.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/legal_documentation_page.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/personal_data_page.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/profile_page.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/security_password_page.dart';

const Color _kProfilBg = Color(0xFFF5F6F8);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kSectionLabel = Color(0xFF6B7280);
const Color _kLogoutPink = Color(0xFFFEE2E2);
const Color _kLogoutRed = Color(0xFFDC2626);

Color _mintCircle(BuildContext context) =>
    DefaultColors.blueBackground.withValues(alpha: 0.2);

String _languageDisplayName(AppLocalizations t, Locale loc) {
  switch (loc.languageCode) {
    case 'fr':
      return t.languageNameFr;
    case 'en':
      return t.languageNameEn;
    case 'es':
      return t.languageNameEs;
    case 'de':
      return t.languageNameDe;
    default:
      return t.languageNameFr;
  }
}

/// Paramètres / profil (consomme [ProfileBloc]).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (p, c) =>
          c is ProfileLogoutSuccess ||
          (c is ProfileError &&
              p is! ProfileSubmittingPassword &&
              p is! ProfileSubmittingAddress &&
              p is! ProfileSubmittingContact &&
              p is! ProfileSubmittingIdentity),
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          });
        } else if (state is ProfileError) {
          final t = AppLocalizations.of(context)!;
          TopSnackBar.show(
            context,
            state.message,
            type: TopSnackBarType.error,
            title: t.errorTitle,
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final displayName = state is ProfileLoaded
              ? state.user.displayName
              : l10n.settingsNamePlaceholder;
          final profilePhotoUrl =
              state is ProfileLoaded ? state.user.profilePhotoUrl : null;
          final profileRole =
              state is ProfileLoaded && state.user.role.trim().isNotEmpty
                  ? state.user.role
                  : null;

          return Scaffold(
            backgroundColor: _kProfilBg,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  const SizedBox(height: 28),
                  Center(
                    child: CustomUserAvatar(
                      profilePhotoUrl: profilePhotoUrl,
                      role: profileRole,
                      radius: 34,
                      backgroundColor: Colors.grey.shade200
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 22.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _SectionTitle(label: l10n.settingsDocumentsSection),
                  _WhiteCard(
                    children: [
                      _ProfileMenuRow(
                        title: l10n.settingsMenuDocuments,
                        icon: Icons.description_outlined,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: const AddressVerificationPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(label: l10n.settingsGeneralSection),
                  _WhiteCard(
                    children: [
                      BlocBuilder<LocaleCubit, Locale>(
                        builder: (context, loc) {
                          return _ProfileMenuRow(
                            title: l10n.settingsLanguage,
                            subtitle: _languageDisplayName(l10n, loc),
                            icon: Icons.public_rounded,
                            iconColor: DefaultColors.blueBackground,
                            circleColor: _mintCircle(context),
                            onTap: () {
                              Navigator.of(context, rootNavigator: false).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LanguageSelectionPage(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      _rowDivider(),
                      _ProfileMenuRow(
                        title: l10n.settingsMenuProfile,
                        icon: Icons.person_outline_rounded,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: const ProfilePage(),
                              ),
                            ),
                          );
                        },
                      ),
                      _rowDivider(),
                      _ProfileMenuRow(
                        title: l10n.settingsMenuContact,
                        icon: Icons.badge_outlined,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: const PersonalDataPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      _rowDivider(),
                      _ProfileMenuRow(
                        title: l10n.settingsMenuReportProblem,
                        icon: Icons.flag_outlined,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () => openSupportChatInMainTab(context),
                      ),
                      _rowDivider(),
                      _ProfileMenuRow(
                        title: l10n.settingsMenuCardsHistory,
                        icon: Icons.manage_history_rounded,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CardsHistoryPage(),
                            ),
                          );
                        },
                      ),
                      _rowDivider(),
                      _ProfileMenuRow(
                        title: l10n.settingsMenuLegal,
                        icon: Icons.info_outline_rounded,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LegalDocumentationPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(label: l10n.settingsSecuritySection),
                  _WhiteCard(
                    children: [
                      _ProfileMenuRow(
                        title: l10n.settingsMenuPassword,
                        icon: Icons.lock_outline_rounded,
                        iconColor: DefaultColors.blueBackground,
                        circleColor: _mintCircle(context),
                        onTap: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: const SecurityPasswordPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(label: l10n.settingsAccountSection),
                  _WhiteCard(
                    children: [
                      _ProfileMenuRow(
                        title: l10n.settingsMenuLogout,
                        icon: Icons.logout_rounded,
                        iconColor: _kLogoutRed,
                        circleColor: _kLogoutPink,
                        busy: state is ProfileLogoutLoading,
                        onTap: state is ProfileLogoutLoading
                            ? null
                            : () => context.read<ProfileBloc>().add(LogoutRequested()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compatibilité avec l’ancien nom d’onglet.
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) => const SettingsPage();
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _kSectionLabel,
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

Widget _rowDivider() => Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
    this.onTap,
    this.busy = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: busy
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: loader(compact: true, color: iconColor),
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: onTap == null && !busy
                              ? DefaultColors.greyText
                              : _kTextPrimary,
                        ),
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: DefaultColors.greyText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade500,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
