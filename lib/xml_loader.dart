import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class XmlLoader {
  // Klasa singletonowa do pobierania pliku musicxml z api
  XmlLoader._internal();

  static final XmlLoader _instance = XmlLoader._internal();

  factory XmlLoader() {
    return _instance;
  }

  final String apiUrl = 'http://127.0.0.1:8000/audio-to-xml';

  String fileName = '';
  List<int> fileData = [];

  String xmlContent = '';
  String error = '';

  Future<void> fetchXml() async {
    try { 
      final request = MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(
          MultipartFile.fromBytes(
            'file',               // nazwa musi być taka sama jak w FastAPI (UploadFile = File(...))
            fileData,
            filename: fileName, // dowolna nazwa
            contentType: MediaType('audio', 'mpeg'),
          ),
        );

      // możesz dodać nagłówki, jeśli chcesz
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

  void setFile(String fileName, List<int> fileData) {
    this.fileName = fileName;
    this.fileData = fileData;
  }
}
