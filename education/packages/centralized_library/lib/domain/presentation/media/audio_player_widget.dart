import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Global cache manager for all network audio
final globalAudioCacheManager = CacheManager(
  Config(
    'globalAudioCache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 100,
  ),
);

/// A simple, reusable audio player widget
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Color? color;
  final bool autoPlay;
  final bool loop;
  final double volume;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.color,
    this.autoPlay = false,
    this.loop = false,
    this.volume = 1.0,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioAsync();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioAsync() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setVolume(widget.volume);
    await _audioPlayer.setLoopMode(widget.loop ? LoopMode.one : LoopMode.off);

    final path = widget.audioUrl;

    // Handle HTTP/HTTPS URLs with caching
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final cachedFile = await globalAudioCacheManager.getSingleFile(path);
      await _audioPlayer.setFilePath(cachedFile.path);
    }
    // Handle Firebase Storage paths with caching
    else if (path.startsWith('gs://') ||
        (!path.startsWith('assets/') && !path.contains('/'))) {
      final firebaseUrl =
      await FirebaseStorage.instance.ref().child(path).getDownloadURL();
      final cachedFile =
      await globalAudioCacheManager.getSingleFile(firebaseUrl);
      await _audioPlayer.setFilePath(cachedFile.path);
    }
    // Handle asset files
    else {
      await _audioPlayer.setAsset(path);
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }

    if (widget.autoPlay && mounted) {
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return StreamBuilder<Duration>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _audioPlayer.duration ?? Duration.zero;
        final isPlaying = _audioPlayer.playing;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color?.withValues(alpha: 0.1) ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  if (isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                    await _audioPlayer.play();
                  }
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor:
                        widget.color ?? Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: (widget.color ??
                            Theme.of(context).colorScheme.primary)
                            .withValues(alpha: 0.2),
                        thumbColor:
                        widget.color ?? Theme.of(context).colorScheme.primary,
                      ),
                      child: Slider(
                        value: duration.inMilliseconds > 0
                            ? position.inMilliseconds.toDouble().clamp(
                            0, duration.inMilliseconds.toDouble())
                            : 0,
                        max: duration.inMilliseconds.toDouble() > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1,
                        onChanged: (value) async {
                          await _audioPlayer
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.color?.withValues(alpha: 0.7) ??
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.color?.withValues(alpha: 0.7) ??
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
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
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color?.withValues(alpha: 0.1) ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Loading audio...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.color?.withValues(alpha: 0.7) ??
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}