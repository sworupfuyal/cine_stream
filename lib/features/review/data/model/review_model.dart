import '../../domain/entities/review_entity.dart';

class ReviewUserModel {
  final String id;
  final String fullName;

  const ReviewUserModel({required this.id, required this.fullName});

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
  return ReviewUserModel(
    id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
    // ✅ handle both fullname and fullName
    fullName: json['fullname']?.toString() ??
              json['fullName']?.toString() ??
              'Unknown',
  );
}

  ReviewUserEntity toEntity() => ReviewUserEntity(id: id, fullName: fullName);
}

class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isOwn;
  final ReviewUserModel user;

  const ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.isOwn,
    required this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isOwn: json['isOwn'] as bool? ?? false,
      user: ReviewUserModel.fromJson(
          json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  ReviewEntity toEntity() => ReviewEntity(
        id: id,
        rating: rating,
        comment: comment,
        createdAt: createdAt,
        isOwn: isOwn,
        user: user.toEntity(),
      );
}

class ReviewSummaryModel {
  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  const ReviewSummaryModel({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    return ReviewSummaryModel(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      reviews: rawReviews
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ReviewSummaryEntity toEntity() => ReviewSummaryEntity(
        averageRating: averageRating,
        totalReviews: totalReviews,
        reviews: reviews.map((r) => r.toEntity()).toList(),
      );
}