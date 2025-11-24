import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:fastscore_frontend/utils/validators.dart';
import 'package:fastscore_frontend/widgets/auth_primary_button.dart';
import 'package:fastscore_frontend/widgets/auth_text_field.dart';


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
  final _otpController = TextEditingController();
  bool _codeSent = false;

  String _fullPhoneNumber = '';
  final PhoneNumber _initialNumber = PhoneNumber(isoCode: 'PL');
  bool _isPhoneNumberValid = false;

  @override
  void dispose(){
    _otpController.dispose();
    super.dispose();
  }

  void _handleMainButton() {
    if (!_formKey.currentState!.validate()) return;

    if (!_codeSent) {
      if (_isPhoneNumberValid) {
        widget.onSendCode(_fullPhoneNumber);
        setState(() => _codeSent = true);
      }
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

          SizedBox(
            width: 400,
            child: InternationalPhoneNumberInput(
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              inputDecoration: InputDecoration(
                labelText: 'Numer telefonu',
                icon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: 'np. 123 456 789',
              ),
              errorMessage: 'Nieprawidłowy numer telefonu.',
              isEnabled: !_codeSent,
              initialValue: _initialNumber,
              keyboardType: TextInputType.number,

              onInputChanged: (PhoneNumber number) {
                _fullPhoneNumber = number.phoneNumber ?? '';
              },

              onInputValidated: (bool isValid) {
                setState(() {
                  _isPhoneNumberValid = isValid;
                });
              },
            ),
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