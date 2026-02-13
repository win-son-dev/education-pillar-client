/// Generic paginated result for cursor-based API pagination.
///
/// Used with Firebase Cloud Functions that return `lastId` and `hasMore`
/// for cursor-based pagination (e.g. `getAthletes`, `getCampaigns`).
class ApiPaginatedResult<T> {
  final List<T> items;
  final String? lastItemId;
  final bool hasMore;

  const ApiPaginatedResult({
    required this.items,
    this.lastItemId,
    required this.hasMore,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
}