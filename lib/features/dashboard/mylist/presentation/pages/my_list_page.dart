import 'package:cine_stream/features/dashboard/home/presentation/pages/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_list_entity.dart';
import '../state/my_list_state.dart';
import '../view_model/my_list_view_model.dart';

class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  ConsumerState<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _favScrollController = ScrollController();
  final ScrollController _watchScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _favScrollController.addListener(() {
      if (_favScrollController.position.pixels >=
          _favScrollController.position.maxScrollExtent - 200) {
        ref.read(myListViewModelProvider.notifier).loadMoreFavorites();
      }
    });

    _watchScrollController.addListener(() {
      if (_watchScrollController.position.pixels >=
          _watchScrollController.position.maxScrollExtent - 200) {
        ref.read(myListViewModelProvider.notifier).loadMoreWatchLater();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _favScrollController.dispose();
    _watchScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myListViewModelProvider);
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
          child: state.isLoading
              ? const _LoadingSkeleton()
              : state.hasError
                  ? _ErrorView(
                      message: state.error ?? 'Failed to load your lists',
                      onRetry: () =>
                          ref.read(myListViewModelProvider.notifier).refresh(),
                    )
                  : _ListContent(
                      state: state,
                      theme: theme,
                      tabController: _tabController,
                      favScrollController: _favScrollController,
                      watchScrollController: _watchScrollController,
                    ),
        ),
      ),
    );
  }
}

class _ListContent extends ConsumerWidget {
  final MyListState state;
  final ThemeData theme;
  final TabController tabController;
  final ScrollController favScrollController;
  final ScrollController watchScrollController;

  const _ListContent({
    required this.state,
    required this.theme,
    required this.tabController,
    required this.favScrollController,
    required this.watchScrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'My List',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (state.counts != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _CountBadge(
                  icon: Icons.favorite,
                  label: '${state.counts!.favorites} Favourites',
                  color: colors.error,
                ),
                const SizedBox(width: 12),
                _CountBadge(
                  icon: Icons.watch_later_outlined,
                  label: '${state.counts!.watchlater} Watch Later',
                  color: colors.primary,
                ),
              ],
            ),
          ),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Favourites'),
            Tab(text: 'Watch Later'),
          ],
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurface.withOpacity(0.4),
          dividerColor: colors.onSurface.withOpacity(0.1),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              RefreshIndicator(
                onRefresh: () =>
                    ref.read(myListViewModelProvider.notifier).refresh(),
                child: _MovieListTab(
                  items: state.displayedFavorites,
                  isLoadingMore: state.isLoadingMoreFavorites,
                  hasMore: state.hasMorFavorites,
                  listType: ListType.favorite,
                  removingIds: state.removingIds,
                  scrollController: favScrollController,
                  emptyMessage: "No favourites yet",
                  emptySubtitle: "Movies you love will appear here",
                  emptyIcon: Icons.favorite_border,
                ),
              ),
              RefreshIndicator(
                onRefresh: () =>
                    ref.read(myListViewModelProvider.notifier).refresh(),
                child: _MovieListTab(
                  items: state.displayedWatchLater,
                  isLoadingMore: state.isLoadingMoreWatchLater,
                  hasMore: state.hasMoreWatchLater,
                  listType: ListType.watchlater,
                  removingIds: state.removingIds,
                  scrollController: watchScrollController,
                  emptyMessage: "Watch Later is empty",
                  emptySubtitle: "Save movies to watch them later",
                  emptyIcon: Icons.watch_later_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CountBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _MovieListTab extends ConsumerWidget {
  final List<UserListEntity> items;
  final bool isLoadingMore;
  final bool hasMore;
  final ListType listType;
  final Set<String> removingIds;
  final ScrollController scrollController;
  final String emptyMessage;
  final String emptySubtitle;
  final IconData emptyIcon;

  const _MovieListTab({
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
    required this.listType,
    required this.removingIds,
    required this.scrollController,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (items.isEmpty) {
      return _EmptyState(
        message: emptyMessage,
        subtitle: emptySubtitle,
        icon: emptyIcon,
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!hasMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'All items loaded',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            );
          }
          return const SizedBox(height: 16);
        }

        final item = items[index];
        final isRemoving = removingIds.contains(item.id);

        return _SwipeToRemoveTile(
          key: ValueKey(item.id),
          item: item,
          listType: listType,
          isRemoving: isRemoving,
          onRemove: () => ref
              .read(myListViewModelProvider.notifier)
              .removeFromList(
                listItemId: item.id,
                movieId: item.movieId,
                listType: listType,
              ),
        );
      },
    );
  }
}

class _SwipeToRemoveTile extends StatelessWidget {
  final UserListEntity item;
  final ListType listType;
  final bool isRemoving;
  final VoidCallback onRemove;

  const _SwipeToRemoveTile({
    super.key,
    required this.item,
    required this.listType,
    required this.isRemoving,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final movie = item.movie;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: colors.onError, size: 26),
            const SizedBox(height: 4),
            Text(
              'Remove',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onError,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async => await _confirmRemove(context),
      onDismissed: (_) => onRemove(),
      child: AnimatedOpacity(
        opacity: isRemoving ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () {
            if (movie != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(movie: movie),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: SizedBox(
                    width: 90,
                    height: 120,
                    child: movie?.thumbnailUrl != null
                        ? Image.network(
                            movie!.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ThumbnailPlaceholder(theme: theme),
                          )
                        : _ThumbnailPlaceholder(theme: theme),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie?.title ?? 'Unknown Title',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (movie != null) ...[
                          Text(
                            '${movie.releaseYear} • ${movie.formattedDuration}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            children: movie.genres
                                .take(2)
                                .map(
                                  (g) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.onSurface.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      g,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurface.withOpacity(0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Remove / loading icon button
                IconButton(
                  icon: isRemoving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : Icon(
                          listType == ListType.favorite
                              ? Icons.favorite
                              : Icons.watch_later,
                          color: listType == ListType.favorite
                              ? colors.error
                              : colors.primary,
                          size: 22,
                        ),
                  onPressed: isRemoving
                      ? null
                      : () async {
                          final confirmed = await _confirmRemove(context);
                          if (confirmed == true) onRemove();
                        },
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove from list?'),
        content: Text(
          'Remove "${item.movie?.title ?? 'this movie'}" from '
          '${listType == ListType.favorite ? 'Favourites' : 'Watch Later'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _ThumbnailPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      child: Center(
        child: Icon(
          Icons.movie,
          color: colors.onSurface.withOpacity(0.2),
          size: 30,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.message,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colors.onSurface.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => _ShimmerTile(theme: theme),
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  final ThemeData theme;
  const _ShimmerTile({required this.theme});

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.6).animate(_ctrl);
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
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load your lists',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
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