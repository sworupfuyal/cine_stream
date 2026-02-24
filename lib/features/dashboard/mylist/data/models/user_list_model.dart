import 'package:cine_stream/features/dashboard/home/data/models/movie_model.dart';
import '../../domain/entities/user_list_entity.dart';

class UserListModel {
  final String id;
  final String userId;
  final String movieId;
  final String listType;
  final MovieModel? movie;
  final DateTime? createdAt;

  const UserListModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.listType,
    this.movie,
    this.createdAt,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    MovieModel? movie;
    String movieId = '';

    // ✅ Backend returns populated "movie" object directly (not "movieId")
    final rawMovie = json['movie'];
    if (rawMovie is Map<String, dynamic>) {
      movie = MovieModel.fromJson(rawMovie);
      movieId = rawMovie['_id']?.toString() ?? '';
    }

    // Fallback: try "movieId" field in case structure changes
    if (movieId.isEmpty) {
      final rawMovieId = json['movieId'];
      if (rawMovieId is Map<String, dynamic>) {
        movie = MovieModel.fromJson(rawMovieId);
        movieId = rawMovieId['_id']?.toString() ?? '';
      } else {
        movieId = rawMovieId?.toString() ?? '';
      }
    }

    final rawUserId = json['userId'];
    final userId = rawUserId is Map<String, dynamic>
        ? rawUserId['_id']?.toString() ?? ''
        : rawUserId?.toString() ?? '';

    // ✅ Backend returns "listId" not "_id", and "addedAt" not "createdAt"
    final id = json['listId']?.toString() ??
        json['_id']?.toString() ?? '';

    final createdAtStr = json['addedAt']?.toString() ??
        json['createdAt']?.toString();

    return UserListModel(
      id: id,
      userId: userId,
      movieId: movieId,
      listType: json['listType']?.toString() ?? 'watchlater',
      movie: movie,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
    );
  }

  UserListEntity toEntity() => UserListEntity(
        id: id,
        userId: userId,
        movieId: movieId,
        listType:
            listType == 'favorite' ? ListType.favorite : ListType.watchlater,
        movie: movie?.toEntity(),
        createdAt: createdAt,
      );
}

class UserListCountsModel {
  final int favorites;
  final int watchlater;

  const UserListCountsModel({required this.favorites, required this.watchlater});

  factory UserListCountsModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle both key names: "favorite" and "favorites"
    return UserListCountsModel(
      favorites: (json['favorites'] as num?)?.toInt() ??
          (json['favorite'] as num?)?.toInt() ?? 0,
      watchlater: (json['watchLater'] as num?)?.toInt() ??
          (json['watchlater'] as num?)?.toInt() ?? 0,
    );
  }
  

  UserListCountsEntity toEntity() =>
      UserListCountsEntity(favorites: favorites, watchlater: watchlater);
}

class MovieListStatusModel {
  final String movieId;
  final bool isFavorite;
  final bool isWatchLater;

  const MovieListStatusModel({
    required this.movieId,
    required this.isFavorite,
    required this.isWatchLater,
  });

  factory MovieListStatusModel.fromJson(Map<String, dynamic> json) {
    return MovieListStatusModel(
      movieId: json['movieId']?.toString() ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isWatchLater: json['isWatchLater'] as bool? ?? false,
    );
  }

  MovieListStatusEntity toEntity() => MovieListStatusEntity(
        movieId: movieId,
        isFavorite: isFavorite,
        isWatchLater: isWatchLater,
      );
}