import 'package:fastscore_frontend/widgets/auth_option_button.dart';
import 'package:flutter/material.dart';

import '../utils/validators.dart';
import 'auth_primary_button.dart';

class ResetPasswordForm extends StatefulWidget{
  final Function(String email) onReset;
  final VoidCallback onBack;

  const ResetPasswordForm({
    super.key,
    required this.onReset,
    required this.onBack
  });

  @override
  State<StatefulWidget> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onReset(_emailController.text);
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
          const SizedBox(height: 24),
          AuthPrimaryButton(onPressed: _submit, label: 'Wyślij'),
          const SizedBox(height: 18),
          AuthOptionButton(onPressed: widget.onBack, icon: Icons.arrow_back, label: 'Wróć'),
        ],
      ),
    );
  }
}