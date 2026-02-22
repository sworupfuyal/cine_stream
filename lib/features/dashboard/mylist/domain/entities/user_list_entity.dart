import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';

enum ListType { favorite, watchlater }

extension ListTypeExtension on ListType {
  String get value => name; // 'favorite' | 'watchlater'
  String get label => this == ListType.favorite ? 'Favourites' : 'Watch Later';
}

class UserListEntity {
  final String id;
  final String userId;
  final String movieId;
  final ListType listType;
  final MovieEntity? movie; // populated from backend
  final DateTime? createdAt;

  const UserListEntity({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.listType,
    this.movie,
    this.createdAt,
  });
}

class UserListCountsEntity {
  final int favorites;
  final int watchlater;

  const UserListCountsEntity({
    required this.favorites,
    required this.watchlater,
  });
}

class MovieListStatusEntity {
  final String movieId;
  final bool isFavorite;
  final bool isWatchLater;

  const MovieListStatusEntity({
    required this.movieId,
    required this.isFavorite,
    required this.isWatchLater,
  });
}