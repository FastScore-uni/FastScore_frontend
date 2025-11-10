import 'package:flutter/material.dart';

typedef VoidCallback = void Function();
typedef DurationFormatter = String Function(Duration duration);

class RecordingPanel extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final bool isRecording;
  final bool isDataReady;
  final Duration recordDuration;
  final DurationFormatter formatDuration;

  const RecordingPanel({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.isRecording,
    required this.recordDuration,
    required this.formatDuration,
    required this.isDataReady,
  });

  @override
  State<RecordingPanel> createState() => _RecordingPanelState();

}

class _RecordingPanelState extends State<RecordingPanel> {
  final Duration _maxDuration = Duration(hours: 1);


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progressValue = widget.recordDuration.inSeconds / _maxDuration.inSeconds;
    final onPressedAction = widget.isRecording ? widget.onStop : widget.onStart;

    return Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: FilledButton.icon(
                onPressed: onPressedAction,
                icon: Icon(widget.isRecording ? Icons.stop : Icons.mic_sharp),
                label: Text(widget.isRecording ? 'Zakończ nagrywanie' :'Rozpocznij nagrywanie'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.onTertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
              ),
            ),
           ),
            const SizedBox(height: 30),
            Row(
              children: [
                // IconButton(
                //     onPressed: (){/* TODO: */},
                //     icon: Icon(widget.isRecording ? Icons.pause_circle : Icons.play_circle),
                //     color: colorScheme.tertiary,
                //     iconSize: 30,
                // ),
                // const SizedBox(width: 8),
                Text(
                  widget.isRecording ? widget.formatDuration(widget.recordDuration) : '00:00',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 4,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                    ),
                  ),
                ),
                Text(widget.formatDuration(_maxDuration), style: TextStyle(color: Colors.grey.shade700)),
              ],
            )
          ],
        ),
      );
    }
  }