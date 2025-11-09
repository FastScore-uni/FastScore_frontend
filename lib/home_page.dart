import 'package:flutter/material.dart';
import 'package:fastscore_frontend/widgets/sidebar.dart';
import 'package:fastscore_frontend/widgets/file_drop_zone.dart';
import 'package:fastscore_frontend/widgets/html_widget.dart';
import 'package:fastscore_frontend/widgets/audio_recorder.dart';


class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final GlobalKey<HtmlWidgetState> htmlWidgetKey = GlobalKey<HtmlWidgetState>();
  final TextEditingController _titleController = TextEditingController();
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  bool _isDataReady = false;

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
    setState(() {
      _isRecording = true;
    });
    // TODO: podłącz pakiet `record` albo `flutter_sound`
  }

  void _stopRecording(){
    debugPrint("Stop recording...");
    setState(() {
      _isRecording = false;
      _isDataReady = true;
    });
  }


  void _handleFileDropped(String fileName, List<int> fileData) {
    htmlWidgetKey.currentState?.process(null);
    setState(() {
      // Handle file dropped
    });
    debugPrint("Plik upuszczony: $fileName, Rozmiar: ${fileData.length} bajtów");
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final hours = d.inHours;

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
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

                          Text(
                            _isRecording  ? ' ' : 'lub',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),

                          AudioRecorder(
                            onStart: _startRecording,
                            onStop: _stopRecording,

                            isRecording: _isRecording,
                            recordDuration: _recordDuration,

                            isDataReady: _isDataReady,

                            formatDuration: _formatDuration,
                          ),
                          const SizedBox(height: 24),

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