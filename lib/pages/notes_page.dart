import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fastscore_frontend/services/backend_service.dart';
import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:fastscore_frontend/widgets/html_widget.dart';
import 'package:fastscore_frontend/widgets/split_button.dart';
import 'package:fastscore_frontend/widgets/audio_player_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_saver/file_saver.dart';

class NotesPage extends StatefulWidget {
  final String songTitle;
  final String? songId;

  const NotesPage({
    super.key,
    required this.songTitle,
    this.songId,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {

  final GlobalKey<HtmlWidgetState> htmlWidgetKey = GlobalKey<HtmlWidgetState>();
  int _selectedDownloadIndex = 0;
  List<int>? _audioBytes;
  bool _loading = true;
  bool _audioPlayerError = false;
  String? _errorMessage;

    @override
    void initState() {
      super.initState();
      _loadAudio();
    }

  Future<void> _loadAudio() async {
    final backend = BackendService();

    try {
      await backend.fetchXml();
      
      List<int> wavBytes = [];
      try {
        wavBytes = await backend.convertMidiToWav();
        // Check if the file is suspiciously small (e.g. < 5KB), which might indicate an error or empty file
        if (wavBytes.length < 5 * 1024) {
           debugPrint("Otrzymano podejrzanie mały plik WAV (${wavBytes.length} bytes). Ignorowanie.");
           wavBytes = [];
        }
      } catch (e) {
        debugPrint("Błąd konwersji MIDI: $e");
      }

      if (mounted) {
        setState(() {
          _audioBytes = wavBytes.isNotEmpty ? wavBytes : null;
          _loading = false;
        });
      }

    } catch (e) {
      print("Błąd ładowania audio/XML: $e");
      if (mounted) setState(() => _loading = false);
    }
  }
  
  final List<SplitButtonOption> _downloadOptions = const [
    SplitButtonOption(label: 'Pobierz PDF', icon: Icons.picture_as_pdf),
    SplitButtonOption(label: 'Pobierz XML', icon: Icons.code),
    SplitButtonOption(label: 'Pobierz MIDI', icon: Icons.audio_file),
  ];

  Future<void> saveBytes(String name, String ext, List<int> bytes) async {
    await FileSaver.instance.saveFile(
      name: name,
      fileExtension: ext,
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.other,
    );
  }

  Future<void> _download() async {
    final option = _downloadOptions[_selectedDownloadIndex];
    debugPrint('Downloading: ${option.label}');
    
    if (option.label == 'Pobierz PDF') {
       try {
         final pdfBytes = await BackendService().downloadPdf();
         if (pdfBytes.length < 1024) {
            throw Exception("Wygenerowany PDF jest zbyt mały (${pdfBytes.length} bytes). Prawdopodobnie wystąpił błąd.");
         }
         await saveBytes(widget.songTitle, "pdf", pdfBytes);
       } catch (e) {
         debugPrint("PDF download error: $e");
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Błąd pobierania PDF: $e')),
           );
         }
       }
       return;
    }

    String? url;
    if (option.label == 'Pobierz XML') {
      url = BackendService().xmlUrl;
    } else if (option.label == 'Pobierz MIDI') {
      url = BackendService().midiUrl;
    }

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint('Could not launch $url');
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nie można otworzyć linku: $url')),
            );
        }
      }
    } else {
        debugPrint('URL is empty');
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link do pliku nie jest dostępny')),
            );
        }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Przetwarzanie pliku audio..."),
            ],
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    return ResponsiveLayout(
      showNavigation: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: Column(
          children: [
            // Top bar with title and actions
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        tooltip: 'Powrót',
                      ),
                      const SizedBox(width: 16),
                      // Song title
                      Expanded(
                        child: Text(
                          widget.songTitle,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Split download button
                      SplitButton(
                        label: _downloadOptions[_selectedDownloadIndex].label,
                        icon: Icons.download,
                        onPressed: _download,
                        options: _downloadOptions,
                        selectedIndex: _selectedDownloadIndex,
                        onOptionSelected: (index) {
                          debugPrint('NotesPage: onOptionSelected called with index: $index');
                          setState(() {
                            _selectedDownloadIndex = index;
                          });
                          debugPrint('NotesPage: _selectedDownloadIndex updated to: $_selectedDownloadIndex');
                        },
                      ),
                    ],
                  ),
                ),
                // Notes display area
                Expanded(
                  child: Center(
                      child: HtmlWidget(
                        key: htmlWidgetKey,
                        xmlContent: BackendService().xmlContent,
                      ),
                    ),
                ),
                // Audio player at the bottom
                if (!_audioPlayerError)
                  Builder(
                    builder: (context) {
                      try {
                        return AudioPlayerBar(
                          songTitle: widget.songTitle,
                          audioBytes: _audioBytes,
                          audioUrl: BackendService().audioUrl.isNotEmpty ? BackendService().audioUrl : null,
                        );
                      } catch (e) {
                        debugPrint('Error rendering AudioPlayerBar: $e');
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _audioPlayerError = true);
                          }
                        });
                        return const SizedBox.shrink();
                      }
                    },
                  )
                else
                  Container(
                    height: 96,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Audio player unavailable',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _errorMessage!.length > 50 
                                ? '${_errorMessage!.substring(0, 50)}...' 
                                : _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
  }
}