import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BackendService {
  // Klasa singletonowa do komunikacji z api na backendzie
  BackendService._internal();

  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  final String apiUrl = 'http://127.0.0.1:8000/audio-to-xml';

  String audioFileName = '';
  List<int> audioFileData = [];

  String xmlContent = '';
  List<int> midiBytes = [];
  List<int> wavBytes = [];
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
      request.headers['Accept'] = 'application/xml';

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        xmlContent = data['xml'] as String;
        final midiB64 = data['midi_base64'] as String;
        midiBytes = base64Decode(midiB64);
      } else {
        error = 'Błąd: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Nie udało się pobrać XML: $e';
    }
  }

  Future<List<int>> convertMidiToWav() async {
    final url = Uri.parse("http://127.0.0.1:8000/midi-to-audio");
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
    final url = Uri.parse("http://127.0.0.1:8000/xml-to-pdf");
    final res = await post(url, body: {'xml': xmlContent});
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception("PDF failed ${res.statusCode}");
  }

  void setAudioFile(String fileName, List<int> fileData) {
    audioFileName = fileName;
    audioFileData = fileData;
  }

}
