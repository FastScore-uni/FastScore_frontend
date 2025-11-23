import 'package:flutter/material.dart';

class AuthOptionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const AuthOptionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWebWidth = 400.0;
    final double finalWidth = screenWidth > maxWebWidth ? maxWebWidth : screenWidth;

    return SizedBox(
      width: finalWidth,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        label: Text(label),
      ),
    );
  }
}