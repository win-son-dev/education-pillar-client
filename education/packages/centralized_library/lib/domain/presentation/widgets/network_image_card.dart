import 'package:flutter/material.dart';
import 'media_loader.dart';

class NetworkImageCard extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final bool enableZoom;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const NetworkImageCard({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.enableZoom = false,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = MediaLoader(
      config: MediaConfig.network(imageUrl),
      fit: fit,
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    if (width != null || height != null) {
      image = SizedBox(
        width: width,
        height: height,
        child: image,
      );
    }

    if (onTap != null || onLongPress != null || onDoubleTap != null) {
      image = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: image,
      );
    }

    if (enableZoom) {
      image = InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: image,
      );
    }

    return image;
  }
}