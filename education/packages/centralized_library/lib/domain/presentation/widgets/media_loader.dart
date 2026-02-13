import 'dart:async';

import 'package:centralized_library/centralized_library.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';

class TimeoutFileService extends HttpFileService {
  final Duration timeout;

  TimeoutFileService({this.timeout = const Duration(seconds: 10)});

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) {
    return super.get(url, headers: headers).timeout(
      timeout,
      onTimeout: () => throw TimeoutException('Image load timeout'),
    );
  }
}

/// Global cache manager with timeout support
CacheManager createImageCacheManager(Duration timeout) {
  return CacheManager(
    Config(
      'globalImageCache',
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 200,
      fileService: TimeoutFileService(timeout: timeout),
    ),
  );
}

final globalImageCacheManager = createImageCacheManager(const Duration(seconds: 10));

/// Track pending downloads to avoid duplicate requests
final _pendingDownloads = <String, Future<FileInfo>>{};

/// Download a file with deduplication - prevents multiple downloads of the same URL
Future<FileInfo> downloadWithDeduplicationAsync(
  CacheManager cacheManager,
  String url, {
  String? key,
}) async {
  final cacheKey = key ?? url;

  // Check if already cached
  final cached = await cacheManager.getFileFromCache(cacheKey);
  if (cached != null) return cached;

  // Check if download already in progress
  if (_pendingDownloads.containsKey(cacheKey)) {
    return _pendingDownloads[cacheKey]!;
  }

  // Start new download
  final downloadFuture = cacheManager.downloadFile(url, key: cacheKey).then((fileInfo) {
    _pendingDownloads.remove(cacheKey);
    return fileInfo;
  }).catchError((error) {
    _pendingDownloads.remove(cacheKey);
    throw error;
  });

  _pendingDownloads[cacheKey] = downloadFuture;
  return downloadFuture;
}

/// Represents different types of media that can be loaded
enum MediaType { svg, png, iconData, lottie, network }

/// Configuration for the media to be loaded
class MediaConfig {
  final MediaType type;
  final String? assetPath;
  final String? package;
  final IconData? iconData;
  final Color? color;
  final double? size;
  final bool useOriginalColor;
  final bool animate;
  final bool repeat;
  final AnimationController? controller;
  final void Function(LottieComposition)? onLoaded;
  final Duration? cacheMaxAge;
  final String? cacheKey;
  final Duration timeoutDuration;

  const MediaConfig({
    required this.type,
    this.assetPath,
    this.package,
    this.iconData,
    this.color,
    this.size,
    this.useOriginalColor = false,
    this.animate = true,
    this.repeat = true,
    this.controller,
    this.onLoaded,
    this.cacheMaxAge,
    this.cacheKey,
    this.timeoutDuration = const Duration(seconds: 10),
  }) : assert(
  (type == MediaType.iconData && iconData != null) ||
      (type != MediaType.iconData && assetPath != null),
  'iconData must be provided for IconType.iconData, '
      'assetPath must be provided for other types',
  );

  factory MediaConfig.svg(
      String assetPath, {
        String? package,
        Color? color,
        double? size,
        bool useOriginalColor = true,
      }) =>
      MediaConfig(
        type: MediaType.svg,
        assetPath: assetPath,
        package: package,
        color: color,
        size: size,
        useOriginalColor: useOriginalColor,
      );

  factory MediaConfig.png(
      String assetPath, {
        String? package,
        Color? color,
        double? size,
      }) =>
      MediaConfig(
        type: MediaType.png,
        assetPath: assetPath,
        package: package,
        color: color,
        size: size,
      );

  factory MediaConfig.icon(
      IconData iconData, {
        Color? color,
        double? size,
      }) =>
      MediaConfig(
        type: MediaType.iconData,
        iconData: iconData,
        color: color,
        size: size,
      );

  factory MediaConfig.lottie(
      String assetPath, {
        String? package,
        double? size,
        bool animate = true,
        bool repeat = true,
        AnimationController? controller,
        void Function(LottieComposition)? onLoaded,
      }) =>
      MediaConfig(
        type: MediaType.lottie,
        assetPath: assetPath,
        package: package,
        size: size,
        animate: animate,
        repeat: repeat,
        controller: controller,
        onLoaded: onLoaded,
      );

  factory MediaConfig.network(
      String url, {
        Color? color,
        double? size,
        Duration? cacheMaxAge,
        String? cacheKey,
        Duration timeoutDuration = const Duration(seconds: 10),
      }) =>
      MediaConfig(
        type: MediaType.network,
        assetPath: url,
        color: color,
        size: size,
        cacheMaxAge: cacheMaxAge,
        cacheKey: cacheKey ?? url,
        timeoutDuration: timeoutDuration,
      );
}

/// A widget that loads and displays media from various sources
class MediaLoader extends StatefulWidget {
  final MediaConfig config;
  final double defaultSize;
  final BoxFit fit;
  final VoidCallback? onTap;

  const MediaLoader({
    super.key,
    required this.config,
    this.defaultSize = 24.0,
    this.fit = BoxFit.contain,
    this.onTap,
  });

  @override
  State<MediaLoader> createState() => _MediaLoaderState();
}

class _MediaLoaderState extends State<MediaLoader> {
  String? _resolvedUrl;
  bool _hasError = false;
  CacheManager? _customCacheManager;

  @override
  void initState() {
    super.initState();
    if (widget.config.type == MediaType.network) {
      _initializeCacheManagerIfNeeded();
      _resolveUrlAsync();
    }
  }

