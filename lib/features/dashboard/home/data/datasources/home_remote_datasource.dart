import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/api/app_client.dart';

import '../models/movie_model.dart';

class HomeRemoteDataSource {
  final ApiClient _apiClient;

  HomeRemoteDataSource(this._apiClient);

  Future<({List<MovieModel> movies, Map<String, dynamic> pagination})>
      getMovies({
    int page = 1,
    int limit = 20,
    String? genre,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (genre != null) 'genre': genre,
      if (search != null) 'search': search,
    };

    final response = await _apiClient.get(
      ApiEndpoints.getMovies,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch movies');
    }

    final movies = (data['data'] as List)
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return (
      movies: movies,
      pagination: data['pagination'] as Map<String, dynamic>,
    );
  }

  Future<MovieModel> getMovieById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.getMovies}/$id');

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch movie');
    }

    return MovieModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<String>> getGenres() async {
    final response = await _apiClient.get(ApiEndpoints.getGenres);

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch genres');
    }

    return List<String>.from(data['data'] ?? []);
  }
}