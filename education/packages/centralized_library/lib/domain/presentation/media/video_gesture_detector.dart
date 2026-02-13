import 'dart:async';
import 'package:centralized_library/centralized_library.dart';
import 'package:centralized_library/domain/presentation/media/video_config.dart';

const double _kFeedbackIconSize = 56.0;
const double _kFeedbackLabelSpacing = 8.0;
const double _kFeedbackLabelFontSize = 14.0;
const Duration _kFeedbackDuration = Duration(milliseconds: 600);

class VideoGestureDetector extends StatefulWidget {
  final VideoConfig config;
  final VideoPlayerController? controller;
  final VoidCallback onSingleTap;
  final Widget child;

  const VideoGestureDetector({
    super.key,
    required this.config,
    required this.onSingleTap,
    required this.child,
    this.controller,
  });

  @override
  State<VideoGestureDetector> createState() => _VideoGestureDetectorState();
}

class _VideoGestureDetectorState extends State<VideoGestureDetector> {
  IconData? _feedbackIcon;
  String? _feedbackLabel;
  Timer? _feedbackTimer;
  Offset? _dragStart;

  @override
  void dispose() {
    _cancelFeedbackTimer();
    super.dispose();
  }

  void _cancelFeedbackTimer() {
    _feedbackTimer?.cancel();
    _feedbackTimer = null;
  }

  void _showFeedback(IconData? icon, String? label) {
    if (icon == null) return;

    _cancelFeedbackTimer();

    setState(() {
      _feedbackIcon = icon;
      _feedbackLabel = label;
    });

    _feedbackTimer = Timer(_kFeedbackDuration, () {
      if (mounted) {
        setState(() {
          _feedbackIcon = null;
          _feedbackLabel = null;
        });
      }
    });
  }

  Future<void> _handleDoubleTapAsync(TapDownDetails details) async {
    if (!widget.config.enableDoubleTapSeek || widget.controller == null) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.localPosition.dx;
    final leftZone = screenWidth * widget.config.doubleTapZoneRatio;
    final rightZone = screenWidth * (1 - widget.config.doubleTapZoneRatio);

    final isLeftZone = tapX < leftZone;
    final isRightZone = tapX > rightZone;

    if (!isLeftZone && !isRightZone) return;

    final currentPosition = widget.controller!.value.position;
    final duration = widget.controller!.value.duration;
    final seekAmount = widget.config.seekSeconds;

    final newPosition = isLeftZone
        ? currentPosition - Duration(seconds: seekAmount)
        : currentPosition + Duration(seconds: seekAmount);

    // Clamp position between zero and duration
    final clampedPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(
        0,
        duration.inMilliseconds,
      ),
    );

    await widget.controller!.seekTo(clampedPosition);

    _showFeedback(
      isLeftZone ? widget.config.seekBackwardIcon : widget.config.seekForwardIcon,
      '${seekAmount}s',
    );
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragStart == null) return;

    final velocity = details.velocity.pixelsPerSecond.dy;

    if (velocity.abs() < widget.config.swipeVelocityThreshold) {
      _dragStart = null;
      return;
    }

    if (velocity < 0) {
      widget.config.onSwipeUp?.call();
      _showFeedback(widget.config.swipeUpIcon, widget.config.swipeUpLabel);
    } else {
      widget.config.onSwipeDown?.call();
      _showFeedback(widget.config.swipeDownIcon, widget.config.swipeDownLabel);
    }

    _dragStart = null;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_dragStart == null) return;

    final velocity = details.velocity.pixelsPerSecond.dx;

    if (velocity.abs() < widget.config.swipeVelocityThreshold) {
      _dragStart = null;
      return;
    }

    if (velocity < 0) {
      widget.config.onSwipeLeft?.call();
      _showFeedback(widget.config.swipeLeftIcon, widget.config.swipeLeftLabel);
    } else {
      widget.config.onSwipeRight?.call();
      _showFeedback(widget.config.swipeRightIcon, widget.config.swipeRightLabel);
    }

    _dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSingleTap,
      onDoubleTapDown: _handleDoubleTapAsync,
      onVerticalDragStart: (details) => _dragStart = details.localPosition,
      onVerticalDragEnd: _handleVerticalDragEnd,
      onHorizontalDragStart: (details) => _dragStart = details.localPosition,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_feedbackIcon != null) _buildFeedbackOverlay(),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _feedbackIcon!,
                  color: Colors.white,
                  size: _kFeedbackIconSize,
                ),
                if (_feedbackLabel != null) ...[
                  const SizedBox(height: _kFeedbackLabelSpacing),
                  Text(
                    _feedbackLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _kFeedbackLabelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}