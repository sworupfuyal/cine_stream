class ReviewUserEntity {
  final String id;
  final String fullName;

  const ReviewUserEntity({required this.id, required this.fullName});
}

class ReviewEntity {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isOwn;
  final ReviewUserEntity user;

  const ReviewEntity({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.isOwn,
    required this.user,
  });
}

class ReviewSummaryEntity {
  final double averageRating;
  final int totalReviews;
  final List<ReviewEntity> reviews;

  const ReviewSummaryEntity({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });
}