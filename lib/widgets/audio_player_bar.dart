import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class AudioPlayerBar extends StatefulWidget {
  final String songTitle;
  final String duration;
  final VoidCallback? onPlayPause;
  final bool isPlaying;

  const AudioPlayerBar({
    super.key,
    required this.songTitle,
    this.duration = '0:58',
    this.onPlayPause,
    this.isPlaying = false,
  });

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 58);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ProgressBar(
              progress: _currentPosition,
              total: _totalDuration,
              buffered: _totalDuration, // Can be updated with actual buffered value
              onSeek: (duration) {
                setState(() {
                  _currentPosition = duration;
                });
                // TODO: Seek to position in audio player
              },
              barHeight: 3.0,
              thumbRadius: 6.0,
              timeLabelLocation: TimeLabelLocation.none,
              progressBarColor: Theme.of(context).colorScheme.primary,
              baseBarColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              bufferedBarColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              thumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Player controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Album art / thumbnail
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Song info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.songTitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.duration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Playback controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                        onPressed: widget.onPlayPause,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 28),
                        onPressed: () {
                          // Next track
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
