import 'package:flutter/material.dart';

import 'package:fastscore_frontend/html_widget_stub.dart'
    // if (dart.library.io) 'package:fastscore_frontend/html_widget_android.dart'
    if (dart.library.html) 'package:fastscore_frontend/html_widget_web.dart';

class HtmlWidget extends StatefulWidget {
  const HtmlWidget({super.key});

  @override
  // ignore: no_logic_in_create_state
  HtmlWidgetState createState() => createHtmlWidgetState();
}

abstract class HtmlWidgetState extends State<HtmlWidget> {
  String? htmlContent;

  Future<void> loadHtml();
}