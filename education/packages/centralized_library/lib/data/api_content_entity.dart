import 'package:equatable/equatable.dart';

import 'content_block_entity.dart';
import '../utils/html_block_parser.dart';

/// Supported content types from the API
enum ApiContentType {
  news('news'),
  events('events'),
  videos('videos'),
  athletes('athletes'),
  galleries('galleries');

  final String endpoint;
  const ApiContentType(this.endpoint);
}

/// Author information from API content
class ApiAuthor extends Equatable {
  final int id;
  final String name;
  final String? avatar;

  const ApiAuthor({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory ApiAuthor.fromJson(Map<String, dynamic> json) {
    return ApiAuthor(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatar != null) 'avatar': avatar,
  };

  @override
  List<Object?> get props => [id, name, avatar];
}

/// Category information from API content
class ApiCategory extends Equatable {
  final int id;
  final String name;
  final String? slug;

  const ApiCategory({
    required this.id,
    required this.name,
    this.slug,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (slug != null) 'slug': slug,
  };

  @override
  List<Object?> get props => [id, name, slug];
}

/// Entity representing content fetched from olympiccambodia.com API
class ApiContentEntity extends Equatable {
  final int id;
  final String slug;
  final ApiContentType type;
  final String imageUrl;
  final String createdAt;
  final ApiAuthor? author;
  final ApiCategory? category;
  final List<String> tags;
  final Map<String, dynamic> rawData;

  const ApiContentEntity({
    required this.id,
    required this.slug,
    required this.type,
    required this.imageUrl,
    required this.createdAt,
    this.author,
    this.category,
    this.tags = const [],
    required this.rawData,
  });

  /// Get localized title
  /// [language] should be 'en' for English or 'km' for Khmer
  String title(String language) {
    if (language == 'km') {
      return rawData['title_kh'] as String? ??
          rawData['title'] as String? ?? '';
    }
    return rawData['title'] as String? ?? '';
  }

  /// Get localized description/content as parsed content blocks
  /// [language] should be 'en' for English or 'km' for Khmer
  List<ContentBlockEntity> blocks(String language) {
    String htmlContent;
    if (language == 'km') {
      htmlContent = rawData['des_kh'] as String? ??
          rawData['des_en'] as String? ?? '';
    } else {
      htmlContent = rawData['des_en'] as String? ?? '';
    }
    return HtmlBlockParser.parse(htmlContent);
  }

  /// Get raw HTML content for a specific language
  String rawContent(String language) {
    if (language == 'km') {
      return rawData['des_kh'] as String? ??
          rawData['des_en'] as String? ?? '';
    }
    return rawData['des_en'] as String? ?? '';
  }

  /// Get short description/excerpt
  String excerpt(String language) {
    if (language == 'km') {
      return rawData['short_des_kh'] as String? ??
          rawData['short_des'] as String? ?? '';
    }
    return rawData['short_des'] as String? ?? '';
  }

  factory ApiContentEntity.fromJson(
      Map<String, dynamic> json, {
        required ApiContentType type,
      }) {
    // Parse author
    ApiAuthor? author;
    if (json['author'] != null && json['author'] is Map) {
      author = ApiAuthor.fromJson(json['author'] as Map<String, dynamic>);
    }

    // Parse category
    ApiCategory? category;
    if (json['category'] != null && json['category'] is Map) {
      category = ApiCategory.fromJson(json['category'] as Map<String, dynamic>);
    }

    // Parse tags
    List<String> tags = [];
    if (json['tags'] != null && json['tags'] is List) {
      tags = (json['tags'] as List)
          .map((t) => t is Map ? (t['name'] as String? ?? '') : t.toString())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    return ApiContentEntity(
      id: json['id'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
      type: type,
      imageUrl: json['image'] as String? ?? json['thumbnail'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      author: author,
      category: category,
      tags: tags,
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'type': type.endpoint,
    'imageUrl': imageUrl,
    'createdAt': createdAt,
    if (author != null) 'author': author!.toJson(),
    if (category != null) 'category': category!.toJson(),
    'tags': tags,
    'rawData': rawData,
  };

  @override
  List<Object?> get props => [id, slug, type, imageUrl, createdAt, author, category, tags];
}

/// Pagination metadata from API response
class ApiPaginationMeta extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ApiPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;

  factory ApiPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ApiPaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}

/// Result of a paginated API content request
class ApiContentPageResult extends Equatable {
  final List<ApiContentEntity> items;
  final ApiPaginationMeta meta;
  final String? nextPageUrl;
  final String? previousPageUrl;

  const ApiContentPageResult({
    required this.items,
    required this.meta,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  bool get hasMore => meta.hasNextPage;

  @override
  List<Object?> get props => [items, meta, nextPageUrl, previousPageUrl];
}
