import 'package:http/http.dart';
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

      final response = await request.send();

      if (response.statusCode == 200) {
        xmlContent = await response.stream.bytesToString();
      } else {
        error = 'Błąd: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Nie udało się pobrać XML: $e';
    }
  }

  Future<List<int>> convertMidiToWav() async {
    final baseName = audioFileName.replaceAll(RegExp(r'\.[^.]+$'), '');
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
    final baseName = audioFileName.replaceAll(RegExp(r'\.[^.]+$'), '');
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

    void setAudioFile(String fileName, List<int> fileData) {
      audioFileName = fileName;
      audioFileData = fileData;
    }

}
