import 'package:cine_stream/features/dashboard/home/domain/entities/movie_entity.dart';
import 'package:cine_stream/features/dashboard/home/presentation/pages/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/search_state.dart';
import '../view_model/search_view_model.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (q) =>
                    ref.read(searchViewModelProvider.notifier).onQueryChanged(q),
                onClear: () {
                  _searchController.clear();
                  ref.read(searchViewModelProvider.notifier).clearSearch();
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                },
              ),
              Expanded(
                child: _SearchBody(
                  state: state,
                  theme: theme,
                  scrollController: _scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search movies by title...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBody extends StatelessWidget {
  final SearchState state;
  final ThemeData theme;
  final ScrollController scrollController;

  const _SearchBody({
    required this.state,
    required this.theme,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isInitial) return const _InitialHint();
    if (state.isLoading) return const _SearchLoading();
    if (state.hasError) return _SearchError(message: state.error ?? '');
    if (state.isEmpty) return _EmptyResults(query: state.query);

    return _ResultsGrid(
      state: state,
      theme: theme,
      scrollController: scrollController,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Initial hint
// ─────────────────────────────────────────────────────────────────────────────

class _InitialHint extends StatelessWidget {
  const _InitialHint();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 72,
            color: colors.onSurface.withOpacity(0.15),
          ),
          const SizedBox(height: 20),
          Text(
            'Find your next watch',
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by movie title',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemCount: 9,
        itemBuilder: (_, __) => _ShimmerCard(theme: theme),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final ThemeData theme;
  const _ShimmerCard({required this.theme});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
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
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results grid with pagination
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsGrid extends StatelessWidget {
  final SearchState state;
  final ThemeData theme;
  final ScrollController scrollController;

  const _ResultsGrid({
    required this.state,
    required this.theme,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Result count header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '${state.results.length} result${state.results.length == 1 ? '' : 's'}'
              '${state.hasMore ? '+' : ''}',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ),

        // Movie grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _SearchMovieCard(movie: state.results[index], theme: theme),
              childCount: state.results.length,
            ),
          ),
        ),

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
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'All results loaded',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.3),
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
// Empty / Error
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  final String query;
  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colors.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different movie title',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final String message;
  const _SearchError({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: colors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search failed',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Movie card
// ─────────────────────────────────────────────────────────────────────────────

class _SearchMovieCard extends StatelessWidget {
  final MovieEntity movie;
  final ThemeData theme;

  const _SearchMovieCard({required this.movie, required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailPage(movie: movie),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.thumbnailUrl != null)
              Image.network(
                movie.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _CardPlaceholder(theme: theme),
              )
            else
              _CardPlaceholder(theme: theme),

            // Title gradient overlay — kept black as it's a media overlay,
            // not a UI surface, and needs to contrast against any image
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colors.shadow.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Text(
                  movie.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white, // always white — text over dark image overlay
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      child: Icon(
        Icons.movie,
        size: 28,
        color: colors.onSurface.withOpacity(0.2),
      ),
    );
  }
}