import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/features/review/data/datasource/review_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/review_repository.dart';
import '../../domain/entities/review_entity.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final reviewDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return ReviewRemoteDataSource(client);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ref.read(reviewDataSourceProvider));
});

// ── State ─────────────────────────────────────────────────────────────────────

class ReviewState {
  final ReviewSummaryEntity? summary;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? submitError;
  final bool submitSuccess;

  const ReviewState({
    this.summary,
    this.isLoading = true,
    this.isSubmitting = false,
    this.error,
    this.submitError,
    this.submitSuccess = false,
  });

  ReviewState copyWith({
    ReviewSummaryEntity? summary,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? submitError,
    bool? submitSuccess,
    bool clearSubmitError = false,
    bool clearError = false,
  }) =>
      ReviewState(
        summary: summary ?? this.summary,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : (error ?? this.error),
        submitError:
            clearSubmitError ? null : (submitError ?? this.submitError),
        submitSuccess: submitSuccess ?? this.submitSuccess,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository _repository;
  final ReviewRemoteDataSource _dataSource;
  final String movieId;

  ReviewNotifier({
    required ReviewRepository repository,
    required ReviewRemoteDataSource dataSource,
    required this.movieId,
  })  : _repository = repository,
        _dataSource = dataSource,
        super(const ReviewState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final summary = await _repository.getReviews(movieId);
      state = ReviewState(summary: summary, isLoading: false);
    } catch (e) {
      state = ReviewState(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitReview({required int rating, String? comment}) async {
    state = state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      submitSuccess: false,
    );
    try {
      await _dataSource.submitReview(
        movieId: movieId,
        rating: rating,
        comment: comment,
      );
      state = state.copyWith(isSubmitting: false, submitSuccess: true);
      await fetch(); // refresh list after submit
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: e.toString(),
        submitSuccess: false,
      );
      return false;
    }
  }

  Future<bool> deleteReview() async {
    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      await _dataSource.deleteReview(movieId);
      state = state.copyWith(isSubmitting: false, submitSuccess: true);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: e.toString(),
      );
      return false;
    }
  }

  void clearSubmitSuccess() {
    state = state.copyWith(submitSuccess: false);
  }
}

// ── Provider family ───────────────────────────────────────────────────────────

final reviewProvider = StateNotifierProvider.autoDispose
    .family<ReviewNotifier, ReviewState, String>((ref, movieId) {
  return ReviewNotifier(
    repository: ref.read(reviewRepositoryProvider),
    dataSource: ref.read(reviewDataSourceProvider),
    movieId: movieId,
  );
});