import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as html;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';


class HtmlWidget extends StatefulWidget {
  const HtmlWidget({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<HtmlWidget> createState() => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux ? HtmlWidgetStateStub() : HtmlWidgetState();
}

class HtmlWidgetState extends State<HtmlWidget> {
  final String pageUrl = 'assets/score_loader.html';
  // final String musicfileUrl = 'assets/score.musicxml';
  final String apiUrl = 'http://127.0.0.1:8000/audio-to-xml';
  String? htmlContent;

  String _xmlContent = '';
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    process(null);
  }

  Future<void> process(File? musicfile) async {
    _fetchXml(musicfile).then((_) => {
      if(_error != '') {
        _loadHtml()
      }
    });
  }

  Future<void> _fetchXml(File? musicfile) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try { 

  // Mockowe dane binarne (np. udawany plik audio)
  final mockData = utf8.encode('Fake audio content');

  final request = html.MultipartRequest('POST', Uri.parse(apiUrl))
    ..files.add(
      html.MultipartFile.fromBytes(
        'file',               // nazwa musi być taka sama jak w FastAPI (UploadFile = File(...))
        mockData,
        filename: 'mock.mp3', // dowolna nazwa
        contentType: MediaType('audio', 'mpeg'),
      ),
    );

  // możesz dodać nagłówki, jeśli chcesz
  request.headers['Accept'] = 'application/xml';

  final response = await request.send();
      // final response = await post(
      //   Uri.parse(apiUrl), // zmień adres jeśli potrzebujesz
      //   headers: {'Accept': 'application/xml'},
      //   body: {'file': musicfile},
      // );

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
    final html = await rootBundle.loadString(pageUrl);
    setState(() {
      htmlContent = html.replaceFirst('{{MUSICXML_DATA}}', _xmlContent);
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
    if (htmlContent == null) {
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
      initialData: InAppWebViewInitialData(data: htmlContent!),
    );
  }
}


class HtmlWidgetStateStub extends State<HtmlWidget> {
  @override
  Widget build(BuildContext context) {
    return Text("Unsupposrted platform");
  }
}


