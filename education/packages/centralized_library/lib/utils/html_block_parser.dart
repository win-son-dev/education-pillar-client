import '../data/content_block_entity.dart';

/// Parses HTML content into a list of [ContentBlockEntity] blocks.
///
/// Supports:
/// - `<p>` tags → text blocks
/// - `<img>` tags → image blocks
/// - `<h1>`-`<h6>` tags → heading blocks
/// - `<blockquote>` tags → quote blocks
/// - `<ul>`, `<ol>` tags → list blocks
/// - Empty paragraphs and `<br>` tags are skipped
class HtmlBlockParser {
  // Regex for matching src attribute (handles both " and ')
  static final _srcPattern = RegExp('src=["\']([^"\']+)["\']', caseSensitive: false);
  // Regex for matching alt attribute
  static final _altPattern = RegExp('alt=["\']([^"\']*)["\']', caseSensitive: false);

  /// Parses HTML string into content blocks
  static List<ContentBlockEntity> parse(String html) {
    if (html.isEmpty) return [];

    final blocks = <ContentBlockEntity>[];
    var remaining = html.trim();

    while (remaining.isNotEmpty) {
      final result = _parseNextBlock(remaining);
      if (result.block != null) {
        blocks.add(result.block!);
      }
      if (result.consumed == 0) {
        // Safety: prevent infinite loop if we can't parse anything
        break;
      }
      remaining = remaining.substring(result.consumed).trim();
    }

    return blocks;
  }

  static _ParseResult _parseNextBlock(String html) {
    // Try to match different HTML elements
    final headingMatch = RegExp(r'^<h([1-6])[^>]*>(.*?)</h\1>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (headingMatch != null) {
      final level = int.parse(headingMatch.group(1)!);
      final content = _stripTags(headingMatch.group(2) ?? '').trim();
      if (content.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.heading(content, level: level),
          consumed: headingMatch.end,
        );
      }
      return _ParseResult(consumed: headingMatch.end);
    }

    // Image tag
    final imgMatch = RegExp(r'^<img[^>]+/?>', caseSensitive: false).firstMatch(html);
    if (imgMatch != null) {
      final imgTag = imgMatch.group(0) ?? '';
      final srcMatch = _srcPattern.firstMatch(imgTag);
      final src = srcMatch?.group(1) ?? '';
      final altMatch = _altPattern.firstMatch(imgTag);
      final caption = altMatch?.group(1);
      if (src.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.image(src, caption: caption),
          consumed: imgMatch.end,
        );
      }
      return _ParseResult(consumed: imgMatch.end);
    }

    // Blockquote
    final quoteMatch = RegExp(r'^<blockquote[^>]*>(.*?)</blockquote>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (quoteMatch != null) {
      final content = _stripTags(quoteMatch.group(1) ?? '').trim();
      if (content.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.quote(content),
          consumed: quoteMatch.end,
        );
      }
      return _ParseResult(consumed: quoteMatch.end);
    }

    // Unordered list
    final ulMatch = RegExp(r'^<ul[^>]*>(.*?)</ul>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (ulMatch != null) {
      final items = _parseListItems(ulMatch.group(1) ?? '');
      if (items.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.list(items, ordered: false),
          consumed: ulMatch.end,
        );
      }
      return _ParseResult(consumed: ulMatch.end);
    }

    // Ordered list
    final olMatch = RegExp(r'^<ol[^>]*>(.*?)</ol>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (olMatch != null) {
      final items = _parseListItems(olMatch.group(1) ?? '');
      if (items.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.list(items, ordered: true),
          consumed: olMatch.end,
        );
      }
      return _ParseResult(consumed: olMatch.end);
    }

    // Paragraph
    final pMatch = RegExp(r'^<p[^>]*>(.*?)</p>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (pMatch != null) {
      final innerHtml = pMatch.group(1) ?? '';

      // Check if paragraph contains only an image
      final innerImgMatch = RegExp(r'^\s*<img[^>]+/?>\s*$', caseSensitive: false).firstMatch(innerHtml);
      if (innerImgMatch != null) {
        final srcMatch = _srcPattern.firstMatch(innerHtml);
        final src = srcMatch?.group(1) ?? '';
        final altMatch = _altPattern.firstMatch(innerHtml);
        final caption = altMatch?.group(1);
        if (src.isNotEmpty) {
          return _ParseResult(
            block: ContentBlockEntity.image(src, caption: caption),
            consumed: pMatch.end,
          );
        }
      }

      final content = _stripTags(innerHtml).trim();
      if (content.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.text(content),
          consumed: pMatch.end,
        );
      }
      return _ParseResult(consumed: pMatch.end);
    }

    // Div (treat content inside as blocks)
    final divMatch = RegExp(r'^<div[^>]*>(.*?)</div>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (divMatch != null) {
      final innerHtml = divMatch.group(1) ?? '';
      final innerBlocks = parse(innerHtml);
      if (innerBlocks.isNotEmpty) {
        // Return first block and continue parsing
        return _ParseResult(
          block: innerBlocks.first,
          consumed: divMatch.end,
        );
      }
      return _ParseResult(consumed: divMatch.end);
    }

    // Skip br tags
    final brMatch = RegExp(r'^<br\s*/?>', caseSensitive: false).firstMatch(html);
    if (brMatch != null) {
      return _ParseResult(consumed: brMatch.end);
    }

    // Skip other self-closing or empty tags
    final emptyTagMatch = RegExp(r'^<[^>]+/?>').firstMatch(html);
    if (emptyTagMatch != null) {
      return _ParseResult(consumed: emptyTagMatch.end);
    }

    // Plain text before next tag
    final nextTagIndex = html.indexOf('<');
    if (nextTagIndex > 0) {
      final textContent = html.substring(0, nextTagIndex).trim();
      if (textContent.isNotEmpty) {
        return _ParseResult(
          block: ContentBlockEntity.text(textContent),
          consumed: nextTagIndex,
        );
      }
      return _ParseResult(consumed: nextTagIndex);
    }

    // No more tags, remaining is plain text
    final trimmed = html.trim();
    if (trimmed.isNotEmpty && !trimmed.startsWith('<')) {
      return _ParseResult(
        block: ContentBlockEntity.text(trimmed),
        consumed: html.length,
      );
    }

    // Skip unrecognized tag
    final unknownTagMatch = RegExp(r'^<[^>]+>').firstMatch(html);
    if (unknownTagMatch != null) {
      return _ParseResult(consumed: unknownTagMatch.end);
    }

    return _ParseResult(consumed: html.length);
  }

  static List<String> _parseListItems(String html) {
    final items = <String>[];
    final liMatches = RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true).allMatches(html);
    for (final match in liMatches) {
      final content = _stripTags(match.group(1) ?? '').trim();
      if (content.isNotEmpty) {
        items.add(content);
      }
    }
    return items;
  }

  /// Strips HTML tags and decodes common HTML entities
  static String _stripTags(String html) {
    // Remove all HTML tags
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…')
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®')
        .replaceAll('&trade;', '™');

    // Collapse multiple whitespaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text;
  }
}

class _ParseResult {
  final ContentBlockEntity? block;
  final int consumed;

  _ParseResult({this.block, required this.consumed});
}
