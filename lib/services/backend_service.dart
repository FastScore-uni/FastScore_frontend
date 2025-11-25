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
  bool unfetchedData = false;
  String xmlContent = '';
  String error = '';

  Future<void> fetchXml() async {
    if(!unfetchedData) {
      return;
    }
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
        unfetchedData = false;
      } else {
        error = 'Błąd: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Nie udało się pobrać XML: $e';
    }
  }

  void setAudioFile(String fileName, List<int> fileData) {
    audioFileName = fileName;
    audioFileData = fileData;
    unfetchedData = true;
  }
}
