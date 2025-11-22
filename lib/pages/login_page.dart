import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Duration get loadingTime => const Duration(milliseconds: 1000);

  Future<String?> _authUser(LoginData data){
    return Future.delayed(loadingTime).then((value) => null);
  }

  Future<String?> _recoverUserPassword(String data){
    return Future.delayed(loadingTime).then((value) => null);
  }

  Future<String?> _signupUser(SignupData data){
    return Future.delayed(loadingTime).then((value) => null);
  }


  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(child: Scaffold(
      body: FlutterLogin(
          onLogin: _authUser,
          onRecoverPassword: _recoverUserPassword,
          onSignup: _signupUser,
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