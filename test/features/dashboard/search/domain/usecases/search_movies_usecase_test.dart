import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/dashboard/home/domain/repositories/home_repository.dart';
import 'package:cine_stream/features/dashboard/search/domain/usecases/search_movies_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late SearchMoviesUseCase usecase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = SearchMoviesUseCase(mockRepository);
  });

  const tMovie = MovieEntity(
    id: '1',
    title: 'Batman',
    description: 'Dark Knight',
    duration: 152,
    releaseYear: 2008,
    genres: ['Action'],
    cast: ['Christian Bale'],
    director: 'Christopher Nolan',
  );

  const tPagination = PaginationMeta(
    page: 1,
    limit: 30,
    total: 1,
    totalPages: 1,
  );

  group('SearchMoviesUseCase', () {
    test('should return movies matching query', () async {
      when(() => mockRepository.getMovies(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            genre: any(named: 'genre'),
            search: any(named: 'search'),
          )).thenAnswer(
              (_) async => (movies: [tMovie], pagination: tPagination));

      final result = await usecase.call('Batman');

      expect(result.length, 1);
      expect(result.first.title, 'Batman');
    });

    test('should return empty list for empty query', () async {
      final result = await usecase.call('');

      expect(result, isEmpty);
      verifyNever(() => mockRepository.getMovies(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            genre: any(named: 'genre'),
            search: any(named: 'search'),
          ));
    });

    test('should return empty list for whitespace-only query', () async {
      final result = await usecase.call('   ');

      expect(result, isEmpty);
      verifyNever(() => mockRepository.getMovies(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            genre: any(named: 'genre'),
            search: any(named: 'search'),
          ));
    });

   


  });
}
