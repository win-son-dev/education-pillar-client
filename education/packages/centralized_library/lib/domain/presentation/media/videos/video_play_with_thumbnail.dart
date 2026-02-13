import 'package:centralized_library/centralized_library.dart';

import 'video_thumbnail_loader.dart';

/// A widget that shows a thumbnail initially and plays video when tapped
/// Pre-caches video in background for instant playback
class VideoPlayerWithThumbnail extends StatefulWidget {
  final VideoConfig config;
  final Widget? playButtonOverlay;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showControlsOnPlay;
  final bool preCacheVideo; // NEW: Option to pre-cache video
  final VoidCallback? onVideoStarted;
  final VoidCallback? onVideoEnded;

  const VideoPlayerWithThumbnail({
    super.key,
    required this.config,
    this.playButtonOverlay,
    this.loadingWidget,
    this.errorWidget,
    this.showControlsOnPlay = true,
    this.preCacheVideo = true, // Default: pre-cache for instant playback
    this.onVideoStarted,
    this.onVideoEnded,
  });

  @override
  State<VideoPlayerWithThumbnail> createState() =>
      _VideoPlayerWithThumbnailState();
}

class _VideoPlayerWithThumbnailState extends State<VideoPlayerWithThumbnail> {
  bool _isPlaying = false;
  VideoPlayerController? _controller;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    if (widget.preCacheVideo && widget.config.useCache) {
      _preCacheVideoInBackgroundAsync();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    super.dispose();
  }

  Future<void> _preCacheVideoInBackgroundAsync() async {
    final resolvedUrl = await _resolveUrlAsync(widget.config.url);

    // Check if already cached
    final fileInfo = await globalVideoCacheManager.getFileFromCache(resolvedUrl);

    if (fileInfo == null) {
      // Not cached, start downloading in background
      globalVideoCacheManager.downloadFile(resolvedUrl);
    }
  }

  Future<String> _resolveUrlAsync(String url) async {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return FirebaseStorage.instance.ref().child(url).getDownloadURL();
  }

  void _videoListener() {
    if (_controller == null || !mounted) return;

    if (_controller!.value.position >= _controller!.value.duration) {
      _handleVideoEndedAsync();
    }
  }

  Future<void> _handleVideoEndedAsync() async {
    widget.onVideoEnded?.call();

    if (!widget.config.looping && mounted) {
      setState(() {
        _isPlaying = false;
        _showControls = false;
      });
    }
  }

  void _onPlayTapped() {
    setState(() => _isPlaying = true);
    widget.onVideoStarted?.call();
  }

  void _onControllerReady(VideoPlayerController controller) {
    _controller = controller;
    _controller!.addListener(_videoListener);

    if (widget.showControlsOnPlay) {
      setState(() => _showControls = true);
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return _buildThumbnailView();
    }

    return _buildVideoView();
  }

  Widget _buildThumbnailView() {
    return GestureDetector(
      onTap: _onPlayTapped,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoThumbnailLoader(
            config: widget.config,
            loadingWidget: widget.loadingWidget,
            errorWidget: widget.errorWidget,
          ),
          widget.playButtonOverlay ?? _buildDefaultPlayButton(),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        VideoLoader(
          config: widget.config,
          onControllerReady: _onControllerReady,
          loadingWidget: widget.loadingWidget,
          errorWidget: widget.errorWidget,
        ),
        if (_showControls)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _controller?.value.isPlaying == true ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller?.value.isPlaying == true
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultPlayButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}