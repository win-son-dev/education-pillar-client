import 'package:centralized_library/centralized_library.dart';

/// Configuration for video loading and gestures
class VideoConfig extends Equatable {
  // Video source
  final String url;
  final double? aspectRatio;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool muted;
  final bool useCache;
  final String? description;

  // Thumbnail settings
  final int thumbnailTimeMs;
  final int thumbnailQuality;

  // Gesture callbacks
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  // Gesture feedback (null = no feedback shown)
  final IconData? swipeUpIcon;
  final String? swipeUpLabel;
  final IconData? swipeDownIcon;
  final String? swipeDownLabel;
  final IconData? swipeLeftIcon;
  final String? swipeLeftLabel;
  final IconData? swipeRightIcon;
  final String? swipeRightLabel;

  // Double-tap seek settings
  final bool enableDoubleTapSeek;
  final int seekSeconds;
  final IconData? seekForwardIcon;
  final IconData? seekBackwardIcon;

  // Gesture thresholds
  final double swipeVelocityThreshold;
  final double doubleTapZoneRatio;

  const VideoConfig({
    required this.url,
    this.aspectRatio,
    this.fit = BoxFit.contain,
    this.autoPlay = false,
    this.looping = false,
    this.muted = false,
    this.useCache = true,
    this.description,
    this.thumbnailTimeMs = 0,
    this.thumbnailQuality = 75,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeUpIcon,
    this.swipeUpLabel,
    this.swipeDownIcon,
    this.swipeDownLabel,
    this.swipeLeftIcon,
    this.swipeLeftLabel,
    this.swipeRightIcon,
    this.swipeRightLabel,
    this.enableDoubleTapSeek = true,
    this.seekSeconds = 10,
    this.seekForwardIcon,
    this.seekBackwardIcon,
    this.swipeVelocityThreshold = 500.0,
    this.doubleTapZoneRatio = 0.35,
  });

