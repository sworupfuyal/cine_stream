import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/dashboard/home/domain/repositories/home_repository.dart';

enum SearchStatus { initial, loading, success, failure, empty }

class SearchState {
  final SearchStatus status;
  final List<MovieEntity> results;
  final String query;
  final String? error;
  final PaginationMeta? pagination;
  final bool isLoadingMore;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.query = '',
    this.error,
    this.pagination,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == SearchStatus.loading;
  bool get hasError => status == SearchStatus.failure;
  bool get isEmpty => status == SearchStatus.empty;
  bool get hasResults => status == SearchStatus.success && results.isNotEmpty;
  bool get isInitial => status == SearchStatus.initial;
  bool get hasMore => pagination?.hasMore ?? false;
  bool get canLoadMore => hasMore && !isLoadingMore;

  SearchState copyWith({
    SearchStatus? status,
    List<MovieEntity>? results,
    String? query,
    String? error,
    PaginationMeta? pagination,
    bool? isLoadingMore,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      query: query ?? this.query,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}