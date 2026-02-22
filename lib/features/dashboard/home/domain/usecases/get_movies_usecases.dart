import '../entities/movie_entity.dart';
import '../repositories/home_repository.dart';

class GetMoviesUseCase {
  final HomeRepository _repository;

  GetMoviesUseCase(this._repository);

  Future<({List<MovieEntity> movies, PaginationMeta pagination})> call({
    int page = 1,
    int limit = 20,
    String? genre,
    String? search,
  }) {
    return _repository.getMovies(
      page: page,
      limit: limit,
      genre: genre,
      search: search,
    );
  }
}

class GetGenresUseCase {
  final HomeRepository _repository;

  GetGenresUseCase(this._repository);

  Future<List<String>> call() => _repository.getGenres();
}

class GetMovieByIdUseCase {
  final HomeRepository _repository;

  GetMovieByIdUseCase(this._repository);

  Future<MovieEntity> call(String id) => _repository.getMovieById(id);
}