import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/features/review/data/model/review_model.dart';

class ReviewRemoteDataSource {
  final ApiClient _apiClient;

  ReviewRemoteDataSource(this._apiClient);

  Future<ReviewSummaryModel> getReviews(String movieId) async {
    final response = await _apiClient.get(ApiEndpoints.movieReviews(movieId));
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to fetch reviews');
    }
    return ReviewSummaryModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> submitReview({
    required String movieId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.movieReviews(movieId),
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to submit review');
    }
  }

  Future<void> deleteReview(String movieId) async {
    final response =
        await _apiClient.delete(ApiEndpoints.movieReviews(movieId));
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete review');
    }
  }
}