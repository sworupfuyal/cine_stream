class MovieEntity {
  final String id;
  final String title;
  final String description;
  final int duration; // minutes
  final int releaseYear;
  final List<String> genres;
  final List<String> cast;
  final String director;
  final String? thumbnailUrl;
  final String? videoUrl;
  final DateTime? createdAt;

  const MovieEntity({
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

  String get formattedDuration {
    final h = duration ~/ 60;
    final m = duration % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}