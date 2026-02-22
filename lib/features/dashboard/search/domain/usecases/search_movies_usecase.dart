import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/dashboard/home/domain/repositories/home_repository.dart';

class SearchMoviesUseCase {
  final HomeRepository _repository;

  SearchMoviesUseCase(this._repository);

  Future<List<MovieEntity>> call(String query) async {
    if (query.trim().isEmpty) return [];

    final result = await _repository.getMovies(
      search: query.trim(),
      limit: 30,
    );

    return result.movies;
  }
}