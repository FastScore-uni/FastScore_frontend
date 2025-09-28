import 'package:fastscore_frontend/html_viewer.dart';
import 'package:flutter/material.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {

  void _startRecording() {
    debugPrint("Start recording...");
    // TODO: podłącz pakiet `record` albo `flutter_sound`
  }

  void _stopRecording() {
    debugPrint("Stop recording...");
  }

  void _uploadRecording() {
    debugPrint("Upload recording...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nagrywanie i nutki"),
        actions: [
          IconButton(
            onPressed: _startRecording,
            icon: const Icon(Icons.play_arrow),
            tooltip: "Start",
          ),
          IconButton(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop),
            tooltip: "Stop",
          ),
          IconButton(
            onPressed: _uploadRecording,
            icon: const Icon(Icons.upload_file),
            tooltip: "Upload",
          ),
        ],
      ),
      // body: WebViewX(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   initialContent: _htmlVexflow,
      //   initialSourceType: SourceType.html,
      //   onWebViewCreated: (controller) => webviewController = controller,
      // ),
      body: HtmlViewer()
    );
  }
}