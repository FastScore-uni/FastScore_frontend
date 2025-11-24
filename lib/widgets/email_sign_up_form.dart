import 'package:flutter/material.dart';
import '../utils/validators.dart';
import 'auth_primary_button.dart';
import 'auth_text_field.dart';

class EmailSignUpForm extends StatefulWidget{
  final Function(String email, String password) onSignUp;

  const EmailSignUpForm({
    super.key,
    required this.onSignUp,
  });

  @override
  State<StatefulWidget> createState() => _EmailSignUpFormState();
}

class _EmailSignUpFormState extends State<EmailSignUpForm>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSignUp(_emailController.text, _passwordController.text);
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

          const SizedBox(height: 16),

          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Powtórz hasło',
            icon: Icons.lock,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            validator: (value) => Validators.confirmPassword(value, _passwordController.text),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(onPressed: _submit, label: 'Utwórz konto'),
        ],
      ),
    );
  }
}