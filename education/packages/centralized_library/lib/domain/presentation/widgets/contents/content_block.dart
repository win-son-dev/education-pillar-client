import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/content_block_entity.dart';
import '../../media/audio_player_widget.dart';
import '../../media/video_config.dart';
import '../media_loader.dart';
import '../../media/video_loader.dart';
import 'content_block_config.dart';

const double _kVerticalSpacing = 16.0;
const double _kContentPadding = 16.0;
const double _kBorderRadius = 8.0;
const double _kQuoteBorderWidth = 4.0;
const double _kDividerHeight = 1.0;


const double _kCaptionTopSpacing = 8.0;
const double _kDefaultPlayButtonSize = 64.0;

class ContentBlock extends StatelessWidget {
  final ContentBlockEntity block;
  final ContentBlocksConfig? config;

  const ContentBlock({
    super.key,
    required this.block,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: config?.padding ??  const EdgeInsets.symmetric(horizontal: 16),
      child: _buildBlockContent(context),
    );
  }

  Widget _buildBlockContent(BuildContext context) {
    switch (block.type) {
      case ContentBlockType.text:
        return TextContentBlock(
          content: block.content,
          fontFamily: config?.fontFamily,
        );
      case ContentBlockType.heading:
        return HeadingContentBlock(
          content: block.content,
          fontFamily: config?.fontFamily,
          level: block.headingLevel,
        );
      case ContentBlockType.quote:
        return QuoteContentBlock(
          content: block.content,
          fontFamily: config?.fontFamily,
          author: block.credit,
        );
      case ContentBlockType.image:
        return ImageContentBlock(
          imageUrl: block.content,
          caption: block.caption,
          credit: block.credit,
        );
      case ContentBlockType.video:
        return VideoContentBlock(
          videoUrl: block.content,
          caption: block.caption,
          aspectRatio: block.videoAspectRatio,
          autoPlay: block.videoAutoPlay,
          looping: block.videoLooping,
          muted: block.videoMuted,
        );
      case ContentBlockType.audio:
        return AudioContentBlock(
          audioUrl: block.content,
          caption: block.caption,
          autoPlay: block.audioAutoPlay,
          loop: block.audioLoop,
        );
      case ContentBlockType.code:
        return CodeContentBlock(
          content: block.content,
          language: block.codeLanguage,
        );
      case ContentBlockType.list:
        return ListContentBlock(
          items: block.listItems,
          ordered: block.isOrderedList,
          fontFamily: config?.fontFamily,
        );
      case ContentBlockType.divider:
        return const DividerContentBlock();
    }
  }
}

class HtmlLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const HtmlLinkText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  bool _isInternalRoute(String url) {
    return !url.contains('://') || url.startsWith('/');
  }

  Future<void> _handleLinkAsync(BuildContext context, String url) async {
    if (_isInternalRoute(url)) {
      context.push(url.startsWith('/') ? url : '/$url');
    } else {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<InlineSpan> _parseHtmlLinks(BuildContext context) {
    final spans = <InlineSpan>[];
    final linkPattern = RegExp(r'<a href="([^"]+)">([^<]+)</a>');
    final matches = linkPattern.allMatches(text);

    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }

    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final url = match.group(1)!;
      final linkText = match.group(2)!;

      spans.add(
        TextSpan(
          text: linkText,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleLinkAsync(context, url),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: _parseHtmlLinks(context),
        style: style,
      ),
      textAlign: textAlign,
    );
  }
}

class TextContentBlock extends StatelessWidget {
  final String content;
  final String? fontFamily;

