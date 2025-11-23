import 'package:fastscore_frontend/widgets/auth_option_button.dart';
import 'package:flutter/material.dart';
import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fastscore_frontend/models/auth_view.dart';

class AuthPage extends StatefulWidget{
  final AuthView initialView;
  const AuthPage({super.key, this.initialView = AuthView.emailLogin});

  @override
  State<AuthPage> createState() => _AuthPage();
}

class _AuthPage extends State<AuthPage> {
  late AuthView _currentView;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
  }

  bool get _isResetPassword => _currentView == AuthView.phoneResetPassword;
  bool get _showGoogle => !_isResetPassword;
  bool get _showUsePhoneButton =>
      _currentView == AuthView.emailLogin || _currentView == AuthView.emailSignUp;
  bool get _showUseEmailButton =>
      _currentView == AuthView.phoneLoginOrSignUp;
  bool get _showLoginButton => _currentView == AuthView.emailSignUp;
  bool get _showSignUpButton => _currentView == AuthView.emailLogin;

  void _switchToPhone() => setState(() => _currentView = AuthView.phoneLoginOrSignUp);
  void _switchToEmail() => setState(() => _currentView = AuthView.emailLogin);
  void _switchToSignUp() => setState(() => _currentView = AuthView.emailSignUp);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ResponsiveLayout(
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24 : 48,
                horizontal: 16,
              ),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 24 : 48),
                  // logo
                  Image.asset(
                      'assets/images/logo.png',
                    height: 72,
                  ),
                  SizedBox(height: isMobile ? 12 : 24),
                  Text(
                    'FastScore',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ),
                  SizedBox(height: isMobile ? 12 : 24),

                  if (_showGoogle)...[
                    AuthOptionButton(
                        onPressed: (){},
                        icon: FontAwesomeIcons.google,
                        label: 'Kontynuuj z Google',
                    ),
                    SizedBox(height: 18),
                  ],

                  if (_showUsePhoneButton)...[
                    AuthOptionButton(
                      onPressed: (){
                        debugPrint('logowanie telefonem');
                        _switchToPhone();
                      },
                      icon: Icons.phone,
                      label: 'Użyj telefonu',
                    ),
                    SizedBox(height: 18),
                  ],

                  if (_showUseEmailButton)...[
                    AuthOptionButton(
                      onPressed: (){
                        debugPrint('logowanie email');
                        _switchToEmail();
                      },
                      icon: Icons.phone,
                      label: 'Użyj emaila',
                    ),
                    SizedBox(height: 18),
                  ],


                  if (_showLoginButton) ... [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Masz już konto? ",
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('Kliknięto logowanie!');
                            setState(() {
                              _currentView = AuthView.emailLogin;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Zaloguj się",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (_showSignUpButton) ... [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Nie masz konta? ",
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('Kliknięto rejestracje!');
                            _switchToSignUp();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Utwórz konto",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          )
    ));
  }
}