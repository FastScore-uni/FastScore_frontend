import 'package:fastscore_frontend/models/transcription_model.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class BackendService {
  // Klasa singletonowa do komunikacji z api na backendzie
  BackendService._internal();

  static final BackendService _instance = BackendService._internal();

  factory BackendService() {
    return _instance;
  }

  TranscriptionModel _currentModel = TranscriptionModel.basicPitch;
  TranscriptionModel? _previousModel;

  String _audioFileName = '';
  List<int> _audioFileData = [];
  bool _unfetchedData = false;
  String xmlContent = '';
  String error = '';

  void setAudioFile(String fileName, List<int> fileData) {
    _audioFileName = fileName;
    _audioFileData = fileData;
    _unfetchedData = true;
  }

  set currentModel(TranscriptionModel newModel){
    _currentModel = newModel;
  }

  Future<void> fetchXml() async {
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
      request.headers['Accept'] = 'application/xml';

      final response = await request.send();

      if (response.statusCode == 200) {
        xmlContent = await response.stream.bytesToString();
        _unfetchedData = false;
        _previousModel = _currentModel;
      } else {
        error = 'Błąd: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Nie udało się pobrać XML: $e';
    }
  }
}
