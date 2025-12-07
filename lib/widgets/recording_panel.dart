import 'package:flutter/material.dart';
import 'dart:async';

typedef VoidCallback = void Function();
typedef DurationFormatter = String Function(Duration duration);
typedef SeekCallback = void Function(double position);

class RecordingPanel extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback? onReset;

  final VoidCallback onPlayPause;
  final SeekCallback onSeek;

  final bool isRecording;
  final bool isPaused;
  final bool isDataReady;

  final bool isPlaying;
  final Duration playbackPosition;
  final Duration playbackDuration;

  final Stream<Duration> durationStream;
  final DurationFormatter formatDuration;

  const RecordingPanel({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onPlayPause,
    required this.onSeek,
    required this.isRecording,
    required this.isPaused,
    required this.isDataReady,
    required this.isPlaying,
    required this.playbackPosition,
    required this.playbackDuration,
    required this.durationStream,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(color: colorScheme.outlineVariant, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recording button
          if (!isDataReady || isRecording)
            FilledButton.icon(
              onPressed: isRecording ? onStop : onStart,
              icon: Icon(
                isRecording ? Icons.stop : Icons.mic,
                size: isMobile ? 20 : 24,
              ),
              label: Text(
                isRecording ? 'Zakończ nagrywanie' : 'Nagraj utwór teraz',
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
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),

          // Progress bar
          if (isRecording) ...[
            SizedBox(height: isMobile ? 16 : 20),
            Row(
              children: [
                IconButton(
                  onPressed: isPaused ? onResume : onPause,
                  icon: Icon(isPaused ? Icons.play_circle : Icons.pause_circle),
                  highlightColor: colorScheme.onTertiary,
                  color: colorScheme.tertiary,
                  iconSize: 44,
                ),
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: durationStream,
                    initialData: Duration.zero,
                    builder: (context, snapshot) {
                      final currentDuration = snapshot.data ?? Duration.zero;
                      final maxDuration = const Duration(minutes: 10);
                      final progressValue = currentDuration.inSeconds / maxDuration.inSeconds;

                      return Row(
                        children: [
                          Text(
                            formatDuration(currentDuration),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: isMobile ? 13 : 14,
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                              child: LinearProgressIndicator(
                                value: progressValue.clamp(0.0, 1.0),
                                minHeight: isMobile ? 3 : 4,
                                borderRadius: BorderRadius.circular(2),
                                color: colorScheme.tertiary,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          Text(
                            formatDuration(maxDuration),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: isMobile ? 13 : 14,
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                ),
              ],
            ),
          ],

          // After recording
          if (isDataReady && !isRecording) ...[
            // Recording status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nagranie jest gotowe do wysłania',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Usuń'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  highlightColor: colorScheme.onTertiary,
                  color: colorScheme.tertiary,
                  iconSize: 44,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: playbackPosition.inSeconds.toDouble().clamp(0.0, playbackDuration.inSeconds.toDouble()),
                          max: playbackDuration.inSeconds.toDouble() > 0
                              ? playbackDuration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: onSeek,
                          activeColor: colorScheme.tertiary,
                          inactiveColor: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(playbackPosition),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: isMobile ? 13 : 14,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              formatDuration(playbackDuration),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: isMobile ? 13 : 14,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}