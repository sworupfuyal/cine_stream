import '../entities/user_list_entity.dart';

abstract class UserListRepository {
  /// GET /api/user/lists?listType=favorite|watchlater
  Future<List<UserListEntity>> getUserList({ListType? listType});

  /// POST /api/user/lists
  Future<void> addToList({required String movieId, required ListType listType});

  /// DELETE /api/user/lists/:movieId/:listType
  Future<void> removeFromList({
    required String movieId,
    required ListType listType,
  });

  /// GET /api/user/lists/counts
  Future<UserListCountsEntity> getListCounts();

  /// POST /api/user/lists/status
  Future<List<MovieListStatusEntity>> getListStatus(List<String> movieIds);
}