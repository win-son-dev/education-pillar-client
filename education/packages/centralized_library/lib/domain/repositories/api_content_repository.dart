import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/api_content_entity.dart';
import 'i_api_content_repository.dart';

/// Implementation of [IApiContentRepository] that fetches content from
/// the olympiccambodia.com API.
class ApiContentRepository implements IApiContentRepository {
  static const String _baseUrl = 'https://olympiccambodia.com/api/nocc';

  final Dio _dio;
  final ApiContentType _contentType;

  /// Cache for single items by ID
  final Map<int, ApiContentEntity> _itemCache = {};

  /// Cache for pages
  final Map<int, ApiContentPageResult> _pageCache = {};

  ApiContentRepository({
    required ApiContentType contentType,
    Dio? dio,
  })  : _contentType = contentType,
        _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

  @override
  ApiContentType get contentType => _contentType;

  String get _endpoint => '$_baseUrl/${_contentType.endpoint}';

  @override
  Future<ApiContentEntity?> getContentByIdAsync(int id) async {
    // Check cache first
    if (_itemCache.containsKey(id)) {
      return _itemCache[id];
    }

    final response = await _dio.get<Map<String, dynamic>>('$_endpoint/$id');

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!;

      // Handle both direct data and nested 'data' key
      final itemData = data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data;

      final entity = ApiContentEntity.fromJson(itemData, type: _contentType);
      _itemCache[id] = entity;
      return entity;
    }

    return null;
  }

  @override
  Future<ApiContentEntity?> getContentBySlugAsync(String slug) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_endpoint/slug/$slug',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!;
      final itemData = data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data;

      final entity = ApiContentEntity.fromJson(itemData, type: _contentType);
      _itemCache[entity.id] = entity;
      return entity;
    }

    return null;
  }

  @override
  Future<ApiContentPageResult> getPageAsync({
    required int page,
    int pageSize = 15,
    int? categoryId,
  }) async {
    // Check cache first
    final cacheKey = _pageCacheKey(page, pageSize, categoryId);
    if (_pageCache.containsKey(cacheKey)) {
      return _pageCache[cacheKey]!;
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': pageSize,
    };

    if (categoryId != null && categoryId > 0) {
      queryParams['category_id'] = categoryId;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      _endpoint,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final responseData = response.data!;

      // API wraps response in {status, message, data} - unwrap if needed
      final data = responseData['data'] is Map<String, dynamic> &&
                   responseData.containsKey('status')
          ? responseData['data'] as Map<String, dynamic>
          : responseData;

      // Parse items from data['data'] array
      final rawItems = data['data'];
      List<Map<String, dynamic>> itemsList = [];

      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map<String, dynamic>) {
            itemsList.add(item);
          } else if (item is Map) {
            itemsList.add(Map<String, dynamic>.from(item));
          }
        }
      }

      debugPrint('[ApiContentRepository] Parsed ${itemsList.length} items');

      final items = itemsList
          .map((item) => ApiContentEntity.fromJson(
                item,
                type: _contentType,
              ))
          .toList();

      // Cache individual items
      for (final item in items) {
        _itemCache[item.id] = item;
      }

      // Parse pagination meta
      final metaData = data['meta'] as Map<String, dynamic>? ?? {};
      final meta = ApiPaginationMeta.fromJson(metaData);

      // Parse links
      final links = data['links'] as Map<String, dynamic>? ?? {};

      final result = ApiContentPageResult(
        items: items,
        meta: meta,
        nextPageUrl: links['next'] as String?,
        previousPageUrl: links['prev'] as String?,
      );

      _pageCache[cacheKey] = result;
      return result;
    }

    // Return empty result on error
    return const ApiContentPageResult(
      items: [],
      meta: ApiPaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      ),
    );
  }

  @override
  void resetPagination() {
    _pageCache.clear();
  }

  @override
  Future<void> clearCacheAsync() async {
    _itemCache.clear();
    _pageCache.clear();
  }

  int _pageCacheKey(int page, int pageSize, int? categoryId) =>
      page * 10000 + pageSize * 100 + (categoryId ?? 0);
}

/// Factory for creating API content repositories for different content types
class ApiContentRepositoryFactory {
  final Dio? _dio;

  ApiContentRepositoryFactory({Dio? dio}) : _dio = dio;

  /// Creates a repository for the specified content type
  IApiContentRepository create(ApiContentType type) {
    return ApiContentRepository(
      contentType: type,
      dio: _dio,
    );
  }

  /// Creates a news repository
  IApiContentRepository news() => create(ApiContentType.news);

  /// Creates an events repository
  IApiContentRepository events() => create(ApiContentType.events);

  /// Creates a videos repository
  IApiContentRepository videos() => create(ApiContentType.videos);

  /// Creates an athletes repository
  IApiContentRepository athletes() => create(ApiContentType.athletes);

  /// Creates a galleries repository
  IApiContentRepository galleries() => create(ApiContentType.galleries);
}
