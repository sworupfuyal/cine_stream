import 'package:cine_stream/features/dashboard/mylist/domain/entities/user_list_entity.dart';
import 'package:cine_stream/features/dashboard/mylist/domain/repositories/user_list_repository.dart';
import 'package:cine_stream/features/dashboard/mylist/domain/usecases/user_list_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserListRepository extends Mock implements UserListRepository {}

void main() {
  late MockUserListRepository mockRepository;

  setUp(() {
    mockRepository = MockUserListRepository();
  });

  group('GetUserListUseCase', () {
    late GetUserListUseCase usecase;

    setUp(() {
      usecase = GetUserListUseCase(mockRepository);
    });

    test('should return list of user list entities', () async {
      const items = [
        UserListEntity(
          id: '1',
          userId: 'u1',
          movieId: 'm1',
          listType: ListType.favorite,
        ),
      ];
      when(() => mockRepository.getUserList(listType: any(named: 'listType')))
          .thenAnswer((_) async => items);

      final result = await usecase.call();

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('should pass listType to repository', () async {
      when(() => mockRepository.getUserList(listType: any(named: 'listType')))
          .thenAnswer((_) async => []);

      await usecase.call(listType: ListType.favorite);

      verify(() => mockRepository.getUserList(listType: ListType.favorite))
          .called(1);
    });
  });

  group('GetListStatusUseCase', () {
    late GetListStatusUseCase usecase;

    setUp(() {
      usecase = GetListStatusUseCase(mockRepository);
    });

    test('should return status list from repository', () async {
      const statuses = [
        MovieListStatusEntity(
          movieId: 'm1',
          isFavorite: true,
          isWatchLater: false,
        ),
        MovieListStatusEntity(
          movieId: 'm2',
          isFavorite: false,
          isWatchLater: true,
        ),
      ];
      when(() => mockRepository.getListStatus(any()))
          .thenAnswer((_) async => statuses);

      final result = await usecase.call(['m1', 'm2']);

      expect(result.length, 2);
      expect(result[0].isFavorite, true);
      expect(result[1].isWatchLater, true);
    });

    test('should pass movie IDs to repository', () async {
      when(() => mockRepository.getListStatus(any()))
          .thenAnswer((_) async => []);

      await usecase.call(['m1', 'm2', 'm3']);

      verify(() => mockRepository.getListStatus(['m1', 'm2', 'm3'])).called(1);
    });
  });
}
