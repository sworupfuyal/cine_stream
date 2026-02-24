import 'package:cine_stream/features/review/data/datasource/review_remote_datasource.dart';

import '../../domain/entities/review_entity.dart';

// ── Abstract interface ────────────────────────────────────────────────────────
abstract class ReviewRepository {
  Future<ReviewSummaryEntity> getReviews(String movieId);
}

// ── Implementation ────────────────────────────────────────────────────────────
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _dataSource;

  ReviewRepositoryImpl(this._dataSource);

  @override
  Future<ReviewSummaryEntity> getReviews(String movieId) async {
    try {
      final model = await _dataSource.getReviews(movieId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}