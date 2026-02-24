import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/dashboard/mylist/domain/entities/user_list_entity.dart';
import 'package:cine_stream/features/dashboard/mylist/domain/usecases/user_list_usecases.dart';
import 'package:cine_stream/features/dashboard/mylist/presentation/view_model/my_list_view_model.dart';
import 'package:cine_stream/features/review/domain/entities/review_entity.dart';
import 'package:cine_stream/features/review/presentation/state/review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'movie_player_page.dart';

// ── Local state for this screen's list status ────────────────────────────────

class _ListStatus {
  final bool isFavorite;
  final bool isWatchLater;
  final bool isLoading;

  const _ListStatus({
    this.isFavorite = false,
    this.isWatchLater = false,
    this.isLoading = true,
  });

  _ListStatus copyWith({
    bool? isFavorite,
    bool? isWatchLater,
    bool? isLoading,
  }) =>
      _ListStatus(
        isFavorite: isFavorite ?? this.isFavorite,
        isWatchLater: isWatchLater ?? this.isWatchLater,
        isLoading: isLoading ?? this.isLoading,
      );
}

final _listStatusProvider = StateNotifierProvider.autoDispose
    .family<_ListStatusNotifier, _ListStatus, String>((ref, movieId) {
  final repo = ref.read(userListRepositoryProvider);
  return _ListStatusNotifier(
    movieId: movieId,
    getStatus: GetListStatusUseCase(repo),
    addToList: AddToListUseCase(repo),
    removeFromList: RemoveFromListUseCase(repo),
    ref: ref,
  );
});

class _ListStatusNotifier extends StateNotifier<_ListStatus> {
  final String movieId;
  final GetListStatusUseCase _getStatus;
  final AddToListUseCase _addToList;
  final RemoveFromListUseCase _removeFromList;
  final Ref _ref;

  _ListStatusNotifier({
    required this.movieId,
    required GetListStatusUseCase getStatus,
    required AddToListUseCase addToList,
    required RemoveFromListUseCase removeFromList,
    required Ref ref,
  })  : _getStatus = getStatus,
        _addToList = addToList,
        _removeFromList = removeFromList,
        _ref = ref,
        super(const _ListStatus()) {
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _getStatus([movieId]);
      final s = results.isNotEmpty ? results.first : null;
      state = _ListStatus(
        isFavorite: s?.isFavorite ?? false,
        isWatchLater: s?.isWatchLater ?? false,
        isLoading: false,
      );
    } catch (e, st) {
      debugPrint('_fetchStatus error: $e\n$st');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleFavorite() async {
    final wasFavorite = state.isFavorite;
    state = state.copyWith(isFavorite: !wasFavorite);
    try {
      if (wasFavorite) {
        await _removeFromList(movieId: movieId, listType: ListType.favorite);
      } else {
        await _addToList(movieId: movieId, listType: ListType.favorite);
      }
      _ref.read(myListViewModelProvider.notifier).refresh();
    } catch (_) {
      state = state.copyWith(isFavorite: wasFavorite);
    } finally {
      await _fetchStatus();
    }
  }

  Future<void> toggleWatchLater() async {
    final wasWatchLater = state.isWatchLater;
    state = state.copyWith(isWatchLater: !wasWatchLater);
    try {
      if (wasWatchLater) {
        await _removeFromList(movieId: movieId, listType: ListType.watchlater);
      } else {
        await _addToList(movieId: movieId, listType: ListType.watchlater);
      }
      _ref.read(myListViewModelProvider.notifier).refresh();
    } catch (_) {
      state = state.copyWith(isWatchLater: wasWatchLater);
    } finally {
      await _fetchStatus();
    }
  }
}

// ── Page ─────────────────────────────────────────────────────────────────────

class MovieDetailPage extends ConsumerWidget {
  final MovieEntity movie;

  const MovieDetailPage({super.key, required this.movie});

