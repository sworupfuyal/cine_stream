import 'package:chewie/chewie.dart';
import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/review/domain/entities/review_entity.dart';
import 'package:cine_stream/features/review/presentation/state/review_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class MoviePlayerPage extends ConsumerStatefulWidget {
  final MovieEntity movie;
  final String videoUrl;

  const MoviePlayerPage({
    super.key,
    required this.movie,
    required this.videoUrl,
  });

  @override
  ConsumerState<MoviePlayerPage> createState() => _MoviePlayerPageState();
}

class _MoviePlayerPageState extends ConsumerState<MoviePlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final colors = Theme.of(context).colorScheme;

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: colors.primary,
          handleColor: colors.primary,
          bufferedColor: Colors.white38,
          backgroundColor: Colors.white12,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) => _PlayerError(
          message: errorMessage,
          onRetry: () {
            setState(() => _error = null);
            _disposePlayer();
            _initPlayer();
          },
        ),
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposePlayer();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Player ────────────────────────────────────────────────
            ColoredBox(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: _isInitialized
                    ? _videoPlayerController!.value.aspectRatio
                    : 16 / 9,
                child: _error != null
                    ? _PlayerError(
                        message: _error!,
                        onRetry: () {
                          setState(() => _error = null);
                          _disposePlayer();
                          _initPlayer();
                        },
                      )
                    : !_isInitialized
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                    color: colors.primary),
                                const SizedBox(height: 16),
                                const Text(
                                  'Loading stream...',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : Chewie(controller: _chewieController!),
              ),
            ),

            // ── Scrollable info + review section ──────────────────────
            Expanded(
              child: Container(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.onSurface.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back,
                                  color: colors.onSurface, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.movie.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Meta row
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _MetaChip('${widget.movie.releaseYear}'),
                          _MetaChip(widget.movie.formattedDuration),
                          if (widget.movie.director.isNotEmpty)
                            _MetaChip(widget.movie.director),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Genres
                      if (widget.movie.genres.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: widget.movie.genres
                              .map(
                                (g) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color:
                                            colors.primary.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    g,
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 14),

                      // Description
                      Text(
                        widget.movie.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: colors.onSurface.withOpacity(0.65),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Rate & Review section ─────────────────────────
                      _RateAndReviewSection(movieId: widget.movie.id),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rate & Review section — submit form + existing reviews
// ─────────────────────────────────────────────────────────────────────────────

class _RateAndReviewSection extends ConsumerStatefulWidget {
  final String movieId;

  const _RateAndReviewSection({required this.movieId});

  @override
  ConsumerState<_RateAndReviewSection> createState() =>
      _RateAndReviewSectionState();
}

class _RateAndReviewSectionState
    extends ConsumerState<_RateAndReviewSection> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isEditing = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _prefillOwnReview(ReviewEntity own) {
    _selectedRating = own.rating;
    _commentController.text = own.comment ?? '';
  }

  void _resetForm() {
    setState(() {
      _selectedRating = 0;
      _commentController.clear();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reviewState = ref.watch(reviewProvider(widget.movieId));
    final notifier = ref.read(reviewProvider(widget.movieId).notifier);

    // Find own review from list
    final ownReview = reviewState.summary?.reviews
        .where((r) => r.isOwn)
        .firstOrNull;

    // Pre-fill form when editing
    if (_isEditing && ownReview != null && _selectedRating == 0) {
      _prefillOwnReview(ownReview);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────
        Row(
          children: [
            Text(
              'Ratings & Reviews',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (reviewState.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.primary),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Average rating card ────────────────────────────────────────
        if (!reviewState.isLoading &&
            reviewState.summary != null &&
            reviewState.summary!.totalReviews > 0) ...[
          _AverageRatingCard(
              summary: reviewState.summary!, theme: theme, colors: colors),
          const SizedBox(height: 20),
        ],

        // ── Submit / Edit form ─────────────────────────────────────────
        if (ownReview == null || _isEditing) ...[
          _ReviewForm(
            selectedRating: _selectedRating,
            commentController: _commentController,
            commentFocus: _commentFocus,
            isSubmitting: reviewState.isSubmitting,
            submitError: reviewState.submitError,
            isEditing: _isEditing,
            onStarTap: (star) => setState(() => _selectedRating = star),
            onSubmit: () async {
              if (_selectedRating == 0) return;
              final ok = await notifier.submitReview(
                rating: _selectedRating,
                comment: _commentController.text.trim(),
              );
              if (ok && mounted) {
                setState(() => _isEditing = false);
                _commentFocus.unfocus();
              }
            },
            onCancel: _isEditing
                ? () {
                    _resetForm();
                  }
                : null,
          ),
          const SizedBox(height: 20),
        ]

        // ── Own review display ─────────────────────────────────────────
        else if (ownReview != null) ...[
          _OwnReviewCard(
            review: ownReview,
            theme: theme,
            colors: colors,
            isSubmitting: reviewState.isSubmitting,
            onEdit: () => setState(() => _isEditing = true),
            onDelete: () async {
              await notifier.deleteReview();
              _resetForm();
            },
          ),
          const SizedBox(height: 20),
        ],

        // ── Other reviews ──────────────────────────────────────────────
        if (!reviewState.isLoading) ...[
          if (reviewState.summary != null) ...[
            ...reviewState.summary!.reviews
                .where((r) => !r.isOwn)
                .map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewCard(
                        review: review, theme: theme, colors: colors),
                  ),
                ),
            if (reviewState.summary!.reviews
                .where((r) => !r.isOwn)
                .isEmpty &&
                ownReview == null)
              _EmptyReviews(colors: colors, theme: theme),
          ] else if (reviewState.error != null)
            _ErrorState(
              colors: colors,
              theme: theme,
              onRetry: notifier.fetch,
            ),
        ] else
          _ReviewSkeleton(colors: colors),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review submit / edit form
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewForm extends StatelessWidget {
  final int selectedRating;
  final TextEditingController commentController;
  final FocusNode commentFocus;
  final bool isSubmitting;
  final String? submitError;
  final bool isEditing;
  final ValueChanged<int> onStarTap;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  const _ReviewForm({
    required this.selectedRating,
    required this.commentController,
    required this.commentFocus,
    required this.isSubmitting,
    required this.submitError,
    required this.isEditing,
    required this.onStarTap,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit your review' : 'Rate this movie',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          // Star selector
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => onStarTap(star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      star <= selectedRating ? Icons.star : Icons.star_border,
                      key: ValueKey('$star-${star <= selectedRating}'),
                      size: 36,
                      color: star <= selectedRating
                          ? const Color(0xFFFFC107)
                          : colors.onSurface.withOpacity(0.25),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (selectedRating > 0) ...[
            const SizedBox(height: 4),
            Text(
              _ratingLabel(selectedRating),
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFFFC107),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Comment field
          TextField(
            controller: commentController,
            focusNode: commentFocus,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: 'Write a comment (optional)',
              hintStyle: TextStyle(
                  color: colors.onSurface.withOpacity(0.35), fontSize: 13),
              filled: true,
              fillColor: colors.onSurface.withOpacity(0.05),
              counterStyle: TextStyle(
                  color: colors.onSurface.withOpacity(0.35), fontSize: 10),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: colors.onSurface.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: colors.onSurface.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),

          // Error message
          if (submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                submitError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.error),
              ),
            ),

          // Buttons
          Row(
            children: [
              if (onCancel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(
                          color: colors.onSurface.withOpacity(0.25)),
                    ),
                    child: Text('Cancel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.6))),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (selectedRating == 0 || isSubmitting)
                      ? null
                      : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    disabledBackgroundColor:
                        colors.primary.withOpacity(0.35),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Review' : 'Submit Review',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Own review display card (with edit / delete)
// ─────────────────────────────────────────────────────────────────────────────

class _OwnReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final ThemeData theme;
  final ColorScheme colors;
  final bool isSubmitting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OwnReviewCard({
    required this.review,
    required this.theme,
    required this.colors,
    required this.isSubmitting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withOpacity(0.2),
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
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Your Review',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _StarRow(
                        rating: review.rating.toDouble(),
                        size: 13,
                        colors: colors),
                  ],
                ),
              ),
              // Edit / Delete actions
              if (!isSubmitting) ...[
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: colors.primary),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: colors.error),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ] else
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: colors.primary),
                ),
            ],
          ),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content:
            const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text('Delete',
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Column(
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
              _StarRow(
                  rating: summary.averageRating, size: 14, colors: colors),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.onSurface.withOpacity(0.45)),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count =
                    summary.reviews.where((r) => r.rating == star).length;
                final fraction = summary.totalReviews > 0
                    ? count / summary.totalReviews
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(0.45),
                              fontSize: 11)),
                      const SizedBox(width: 4),
                      Icon(Icons.star,
                          size: 10,
                          color: colors.onSurface.withOpacity(0.35)),
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
                                colors.primary.withOpacity(0.7)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 18,
                        child: Text('$count',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withOpacity(0.4),
                                fontSize: 11),
                            textAlign: TextAlign.right),
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
// Other users' review card
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final ThemeData theme;
  final ColorScheme colors;

  const _ReviewCard(
      {required this.review, required this.theme, required this.colors});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withOpacity(0.12),
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
                    Text(
                      review.user.fullName,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.4),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              _StarRow(
                  rating: review.rating.toDouble(),
                  size: 14,
                  colors: colors),
            ],
          ),
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
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  final ColorScheme colors;

  const _StarRow(
      {required this.rating, required this.size, required this.colors});

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

class _EmptyReviews extends StatelessWidget {
  final ColorScheme colors;
  final ThemeData theme;

  const _EmptyReviews({required this.colors, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined,
              size: 36, color: colors.onSurface.withOpacity(0.2)),
          const SizedBox(height: 8),
          Text(
            'No reviews yet — be the first!',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colors.onSurface.withOpacity(0.35)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ColorScheme colors;
  final ThemeData theme;
  final VoidCallback onRetry;

  const _ErrorState(
      {required this.colors, required this.theme, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Could not load reviews',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.error)),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Text('Retry',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

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
                      backgroundColor: colors.onSurface.withOpacity(0.08)),
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
// Existing small widgets (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String text;
  const _MetaChip(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PlayerError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load video',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 6),
              const Text(
                'Your device may not support this video format.\nTry a lower quality if available.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}