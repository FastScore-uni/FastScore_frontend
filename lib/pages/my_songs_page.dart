import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:fastscore_frontend/widgets/song_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastscore_frontend/services/backend_service.dart';


class MySongsPage extends StatelessWidget {
  const MySongsPage({super.key});

  Color _getColor(String? colorName) {
    // Simple mapping or random if needed. 
    // Since backend doesn't save color yet, we can use a default or hash based on title.
    if (colorName == null) return Colors.blue.shade200;
    // Add more logic if needed
    return Colors.blue.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final user = FirebaseAuth.instance.currentUser;
    
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: isMobile ? null : AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Moje utwory'),
        ),
        body: user == null 
          ? const Center(child: Text('Zaloguj się, aby zobaczyć swoje utwory'))
          : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('songs')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, size: 64, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Brak zapisanych utworów',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 12 : 16,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return SongItem(
                      date: data['date'] ?? '',
                      title: data['title'] ?? 'Utwór bez tytułu',
                      duration: data['duration'] ?? '0:00',
                      format: data['format'] ?? 'MP3',
                      color: _getColor(data['color']),
                      isSelected: false,
                      onTap: () {
                        // Update BackendService with the selected song's data
                        final backendService = BackendService();
                        backendService.xmlUrl = data['xmlUrl'] ?? '';
                        backendService.midiUrl = data['midiUrl'] ?? '';
                        backendService.audioUrl = data['audioUrl'] ?? '';
                        backendService.title = data['title'] ?? '';
                        backendService.firestoreId = doc.id;
                        
                        Navigator.of(context).pushNamed(
                          '/notes',
                          arguments: {
                            'title': data['title'] ?? 'Utwór bez tytułu',
                            'songId': doc.id,
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
      ),
    );
  }
}
