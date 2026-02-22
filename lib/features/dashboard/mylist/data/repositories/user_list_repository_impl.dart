import '../../domain/entities/user_list_entity.dart';
import '../../domain/repositories/user_list_repository.dart';
import '../datasources/user_list_remote_datasource.dart';

class UserListRepositoryImpl implements UserListRepository {
  final UserListRemoteDataSource _dataSource;

  UserListRepositoryImpl(this._dataSource);

  @override
  Future<List<UserListEntity>> getUserList({ListType? listType}) async {
    try {
      final models = await _dataSource.getUserList(listType: listType);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> addToList({
    required String movieId,
    required ListType listType,
  }) async {
    try {
      await _dataSource.addToList(movieId: movieId, listType: listType);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> removeFromList({
    required String movieId,
    required ListType listType,
  }) async {
    try {
      await _dataSource.removeFromList(movieId: movieId, listType: listType);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<UserListCountsEntity> getListCounts() async {
    try {
      final model = await _dataSource.getListCounts();
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<MovieListStatusEntity>> getListStatus(
      List<String> movieIds) async {
    try {
      final models = await _dataSource.getListStatus(movieIds);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}