  /// Simple video player - only double-tap to seek, no swipe gestures
  factory VideoConfig.simple({
    required String url,
    String? description,
    bool autoPlay = false,
    bool looping = false,
    int seekSeconds = 10,
    int thumbnailTimeMs = 0,
    int thumbnailQuality = 75,
  }) {
    return VideoConfig(
      url: url,
      description: description,
      autoPlay: autoPlay,
      looping: looping,
      enableDoubleTapSeek: true,
      seekSeconds: seekSeconds,
      seekForwardIcon: Icons.forward_10_rounded,
      seekBackwardIcon: Icons.replay_10_rounded,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  /// YouTube-style - swipe up/down for navigation, double-tap to seek
  factory VideoConfig.youtubeStyle({
    required String url,
    VoidCallback? onSwipeDown,
    VoidCallback? onSwipeUp,
    String? description,
    bool autoPlay = true,
    int seekSeconds = 10,
    int thumbnailTimeMs = 1000,
    int thumbnailQuality = 80,
  }) {
    return VideoConfig(
      url: url,
      autoPlay: autoPlay,
      description: description,
      onSwipeDown: onSwipeDown,
      onSwipeUp: onSwipeUp,
      swipeDownIcon: Icons.arrow_downward_rounded,
      swipeDownLabel: 'Next',
      swipeUpIcon: Icons.arrow_upward_rounded,
      swipeUpLabel: 'Previous',
      enableDoubleTapSeek: true,
      seekSeconds: seekSeconds,
      seekForwardIcon: Icons.forward_10_rounded,
      seekBackwardIcon: Icons.replay_10_rounded,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  /// TikTok-style - swipe up/down for navigation, no seek controls
  factory VideoConfig.tiktokStyle({
    required String url,
    VoidCallback? onSwipeDown,
    VoidCallback? onSwipeUp,
    String? description,
    bool autoPlay = true,
    bool looping = true,
    int thumbnailTimeMs = 0,
    int thumbnailQuality = 75,
  }) {
    return VideoConfig(
      url: url,
      autoPlay: autoPlay,
      looping: looping,
      description: description,
      onSwipeDown: onSwipeDown,
      onSwipeUp: onSwipeUp,
      swipeDownIcon: Icons.arrow_downward_rounded,
      swipeUpIcon: Icons.arrow_upward_rounded,
      enableDoubleTapSeek: false,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  /// Instagram-style - swipe left/right, double-tap to seek
  factory VideoConfig.instagramStyle({
    required String url,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    String? description,
    bool autoPlay = true,
    int seekSeconds = 10,
    int thumbnailTimeMs = 500,
    int thumbnailQuality = 80,
  }) {
    return VideoConfig(
      url: url,
      autoPlay: autoPlay,
      description: description,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      swipeLeftIcon: Icons.arrow_back_rounded,
      swipeLeftLabel: 'Back',
      swipeRightIcon: Icons.arrow_forward_rounded,
      swipeRightLabel: 'Next',
      enableDoubleTapSeek: true,
      seekSeconds: seekSeconds,
      seekForwardIcon: Icons.forward_10_rounded,
      seekBackwardIcon: Icons.replay_10_rounded,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  /// Stories-style - swipe left to close, tap to pause
  factory VideoConfig.storiesStyle({
    required String url,
    VoidCallback? onSwipeLeft,
    String? description,
    bool autoPlay = true,
    bool looping = false,
    int thumbnailTimeMs = 0,
    int thumbnailQuality = 75,
  }) {
    return VideoConfig(
      url: url,
      autoPlay: autoPlay,
      looping: looping,
      description: description,
      onSwipeLeft: onSwipeLeft,
      swipeLeftIcon: Icons.close_rounded,
      swipeLeftLabel: 'Close',
      enableDoubleTapSeek: false,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  /// Feed-style - vertical swipe for navigation, horizontal swipe for actions
  factory VideoConfig.feedStyle({
    required String url,
    VoidCallback? onSwipeDown,
    VoidCallback? onSwipeUp,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    String? description,
    String? swipeLeftLabel,
    String? swipeRightLabel,
    IconData? swipeLeftIcon,
    IconData? swipeRightIcon,
    bool autoPlay = true,
    int seekSeconds = 10,
    int thumbnailTimeMs = 1000,
    int thumbnailQuality = 80,
  }) {
    return VideoConfig(
      url: url,
      autoPlay: autoPlay,
      description: description,
      onSwipeDown: onSwipeDown,
      onSwipeUp: onSwipeUp,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      swipeDownIcon: Icons.arrow_downward_rounded,
      swipeDownLabel: 'Next',
      swipeUpIcon: Icons.arrow_upward_rounded,
      swipeUpLabel: 'Previous',
      swipeLeftIcon: swipeLeftIcon ?? Icons.close_rounded,
      swipeLeftLabel: swipeLeftLabel ?? 'Close',
      swipeRightIcon: swipeRightIcon ?? Icons.share_rounded,
      swipeRightLabel: swipeRightLabel ?? 'Share',
      enableDoubleTapSeek: true,
      seekSeconds: seekSeconds,
      seekForwardIcon: Icons.forward_10_rounded,
      seekBackwardIcon: Icons.replay_10_rounded,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  /// No gestures - only manual controls
  factory VideoConfig.noGestures({
    required String url,
    String? description,
    bool autoPlay = false,
    bool looping = false,
    int thumbnailTimeMs = 0,
    int thumbnailQuality = 75,
  }) {
    return VideoConfig(
      url: url,
      description: description,
      autoPlay: autoPlay,
      looping: looping,
      enableDoubleTapSeek: false,
      thumbnailTimeMs: thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality,
    );
  }

  VideoConfig copyWith({
    String? url,
    double? aspectRatio,
    BoxFit? fit,
    bool? autoPlay,
    bool? looping,
    bool? muted,
    bool? useCache,
    String? description,
    int? thumbnailTimeMs,
    int? thumbnailQuality,
    VoidCallback? onSwipeUp,
    VoidCallback? onSwipeDown,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    IconData? swipeUpIcon,
    String? swipeUpLabel,
    IconData? swipeDownIcon,
    String? swipeDownLabel,
    IconData? swipeLeftIcon,
    String? swipeLeftLabel,
    IconData? swipeRightIcon,
    String? swipeRightLabel,
    bool? enableDoubleTapSeek,
    int? seekSeconds,
    IconData? seekForwardIcon,
    IconData? seekBackwardIcon,
    double? swipeVelocityThreshold,
    double? doubleTapZoneRatio,
  }) {
    return VideoConfig(
      url: url ?? this.url,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      fit: fit ?? this.fit,
      autoPlay: autoPlay ?? this.autoPlay,
      looping: looping ?? this.looping,
      muted: muted ?? this.muted,
      useCache: useCache ?? this.useCache,
      description: description ?? this.description,
      thumbnailTimeMs: thumbnailTimeMs ?? this.thumbnailTimeMs,
      thumbnailQuality: thumbnailQuality ?? this.thumbnailQuality,
      onSwipeUp: onSwipeUp ?? this.onSwipeUp,
      onSwipeDown: onSwipeDown ?? this.onSwipeDown,
      onSwipeLeft: onSwipeLeft ?? this.onSwipeLeft,
      onSwipeRight: onSwipeRight ?? this.onSwipeRight,
      swipeUpIcon: swipeUpIcon ?? this.swipeUpIcon,
      swipeUpLabel: swipeUpLabel ?? this.swipeUpLabel,
      swipeDownIcon: swipeDownIcon ?? this.swipeDownIcon,
      swipeDownLabel: swipeDownLabel ?? this.swipeDownLabel,
      swipeLeftIcon: swipeLeftIcon ?? this.swipeLeftIcon,
      swipeLeftLabel: swipeLeftLabel ?? this.swipeLeftLabel,
      swipeRightIcon: swipeRightIcon ?? this.swipeRightIcon,
      swipeRightLabel: swipeRightLabel ?? this.swipeRightLabel,
      enableDoubleTapSeek: enableDoubleTapSeek ?? this.enableDoubleTapSeek,
      seekSeconds: seekSeconds ?? this.seekSeconds,
      seekForwardIcon: seekForwardIcon ?? this.seekForwardIcon,
      seekBackwardIcon: seekBackwardIcon ?? this.seekBackwardIcon,
      swipeVelocityThreshold: swipeVelocityThreshold ?? this.swipeVelocityThreshold,
      doubleTapZoneRatio: doubleTapZoneRatio ?? this.doubleTapZoneRatio,
    );
  }

  @override
  List<Object?> get props => [
    url,
    aspectRatio,
    fit,
    autoPlay,
    looping,
    muted,
    useCache,
    description,
    thumbnailTimeMs,
    thumbnailQuality,
    onSwipeUp,
    onSwipeDown,
    onSwipeLeft,
    onSwipeRight,
    swipeUpIcon,
    swipeUpLabel,
    swipeDownIcon,
    swipeDownLabel,
    swipeLeftIcon,
    swipeLeftLabel,
    swipeRightIcon,
    swipeRightLabel,
    enableDoubleTapSeek,
    seekSeconds,
    seekForwardIcon,
    seekBackwardIcon,
    swipeVelocityThreshold,
    doubleTapZoneRatio,
  ];
}