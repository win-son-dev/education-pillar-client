import 'package:centralized_library/centralized_library.dart';
import 'package:centralized_library/domain/presentation/media/video_config.dart';

/// Global cache manager for all network videos
final globalVideoCacheManager = CacheManager(
  Config(
    'globalVideoCache',
    stalePeriod: const Duration(days: 2),
    maxNrOfCacheObjects: 20,
  ),
);

/// A widget that loads and displays video with caching support
class VideoLoader extends StatefulWidget {
  final VideoConfig config;
  final void Function(VideoPlayerController)? onControllerReady;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const VideoLoader({
    super.key,
    required this.config,
    this.onControllerReady,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<VideoLoader> createState() => _VideoLoaderState();
}

class _VideoLoaderState extends State<VideoLoader> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  @override
  void didUpdateWidget(VideoLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.url != widget.config.url) {
      _disposeController();
      _initializeAsync();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  Future<void> _initializeAsync() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
    });

    final resolvedUrl = await _resolveUrlAsync(widget.config.url);
    final controller = await _createControllerAsync(resolvedUrl);

    if (!mounted) return;

    _controller = controller;

    await controller.initialize().catchError((error) {
      if (mounted) {
        setState(() => _hasError = true);
      }
      throw error;
    });

    if (!mounted) return;

    _configureController(controller);

    setState(() => _isInitialized = true);

    widget.onControllerReady?.call(controller);
  }

  Future<String> _resolveUrlAsync(String url) async {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return FirebaseStorage.instance.ref().child(url).getDownloadURL();
  }

  Future<VideoPlayerController> _createControllerAsync(String url) async {
    if (!widget.config.useCache) {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }

    final fileInfo = await globalVideoCacheManager.getFileFromCache(url);

    if (fileInfo != null) {
      return VideoPlayerController.file(fileInfo.file);
    }

    _cacheVideoInBackgroundAsync(url);

    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  Future<void> _cacheVideoInBackgroundAsync(String url) async {
    globalVideoCacheManager.downloadFile(url);
  }

  void _configureController(VideoPlayerController controller) {
    if (widget.config.muted) {
      controller.setVolume(0.0);
    }
    if (widget.config.looping) {
      controller.setLooping(true);
    }
    if (widget.config.autoPlay) {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildDefaultError();
    }

    if (!_isInitialized || _controller == null) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    final aspectRatio =
        widget.config.aspectRatio ?? _controller!.value.aspectRatio;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: FittedBox(
        fit: widget.config.fit,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildDefaultLoading() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.black.withValues(alpha: 0.05),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.black.withValues(alpha: 0.05),
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
      ),
    );
  }
}