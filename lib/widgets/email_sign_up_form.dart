import 'package:flutter/material.dart';
import '../utils/validators.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Hasło', prefixIcon: Icon(Icons.lock)),
            obscureText: true,
            validator: Validators.password,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Text('Zaloguj się'),
          ),
        ],
      ),
    );
  }
}