import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:fastscore_frontend/html_widget.dart';


class HtmlWidgetStateWeb extends HtmlWidgetState {
  @override
  void initState() {
    super.initState();
    loadHtml().then((_) => setState(() {}));
  }

  @override
  Future<void> loadHtml() async {
    htmlContent = await rootBundle.loadString('lib/notes.html');
  }

  @override
  Widget build(BuildContext context) {
    if (htmlContent == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // dla web możesz np. użyć HtmlElementView albo też InAppWebView
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: htmlContent!),
    );
  }
}

HtmlWidgetState createHtmlWidgetState() => HtmlWidgetStateWeb();