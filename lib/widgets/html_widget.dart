import 'dart:io';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';


class HtmlWidget extends StatefulWidget {
  const HtmlWidget({super.key});

  @override
  // ignore: no_printic_in_create_state
  State<HtmlWidget> createState() => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux ? HtmlWidgetStateStub() : HtmlWidgetState();
}

class HtmlWidgetState extends State<HtmlWidget> {
  final String pageUrl = 'assets/score_loader.html';
  final String apiUrl = 'http://127.0.0.1:8000/audio-to-xml';
  String htmlContent = '';
  String? injectedHtmlContent;

  String _xmlContent = '';
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // process(null);
  }



  Future<void> process(File? musicfile) async {
    await _fetchXml(musicfile);
    if(_error.isEmpty) {
      _loadHtml();
    }
  }

  Future<void> _fetchXml(File? musicfile) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try { 

  // Mockowe dane binarne (np. udawany plik audio)
  final mockData = utf8.encode('Fake audio content');

  final request = MultipartRequest('POST', Uri.parse(apiUrl))
    ..files.add(
      MultipartFile.fromBytes(
        'file',               // nazwa musi być taka sama jak w FastAPI (UploadFile = File(...))
        mockData,
        filename: 'mock.mp3', // dowolna nazwa
        contentType: MediaType('audio', 'mpeg'),
      ),
    );

  // możesz dodać nagłówki, jeśli chcesz
  request.headers['Accept'] = 'application/xml';

  final response = await request.send();

      if (response.statusCode == 200) {
        _xmlContent = await response.stream.bytesToString();
        setState(() {});
      } else {
        setState(() {
          _error = 'Błąd: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Nie udało się pobrać XML: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadHtml() async {
    if (htmlContent.isEmpty) {
      htmlContent = await rootBundle.loadString(pageUrl);
    }
    setState(() {
      injectedHtmlContent = htmlContent.replaceFirst('{{MUSICXML_DATA}}', _xmlContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != '') {
      return Text(
              _error,
              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 209, 47, 47))
              );
    }
    if (injectedHtmlContent == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Brak wybranego utworu',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )
      );
    }

    return InAppWebView(
      initialData: InAppWebViewInitialData(data: injectedHtmlContent!),
    );
  }
}


class HtmlWidgetStateStub extends State<HtmlWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("Unsupposrted platform");
  }
}