  @override
  void didUpdateWidget(MediaLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.type == MediaType.network &&
        (oldWidget.config.assetPath != widget.config.assetPath ||
            oldWidget.config.timeoutDuration != widget.config.timeoutDuration)) {
      _resolvedUrl = null;
      _hasError = false;
      _initializeCacheManagerIfNeeded();
      _resolveUrlAsync();
    }
  }

  @override
  void dispose() {
    _customCacheManager?.dispose();
    super.dispose();
  }

  void _initializeCacheManagerIfNeeded() {
    final needsCustomTimeout =
        widget.config.timeoutDuration != const Duration(seconds: 10);

    if (needsCustomTimeout) {
      _customCacheManager?.dispose();
      _customCacheManager = createImageCacheManager(widget.config.timeoutDuration);
    }
  }

  CacheManager get _effectiveCacheManager =>
      _customCacheManager ?? globalImageCacheManager;

  Future<void> _resolveUrlAsync() async {
    final url = widget.config.assetPath;

    if (url == null || url.isEmpty || url.trim().isEmpty) {
      if (mounted) {
        setState(() => _hasError = true);
      }
      return;
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (mounted) {
        setState(() => _resolvedUrl = url);
      }
      return;
    }

    if (kDebugMode) {
      print('[MediaLoader] Resolving as Storage path: "$url"');
    }

    FirebaseStorage.instance
        .ref()
        .child(url)
        .getDownloadURL()
        .then((firebaseUrl) {
      if (mounted) {
        setState(() => _resolvedUrl = firebaseUrl);
      }
    }).onError((error, stackTrace) {
      if (mounted) {
        setState(() => _hasError = true);
      }
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.config.size ?? widget.defaultSize;
    final color = widget.config.color;

    Widget mediaWidget = _buildMediaWidget(size, color);

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: mediaWidget,
      );
    }

    return mediaWidget;
  }

  Widget _buildMediaWidget(double size, Color? color) {
    switch (widget.config.type) {
      case MediaType.svg:
        return _buildSvgWidget(size, color);
      case MediaType.png:
        return _buildPngWidget(size, color);
      case MediaType.iconData:
        return _buildIconWidget(size, color);
      case MediaType.lottie:
        return _buildLottieWidget(size);
      case MediaType.network:
        return _buildNetworkWidget(size, color);
    }
  }

  Widget _buildSvgWidget(double size, Color? color) {
    return SvgPicture.asset(
      widget.config.assetPath!,
      package: widget.config.package,
      width: size,
      height: size,
      colorFilter: widget.config.useOriginalColor || color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
      fit: widget.fit,
      placeholderBuilder: (context) => _buildPlaceholder(size),
    );
  }

  Widget _buildPngWidget(double size, Color? color) {
    return Image.asset(
      widget.config.assetPath!,
      package: widget.config.package,
      width: size,
      height: size,
      color: color,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(size),
    );
  }

  Widget _buildIconWidget(double size, Color? color) {
    return Icon(
      widget.config.iconData,
      size: size,
      color: color,
    );
  }

  Widget _buildLottieWidget(double size) {
    return Lottie.asset(
      widget.config.assetPath!,
      package: widget.config.package,
      width: size,
      height: size,
      fit: widget.fit,
      animate: widget.config.animate,
      repeat: widget.config.repeat,
      controller: widget.config.controller,
      frameRate: FrameRate.max,
      onLoaded: widget.config.onLoaded,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(size),
    );
  }

  Widget _buildNetworkWidget(double size, Color? color) {
    if (_hasError) {
      return _buildErrorWidget(size);
    }

    if (_resolvedUrl == null) {
      return _buildPlaceholder(size);
    }

    return CachedNetworkImage(
      imageUrl: _resolvedUrl!,
      width: _isFullWidth(size) ? null : size,
      height: _isFullWidth(size) ? null : size,
      fit: widget.fit,
      color: color,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      cacheKey: widget.config.cacheKey,
      cacheManager: _effectiveCacheManager,
      maxHeightDiskCache: _isFullWidth(size) ? null : (size * 2).toInt(),
      maxWidthDiskCache: _isFullWidth(size) ? null : (size * 2).toInt(),
      memCacheWidth: _isFullWidth(size) ? null : (size * 2).toInt(),
      memCacheHeight: _isFullWidth(size) ? null : (size * 2).toInt(),
      placeholder: (context, url) => _buildPlaceholder(size),
      errorWidget: (context, url, error) => _buildErrorWidget(size),
    );
  }

  bool _isFullWidth(double size) =>
      widget.config.type == MediaType.network && size == widget.defaultSize;

  Widget _buildPlaceholder(double size) {
    final placeholder = const _BreathingPlaceholder();

    if (_isFullWidth(size)) {
      return const SizedBox(
        width: double.infinity,
        height: 200,
        child: _BreathingPlaceholder(),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: placeholder,
    );
  }

  Widget _buildErrorWidget(double size) {
    final icon = Icon(
      Icons.image_not_supported_outlined,
      size: _isFullWidth(size) ? 50 : size,
      color: widget.config.color?.withValues(alpha: 0.5),
    );

    if (_isFullWidth(size)) {
      return Container(
        width: double.infinity,
        height: 200,
        color: widget.config.color?.withValues(alpha: 0.1),
        child: Center(child: icon),
      );
    }

    return icon;
  }
}

class _BreathingPlaceholder extends StatelessWidget {
  const _BreathingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}