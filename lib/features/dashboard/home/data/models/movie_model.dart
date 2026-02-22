import '../../domain/entities/movie_entity.dart';

class MovieModel {
  final String id;
  final String title;
  final String description;
  final int duration;
  final int releaseYear;
  final List<String> genres;
  final List<String> cast;
  final String director;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime? createdAt;

  const MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.releaseYear,
    required this.genres,
    required this.cast,
    required this.director,
    this.thumbnailUrl,
    this.videoUrl,
    this.createdAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: (json['duration'] as num).toInt(),
      releaseYear: (json['releaseYear'] as num).toInt(),
      genres: List<String>.from(json['genres'] ?? []),
      cast: List<String>.from(json['cast'] ?? []),
      director: json['director'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  MovieEntity toEntity() => MovieEntity(
        id: id,
        title: title,
        description: description,
        duration: duration,
        releaseYear: releaseYear,
        genres: genres,
        cast: cast,
        director: director,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        createdAt: createdAt,
      );
}