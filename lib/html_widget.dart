import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

import 'package:flutter/material.dart';

import 'package:fastscore_frontend/html_widget_stub.dart';
import 'package:fastscore_frontend/html_widget_web.dart';

class HtmlWidget extends StatefulWidget {
  const HtmlWidget({super.key});

  @override
  // ignore: no_logic_in_create_state
  HtmlWidgetState createState() => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux ? HtmlWidgetStateStub() : HtmlWidgetStateWeb();
}

abstract class HtmlWidgetState extends State<HtmlWidget> {
  final String pageUrl = 'assets/score_loader.html';
  final String musicfileUrl = 'assets/score.musicxml';
  String? htmlContent;

  Future<void> loadHtml();
}