import '../../domain/entities/user_list_entity.dart';

enum MyListStatus { initial, loading, success, failure }

class MyListState {
  final MyListStatus status;

  // All fetched items (full lists from API)
  final List<UserListEntity> allFavorites;
  final List<UserListEntity> allWatchLater;

  // Currently displayed (paginated slice)
  final List<UserListEntity> displayedFavorites;
  final List<UserListEntity> displayedWatchLater;

  final UserListCountsEntity? counts;
  final String? error;

  // Pagination
  final int favoritesPage;
  final int watchLaterPage;
  final bool isLoadingMoreFavorites;
  final bool isLoadingMoreWatchLater;

  // Optimistic removal tracking
  final Set<String> removingIds;

  static const int pageSize = 10;

  const MyListState({
    this.status = MyListStatus.initial,
    this.allFavorites = const [],
    this.allWatchLater = const [],
    this.displayedFavorites = const [],
    this.displayedWatchLater = const [],
    this.counts,
    this.error,
    this.favoritesPage = 1,
    this.watchLaterPage = 1,
    this.isLoadingMoreFavorites = false,
    this.isLoadingMoreWatchLater = false,
    this.removingIds = const {},
  });

  bool get isLoading => status == MyListStatus.loading;
  bool get hasError => status == MyListStatus.failure;

  bool get hasMorFavorites =>
      displayedFavorites.length < allFavorites.length;
  bool get hasMoreWatchLater =>
      displayedWatchLater.length < allWatchLater.length;

  MyListState copyWith({
    MyListStatus? status,
    List<UserListEntity>? allFavorites,
    List<UserListEntity>? allWatchLater,
    List<UserListEntity>? displayedFavorites,
    List<UserListEntity>? displayedWatchLater,
    UserListCountsEntity? counts,
    String? error,
    int? favoritesPage,
    int? watchLaterPage,
    bool? isLoadingMoreFavorites,
    bool? isLoadingMoreWatchLater,
    Set<String>? removingIds,
  }) {
    return MyListState(
      status: status ?? this.status,
      allFavorites: allFavorites ?? this.allFavorites,
      allWatchLater: allWatchLater ?? this.allWatchLater,
      displayedFavorites: displayedFavorites ?? this.displayedFavorites,
      displayedWatchLater: displayedWatchLater ?? this.displayedWatchLater,
      counts: counts ?? this.counts,
      error: error ?? this.error,
      favoritesPage: favoritesPage ?? this.favoritesPage,
      watchLaterPage: watchLaterPage ?? this.watchLaterPage,
      isLoadingMoreFavorites:
          isLoadingMoreFavorites ?? this.isLoadingMoreFavorites,
      isLoadingMoreWatchLater:
          isLoadingMoreWatchLater ?? this.isLoadingMoreWatchLater,
      removingIds: removingIds ?? this.removingIds,
    );
  }
}