import '../entities/user_list_entity.dart';
import '../repositories/user_list_repository.dart';

class GetUserListUseCase {
  final UserListRepository _repository;
  GetUserListUseCase(this._repository);

  Future<List<UserListEntity>> call({ListType? listType}) =>
      _repository.getUserList(listType: listType);
}

class AddToListUseCase {
  final UserListRepository _repository;
  AddToListUseCase(this._repository);

  Future<void> call({required String movieId, required ListType listType}) =>
      _repository.addToList(movieId: movieId, listType: listType);
}

class RemoveFromListUseCase {
  final UserListRepository _repository;
  RemoveFromListUseCase(this._repository);

  Future<void> call({required String movieId, required ListType listType}) =>
      _repository.removeFromList(movieId: movieId, listType: listType);
}

class GetListCountsUseCase {
  final UserListRepository _repository;
  GetListCountsUseCase(this._repository);

  Future<UserListCountsEntity> call() => _repository.getListCounts();
}

class GetListStatusUseCase {
  final UserListRepository _repository;
  GetListStatusUseCase(this._repository);

  Future<List<MovieListStatusEntity>> call(List<String> movieIds) =>
      _repository.getListStatus(movieIds);
}