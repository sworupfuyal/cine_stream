import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _dataSource;

  HomeRepositoryImpl(this._dataSource);

  @override
  Future<({List<MovieEntity> movies, PaginationMeta pagination})> getMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? search,
  }) async {
    try {
      final result = await _dataSource.getMovies(
        page: page,
        limit: limit,
        genre: genre,
        search: search,
      );

      final paginationData = result.pagination;

      return (
        movies: result.movies.map((m) => m.toEntity()).toList(),
        pagination: PaginationMeta(
          page: (paginationData['page'] as num?)?.toInt() ?? page,
          limit: (paginationData['limit'] as num?)?.toInt() ?? limit,
          total: (paginationData['total'] as num?)?.toInt() ?? 0,
          totalPages: (paginationData['totalPages'] as num?)?.toInt() ?? 1,
        ),
      );
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<MovieEntity> getMovieById(String id) async {
    try {
      final model = await _dataSource.getMovieById(id);
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<String>> getGenres() async {
    try {
      return await _dataSource.getGenres();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}