import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AuthPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWebWidth = 400.0;
    final double finalWidth = screenWidth > maxWebWidth ? maxWebWidth : screenWidth;

    return SizedBox(
      width: finalWidth,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ), child: Text(label),
      ),
    );
  }
}