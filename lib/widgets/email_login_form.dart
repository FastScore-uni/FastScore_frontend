import 'package:fastscore_frontend/widgets/auth_primary_button.dart';
import 'package:fastscore_frontend/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

import '../utils/validators.dart';

class EmailLoginForm extends StatefulWidget{
  final Function(String email, String password) onLogin;
  final VoidCallback onForgotPassword;

  const EmailLoginForm({
    super.key,
    required this.onLogin,
    required this.onForgotPassword
  });

  @override
  State<StatefulWidget> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLoginForm>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(_emailController.text, _passwordController.text);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
          ),

          const SizedBox(height: 16),

          AuthTextField(
            controller: _passwordController,
            label: 'Hasło',
            icon: Icons.lock,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            validator: Validators.password,
          ),

          SizedBox(
            width: 400,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onForgotPassword,
                child: const Text('Nie pamiętasz hasła?'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(onPressed: _submit, label: 'Zaloguj się'),
        ],
      ),
    );
  }
}