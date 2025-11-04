import 'package:fastscore_frontend/xml_loader.dart';
import 'package:flutter/material.dart';
import 'package:fastscore_frontend/widgets/sidebar.dart';
import 'package:fastscore_frontend/widgets/file_drop_zone.dart';


class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showNotes() {
    final title = _titleController.text.isEmpty 
        ? 'Utwór bez tytułu' 
        : _titleController.text;
    
    Navigator.of(context).pushNamed(
      '/notes',
      arguments: {
        'title': title,
      },
    );
  }

  void _startRecording() {
    debugPrint("Start recording...");
    // TODO: podłącz pakiet `record` albo `flutter_sound`
  }

  void _handleFileDropped(String fileName, List<int> fileData) {
    XmlLoader().setFile(fileName, fileData);
    setState(() {
      // Handle file dropped
    });
    debugPrint("Plik upuszczony: $fileName, Rozmiar: ${fileData.length} bajtów");
  }

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
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title input field
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Nazwa twojego utworu',
                              hintText: 'Nazwa utworu',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _titleController.clear();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // File drop zone card
                          SizedBox(
                            height: 250,
                            child: FileDropZone(
                              onFileDropped: _handleFileDropped,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Action buttons
                          FilledButton.icon(
                            onPressed: () {
                              _showNotes();// Show notes action
                            },
                            icon: const Icon(Icons.music_note),
                            label: const Text('Wyświetl nuty'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            'lub',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),

                          FilledButton.icon(
                            onPressed: () {
                              _startRecording();// Record action
                            },
                            icon: const Icon(Icons.mic_sharp),
                            label: const Text('Nagraj utwór teraz'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
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