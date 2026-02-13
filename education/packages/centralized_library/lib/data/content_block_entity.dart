import 'package:equatable/equatable.dart';

enum ContentBlockType {
  text,
  image,
  quote,
  heading,
  video,
  audio,
  code,
  list,
  divider,
}

class ContentBlockEntity extends Equatable {
  final ContentBlockType type;
  final Map<String, dynamic> metadata;

  const ContentBlockEntity({
    required this.type,
    required this.metadata,
  });

  // Convenience getters
  String get content => metadata['content'] as String? ?? '';
  String? get caption => metadata['caption'] as String?;
  String? get credit => metadata['credit'] as String?;

  // Type-specific getters
  int get headingLevel => metadata['level'] as int? ?? 1;
  String? get codeLanguage => metadata['language'] as String?;
  List<String> get listItems => (metadata['items'] as List?)?.cast<String>() ?? [];
  bool get isOrderedList => metadata['ordered'] as bool? ?? false;

  // Video-specific getters
  double? get videoAspectRatio => metadata['aspectRatio'] as double?;
  bool get videoAutoPlay => metadata['autoPlay'] as bool? ?? false;
  bool get videoLooping => metadata['looping'] as bool? ?? false;
  bool get videoMuted => metadata['muted'] as bool? ?? false;

  // Audio-specific getters
  bool get audioAutoPlay => metadata['autoPlay'] as bool? ?? false;
  bool get audioLoop => metadata['loop'] as bool? ?? false;

  @override
  List<Object?> get props => [type, metadata];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'metadata': metadata,
    };
  }

  factory ContentBlockEntity.fromJson(Map<String, dynamic> json) {
    // Safely convert metadata to Map<String, dynamic>
    Map<String, dynamic> metadataMap = {};
    if (json['metadata'] != null) {
      final meta = json['metadata'];
      if (meta is Map) {
        metadataMap = Map<String, dynamic>.from(meta);
      }
    }

    return ContentBlockEntity(
      type: ContentBlockType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => ContentBlockType.text,
      ),
      metadata: metadataMap,
    );
  }

  ContentBlockEntity copyWith({
    ContentBlockType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ContentBlockEntity(
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ContentBlock(type: ${type.name}, metadata: $metadata)';
  }

  // Factory constructors
  factory ContentBlockEntity.text(String content) {
    return ContentBlockEntity(
      type: ContentBlockType.text,
      metadata: {'content': content},
    );
  }

  factory ContentBlockEntity.heading(String content, {int level = 1}) {
    return ContentBlockEntity(
      type: ContentBlockType.heading,
      metadata: {
        'content': content,
        'level': level,
      },
    );
  }

  factory ContentBlockEntity.quote(String content, {String? author}) {
    return ContentBlockEntity(
      type: ContentBlockType.quote,
      metadata: {
        'content': content,
        if (author != null) 'credit': author,
      },
    );
  }

  factory ContentBlockEntity.image(
      String url, {
        String? caption,
        String? credit,
      }) {
    return ContentBlockEntity(
      type: ContentBlockType.image,
      metadata: {
        'content': url,
        if (caption != null) 'caption': caption,
        if (credit != null) 'credit': credit,
      },
    );
  }

  factory ContentBlockEntity.video(
      String url, {
        String? caption,
        double? aspectRatio,
        bool autoPlay = false,
        bool looping = false,
        bool muted = false,
      }) {
    return ContentBlockEntity(
      type: ContentBlockType.video,
      metadata: {
        'content': url,
        if (caption != null) 'caption': caption,
        if (aspectRatio != null) 'aspectRatio': aspectRatio,
        'autoPlay': autoPlay,
        'looping': looping,
        'muted': muted,
      },
    );
  }

  factory ContentBlockEntity.audio(
      String url, {
        String? caption,
        bool autoPlay = false,
        bool loop = false,
      }) {
    return ContentBlockEntity(
      type: ContentBlockType.audio,
      metadata: {
        'content': url,
        if (caption != null) 'caption': caption,
        'autoPlay': autoPlay,
        'loop': loop,
      },
    );
  }

  factory ContentBlockEntity.code(String content, {String? language}) {
    return ContentBlockEntity(
      type: ContentBlockType.code,
      metadata: {
        'content': content,
        if (language != null) 'language': language,
      },
    );
  }

  factory ContentBlockEntity.list(List<String> items, {bool ordered = false}) {
    return ContentBlockEntity(
      type: ContentBlockType.list,
      metadata: {
        'items': items,
        'ordered': ordered,
      },
    );
  }

  factory ContentBlockEntity.divider() {
    return const ContentBlockEntity(
      type: ContentBlockType.divider,
      metadata: {},
    );
  }
}