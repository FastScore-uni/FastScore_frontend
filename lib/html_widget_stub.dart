import 'package:flutter/material.dart';

import 'package:fastscore_frontend/html_widget.dart';


class HtmlWidgetStateStub extends HtmlWidgetState {
  @override
  Future<void> loadHtml() async {}
  @override
  Widget build(BuildContext context) {
    return Text("Unsupposrted platform");
  }
}

HtmlWidgetState createHtmlWidgetState() => HtmlWidgetStateStub();