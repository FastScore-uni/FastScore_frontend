import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fastscore_frontend/repositories.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Duration get loadingTime => const Duration(milliseconds: 1000);

  Future<String?> _authUser(BuildContext context, LoginData data){
    return Future.delayed(loadingTime).then((value) => null);
  }

  Future<String?> _recoverUserPassword(BuildContext context, String data){
    return Future.delayed(loadingTime).then((value) => null);
  }

  Future<String?> _signupUser(BuildContext context,SignupData data) async {
    final repo = context.read<UserRepository>();
    await Future.delayed(loadingTime);
    try {
      String login = data.name!.split('@').first;
      await repo.createUser(email: data.name!, password: data.password!, login: login, phone: "");
    } catch (error) {
      return "Rejestracja nieudana";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(child: Scaffold(
      body: FlutterLogin(
          onLogin: (data) => _authUser(context, data),
          onRecoverPassword: (data) => _recoverUserPassword(context, data),
          onSignup: (data) => _signupUser(context, data),
          title: 'FastScore',
        loginProviders: <LoginProvider>[
          LoginProvider(
          icon: FontAwesomeIcons.google,
            label: 'Google',
            callback: () async {
              debugPrint('start google sign in');
              await Future.delayed(loadingTime);
              debugPrint('stop google sign in');
              return null;
            },
          ),
        ],

        messages: LoginMessages(
          loginButton: 'ZALOGUJ SIĘ',
          signupButton: 'ZAREJESTRUJ SIĘ',
          forgotPasswordButton: 'Odzyskaj hasło',

          userHint: 'Email',
          passwordHint: 'Hasło',
          confirmPasswordHint: 'Powtórz hasło',

          signUpSuccess: 'Pomyślnie utworzono konto!',
          recoverPasswordIntro: 'Proszę wprowadzić email użyty przy tworzeniu konta, a my pomożemy Ci ustawić nowe hasło',
          recoverPasswordDescription: 'Wiadomość dotycząca zmiany hasła zostanie wysłana na podany adres email',
          recoverPasswordButton: 'WYŚLIJ',
          goBackButton: 'WRÓĆ',
          providersTitleFirst: 'lub kontynuuj z',

        ),
        theme: LoginTheme(
          primaryColor: Theme.of(context).colorScheme.primary,
          titleStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontFamily: 'Quicksand',
            letterSpacing: 4,
          ),
          cardTheme: CardTheme(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
      ),
    ));
  }
}