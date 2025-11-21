import 'package:fastscore_frontend/backend_service.dart';
import 'package:fastscore_frontend/widgets/model_selection_button.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:fastscore_frontend/widgets/file_drop_zone.dart';
import 'package:fastscore_frontend/widgets/recording_panel.dart';


class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final TextEditingController _titleController = TextEditingController();

  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordDuration = Duration.zero;
  bool _isDataReady = false;
  bool _isFileDropped = false;

  Uint8List? _audioBytes;

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  final Duration _maxRecordDuration = const Duration(minutes: 10);

  String _selectedModel = 'Basic Pitch';

  @override
  void dispose() {
    _titleController.dispose();
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _showNotes() {
    debugPrint('Wybrany model: $_selectedModel');
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration = _recordDuration + const Duration(seconds: 1);
      });
      if (_recordDuration >= _maxRecordDuration) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    if (_isFileDropped){
      setState(() {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nie można rozpocząć nagrywania, gdy upuszczony został plik'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
      return;
    }

    try {
      if (await _recorder.hasPermission()) {
        String filePath = '';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
          _isDataReady = false;
          _audioBytes = null;
          _isPaused = false;
        });
        _startTimer();
        debugPrint("Start recording...");
      } else {
        debugPrint("Brak uprawnień do mikrofonu.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Brak uprawnień do mikrofonu'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Błąd startu nagrywania: $e");
    }
  }


  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _stopTimer();
    final String? path = await _recorder.stop();

    if (path == null) {
      setState(() { _isRecording = false; _isDataReady = false; });
      debugPrint("Nagranie zatrzymane, błąd zapisu pliku.");
      return;
    }

    Uint8List? loadedBytes;

    try {
        final response = await http.get(Uri.parse(path));
        loadedBytes = response.bodyBytes;
      }
      catch (e) {
      debugPrint("Błąd wczytywania audio do pamięci: $e");
    }

    setState(() {
      _isRecording = false;
      _audioBytes = loadedBytes;
      _isDataReady = loadedBytes != null;
      _isPaused = false;
    });

    if (_isDataReady) {
      debugPrint("Wczytano ${_audioBytes!.length} bajtów audio (List<int>). Gotowe do wysłania.");
      BackendService().setAudioFile('recording.wav', _audioBytes!);
    }
  }

  Future<void> _pauseRecording() async {
    if (_isPaused) return;

    try {
      await _recorder.pause();
      _stopTimer();

      setState(() {
        _isPaused = true;
      });
      debugPrint("Pauzowanie nagrywania...");
    } catch (e) {
      debugPrint("Błąd pauzowania nagrywania: $e");
    }
  }

  Future<void> _resumeRecording() async {
    if (!_isPaused) return;

    try {
      await _recorder.resume();
      _startTimer();

      setState(() {
        _isPaused = false;
      });
      debugPrint("Wznawianie nagrywania...");
    } catch (e) {
      debugPrint("Błąd wznawiania nagrywania: $e");
    }
  }

  void _resetRecording() {
    _stopTimer();
    _recorder.stop();

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordDuration = Duration.zero;
      _isDataReady = false;
      _audioBytes = null;
      _titleController.clear();
    });
  }


  void _handleFileDropped(String fileName, List<int> fileData) {
    BackendService().setAudioFile(fileName, fileData);
    setState(() {
      _isFileDropped = true;
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

  void _handleFileDeleted() {
    setState(() {
      _isFileDropped = false;
    });
  }

  void _handleSelectedModel(String newModel){
    setState(() {
      _selectedModel = newModel;
    });
    debugPrint('Wybrany model: $_selectedModel');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return ResponsiveLayout(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isMobile ? 24 : 48),
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
                    height: isMobile ? 200 : 250,
                    child: FileDropZone(
                      onFileDropped: _handleFileDropped,
                      onFileDeleted: _handleFileDeleted,
                      isBlocked: _isRecording || _isDataReady,
                    ),
                  ),

                  Text(
                    'lub',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  RecordingPanel(
                            onStart: _startRecording,
                            onStop: _stopRecording,
                            onPause: _pauseRecording,
                            onResume: _resumeRecording,
                            onReset: _resetRecording,

                            isRecording: _isRecording,
                            isPaused: _isPaused,
                            recordDuration: _recordDuration,

                            isDataReady: _isDataReady,

                            formatDuration: _formatDuration,
                  ),
                  SizedBox(height: isMobile ? 24 : 48),


                  ModelSelectionButton(
                    onModelSelected: _handleSelectedModel,
                  ),
                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: () {
                      _showNotes();
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}