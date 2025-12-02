import 'package:fastscore_frontend/services/backend_service.dart';
import 'package:fastscore_frontend/widgets/model_selection_button.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:fastscore_frontend/widgets/file_drop_zone.dart';
import 'package:fastscore_frontend/widgets/recording_panel.dart';
import 'package:fastscore_frontend/models/transcription_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

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
  final _durationStreamController = StreamController<Duration>.broadcast();
  final Stopwatch _stopwatch = Stopwatch();

  bool _isDataReady = false;
  bool _isFileDropped = false;
  Uint8List? _audioBytes;

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  final Duration _maxRecordDuration = const Duration(minutes: 10);

  TranscriptionModel _selectedModel = TranscriptionModel.basicPitch;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _playbackPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _playbackDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timer?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    _durationStreamController.close();
    super.dispose();
  }

  void _showNotes() {
    debugPrint('Wybrany model: $_selectedModel');
    BackendService().currentModel = _selectedModel;
    final title = _titleController.text.isEmpty
        ? 'Utwór bez tytułu'
        : _titleController.text;

    BackendService().title = title;
    
    Navigator.of(context).pushNamed(
      '/notes',
      arguments: {
        'title': title,
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _recordDuration = _stopwatch.elapsed;
      if (!_durationStreamController.isClosed) {
        _durationStreamController.add(_recordDuration);
      }
      if (_recordDuration >= _maxRecordDuration) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    await _audioPlayer.stop();

    if (_isFileDropped){
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nie można rozpocząć nagrywania, gdy upuszczony został plik'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    try {
      if (await _recorder.hasPermission()) {
        const config = RecordConfig(
          encoder: AudioEncoder.opus,
          sampleRate: 44100,
          numChannels: 1,
          echoCancel: true,
          autoGain: true,
          noiseSuppress: true,
        );

        String path = '';

        await _recorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
          _isDataReady = false;
          _audioBytes = null;
          _isPaused = false;
        });
        _stopwatch.reset();
        _startTimer();
        debugPrint("Start recording...");
      } else {
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

    debugPrint("Zapisano nagranie w: $path");

    Uint8List? loadedBytes;

    try {
      if (kIsWeb) {
        final response = await http.get(Uri.parse(path));
        loadedBytes = response.bodyBytes;
      } else {
        File file = File(path);
        loadedBytes = await file.readAsBytes();
      }

      if (kIsWeb) {
        await _audioPlayer.setSourceUrl(path);
      } else {
        await _audioPlayer.setSourceDeviceFile(path);
      }
    }
    catch (e) {
      debugPrint("Błąd wczytywania audio do pamięci: $e");
    }

    setState(() {
      _isRecording = false;
      _audioBytes = loadedBytes;
      _isDataReady = loadedBytes != null;
      _isPaused = false;
      _playbackDuration = _recordDuration;
    });

    if (_isDataReady) {
      debugPrint("Wczytano ${_audioBytes!.length} bajtów audio (List<int>). Gotowe do wysłania.");
      BackendService().setAudioFile(
        'recording.opus', 
        _audioBytes!, 
        title: _titleController.text.isEmpty ? 'Nagranie' : _titleController.text,
        duration: _formatDuration(_recordDuration),
      );
    }
  }
  Future<void> _pauseRecording() async {
    if (_isPaused) return;
    try {
      await _recorder.pause();
      _stopwatch.stop();
      _stopTimer();
      setState(() => _isPaused = true);
      debugPrint("Pauzowanie nagrywania...");
    } catch (e) {
      debugPrint("Błąd pauzowania nagrania: $e");
    }
  }

  Future<void> _resumeRecording() async {
    if (!_isPaused) return;

    try {
      await _recorder.resume();
      _stopwatch.start();
      _startTimer();
      setState(() => _isPaused = false);
      debugPrint("Wznawianie nagrywania...");
    } catch (e) {
      debugPrint("Błąd wznawiania nagrywania: $e");
      BackendService().setAudioFile(
        'recording.opus', 
        _audioBytes!, 
        title: _titleController.text.isEmpty ? 'Nagranie' : _titleController.text,
        duration: _formatDuration(_recordDuration),
      );
    }
  }

  void _resetRecording() {
    _stopTimer();
    _recorder.stop();
    _audioPlayer.stop();

    _recordDuration = Duration.zero;
    if (!_durationStreamController.isClosed) {
      _durationStreamController.add(Duration.zero);
    }

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _isDataReady = false;
      _audioBytes = null;
      _playbackPosition = Duration.zero;
      _titleController.clear();
    });
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _seekAudio(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  void _handleFileDropped(String fileName, List<int> fileData) {
    _resetRecording();
    BackendService().setAudioFile(
      fileName, 
      fileData,
      title: _titleController.text.isEmpty ? fileName : _titleController.text,
    );
    setState(() {
      _isFileDropped = true;
    });
    debugPrint("Plik upuszczony: $fileName, Rozmiar: ${fileData.length} bajtów");
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _handleFileDeleted() {
    setState(() {
      _isFileDropped = false;
    });
  }

  void _handleSelectedModel(TranscriptionModel newModel){
    setState(() {
      _selectedModel = newModel;
    });
    debugPrint('Wybrany model: ${_selectedModel.displayName}');
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
                  
                  // File drop zone
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

                    onPlayPause: _togglePlayback,
                    onSeek: _seekAudio,

                    isRecording: _isRecording,
                    isPaused: _isPaused,
                    isDataReady: _isDataReady,

                    isPlaying: _isPlaying,
                    playbackPosition: _playbackPosition,
                    playbackDuration: _playbackDuration,

                    durationStream: _durationStreamController.stream,
                    formatDuration: _formatDuration,
                  ),

                  SizedBox(height: isMobile ? 24 : 48),

                  ModelSelectionButton(
                      onModelSelected: _handleSelectedModel
                  ),
                  const SizedBox(height: 32),

                  FilledButton.icon(
                    onPressed: _showNotes,
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