  const TextContentBlock({
    super.key,
    required this.content,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: HtmlLinkText(
        text: content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontSize: 16,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}

class HeadingContentBlock extends StatelessWidget {
  final String content;
  final String? fontFamily;
  final int level;

  const HeadingContentBlock({
    super.key,
    required this.content,
    this.fontFamily,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = switch (level) {
      1 => 24.0,
      2 => 20.0,
      3 => 18.0,
      _ => 16.0,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: HtmlLinkText(
        text: content,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.3,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}

class QuoteContentBlock extends StatelessWidget {
  final String content;
  final String? fontFamily;
  final String? author;

  const QuoteContentBlock({
    super.key,
    required this.content,
    this.fontFamily,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: _kVerticalSpacing),
      padding: const EdgeInsets.all(_kContentPadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(_kBorderRadius),
          bottomRight: Radius.circular(_kBorderRadius),
        ),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: _kQuoteBorderWidth,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlLinkText(
            text: content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: Colors.grey[700],
              fontFamily: fontFamily,
            ),
          ),
          if (author != null) ...[
            const SizedBox(height: 8),
            Text(
              '— $author',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontFamily: fontFamily,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ImageContentBlock extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  final String? credit;

  const ImageContentBlock({
    super.key,
    required this.imageUrl,
    this.caption,
    this.credit,
  });

  void _openFullscreenAsync(BuildContext context) {
    context.push(
      '/fullscreen-image',
      extra: {
        'imageUrl': imageUrl,
        'caption': caption,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _kVerticalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _openFullscreenAsync(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kBorderRadius),
              child: MediaLoader(
                config: MediaConfig.network(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (caption != null || credit != null) ...[
            const SizedBox(height: 8),
            if (caption != null)
              Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            if (credit != null)
              Text(
                credit!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class VideoContentBlock extends StatefulWidget {
  final String videoUrl;
  final String? caption;
  final double? aspectRatio;
  final bool autoPlay;
  final bool looping;
  final bool muted;
  final double playButtonSize;
  final Color playButtonColor;
  final Color playButtonIconColor;

  const VideoContentBlock({
    super.key,
    required this.videoUrl,
    this.caption,
    this.aspectRatio,
    this.autoPlay = false,
    this.looping = false,
    this.muted = false,
    this.playButtonSize = _kDefaultPlayButtonSize,
    this.playButtonColor = Colors.black54,
    this.playButtonIconColor = Colors.white,
  });

  @override
  State<VideoContentBlock> createState() => _VideoContentBlockState();
}

class _VideoContentBlockState extends State<VideoContentBlock> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void dispose() {
    _removeControllerListener();
    super.dispose();
  }

  void _onControllerReady(VideoPlayerController controller) {
    _controller = controller;
    controller.addListener(_onControllerStateChanged);
    _updatePlayingState();
  }

  void _onControllerStateChanged() {
    _updatePlayingState();
  }

  void _updatePlayingState() {
    if (!mounted) return;
    final isPlaying = _controller?.value.isPlaying ?? false;
    if (_isPlaying != isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }
  }

  void _removeControllerListener() {
    _controller?.removeListener(_onControllerStateChanged);
  }

  Future<void> _togglePlayPauseAsync() async {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
  }

  void _openFullscreen(BuildContext context) {
    final fullscreenConfig = VideoConfig.storiesStyle(
      url: widget.videoUrl,
      autoPlay: true,
      description: widget.caption,
      onSwipeLeft: () => context.pop(),
    );

    context.push('/fullscreen-video', extra: fullscreenConfig);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _kVerticalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVideoContainer(context),
          if (widget.caption != null) _buildCaption(context),
        ],
      ),
    );
  }

  Widget _buildVideoContainer(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kBorderRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoLoader(
              config: VideoConfig(
                url: widget.videoUrl,
                aspectRatio: widget.aspectRatio,
                autoPlay: widget.autoPlay,
                looping: widget.looping,
                muted: widget.muted,
              ),
              onControllerReady: _onControllerReady,
            ),
            if (!_isPlaying) _buildPlayButtonOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButtonOverlay() {
    return GestureDetector(
      onTap: _togglePlayPauseAsync,
      child: Container(
        width: widget.playButtonSize,
        height: widget.playButtonSize,
        decoration: BoxDecoration(
          color: widget.playButtonColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: widget.playButtonIconColor,
          size: widget.playButtonSize * 0.6,
        ),
      ),
    );
  }

  Widget _buildCaption(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: _kCaptionTopSpacing),
      child: Text(
        widget.caption!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class AudioContentBlock extends StatelessWidget {
  final String audioUrl;
  final String? caption;
  final bool autoPlay;
  final bool loop;

  const AudioContentBlock({
    super.key,
    required this.audioUrl,
    this.caption,
    this.autoPlay = false,
    this.loop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _kVerticalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AudioPlayerWidget(
            audioUrl: audioUrl,
            autoPlay: autoPlay,
            loop: loop,
          ),
          if (caption != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CodeContentBlock extends StatelessWidget {
  final String content;
  final String? language;

  const CodeContentBlock({
    super.key,
    required this.content,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: _kVerticalSpacing),
      padding: const EdgeInsets.all(_kContentPadding),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(_kBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language != null) ...[
            Text(
              language!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListContentBlock extends StatelessWidget {
  final List<String> items;
  final bool ordered;
  final String? fontFamily;

  const ListContentBlock({
    super.key,
    required this.items,
    this.ordered = false,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final prefix = ordered ? '${index + 1}. ' : '• ';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefix,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: fontFamily,
                  ),
                ),
                Expanded(
                  child: HtmlLinkText(
                    text: items[index],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class DividerContentBlock extends StatelessWidget {
  const DividerContentBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _kVerticalSpacing),
      child: Divider(
        height: _kDividerHeight,
        thickness: _kDividerHeight,
        color: Colors.grey[300],
      ),
    );
  }
}