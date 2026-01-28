/// Domain value for a single page of paginated data.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
}
