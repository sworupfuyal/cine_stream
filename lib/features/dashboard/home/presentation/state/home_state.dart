import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/dashboard/home/domain/repositories/home_repository.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState {
  final HomeStatus status;
  final List<MovieEntity> movies;
  final List<String> genres;
  final String? selectedGenre;
  final String? error;
  final PaginationMeta? pagination;
  final bool isLoadingMore;  // ✅ separate flag for pagination spinner

  const HomeState({
    this.status = HomeStatus.initial,
    this.movies = const [],
    this.genres = const [],
    this.selectedGenre,
    this.error,
    this.pagination,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == HomeStatus.loading;
  bool get hasError => status == HomeStatus.failure;
  bool get hasMore => pagination?.hasMore ?? false;
  bool get canLoadMore => hasMore && !isLoadingMore;

  // Derived sections
  List<MovieEntity> get featuredMovies => movies.take(5).toList();

  List<MovieEntity> get recentMovies {
    final sorted = [...movies];
    sorted.sort((a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return sorted.take(10).toList();
  }

  Map<String, List<MovieEntity>> get moviesByGenre {
    final map = <String, List<MovieEntity>>{};
    for (final movie in movies) {
      for (final genre in movie.genres) {
        map.putIfAbsent(genre, () => []).add(movie);
      }
    }
    return map;
  }

  HomeState copyWith({
    HomeStatus? status,
    List<MovieEntity>? movies,
    List<String>? genres,
    String? selectedGenre,
    String? error,
    PaginationMeta? pagination,
    bool? isLoadingMore,
    bool clearGenre = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      genres: genres ?? this.genres,
      selectedGenre: clearGenre ? null : selectedGenre ?? this.selectedGenre,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}