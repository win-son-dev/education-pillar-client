import 'dart:io';
import 'dart:typed_data';
import 'package:centralized_library/centralized_library.dart';
import 'package:video_compress/video_compress.dart';

/// Global cache manager for video thumbnails
final globalThumbnailCacheManager = CacheManager(
  Config(
    'globalThumbnailCache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 100,
  ),
);

/// A widget that loads and displays video thumbnails using VideoConfig
class VideoThumbnailLoader extends StatefulWidget {
  final VideoConfig config;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onTap;

  const VideoThumbnailLoader({
    super.key,
    required this.config,
    this.loadingWidget,
    this.errorWidget,
    this.onTap,
  });

  @override
  State<VideoThumbnailLoader> createState() => _VideoThumbnailLoaderState();
}

class _VideoThumbnailLoaderState extends State<VideoThumbnailLoader> {
  Uint8List? _thumbnailData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnailAsync();
  }

  @override
  void didUpdateWidget(VideoThumbnailLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.url != widget.config.url ||
        oldWidget.config.thumbnailTimeMs != widget.config.thumbnailTimeMs) {
      _loadThumbnailAsync();
    }
  }

  @override
  void dispose() {
    _thumbnailData = null;
    super.dispose();
  }

  Future<void> _loadThumbnailAsync() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _thumbnailData = null;
    });

    final resolvedUrl = await _resolveUrlAsync(widget.config.url);

    if (!mounted) return;

    final thumbnailData = await _generateThumbnailAsync(resolvedUrl);

    if (!mounted) return;

    if (thumbnailData != null) {
      setState(() {
        _thumbnailData = thumbnailData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<String> _resolveUrlAsync(String url) async {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return FirebaseStorage.instance.ref().child(url).getDownloadURL();
  }

  Future<Uint8List?> _generateThumbnailAsync(String videoUrl) async {
    if (!widget.config.useCache) {
      return _extractThumbnailAsync(videoUrl);
    }

    final cacheKey = _generateCacheKey(videoUrl);
    final cachedFile =
    await globalThumbnailCacheManager.getFileFromCache(cacheKey);

    if (cachedFile != null) {
      return cachedFile.file.readAsBytes();
    }

    final thumbnailData = await _extractThumbnailAsync(videoUrl);

    if (thumbnailData != null) {
      _cacheThumbnailInBackgroundAsync(cacheKey, thumbnailData);
    }

    return thumbnailData;
  }

  Future<Uint8List?> _extractThumbnailAsync(String videoUrl) async {
    // Using video_compress instead of video_thumbnail
    final thumbnailFile = await VideoCompress.getFileThumbnail(
      videoUrl,
      quality: widget.config.thumbnailQuality,
      position: widget.config.thumbnailTimeMs,
    );

    if (thumbnailFile == null) return null;

    return thumbnailFile.readAsBytes();
  }

  Future<void> _cacheThumbnailInBackgroundAsync(
      String cacheKey,
      Uint8List data,
      ) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$cacheKey.png');
    await tempFile.writeAsBytes(data);
    await globalThumbnailCacheManager.putFile(cacheKey, data);
  }

  String _generateCacheKey(String url) {
    return '${url.hashCode}_${widget.config.thumbnailTimeMs}_${widget.config.thumbnailQuality}';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildDefaultError();
    }

    if (_isLoading || _thumbnailData == null) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    final thumbnail = Image.memory(
      _thumbnailData!,
      fit: widget.config.fit,
      width: double.infinity,
      height: double.infinity,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: thumbnail,
      );
    }

    return thumbnail;
  }

  Widget _buildDefaultLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.05),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.05),
      child: const Center(
        child: Icon(
          Icons.video_library_outlined,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}