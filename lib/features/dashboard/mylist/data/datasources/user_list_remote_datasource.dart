import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/features/dashboard/home/data/models/movie_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_list_entity.dart';
import '../models/user_list_model.dart';

class UserListRemoteDataSource {
  final ApiClient _apiClient;

  UserListRemoteDataSource(this._apiClient);

  Future<List<UserListModel>> getUserList({ListType? listType}) async {
    final response = await _apiClient.get(
      ApiEndpoints.userLists,
      queryParameters: listType != null ? {'listType': listType.value} : null,
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch list');
    }

    final raw = data['data'];
    List<UserListModel> items = [];

    if (raw is List) {
      items = raw
          .map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (raw is Map<String, dynamic>) {
      if (raw['favorites'] is List) {
        items.addAll((raw['favorites'] as List)
            .map((e) => UserListModel.fromJson(e as Map<String, dynamic>)));
      }
      if (raw['watchlater'] is List) {
        items.addAll((raw['watchlater'] as List)
            .map((e) => UserListModel.fromJson(e as Map<String, dynamic>)));
      }
    }

    // Fetch movie details for unpopulated items
    final unpopulated =
        items.where((e) => e.movie == null && e.movieId.isNotEmpty).toList();

    if (unpopulated.isNotEmpty) {
      final fetched = await Future.wait(
        unpopulated.map((item) => _fetchMovieById(item.movieId)),
      );

      final movieMap = <String, MovieModel>{};
      for (int i = 0; i < unpopulated.length; i++) {
        final movie = fetched[i];
        if (movie != null) movieMap[unpopulated[i].movieId] = movie;
      }

      items = items.map((item) {
        if (item.movie == null && movieMap.containsKey(item.movieId)) {
          return UserListModel(
            id: item.id,
            userId: item.userId,
            movieId: item.movieId,
            listType: item.listType,
            movie: movieMap[item.movieId],
            createdAt: item.createdAt,
          );
        }
        return item;
      }).toList();
    }

    return items;
  }

  Future<MovieModel?> _fetchMovieById(String movieId) async {
    try {
      final response =
          await _apiClient.get('${ApiEndpoints.getMovies}/$movieId');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return MovieModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Failed to fetch movie $movieId: $e');
      return null;
    }
  }

  Future<void> addToList({
    required String movieId,
    required ListType listType,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userLists,
        data: {'movieId': movieId, 'listType': listType.value},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to add to list');
      }
    } on DioException catch (e) {
      // 409 = already in list — treat as success (idempotent)
      if (e.response?.statusCode == 409) {
        debugPrint('ℹ️ Movie already in list — treating as success');
        return;
      }
      rethrow;
    }
  }

  Future<void> removeFromList({
    required String movieId,
    required ListType listType,
  }) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.userLists}/$movieId/${listType.value}',
    );
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to remove from list');
    }
  }

  Future<UserListCountsModel> getListCounts() async {
    final response = await _apiClient.get(ApiEndpoints.userListCounts);
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch counts');
    }
    return UserListCountsModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// The API returns data as a map keyed by movieId:
  /// { "data": { "<movieId>": { "isFavorite": true, "isWatchLater": false } } }
  Future<List<MovieListStatusModel>> getListStatus(
      List<String> movieIds) async {
    final response = await _apiClient.post(
      ApiEndpoints.userListStatus,
      data: {'movieIds': movieIds},
    );
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch status');
    }

    final dataMap = Map<String, dynamic>.from(data['data'] as Map);

    return dataMap.entries.map((entry) {
      final status = Map<String, dynamic>.from(entry.value as Map);
      return MovieListStatusModel(
        movieId: entry.key,
        isFavorite: status['isFavorite'] as bool? ?? false,
        isWatchLater: status['isWatchLater'] as bool? ?? false,
      );
    }).toList();
  }
}