  String _resolveVideoUrl(String url) {
    if (url.startsWith('http')) return url;
    return '${ApiEndpoints.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasVideo = movie.videoUrl != null && movie.videoUrl!.isNotEmpty;
    final listStatus = ref.watch(_listStatusProvider(movie.id));
    final reviewState = ref.watch(reviewProvider(movie.id));

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.35),
              colors.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── Hero thumbnail ───────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 420,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!listStatus.isLoading) ...[
                  IconButton(
                    tooltip: listStatus.isFavorite
                        ? 'Remove from Favourites'
                        : 'Add to Favourites',
                    icon: Icon(
                      listStatus.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          listStatus.isFavorite ? colors.error : Colors.white,
                    ),
                    onPressed: () => ref
                        .read(_listStatusProvider(movie.id).notifier)
                        .toggleFavorite(),
                  ),
                  IconButton(
                    tooltip: listStatus.isWatchLater
                        ? 'Remove from Watch Later'
                        : 'Add to Watch Later',
                    icon: Icon(
                      listStatus.isWatchLater
                          ? Icons.watch_later
                          : Icons.watch_later_outlined,
                      color: listStatus.isWatchLater
                          ? colors.primary
                          : Colors.white,
                    ),
                    onPressed: () => ref
                        .read(_listStatusProvider(movie.id).notifier)
                        .toggleWatchLater(),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (movie.thumbnailUrl != null)
                      Image.network(
                        movie.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderBg(colors: colors),
                      )
                    else
                      _PlaceholderBg(colors: colors),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            colors.surface.withOpacity(0.8),
                            colors.surface,
                          ],
                          stops: const [0.0, 0.5, 0.85, 1.0],
                        ),
                      ),
                    ),

                    // Play button
                    if (hasVideo)
                      Center(
                        child: GestureDetector(
                          onTap: () => _openPlayer(context),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      movie.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Meta row + inline average rating
                    Row(
                      children: [
                        _MetaBadge(text: '${movie.releaseYear}'),
                        const SizedBox(width: 8),
                        _MetaBadge(text: movie.formattedDuration),
                        const SizedBox(width: 8),
                        if (movie.genres.isNotEmpty)
                          _MetaBadge(text: movie.genres.first),
                        const Spacer(),
                        // ── Average rating pill ──────────────────────────
                        if (!reviewState.isLoading &&
                            reviewState.summary != null &&
                            reviewState.summary!.totalReviews > 0)
                          _RatingPill(
                            rating: reviewState.summary!.averageRating,
                            total: reviewState.summary!.totalReviews,
                            colors: colors,
                            theme: theme,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                hasVideo ? () => _openPlayer(context) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon:
                                const Icon(Icons.play_arrow_rounded, size: 22),
                            label: Text(
                              hasVideo ? 'Play Now' : 'Not Available',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ListActionButton(
                          icon: listStatus.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label:
                              listStatus.isFavorite ? 'Saved' : 'Favourite',
                          color: colors.error,
                          isActive: listStatus.isFavorite,
                          isLoading: listStatus.isLoading,
                          onTap: () => ref
                              .read(_listStatusProvider(movie.id).notifier)
                              .toggleFavorite(),
                        ),
                        const SizedBox(width: 10),
                        _ListActionButton(
                          icon: listStatus.isWatchLater
                              ? Icons.watch_later
                              : Icons.watch_later_outlined,
                          label: listStatus.isWatchLater ? 'Added' : 'Later',
                          color: colors.primary,
                          isActive: listStatus.isWatchLater,
                          isLoading: listStatus.isLoading,
                          onTap: () => ref
                              .read(_listStatusProvider(movie.id).notifier)
                              .toggleWatchLater(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Synopsis
                    Text(
                      'Synopsis',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Genres
                    if (movie.genres.isNotEmpty) ...[
                      Text(
                        'Genres',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres
                            .map((g) => _GenreChip(label: g, colors: colors))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Director
                    _InfoRow(
                      label: 'Director',
                      value: movie.director,
                      theme: theme,
                      colors: colors,
                    ),
                    const SizedBox(height: 16),

                    // Cast
                    if (movie.cast.isNotEmpty) ...[
                      Text(
                        'Cast',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.cast
                            .map((c) => _CastChip(
                                name: c, colors: colors, theme: theme))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ── Ratings & Reviews section ─────────────────────────
                    _ReviewSection(
                      reviewState: reviewState,
                      theme: theme,
                      colors: colors,
                      onRetry: () =>
                          ref.read(reviewProvider(movie.id).notifier).fetch(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlayer(BuildContext context) {
    final resolvedUrl = _resolveVideoUrl(movie.videoUrl!);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoviePlayerPage(movie: movie, videoUrl: resolvedUrl),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating & Reviews section
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  final ReviewState reviewState;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback onRetry;

  const _ReviewSection({
    required this.reviewState,
    required this.theme,
    required this.colors,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text(
              'Ratings & Reviews',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (reviewState.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
            if (reviewState.error != null)
              GestureDetector(
                onTap: onRetry,
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 16, color: colors.primary),
                    const SizedBox(width: 4),
                    Text('Retry',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.primary)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Loading skeleton
        if (reviewState.isLoading) ...[
          _ReviewSkeleton(colors: colors),
        ]

        // Error state
        else if (reviewState.error != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Could not load reviews',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colors.error),
                  ),
                ),
              ],
            ),
          ),
        ]

        // No reviews yet
        else if (reviewState.summary == null ||
            reviewState.summary!.totalReviews == 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: colors.onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 40,
                  color: colors.onSurface.withOpacity(0.25),
                ),
                const SizedBox(height: 10),
                Text(
                  'No reviews yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Be the first to rate this movie',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ]

        // Loaded with data
        else ...[
          // ── Average rating card ────────────────────────────────────────
          _AverageRatingCard(
            summary: reviewState.summary!,
            theme: theme,
            colors: colors,
          ),
          const SizedBox(height: 20),

          // ── Individual review cards ────────────────────────────────────
          ...reviewState.summary!.reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewCard(
                review: review,
                theme: theme,
                colors: colors,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Average rating card
// ─────────────────────────────────────────────────────────────────────────────

class _AverageRatingCard extends StatelessWidget {
  final ReviewSummaryEntity summary;
  final ThemeData theme;
  final ColorScheme colors;

  const _AverageRatingCard({
    required this.summary,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Big number
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              _StarRow(rating: summary.averageRating, size: 16, colors: colors),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Rating bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = summary.reviews
                    .where((r) => r.rating == star)
                    .length;
                final fraction = summary.totalReviews > 0
                    ? count / summary.totalReviews
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star, size: 10,
                          color: colors.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor:
                                colors.onSurface.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.primary.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$count',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.4),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual review card
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final ThemeData theme;
  final ColorScheme colors;

  const _ReviewCard({
    required this.review,
    required this.theme,
    required this.colors,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: review.isOwn
            ? colors.primary.withOpacity(0.06)
            : colors.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: review.isOwn
              ? colors.primary.withOpacity(0.2)
              : colors.onSurface.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withOpacity(0.15),
                child: Text(
                  review.user.fullName.isNotEmpty
                      ? review.user.fullName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.user.fullName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (review.isOwn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'You',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating
              _StarRow(
                  rating: review.rating.toDouble(), size: 14, colors: colors),
            ],
          ),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.75),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Star row widget
// ─────────────────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  final ColorScheme colors;

  const _StarRow({
    required this.rating,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star
              : half
                  ? Icons.star_half
                  : Icons.star_border,
          size: size,
          color: filled || half
              ? const Color(0xFFFFC107)
              : colors.onSurface.withOpacity(0.25),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating pill (shown inline in meta row)
// ─────────────────────────────────────────────────────────────────────────────

class _RatingPill extends StatelessWidget {
  final double rating;
  final int total;
  final ColorScheme colors;
  final ThemeData theme;

  const _RatingPill({
    required this.rating,
    required this.total,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFFFC107),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            ' ($total)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton for reviews
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewSkeleton extends StatelessWidget {
  final ColorScheme colors;

  const _ReviewSkeleton({required this.colors});

  Widget _bone({double? width, double height = 12, double radius = 6}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.onSurface.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colors.onSurface.withOpacity(0.08),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(width: 100),
                      const SizedBox(height: 6),
                      _bone(width: 60, height: 10),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _bone(width: double.infinity, height: 11),
              const SizedBox(height: 6),
              _bone(width: 200, height: 11),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List action button
// ─────────────────────────────────────────────────────────────────────────────

class _ListActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  const _ListActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.18)
              : colors.onSurface.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.5)
                : colors.onSurface.withOpacity(0.12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isActive ? color : colors.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isActive
                          ? color
                          : colors.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceholderBg extends StatelessWidget {
  final ColorScheme colors;
  const _PlaceholderBg({required this.colors});

  @override
  Widget build(BuildContext context) => Container(
        color: colors.surface,
        child: Center(
          child: Icon(Icons.movie,
              size: 80, color: colors.onSurface.withOpacity(0.12)),
        ),
      );
}

class _MetaBadge extends StatelessWidget {
  final String text;
  const _MetaBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final ColorScheme colors;
  const _GenreChip({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: colors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CastChip extends StatelessWidget {
  final String name;
  final ColorScheme colors;
  final ThemeData theme;
  const _CastChip(
      {required this.name, required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.onSurface.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline,
                size: 14, color: colors.onSurface.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      );
}