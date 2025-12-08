import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

// Web platform support
import 'package:just_audio_web/just_audio_web.dart';

class AudioPlayerBar extends StatefulWidget {
  final String songTitle;
  final List<int>? audioBytes;
  final String? audioUrl;

  const AudioPlayerBar({
    super.key,
    required this.songTitle,
    this.audioBytes,
    this.audioUrl,
  });

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    
    try {
      // Set up listeners once
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      }, onError: (e) {
        debugPrint("AudioPlayerBar: Position stream error: $e");
      });

      _player.durationStream.listen((dur) {
        if (dur != null && mounted) {
          setState(() => _duration = dur);
        }
      }, onError: (e) {
        debugPrint("AudioPlayerBar: Duration stream error: $e");
      });

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
        }
        debugPrint("AudioPlayerBar: State changed - playing: ${state.playing}, processing: ${state.processingState}");
      }, onError: (e) {
        debugPrint("AudioPlayerBar: Player state stream error: $e");
        if (mounted) setState(() => _isLoading = false);
      });
      
      _loadAudio();
    } catch (e) {
      debugPrint("AudioPlayerBar: Error in initState: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didUpdateWidget(AudioPlayerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    try {
      if (widget.audioBytes != oldWidget.audioBytes || widget.audioUrl != oldWidget.audioUrl) {
        _loadAudio();
      }
    } catch (e) {
      debugPrint("AudioPlayerBar: Error in didUpdateWidget: $e");
    }
  }

  Future<void> _loadAudio() async {
    if (widget.audioBytes == null && (widget.audioUrl == null || widget.audioUrl!.isEmpty)) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      if (widget.audioBytes != null && widget.audioBytes!.isNotEmpty) {
        debugPrint("AudioPlayerBar: Playing from bytes (size: ${widget.audioBytes!.length})");
        
        // Validate WAV header (first 4 bytes should be "RIFF")
        if (widget.audioBytes!.length > 12) {
          final header = String.fromCharCodes(widget.audioBytes!.sublist(0, 4));
          if (header != 'RIFF') {
            debugPrint("AudioPlayerBar: Invalid WAV file - missing RIFF header. Header: $header");
            throw Exception('Invalid WAV file format');
          }
        }
        
        // Use just_audio's built-in byte handling (works better on web)
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.dataFromBytes(
              widget.audioBytes!,
              mimeType: 'audio/wav',
            ),
          ),
        );
        debugPrint("AudioPlayerBar: Audio source set successfully from bytes");
      } else if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
         debugPrint("AudioPlayerBar: Playing from URL: ${widget.audioUrl}");
         await _player.setUrl(widget.audioUrl!);
         debugPrint("AudioPlayerBar: Audio URL set successfully");
      } else {
        debugPrint("AudioPlayerBar: No audio source available");
        if (mounted) setState(() => _isLoading = false);
        return;
      }

    } catch (e) {
      debugPrint("Błąd ładowania audio: $e");
      debugPrint("Stack trace: ${StackTrace.current}");
      if (mounted) setState(() => _isLoading = false);
      
      // Fallback to URL if bytes fail
      if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty && widget.audioBytes != null) {
        debugPrint("AudioPlayerBar: Attempting fallback to URL");
        try {
          await _player.setUrl(widget.audioUrl!);
        } catch (e2) {
          debugPrint("AudioPlayerBar: Fallback also failed: $e2");
        }
      }
    }
  }

  void _togglePlayPause() {
    runZonedGuarded(() {
      if (_player.playing) {
        _player.pause();
      } else {
        _player.play();
      }
    }, (error, stackTrace) {
      debugPrint("AudioPlayerBar: Error in play/pause: $error");
      debugPrint("Stack trace: $stackTrace");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    try {
      _player.dispose();
    } catch (e) {
      debugPrint("AudioPlayerBar: Error in dispose: $e");
    }
    super.dispose();
  }

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
              progress: _position,
              total: _duration,
              buffered: _duration,
              onSeek: (duration) {
                _player.seek(duration);
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
                  // Ikona
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

                  // Nazwa utworu
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
                          _formatDuration(_duration),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Play/Pause or loader
                  if (_isLoading)
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                      onPressed: _togglePlayPause,
                    ),

                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
