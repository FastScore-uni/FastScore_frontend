import 'package:fastscore_frontend/models/transcription_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class BackendService {
  // Klasa singletonowa do komunikacji z api na backendzie
  BackendService._internal();

  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  final String originUrl = 'http://127.0.0.1:8000';
  // final String originUrl = 'https://audio-to-xml-417992603605.us-central1.run.app';


  TranscriptionModel _currentModel = TranscriptionModel.basicPitch;
  TranscriptionModel? _previousModel;

  String _audioFileName = '';
  List<int> _audioFileData = [];
  bool _unfetchedData = false;
  String xmlContent = '';
  List<int> midiBytes = [];
  List<int> wavBytes = [];
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
      debugPrint("Fetching ...");
      final request = MultipartRequest('POST', Uri.parse(_currentModel.url(originUrl)))
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
      // final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        _unfetchedData = false;
        _previousModel = _currentModel;
        error = '';

        
        xmlContent = jsonResponse['xml'] as String;
        final midiB64 = jsonResponse['midi_base64'] as String;
        midiBytes = base64Decode(midiB64);
        // xmlContent = jsonResponse['xml_content'] ?? '';
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
    final url = Uri.parse("$originUrl/midi-to-audio");
    final request = http.MultipartRequest('POST', url)
    ..files.add(
      http.MultipartFile.fromBytes(
        'midi_file',
        midiBytes,
        filename: 'upload.mid',
        contentType: MediaType('audio', 'midi'),
      ),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception("Błąd konwersji MIDI: ${response.statusCode}");
    }
    wavBytes = response.bodyBytes;
    return wavBytes;
  }

  Future<List<int>> downloadPdf() async {
    final url = Uri.parse("$originUrl/xml-to-pdf");
    final res = await post(url, body: {'xml': xmlContent});
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception("PDF failed ${res.statusCode}");
  }

}
