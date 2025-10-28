import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fastscore_frontend/widgets/sidebar.dart';
import 'package:fastscore_frontend/widgets/song_item.dart';


class MySongsPage extends StatelessWidget {
  const MySongsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      children: [
                      SongItem(
                            date: '2025-10-20',
                            title: 'Poranny blask',
                            duration: '3:20',
                            format: 'wav',
                            color: Colors.green.shade200,
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Poranny blask',
                                  'songId': 'song_1',
                                },
                              );
                            },
                          ),
                          SongItem(
                            date: '2025-10-15',
                            title: 'Taniec liści',
                            duration: '1:24',
                            format: 'mp3',
                            color: Colors.orange.shade200,
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Taniec liści',
                                  'songId': 'song_2',
                                },
                              );
                            },
                          ),
                          SongItem(
                            date: '2025-10-02',
                            title: 'Mglisty poranek',
                            duration: '0:34',
                            format: 'wav',
                            color: Colors.purple.shade200,
                            isSelected: true,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Mglisty poranek',
                                  'songId': 'song_3',
                                },
                              );
                            },
                          ),
                          SongItem(
                            date: '2025-09-25',
                            title: 'Jesienny dół',
                            duration: '7:05',
                            format: 'wav',
                            color: Colors.grey.shade400,
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Jesienny dół',
                                  'songId': 'song_4',
                                },
                              );
                            },
                          ),
                          SongItem(
                            date: '2025-09-15',
                            title: 'Zgasłe gwiazdy',
                            duration: '2:21',
                            format: 'mp3',
                            color: Colors.lime.shade300,
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Zgasłe gwiazdy',
                                  'songId': 'song_5',
                                },
                              );
                            },
                          ),
                          SongItem(
                            date: '2025-09-05',
                            title: 'Come by the Hills',
                            duration: '1:57',
                            format: 'mp3',
                            color: Colors.yellow.shade200,
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Come by the Hills',
                                  'songId': 'song_6',
                                },
                              );
                            },
                            // Example with image URL (uncomment to test):
                            // imageUrl: 'https://example.com/album-art.jpg',
                          ),
                          SongItem(
                            date: '2025-08-28',
                            title: 'Silent Waves',
                            duration: '4:12',
                            format: 'wav',
                            color: Colors.cyan.shade200,
                            isSelected: false,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/notes',
                                arguments: {
                                  'title': 'Silent Waves',
                                  'songId': 'song_7',
                                },
                              );
                            },
                          ),
                        ],
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
