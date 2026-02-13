import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../data/api_content_entity.dart';
import 'i_api_content_repository.dart';

/// Implementation of [IApiContentRepository] that fetches content through
/// Firebase Cloud Functions (proxy to olympiccambodia.com API).
///
/// This approach provides:
/// - Security: API keys and endpoints are not exposed in the client
/// - App Check: Ensures only your app can call the functions
/// - Caching: Can add server-side caching in the future
/// - Rate Limiting: Protects against abuse
class CloudApiContentRepository implements IApiContentRepository {
  final FirebaseFunctions _functions;
  final ApiContentType _contentType;

  /// Cache for single items by ID
  final Map<int, ApiContentEntity> _itemCache = {};

  /// Cache for pages
  final Map<int, ApiContentPageResult> _pageCache = {};

  CloudApiContentRepository({
    required ApiContentType contentType,
    FirebaseFunctions? functions,
  })  : _contentType = contentType,
        _functions = functions ?? FirebaseFunctions.instance;

  @override
  ApiContentType get contentType => _contentType;

  @override
  Future<ApiContentEntity?> getContentByIdAsync(int id) async {
    // Check cache first
    if (_itemCache.containsKey(id)) {
      return _itemCache[id];
    }

    final callable = _functions.httpsCallable('getContentById');

    final result = await callable.call({
      'type': _contentType.endpoint,
      'id': id,
    });

    final data = _toStringDynamicMap(result.data);

    if (data['success'] == true && data['item'] != null) {
      final itemData = _toStringDynamicMap(data['item']);
      final entity = ApiContentEntity.fromJson(itemData, type: _contentType);
      _itemCache[id] = entity;
      return entity;
    }

    return null;
  }

  @override
  Future<ApiContentEntity?> getContentBySlugAsync(String slug) async {
    // Cloud function doesn't have a slug endpoint yet
    // Search through cached items or fetch first page and search
    for (final item in _itemCache.values) {
      if (item.slug == slug) {
        return item;
      }
    }

    // Fetch first page and search
    final page = await getPageAsync(page: 1);
    for (final item in page.items) {
      if (item.slug == slug) {
        return item;
      }
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

    final callable = _functions.httpsCallable('getContent');

    final params = <String, dynamic>{
      'type': _contentType.endpoint,
      'page': page,
    };

    if (categoryId != null && categoryId > 0) {
      params['categoryId'] = categoryId;
    }

    final result = await callable.call(params);
    final data = _toStringDynamicMap(result.data);

    if (data['success'] != true) {
      debugPrint('[CloudApiContentRepository] API returned success=false');
      return _emptyResult();
    }

    // Parse items
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final itemMap = _toStringDynamicMap(item);
      return ApiContentEntity.fromJson(itemMap, type: _contentType);
    }).toList();

    debugPrint('[CloudApiContentRepository] Parsed ${items.length} items');

    // Cache individual items
    for (final item in items) {
      _itemCache[item.id] = item;
    }

    // Parse pagination meta
    final metaData = _toStringDynamicMap(data['meta']);
    final meta = ApiPaginationMeta(
      currentPage: metaData['currentPage'] as int? ?? 1,
      lastPage: metaData['lastPage'] as int? ?? 1,
      perPage: metaData['perPage'] as int? ?? 15,
      total: metaData['total'] as int? ?? 0,
    );

    // Parse links
    final links = _toStringDynamicMap(data['links']);

    final pageResult = ApiContentPageResult(
      items: items,
      meta: meta,
      nextPageUrl: links['next'] as String?,
      previousPageUrl: links['previous'] as String?,
    );

    _pageCache[cacheKey] = pageResult;
    return pageResult;
  }

  /// Fetches available categories for this content type
  Future<List<ApiCategory>> getCategoriesAsync() async {
    final callable = _functions.httpsCallable('getCategories');

    final result = await callable.call({
      'type': _contentType.endpoint,
    });

    final data = _toStringDynamicMap(result.data);

    if (data['success'] == true && data['categories'] != null) {
      final rawCategories = data['categories'] as List<dynamic>;
      return rawCategories.map((c) {
        final map = _toStringDynamicMap(c);
        return ApiCategory.fromJson(map);
      }).toList();
    }

    return [];
  }

  /// Recursively converts dynamic map from Cloud Functions to [Map] with String keys
  /// Handles nested maps and lists from Firebase Cloud Functions responses
  Map<String, dynamic> _toStringDynamicMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) {
      return value.map((key, val) => MapEntry(key, _convertValue(val)));
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _convertValue(val)));
    }
    return {};
  }

  /// Recursively converts values, handling nested maps and lists
  dynamic _convertValue(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _convertValue(val)));
    }
    if (value is List) {
      return value.map((item) => _convertValue(item)).toList();
    }
    return value;
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

  ApiContentPageResult _emptyResult() {
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

  int _pageCacheKey(int page, int pageSize, int? categoryId) {
    return page * 10000 + pageSize * 100 + (categoryId ?? 0);
  }
}

/// Factory for creating Cloud API content repositories for different content types
class CloudApiContentRepositoryFactory {
  final FirebaseFunctions? _functions;

  CloudApiContentRepositoryFactory({FirebaseFunctions? functions})
      : _functions = functions;

  /// Creates a repository for the specified content type
  IApiContentRepository create(ApiContentType type) {
    return CloudApiContentRepository(
      contentType: type,
      functions: _functions,
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