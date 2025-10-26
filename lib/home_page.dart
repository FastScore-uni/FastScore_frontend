import 'package:flutter/material.dart';

import 'package:fastscore_frontend/widgets/file_drop_zone.dart';
import 'package:fastscore_frontend/html_widget.dart';


class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {

  final GlobalKey<HtmlWidgetState> htmlWidgetKey = GlobalKey<HtmlWidgetState>();

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

  void _handleFileDropped(String fileName, List<int> fileData) {
    setState(() {
      // TODO pobranie pliku z backendu
    });
    debugPrint("Plik upuszczony: $fileName, Rozmiar: ${fileData.length} bajtów");
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FileDropZone(
              onFileDropped: _handleFileDropped,
            ),

            const SizedBox(height: 20),

            Expanded(
                child: HtmlWidget(key: htmlWidgetKey)
            )
          ],
        ),
      ),
    );
  }
}