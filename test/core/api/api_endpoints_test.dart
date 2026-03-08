import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEndpoints', () {
    test('register should contain /api/auth/register', () {
      expect(ApiEndpoints.register, contains('/api/auth/register'));
    });

    test('login should contain /api/auth/login', () {
      expect(ApiEndpoints.login, contains('/api/auth/login'));
    });

    test('getProfile should contain /api/user/getProfile', () {
      expect(ApiEndpoints.getProfile, contains('/api/user/getProfile'));
    });

    test('updateProfile should contain /api/user/updateProfile', () {
      expect(ApiEndpoints.updateProfile, contains('/api/user/updateProfile'));
    });

    test('getMovies should contain /api/movies', () {
      expect(ApiEndpoints.getMovies, contains('/api/movies'));
    });

    test('getGenres should contain /api/movies/genres/list', () {
      expect(ApiEndpoints.getGenres, contains('/api/movies/genres/list'));
    });

    test('userLists should contain /api/user/lists', () {
      expect(ApiEndpoints.userLists, contains('/api/user/lists'));
    });

    test('movieReviews should include movieId', () {
      final url = ApiEndpoints.movieReviews('abc123');
      expect(url, '/api/reviews/abc123');
    });

    test('requestPasswordReset should start with /api/auth', () {
      expect(
        ApiEndpoints.requestPasswordReset,
        '/api/auth/request-password-reset',
      );
    });

    test('resetPassword should be correct', () {
      expect(ApiEndpoints.resetPassword, '/api/auth/reset-password');
    });

    test('connectionTimeout should be 30 seconds', () {
      expect(
        ApiEndpoints.connectionTimeout,
        const Duration(seconds: 30),
      );
    });

    test('receiveTimeout should be 30 seconds', () {
      expect(
        ApiEndpoints.receiveTimeout,
        const Duration(seconds: 30),
      );
    });

    test('baseUrl should start with http://', () {
      expect(ApiEndpoints.baseUrl, startsWith('http://'));
    });
  });
}
