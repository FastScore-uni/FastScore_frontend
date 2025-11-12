import 'package:flutter/material.dart';

typedef VoidCallback = void Function();
typedef DurationFormatter = String Function(Duration duration);

class RecordingPanel extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback? onReset;
  final bool isRecording;
  final bool isPaused;
  final bool isDataReady;
  final Duration recordDuration;
  final DurationFormatter formatDuration;

  const RecordingPanel({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.isRecording,
    required this.isPaused,
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;
    final progressValue = widget.recordDuration.inSeconds / _maxDuration.inSeconds;
    final onPressedAction = widget.isRecording ? widget.onStop : widget.onStart;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recording button
          FilledButton.icon(
            onPressed: onPressedAction,
            icon: Icon(
              widget.isRecording ? Icons.stop : Icons.mic,
              size: isMobile ? 20 : 24,
            ),
            label: Text(
              widget.isRecording ? 'Zakończ nagrywanie' : 'Nagraj utwór teraz',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onTertiary,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          
          // Show progress only when recording or data is ready
          if (widget.isRecording || widget.isDataReady) ...[
            SizedBox(height: isMobile ? 16 : 20),

            // Progress bar row
            Row(
              children: [
                // Current time
                IconButton(
                    onPressed: widget.isPaused ? widget.onResume : widget.onPause,
                    icon: Icon(widget.isPaused ? Icons.play_circle : Icons.pause_circle),
                    highlightColor: colorScheme.onTertiary,
                    color: colorScheme.tertiary,
                    iconSize: isMobile ? 20 : 32,
                ),
                Text(
                  widget.isRecording ? widget.formatDuration(widget.recordDuration) : '00:00',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: isMobile ? 13 : 14,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                
                // Progress bar
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: isMobile ? 3 : 4,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Max duration
                Text(
                  widget.formatDuration(_maxDuration),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isMobile ? 13 : 14,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            
            // Status indicator
            if (widget.isDataReady && !widget.isRecording) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.tertiary,
                    size: isMobile ? 16 : 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nagranie gotowe do wysłania',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: widget.onReset,
                    icon: Icon(Icons.delete),
                    label: Text(
                      'Usuń nagranie',
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 32,
                        vertical: isMobile ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}