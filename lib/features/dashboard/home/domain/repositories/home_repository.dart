import '../entities/movie_entity.dart';

abstract class HomeRepository {
  Future<({List<MovieEntity> movies, PaginationMeta pagination})> getMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? search,
  });

  Future<MovieEntity> getMovieById(String id);

  Future<List<String>> getGenres();
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}