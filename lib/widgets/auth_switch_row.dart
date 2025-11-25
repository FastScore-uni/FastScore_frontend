import 'package:flutter/material.dart';

class AuthSwitchRow extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback onActionTap;

  const AuthSwitchRow({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return
      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt),
        SizedBox(width: 2),
        TextButton(
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}