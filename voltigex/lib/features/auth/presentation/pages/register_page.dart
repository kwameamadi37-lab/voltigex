import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voltigex/core/widgets.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_event.dart';
import 'package:voltigex/features/auth/presentation/bloc/auth_state.dart';
import 'package:voltigex/features/auth/presentation/localization/auth_error_localizer.dart';
import 'package:voltigex/features/auth/presentation/widgets/auth_button.dart';
import 'package:voltigex/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:voltigex/features/auth/presentation/widgets/login_prompt.dart';
import 'package:voltigex/l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    BlocProvider.of<AuthBloc>(context).add(
      RegisterEvent(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
            padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthInputField(hint: l10n.registerHintUsername, icon: Icons.person, controller: _usernameController),
            SizedBox(height: 20,),
            AuthInputField(hint: l10n.registerHintEmail, icon: Icons.email, controller: _emailController),
            SizedBox(height: 20,),
            AuthInputField(hint: l10n.registerHintPassword, icon: Icons.lock, controller: _passwordController),
            SizedBox(height: 20,),
            BlocConsumer<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthButton(
                    text: l10n.registerButton,
                    onPressed: _onRegister,
                    isBusy: state is AuthLoading,
                  );
                },
                listener: (context, state){
                  if(state is AuthSuccess){
                    Navigator.pushNamed(context, '/login');
                  }else if (state is AuthFailure){
                    final t = AppLocalizations.of(context)!;
                    TopSnackBar.show(
                      context,
                      localizeAuthError(t, state.error),
                      type: TopSnackBarType.error,
                      title: t.registerErrorSnackbarTitle,
                    );
                  }
                }
            ),
            SizedBox(height: 20,),
            LoginPrompt(
                title: l10n.registerLoginPromptTitle,
                subtitle: l10n.registerLoginPromptSubtitle,
                onTap: (){
                  Navigator.pushNamed(context, '/login');
                }
            )
          ],
        ),),
      ),
    );
  }
}
