import 'dart:io';
import 'package:flutter/material.dart';
import '../../../centralized_library.dart';

class LottieLoader extends StatelessWidget {
  final String path;
  final String? package;
  final double? width;
  final double? height;
  final bool repeat;
  final bool animate;
  final bool reverse;
  final BoxFit fit;
  final FrameRate frameRate;

  /// Set to true if loading from local storage (downloaded files)
  /// Set to false (default) if loading from bundled assets
  final bool isLocalFile;

  /// Widget to show while loading local file path
  final Widget? loadingWidget;

  const LottieLoader({
    super.key,
    this.path = 'assets/loading/bouncing_balls_loading.json',
    this.package = 'centralized_library',
    this.width = 150,
    this.height = 150,
    this.repeat = true,
    this.animate = true,
    this.reverse = false,
    this.fit = BoxFit.contain,
    this.frameRate = FrameRate.composition,
    this.isLocalFile = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Load from bundled assets
    if (!isLocalFile) {
      return Lottie.asset(
        path,
        package: package,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
        reverse: reverse,
        frameRate: frameRate,
      );
    }

    // Load from local storage (downloaded file)
    return FutureBuilder<String>(
      future: FirebaseAssetDownloadManager().getLocalPath(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          // Don't show error details to user
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: (width ?? 150) * 0.3,
                color: Colors.grey,
              ),
            ),
          );
        }

        return Lottie.file(
          File(snapshot.data!),
          width: width,
          height: height,
          fit: fit,
          repeat: repeat,
          animate: animate,
          reverse: reverse,
          frameRate: frameRate,
        );
      },
    );
  }
}