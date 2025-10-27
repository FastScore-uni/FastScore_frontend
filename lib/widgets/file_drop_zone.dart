import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:audioplayers/audioplayers.dart';


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

  bool _validateFileType(String mime) {
    const allowedTypes = ['audio/mpeg', 'audio/wav'];
    return allowedTypes.contains(mime);
  }

  bool _validateFileSize(List<int> fileData){
    final maxSizeInBytes = 1024 * 1024 * 200;
    return fileData.length <= maxSizeInBytes;
  }

  Future<bool?> _validateFileDuration(List<int> fileData) async{
    final Uint8List uint8Bytes = Uint8List.fromList(fileData);
    final player = AudioPlayer();
    await player.setSourceBytes(uint8Bytes);
    final duration = await player.getDuration();
    if (duration != null){
      final seconds = duration.inSeconds;
      if (seconds <= 3600) {
        return true;
      }
    }
    return false;
  }


  void _setDefaultMessage(){
    setState(() {
      message = 'Przeciągnij i upuść';
      isHighlighted = false;
    });
  }

  void _showValidationError(String errorMessage) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _setDefaultMessage();
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final int highlightAlpha = _calculateAlpha((colorScheme.primary.a * 255.0).round() & 0xFF, 0.15);
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
            _calculateAlpha((colorScheme.surfaceContainerHighest.a * 255.0).round() & 0xFF, 0.3)
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
            onHover: () => setState(() => isHighlighted = true),
            onLeave: () => setState(() => isHighlighted = false),
            onDropFile: (file) async {
              setState(() {
                isHighlighted = false;
                message = 'Wczytywanie pliku...';
              });
              
              final mime = await controller.getFileMIME(file);
              
              if (!_validateFileType(mime)){
                _showValidationError('Dozwolone są tylko pliki mp3 oraz wav');
                return;
              }


              final bytes = await controller.getFileData(file);

              if (!_validateFileSize(bytes)){
                _showValidationError('Plik jest za duży. Maksymalny rozmiar to 200MB');
                return;
              }

              final isValid = await _validateFileDuration(bytes);
              if (isValid == false) {
                _showValidationError('Utwór trwa za długo. Maksymalny czas trwania to godzina');
                return;
              }

              final fileName = await controller.getFilename(file);

              widget.onFileDropped(fileName, bytes);

              setState(() {
                message = 'Plik "$fileName" wczytany pomyślnie!';
              });
            },
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
