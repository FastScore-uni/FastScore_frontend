import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
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

  String audioFileName = '';
  List<int> audioFileData = [];
  
  String title = '';
  String duration = '';

  String xmlContent = '';
  String xmlUrl = '';
  String midiUrl = '';
  String audioUrl = '';
  String firestoreId = '';
  String error = '';

  Future<void> fetchXml() async {
    try { 
      final request = MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(
          MultipartFile.fromBytes(
            'file',           // nazwa argumentu w api
            audioFileData,
            filename: audioFileName, 
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

  void setAudioFile(String fileName, List<int> fileData, {String? title, String? duration}) {
    audioFileName = fileName;
    audioFileData = fileData;
    if (title != null) this.title = title;
    if (duration != null) this.duration = duration;
  }
}
