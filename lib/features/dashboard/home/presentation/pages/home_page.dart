import 'package:cine_stream/features/dashboard/home/presentation/pages/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie_entity.dart';
import '../state/home_state.dart';
import '../view_model/home_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger loadMore when 200px from the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
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
        child: SafeArea(
          child: state.isLoading && state.movies.isEmpty
              ? const _LoadingSkeleton()
              : state.hasError && state.movies.isEmpty
                  ? _ErrorView(
                      message: state.error ?? 'Something went wrong',
                      onRetry: () =>
                          ref.read(homeViewModelProvider.notifier).refresh(),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(homeViewModelProvider.notifier).refresh(),
                      child: _HomeContent(
                        state: state,
                        theme: theme,
                        scrollController: _scrollController,
                      ),
                    ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content
// ─────────────────────────────────────────────────────────────────────────────

class _HomeContent extends ConsumerWidget {
  final HomeState state;
  final ThemeData theme;
  final ScrollController scrollController;

  const _HomeContent({
    required this.state,
    required this.theme,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesByGenre = state.moviesByGenre;
    final genreSections = moviesByGenre.entries
        .where((e) => e.value.length >= 2)
        .take(4)
        .toList();

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _Header(theme: theme),
              const SizedBox(height: 16),
              _CategoryChips(theme: theme, state: state),
              const SizedBox(height: 20),
              if (state.featuredMovies.isNotEmpty)
                _FeaturedBanner(
                    movie: state.featuredMovies.first, theme: theme),
              const SizedBox(height: 30),
            ],
          ),
        ),

        // Movie sections as slivers so they scroll together
        if (state.recentMovies.isNotEmpty)
          _MovieSectionSliver(
              title: 'New Arrivals', movies: state.recentMovies, theme: theme),

        ...genreSections.map(
          (entry) => _MovieSectionSliver(
            title: entry.key,
            movies: entry.value,
            theme: theme,
          ),
        ),

        if (state.movies.isNotEmpty)
          _MovieSectionSliver(
              title: 'All Movies', movies: state.movies, theme: theme),

        // Load more indicator
        SliverToBoxAdapter(
          child: state.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : state.hasMore
                  ? const SizedBox(height: 24)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'You\'ve seen it all!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ThemeData theme;
  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'CineStream Originals',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chips
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  final ThemeData theme;
  final HomeState state;

  const _CategoryChips({required this.theme, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(homeViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: 'All',
              isSelected: state.selectedGenre == null,
              theme: theme,
              onTap: () => vm.selectGenre(null),
            ),
            const SizedBox(width: 8),
            ...state.genres.map(
              (genre) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Chip(
                  label: genre,
                  isSelected: state.selectedGenre == genre,
                  theme: theme,
                  onTap: () => vm.selectGenre(genre),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured Banner
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedBanner extends StatelessWidget {
  final MovieEntity movie;
  final ThemeData theme;

  const _FeaturedBanner({required this.movie, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (movie.thumbnailUrl != null)
                Image.network(
                  movie.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _PlaceholderBg(theme: theme),
                )
              else
                _PlaceholderBg(theme: theme),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${movie.releaseYear}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Text('•',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5))),
                              const SizedBox(width: 8),
                              Text(
                                movie.formattedDuration,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: movie.genres
                                .take(3)
                                .map((g) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        g,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.play_arrow,
                          size: 30, color: theme.colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderBg extends StatelessWidget {
  final ThemeData theme;
  const _PlaceholderBg({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surface,
      child: const Center(
          child: Icon(Icons.movie, size: 60, color: Colors.white24)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Movie Section as Sliver
// ─────────────────────────────────────────────────────────────────────────────

class _MovieSectionSliver extends StatelessWidget {
  final String title;
  final List<MovieEntity> movies;
  final ThemeData theme;

  const _MovieSectionSliver({
    required this.title,
    required this.movies,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _MovieCard(movie: movies[index], theme: theme),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Movie Card
// ─────────────────────────────────────────────────────────────────────────────

class _MovieCard extends StatelessWidget {
  final MovieEntity movie;
  final ThemeData theme;

  const _MovieCard({required this.movie, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
),
      child: SizedBox(
        width: 130,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (movie.thumbnailUrl != null)
                Image.network(
                  movie.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _CardPlaceholder(theme: theme),
                )
              else
                _CardPlaceholder(theme: theme),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _CardPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surface,
      child: const Center(child: Icon(Icons.movie, size: 40, color: Colors.white24)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Shimmer(width: 160, height: 28, theme: theme),
          const SizedBox(height: 20),
          Row(
            children: [
              _Shimmer(width: 80, height: 36, radius: 20, theme: theme),
              const SizedBox(width: 8),
              _Shimmer(width: 80, height: 36, radius: 20, theme: theme),
              const SizedBox(width: 8),
              _Shimmer(width: 100, height: 36, radius: 20, theme: theme),
            ],
          ),
          const SizedBox(height: 20),
          _Shimmer(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 1.5,
            radius: 16,
            theme: theme,
          ),
          const SizedBox(height: 30),
          _Shimmer(width: 140, height: 20, theme: theme),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child:
                    _Shimmer(width: 130, height: 200, radius: 12, theme: theme),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final ThemeData theme;

  const _Shimmer({
    required this.width,
    required this.height,
    this.radius = 8,
    required this.theme,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error View
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            const Text('Failed to load movies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}