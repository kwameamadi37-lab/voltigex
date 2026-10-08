import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltigex/core/theme.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_event.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_state.dart';
import 'package:voltigex/features/auth/presentation/localization/auth_error_localizer.dart';
import 'package:voltigex/core/session_controller.dart';
import 'package:voltigex/features/auth/presentation/widgets/auth_button.dart';
import 'package:voltigex/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:voltigex/features/auth/presentation/widgets/login_prompt.dart';
import 'package:voltigex/core/constants.dart';
import 'package:voltigex/features/dashboard/profile/presentation/pages/legal_web_view_page.dart';
import 'package:voltigex/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    BlocProvider.of<AuthBloc>(context).add(
        LoginEvent(
            email: _emailController.text,
            password: _passwordController.text
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image(
                  image: AssetImage("assets/images/app_launcher.png"),
                  height: MediaQuery.of(context).size.height * 0.15
                ),
                SizedBox(height: 50,),
                Center(
                  child: Text(
                    l10n.loginTitle,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 45.5,
                        color: DefaultColors.blueBackground,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AuthInputField(
                  hint: l10n.loginHintEmail,
                  icon: Icons.person,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  hint: l10n.loginHintPassword,
                  icon: Icons.lock,
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => LegalWebViewPage(
                            url: '${Constants.backendServerAddress}/password/reset',
                            title: l10n.loginForgotPassword,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      l10n.loginForgotPassword,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: DefaultColors.blueBackground,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BlocConsumer<AuthBloc, AuthState>(
                  listenWhen: (prev, curr) =>
                      curr is AuthSuccess || curr is AuthFailure,
                  builder: (context, state) {
                    return AuthButton(
                      text: l10n.loginButton,
                      onPressed: _onLogin,
                      isBusy: state is AuthLoading,
                    );
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      final next = SessionController.instance.isAdminSupport
                          ? '/conversationPage'
                          : '/navigationPage';
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        next,
                        (route) => false,
                      );
                    } else if (state is AuthFailure) {
                      final t = AppLocalizations.of(context)!;
                      
                      // Assure que le widget tree est stable avant d'insérer dans l'Overlay
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        TopSnackBar.show(
                          context,
                          localizeAuthError(t, state.error),
                          type: TopSnackBarType.error,
                          title: t.loginErrorSnackbarTitle,
                        );
                      });
                    // }
                    }
                  },
                ),
                const SizedBox(height: 24),
                LoginPrompt(
                  title: l10n.loginRegisterPromptTitle,
                  subtitle: l10n.loginRegisterPromptSubtitle,
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
