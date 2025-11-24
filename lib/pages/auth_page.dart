import 'package:fastscore_frontend/widgets/auth_option_button.dart';
import 'package:fastscore_frontend/widgets/auth_switch_row.dart';
import 'package:flutter/material.dart';
import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fastscore_frontend/models/auth_view.dart';
import 'package:fastscore_frontend/widgets/email_login_form.dart';
import 'package:fastscore_frontend/widgets/email_sign_up_form.dart';
import 'package:fastscore_frontend/widgets/phone_auth_form.dart';
import 'package:fastscore_frontend/widgets/reset_password_form.dart';

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

  bool get _isResetPassword => _currentView == AuthView.emailResetPassword;
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

  void _signInWithGoogle() {
    debugPrint("Logowanie przez Google...");
    // Logowanie z Google
  }

  Widget _buildCurrentForm() {
    switch (_currentView) {
      case AuthView.emailLogin:
        return EmailLoginForm(
          onLogin: (email, password) {
            debugPrint("LOGOWANIE: $email / $password");
            // logowanie z firebase
          },
          onForgotPassword: () {
            setState(() => _currentView = AuthView.emailResetPassword);
          },
        );

      case AuthView.emailSignUp:
        return EmailSignUpForm(
          onSignUp: (email, password) {
            debugPrint("REJESTRACJA: $email / $password");
            // rejestracja z firebase
          },
        );

      case AuthView.phoneLoginOrSignUp:
        return PhoneAuthForm(
          onSendCode: (phone) {
            debugPrint("WYSYŁANIE KODU NA: $phone");
          },
          onVerifyCode: (otp) {
            debugPrint("WERYFIKACJA KODU: $otp");
          },
        );

      case AuthView.emailResetPassword:
        return ResetPasswordForm(
          onReset: (email) {
            debugPrint("RESET HASŁA DLA: $email");
            // resetowanie hasła z firebase
          },
          onBack: () {
            setState(() => _currentView = AuthView.emailLogin);
          },
        );
    }
  }

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
                  _buildCurrentForm(),

                  SizedBox(height: 18),

                  if (_showGoogle)...[
                    AuthOptionButton(
                        onPressed: _signInWithGoogle,
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
                    AuthSwitchRow(
                        prompt: 'Masz już konto?',
                        actionLabel: 'Zaloguj się',
                        onActionTap: (){
                          debugPrint('Przełączanie na logowanie');
                          _switchToEmail();
                        }
                    )
                  ],

                  if (_showSignUpButton) ... [
                    AuthSwitchRow(
                        prompt: 'Nie masz konta?',
                        actionLabel: 'Utwórz konto',
                        onActionTap: (){
                          debugPrint('Przełączanie na rejstrację');
                          _switchToSignUp();
                        }
                    )
                  ],
                ],
              ),
            ),
          )
    ));
  }
}