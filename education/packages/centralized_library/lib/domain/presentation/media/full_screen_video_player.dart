import 'dart:async';
import 'package:centralized_library/centralized_library.dart';
import 'package:centralized_library/domain/presentation/media/video_config.dart';
import 'package:centralized_library/domain/presentation/media/video_gesture_detector.dart';

const double _kControlPadding = 16.0;
const double _kCloseIconSize = 28.0;
const double _kPlayPauseIconSize = 32.0;
const double _kProgressBarSpacing = 8.0;
const double _kTimestampFontSize = 14.0;
const double _kDescriptionFontSize = 14.0;
const double _kDescriptionSpacing = 12.0;
const Duration _kControlsAutoHideDuration = Duration(seconds: 3);

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoConfig config;

  const FullscreenVideoPlayer({
    super.key,
    required this.config,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _setFullscreenMode();
    _startControlsTimer();
  }

  @override
  void dispose() {
    _cancelControlsTimer();
    _removeControllerListener();
    _restoreSystemUI();
    super.dispose();
  }

  void _setFullscreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  void _onControllerReady(VideoPlayerController controller) {
    _controller = controller;
    controller.addListener(_onControllerStateChanged);
  }

  void _onControllerStateChanged() {
    if (mounted) setState(() {});
  }

  void _removeControllerListener() {
    _controller?.removeListener(_onControllerStateChanged);
  }

  Future<void> _togglePlayPauseAsync() async {
    if (_controller == null) return;

    _cancelControlsTimer();

    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
      _startControlsTimer();
    }

    if (mounted) setState(() {});
  }

  void _toggleControls() {
    _cancelControlsTimer();

    setState(() => _showControls = !_showControls);

    if (_showControls && _controller?.value.isPlaying == true) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _cancelControlsTimer();
    _controlsTimer = Timer(_kControlsAutoHideDuration, () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _cancelControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: VideoGestureDetector(
        config: widget.config,
        controller: _controller,
        onSingleTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideoPlayer(),
            if (_showControls) ...[
              _buildTopControls(context),
              if (_controller != null) _buildBottomControls(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Center(
      child: VideoLoader(
        config: widget.config,
        onControllerReady: _onControllerReady,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            label: const Text(
              'Go Back',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(_kControlPadding),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: _kCloseIconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(_kControlPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.config.description != null) ...[
                Text(
                  widget.config.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: _kDescriptionFontSize,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: _kDescriptionSpacing),
              ],
              _buildProgressBar(theme),
              const SizedBox(height: _kProgressBarSpacing),
              _buildControlsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return VideoProgressIndicator(
      _controller!,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: theme.primaryColor,
        bufferedColor: Colors.grey.withValues(alpha: 0.5),
        backgroundColor: Colors.grey.withValues(alpha: 0.3),
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildControlsRow() {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isPlaying = _controller!.value.isPlaying;

    return Row(
      children: [
        IconButton(
          onPressed: _togglePlayPauseAsync,
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: _kPlayPauseIconSize,
          ),
        ),
        const Spacer(),
        Text(
          '${_formatDuration(position)} / ${_formatDuration(duration)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: _kTimestampFontSize,
          ),
        ),
      ],
    );
  }
}