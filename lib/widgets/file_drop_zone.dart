import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mime/mime.dart';


typedef FileDroppedCallback = void Function(String fileName, List<int> fileData);
typedef FileDeletedCallback = void Function();

class FileDropZone extends StatefulWidget {
  final FileDroppedCallback onFileDropped;
  final bool isBlocked;
  final FileDeletedCallback? onFileDeleted;

  const FileDropZone({
    super.key,
    required this.onFileDropped,
    this.isBlocked = false,
    this.onFileDeleted,
  });

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  late DropzoneViewController controller;
  bool _isHighlighted = false;
  static const String _dragAndDropHint = 'Przeciągnij i upuść';
  String _message = 'Przeciągnij i upuść';
  String? _fileName;


  bool _validateFileType(List<int> fileData) {
    final headerBytes = fileData.take(12).toList();

    String? mimeType = lookupMimeType('', headerBytes: headerBytes);
    debugPrint('Typ MIME wykryty : $mimeType');

    const validMimeTypes = {
      'audio/mp3',
      'audio/mpeg',
      'audio/wav',
      'audio/x-wav',
    };

    return validMimeTypes.contains(mimeType);
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


  void _clearFileState(){
    setState(() {
      _message = _dragAndDropHint;
      _isHighlighted = false;
      _fileName = null;
    });
  }

  void _showErrorNotification(String errorMessage) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessNotification(String successMessage) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteFile() {
    if (_fileName != null) {
      _showSuccessNotification('Plik "$_fileName" został usunięty.');
      _clearFileState();

      if (widget.onFileDeleted != null) {
        widget.onFileDeleted!();
      }
    }
  }
  Future<void> _processFile(dynamic file) async{
    setState(() {
      _isHighlighted = false;
      _message = 'Wczytywanie pliku...';
    });

    final bytes = await controller.getFileData(file);

    if (!_validateFileType(bytes)){
      _showErrorNotification('Dozwolone są tylko pliki mp3 oraz wav');
      _clearFileState();
      return;
    }


    if (!_validateFileSize(bytes)){
      _showErrorNotification('Plik jest za duży. Maksymalny rozmiar to 200MB');
      _clearFileState();
      return;
    }

    final isValid = await _validateFileDuration(bytes);
    if (isValid == false) {
      _showErrorNotification('Utwór trwa za długo. Maksymalny czas trwania to godzina');
      _clearFileState();
      return;
    }

    _fileName = await controller.getFilename(file);

    widget.onFileDropped(_fileName!, bytes);
    _showSuccessNotification('Pomyślnie wczytano plik $_fileName');
    setState(() {
      _message = _fileName!;
    });
  }

  Future <void> _pickFile() async{
    if (_fileName != null) {
      _showErrorNotification('Pole jest już zajęte. Najpierw usuń obecny plik.');
      return;
    }

    final List<dynamic> selectedFiles = await controller.pickFiles(
        multiple: false,
        mime: ['audio/mpeg', 'audio/wav'],
    );

    if (selectedFiles.isEmpty){
      return;
    }
    final file = selectedFiles.first;

    _processFile(file);
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color borderColor = _isHighlighted ? colorScheme.primary : colorScheme.outlineVariant;
    final isMobile = MediaQuery.of(context).size.width < 600;


    return IgnorePointer(
      ignoring: widget.isBlocked,
      child: Container(
        width: 600,
        height: 300,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _isHighlighted
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerLow,
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
              onHover: () => {
                if (!widget.isBlocked) {
                  setState(() => _isHighlighted = true),
                }
              },
              onLeave: () => {
                if (!widget.isBlocked) {
                  setState(() => _isHighlighted = false),
                }
              },
              onDropFile: (file) async {
                if (widget.isBlocked) {
                  _showErrorNotification('Strefa upuszczania jest zablokowana, gdy włączone jest nagrywanie.');
                  return;
                }
                if (_fileName != null){
                  _showErrorNotification('Pole jest już zajęte. Najpierw usuń obecny plik.');
                  return;
                }
                _processFile(file);
              },
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: isMobile ? 25 : 50,
                    color: colorScheme.primary,
                  ),
                  if (!isMobile)...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  )
                  ],
                  if (_message == _dragAndDropHint)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.file_open),
                        label: const Text('Wybierz plik'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_message == _dragAndDropHint)
                    const Text(
                        'Wspierane formaty: mp3, wav',
                        style: TextStyle(fontSize: 13, color: Colors.grey)
                    ),
                ],
              ),
            ),
            if (_fileName != null)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.delete_forever, color: colorScheme.error, size: 28),
                  tooltip: 'Usuń wczytany plik',
                  onPressed: _deleteFile,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
