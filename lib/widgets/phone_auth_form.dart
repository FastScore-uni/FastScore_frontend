import 'package:fastscore_frontend/widgets/auth_primary_button.dart';
import 'package:fastscore_frontend/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

import '../utils/validators.dart';

class PhoneAuthForm extends StatefulWidget{
  final Function(String phoneNumber) onSendCode;
  final Function(String otpCode) onVerifyCode;

  const PhoneAuthForm({
    super.key,
    required this.onSendCode,
    required this.onVerifyCode
  });

  @override
  State<StatefulWidget> createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm>{
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose(){
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleMainButton() {
    if (!_formKey.currentState!.validate()) return;

    if (!_codeSent) {
      widget.onSendCode(_phoneController.text);
      setState(() => _codeSent = true);
    } else {
      widget.onVerifyCode(_otpController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [

          AuthTextField(
              controller: _phoneController,
              label: 'Numer telefonu',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
          ),

          if (_codeSent) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _otpController,
              label: 'Kod SMS',
              icon: Icons.sms,
              keyboardType: TextInputType.number,
              validator: Validators.required,
            ),
          ],

          const SizedBox(height: 24),
          AuthPrimaryButton(
              onPressed: _handleMainButton,
              label: _codeSent ? 'Zaloguj się' : 'Wyślij kod'
          ),

          if (_codeSent) ... [
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => setState(() => _codeSent = false),
              child: const Text("Zmień numer telefonu"),
            )
          ]
        ],
      ),
    );
  }
}