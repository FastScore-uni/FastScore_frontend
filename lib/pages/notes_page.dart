import 'package:flutter/material.dart';
import 'package:fastscore_frontend/widgets/sidebar.dart';
import 'package:fastscore_frontend/widgets/html_widget.dart';
import 'package:fastscore_frontend/widgets/split_button.dart';
import 'package:fastscore_frontend/widgets/audio_player_bar.dart';

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
  bool _isPlaying = false;
  
  final List<SplitButtonOption> _downloadOptions = const [
    SplitButtonOption(label: 'Pobierz PDF', icon: Icons.picture_as_pdf),
    SplitButtonOption(label: 'Pobierz XML', icon: Icons.code),
    SplitButtonOption(label: 'Pobierz MIDI', icon: Icons.audio_file),
  ];

  void _download() {
    final option = _downloadOptions[_selectedDownloadIndex];
    debugPrint('Downloading: ${option.label}');
    // Perform download based on selected option
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
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
                // Top bar with title and actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: Center(
                      child: HtmlWidget(
                        key: htmlWidgetKey,
                      ),
                    ),
                  ),
                ),
                // Audio player at the bottom
                AudioPlayerBar(
                  songTitle: widget.songTitle,
                  duration: '0:58',
                  isPlaying: _isPlaying,
                  onPlayPause: _togglePlayPause,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
