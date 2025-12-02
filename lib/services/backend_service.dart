import 'package:fastscore_frontend/models/transcription_model.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class BackendService {
  // Klasa singletonowa do komunikacji z api na backendzie
  BackendService._internal();

  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  final String apiUrl = 'https://audio-to-xml-417992603605.us-central1.run.app';


  TranscriptionModel _currentModel = TranscriptionModel.basicPitch;
  TranscriptionModel? _previousModel;

  String _audioFileName = '';
  List<int> _audioFileData = [];
  bool _unfetchedData = false;
  String xmlContent = '';
  String error = '';

  String title = '';
  String duration = '';
  String xmlUrl = '';
  String midiUrl = '';
  String audioUrl = '';
  String firestoreId = '';

  void setAudioFile(String fileName, List<int> fileData, {String? title, String? duration}) {
    _audioFileName = fileName;
    _audioFileData = fileData;
    _unfetchedData = true;
    if (title != null) this.title = title;
    if (duration != null) this.duration = duration;
  }

  void setExistingSong(String xmlUrl, String midiUrl, String audioUrl, String title, String firestoreId) {
    this.xmlUrl = xmlUrl;
    this.midiUrl = midiUrl;
    this.audioUrl = audioUrl;
    this.title = title;
    this.firestoreId = firestoreId;
    
    this.xmlContent = ''; // Clear content so it forces reload
    this._unfetchedData = false; // Do not try to upload/convert
    this._audioFileData = []; // Clear audio data
  }

  set currentModel(TranscriptionModel newModel){
    _currentModel = newModel;
  }

  Future<void> fetchXml() async {
    // If we have an XML URL but no content, fetch it directly
    if (!_unfetchedData && xmlUrl.isNotEmpty && xmlContent.isEmpty) {
      try {
        final response = await get(Uri.parse(xmlUrl));
        if (response.statusCode == 200) {
          xmlContent = response.body;
          error = '';
        } else {
          error = 'Błąd pobierania XML: ${response.statusCode}';
        }
      } catch (e) {
        error = 'Nie udało się pobrać XML: $e';
      }
      return;
    }

    if(!_unfetchedData && _previousModel == _currentModel) {
      return;
    }
    try { 
      final request = MultipartRequest('POST', Uri.parse(_currentModel.url))
        ..files.add(
          MultipartFile.fromBytes(
            'file',           // nazwa argumentu w api
            _audioFileData,
            filename: _audioFileName, 
            contentType: MediaType('audio', 'mpeg'),
          ),
        );
      request.headers['Accept'] = 'application/json';
      
      // Add metadata
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        request.fields['user_id'] = user.uid;
      }
      
      if (title.isNotEmpty) {
        request.fields['title'] = title;
      }
      
      if (duration.isNotEmpty) {
        request.fields['duration'] = duration;
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        _unfetchedData = false;
        _previousModel = _currentModel;
        error = '';

        final jsonResponse = jsonDecode(responseBody);
        
        xmlContent = jsonResponse['xml_content'] ?? '';
        xmlUrl = jsonResponse['xml_url'] ?? '';
        midiUrl = jsonResponse['midi_url'] ?? '';
        audioUrl = jsonResponse['audio_url'] ?? '';
        firestoreId = jsonResponse['firestoreId'] ?? '';
      } else {
        error = 'Błąd: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Nie udało się pobrać XML: $e';
    }
  }

  Future<List<int>> convertMidiToWav() async {
    final baseName = _audioFileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    String midiPath = "basic_pitch_output/${baseName}_basic_pitch.mid";
    final url = Uri.parse("http://127.0.0.1:8000/midi-to-audio?midi_path=$midiPath");

    final response = await post(url);

    if (response.statusCode != 200) {
      throw Exception("Błąd konwersji MIDI: ${response.statusCode}");
    }

    return response.bodyBytes;
  }

  Future<List<int>> downloadFile(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Błąd pobierania pliku: ${response.statusCode}");
    }
  }

  Future<List<int>> downloadMidi() async {
    final baseName = _audioFileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    String midiPath = "basic_pitch_output/${baseName}_basic_pitch.mid";
    final url = "http://127.0.0.1:8000/download-midi?midi_path=$midiPath";

    return downloadFile(url);
  }

  Future<List<int>> downloadPdf() async {
    String xmlPath = "output.musicxml";
    final url = "http://127.0.0.1:8000/xml-to-pdf?xml_path=$xmlPath";

    return downloadFile(url);
  }

  Future<List<int>> downloadXml() async {
    String xmlPath = "output.musicxml";
    final url = "http://127.0.0.1:8000/download-xml?xml_path=$xmlPath";
    
    return downloadFile(url);
  }
}
