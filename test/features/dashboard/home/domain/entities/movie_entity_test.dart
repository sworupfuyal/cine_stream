import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieEntity', () {
    test('should create with required fields', () {
      const movie = MovieEntity(
        id: '1',
        title: 'Test Movie',
        description: 'A test movie',
        duration: 120,
        releaseYear: 2024,
        genres: ['Action'],
        cast: ['Actor A'],
        director: 'Director X',
      );
      expect(movie.id, '1');
      expect(movie.title, 'Test Movie');
      expect(movie.duration, 120);
      expect(movie.thumbnailUrl, isNull);
      expect(movie.videoUrl, isNull);
      expect(movie.createdAt, isNull);
    });

    test('formattedDuration should show hours and minutes', () {
      const movie = MovieEntity(
        id: '1',
        title: 'T',
        description: 'D',
        duration: 150,
        releaseYear: 2024,
        genres: [],
        cast: [],
        director: 'Dir',
      );
      expect(movie.formattedDuration, '2h 30m');
    });

    test('formattedDuration should show only minutes when under 60', () {
      const movie = MovieEntity(
        id: '1',
        title: 'T',
        description: 'D',
        duration: 45,
        releaseYear: 2024,
        genres: [],
        cast: [],
        director: 'Dir',
      );
      expect(movie.formattedDuration, '45m');
    });

    test('formattedDuration should show 0m for zero duration', () {
      const movie = MovieEntity(
        id: '1',
        title: 'T',
        description: 'D',
        duration: 0,
        releaseYear: 2024,
        genres: [],
        cast: [],
        director: 'Dir',
      );
      expect(movie.formattedDuration, '0m');
    });

    test('formattedDuration for exactly 60 minutes', () {
      const movie = MovieEntity(
        id: '1',
        title: 'T',
        description: 'D',
        duration: 60,
        releaseYear: 2024,
        genres: [],
        cast: [],
        director: 'Dir',
      );
      expect(movie.formattedDuration, '1h 0m');
    });
  });
}
