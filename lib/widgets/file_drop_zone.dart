import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

typedef FileDroppedCallback = void Function(String fileName, List<int> fileData);

class FileDropZone extends StatefulWidget {
  final FileDroppedCallback onFileDropped;

  const FileDropZone({
    super.key,
    required this.onFileDropped,
  });

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  late DropzoneViewController controller;
  bool isHighlighted = false;
  String message = 'Przeciągnij i upuść';

  int _calculateAlpha(int baseAlpha, double ratio) {
    return (baseAlpha * ratio).round().clamp(0, 255);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final int highlightAlpha = _calculateAlpha(colorScheme.primary.alpha, 0.15);
    final Color highlightColor = colorScheme.primary.withAlpha(highlightAlpha);

    final Color borderColor = isHighlighted ? colorScheme.primary : Colors.grey.shade400;

    return Container(
      width: 400,
      height: 200,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted
            ? highlightColor
            : colorScheme.surfaceContainerHighest.withAlpha(
            _calculateAlpha(colorScheme.surfaceContainerHighest.alpha, 0.3)
        ),

        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          DropzoneView(
            onCreated: (ctrl) => controller = ctrl,
            onDropFile: (file) async {
              setState(() {
                isHighlighted = false;
                message = 'Wczytywanie pliku...';
              });

              final bytes = await controller.getFileData(file);

              widget.onFileDropped(file.name, bytes);

              setState(() {
                message = 'Plik "${file.name}" wczytany pomyślnie!';
              });
            },
            onHover: () => setState(() => isHighlighted = true),
            onLeave: () => setState(() => isHighlighted = false),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 50,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                const Text(
                    'Wspierane formaty: mp3, wav',
                    style: TextStyle(fontSize: 10, color: Colors.grey)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
