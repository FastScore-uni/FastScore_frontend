import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fastscore_frontend/theme/theme_provider.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavButton(
                icon: Icons.file_upload_outlined,
                label: 'Wybierz plik',
                isSelected: currentRoute == '/',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
              _BottomNavButton(
                icon: Icons.music_note_outlined,
                label: 'Moje utwory',
                isSelected: currentRoute == '/my-songs',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/my-songs');
                },
              ),
              _BottomNavButton(
                icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                label: themeProvider.isDarkMode ? 'Jasny' : 'Ciemny',
                isSelected: false,
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
