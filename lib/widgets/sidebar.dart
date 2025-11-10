import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fastscore_frontend/theme/theme_provider.dart';
import 'package:fastscore_frontend/providers/sidebar_provider.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sidebarProvider = Provider.of<SidebarProvider>(context);
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarProvider.isOpen ? 100 : 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: sidebarProvider.isOpen
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Burger menu button - always visible
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.menu),
              tooltip: sidebarProvider.isOpen ? 'Close menu' : 'Open menu',
              onPressed: () => sidebarProvider.toggle(),
            ),
          ),
          if (sidebarProvider.isOpen) ...[
            const SizedBox(height: 16),
            // Music Page button
            _SidebarButton(
              icon: Icons.file_upload_outlined,
              label: 'Wybierz\nplik',
              isSelected: currentRoute == '/',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            const SizedBox(height: 8),
            // My Songs button
            _SidebarButton(
              icon: Icons.music_note_outlined,
              label: 'Moje\nutwory',
              isSelected: currentRoute == '/my-songs',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/my-songs');
              },
            ),
            const Spacer(),
            // Theme toggle button
            _SidebarButton(
              icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              label: themeProvider.isDarkMode ? 'Jasny' : 'Ciemny',
              isSelected: false,
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
