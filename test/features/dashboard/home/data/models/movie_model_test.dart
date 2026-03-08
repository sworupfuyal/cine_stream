import 'package:cine_stream/features/dashboard/home/data/models/movie_model.dart';
import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieModel', () {
    final tJson = {
      '_id': 'abc123',
      'title': 'Inception',
      'description': 'A mind-bending thriller',
      'duration': 148,
      'releaseYear': 2010,
      'genres': ['Sci-Fi', 'Action'],
      'cast': ['Leonardo DiCaprio', 'Ellen Page'],
      'director': 'Christopher Nolan',
      'thumbnailUrl': 'http://example.com/thumb.jpg',
      'videoUrl': 'http://example.com/video.mp4',
      'createdAt': '2024-01-15T10:30:00.000Z',
    };

    test('fromJson should parse all fields correctly', () {
      final model = MovieModel.fromJson(tJson);
      expect(model.id, 'abc123');
      expect(model.title, 'Inception');
      expect(model.description, 'A mind-bending thriller');
      expect(model.duration, 148);
      expect(model.releaseYear, 2010);
      expect(model.genres, ['Sci-Fi', 'Action']);
      expect(model.cast, ['Leonardo DiCaprio', 'Ellen Page']);
      expect(model.director, 'Christopher Nolan');
      expect(model.thumbnailUrl, 'http://example.com/thumb.jpg');
      expect(model.videoUrl, 'http://example.com/video.mp4');
      expect(model.createdAt, isNotNull);
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        '_id': '1',
        'title': 'Test',
        'description': 'Desc',
        'duration': 90,
        'releaseYear': 2023,
        'director': 'Dir',
      };
      final model = MovieModel.fromJson(json);
      expect(model.thumbnailUrl, isNull);
      expect(model.videoUrl, isNull);
      expect(model.createdAt, isNull);
      expect(model.genres, isEmpty);
      expect(model.cast, isEmpty);
    });

    test('toEntity should return correct MovieEntity', () {
      final model = MovieModel.fromJson(tJson);
      final entity = model.toEntity();
      expect(entity, isA<MovieEntity>());
      expect(entity.id, 'abc123');
      expect(entity.title, 'Inception');
      expect(entity.duration, 148);
      expect(entity.genres, ['Sci-Fi', 'Action']);
    });

    test('fromJson should parse createdAt as DateTime', () {
      final model = MovieModel.fromJson(tJson);
      expect(model.createdAt, isA<DateTime>());
      expect(model.createdAt!.year, 2024);
      expect(model.createdAt!.month, 1);
      expect(model.createdAt!.day, 15);
    });

    test('fromJson should handle invalid createdAt gracefully', () {
      final json = {
        ...tJson,
        'createdAt': 'invalid-date',
      };
      final model = MovieModel.fromJson(json);
      expect(model.createdAt, isNull);
    });
  });
}
