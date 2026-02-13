import '../../data/api_content_entity.dart';

/// Repository interface for fetching content from olympiccambodia.com API
abstract class IApiContentRepository {
  /// The content type this repository handles
  ApiContentType get contentType;

  /// Fetches a single content item by ID
  ///
  /// Returns null if not found or on error
  Future<ApiContentEntity?> getContentByIdAsync(int id);

  /// Fetches a single content item by slug
  ///
  /// Returns null if not found or on error
  Future<ApiContentEntity?> getContentBySlugAsync(String slug);

  /// Fetches a page of content items
  ///
  /// [page] - Page number (1-indexed)
  /// [pageSize] - Number of items per page (default 15)
  /// [categoryId] - Optional category ID to filter by
  Future<ApiContentPageResult> getPageAsync({
    required int page,
    int pageSize = 15,
    int? categoryId,
  });

  /// Resets pagination state (if any caching is implemented)
  void resetPagination();

  /// Clears any cached data
  Future<void> clearCacheAsync();
}
