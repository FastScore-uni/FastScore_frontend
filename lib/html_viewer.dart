import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HtmlViewer extends StatefulWidget {
  @override
  _HtmlViewerState createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  String? htmlContent;

  @override
  void initState() {
    super.initState();
    loadHtml();
  }

  Future<void> loadHtml() async {
    String fileHtmlContents = await rootBundle.loadString('lib/notes.html');
    setState(() {
      htmlContent = fileHtmlContents;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (htmlContent == null) {
      return Center(child: CircularProgressIndicator());
    }

    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlContent!, // ważne dla lokalnych zasobów JS/CSS
      ),
    );
  }
}