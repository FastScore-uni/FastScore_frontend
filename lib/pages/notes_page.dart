import 'dart:convert';
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

    @override
    void initState() {
      super.initState();
      _loadAudio();
    }

  Future<void> _loadAudio() async {
    final backend = BackendService();

    try {
      await backend.fetchXml();
      final wavBytes = await backend.convertMidiToWav();
      setState(() {
        _audioBytes = wavBytes;
        _loading = false;
      });

    } catch (e) {
      print("Błąd ładowania audio/XML: $e");
      setState(() => _loading = false);
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
    
    // ---------------------------------
    // WERSJA DLA LOKALNEGO BACKENDU
    // ---------------------------------

  // final backend = BackendService();
  // try {
  //   if (_selectedDownloadIndex == 0) {
  //     final pdfBytes = await backend.downloadPdf();
  //     await saveBytes(widget.songTitle, "pdf", pdfBytes);
  //   } 
  //   else if (_selectedDownloadIndex == 1) {
  //     final xmlBytes = utf8.encode(BackendService().xmlContent);
  //     await saveBytes(widget.songTitle, "musicxml", xmlBytes);
  //   } 
  //   else if (_selectedDownloadIndex == 2) {
  //     await saveBytes(widget.songTitle, "midi", backend.midiBytes);
  //   }

  //   } catch (e) {
  //     print("Błąd pobierania: $e");
  //   }
  // }

    String? url;
    if (option.label == 'Pobierz XML') {
      url = BackendService().xmlUrl;
    } else if (option.label == 'Pobierz MIDI') {
      url = BackendService().midiUrl;
    } else if (option.label == 'Pobierz PDF') {
       debugPrint('PDF download not yet supported');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Pobieranie PDF nie jest jeszcze dostępne')),
         );
       }
       return;
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
                AudioPlayerBar(
                  songTitle: widget.songTitle,
                  audioBytes: _audioBytes,
                ),
              ],
            ),
          ),
        );
  }
}