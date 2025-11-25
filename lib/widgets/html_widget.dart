import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fastscore_frontend/services/backend_service.dart';


class HtmlWidget extends StatefulWidget {
  const HtmlWidget({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<HtmlWidget> createState() => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux ? HtmlWidgetStateStub() : HtmlWidgetState();
}

class HtmlWidgetState extends State<HtmlWidget> {
  final String pageUrl = 'assets/score_loader.html';
  String htmlContent = '';
  String? injectedHtmlContent;

  final BackendService backendService = BackendService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    process();
  }

  Future<void> process() async {
    setState(() {
      loading = true;
    });
    backendService.fetchXml().then((_) {
      if (backendService.error.isEmpty) {
        _loadHtml();
      }
    });
  }

  Future<void> _loadHtml() async {
    if (htmlContent.isEmpty) {
      htmlContent = await rootBundle.loadString(pageUrl);
    }
    setState(() {
      injectedHtmlContent = htmlContent.replaceFirst('{{MUSICXML_DATA}}', backendService.xmlContent);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (backendService.error != '') {
      return Text(
              backendService.error,
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


