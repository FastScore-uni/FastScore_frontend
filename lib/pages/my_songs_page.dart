import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fastscore_frontend/widgets/sidebar.dart';
import 'package:fastscore_frontend/providers/sidebar_provider.dart';

class MySongsPage extends StatelessWidget {
  const MySongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebarProvider = Provider.of<SidebarProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  elevation: 0,
                  title: const Text('Moje utwory'),
                  leading: sidebarProvider.isOpen
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => sidebarProvider.open(),
                          tooltip: 'Open menu',
                        ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note_outlined,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Moje utwory',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Twoje zapisane utwory pojawią się tutaj',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Placeholder for song list
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Lista utworów będzie tutaj',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
