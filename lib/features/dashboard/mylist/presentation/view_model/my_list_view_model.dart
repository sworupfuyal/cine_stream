import 'package:cine_stream/core/api/app_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/datasources/user_list_remote_datasource.dart';
import '../../data/repositories/user_list_repository_impl.dart';
import '../../domain/entities/user_list_entity.dart';
import '../../domain/repositories/user_list_repository.dart';
import '../../domain/usecases/user_list_usecases.dart';
import '../state/my_list_state.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final userListDataSourceProvider = Provider<UserListRemoteDataSource>((ref) {
  return UserListRemoteDataSource(ref.read(apiClientProvider));
});

final userListRepositoryProvider = Provider<UserListRepository>((ref) {
  return UserListRepositoryImpl(ref.read(userListDataSourceProvider));
});

final myListViewModelProvider =
    StateNotifierProvider<MyListViewModel, MyListState>((ref) {
  final repo = ref.read(userListRepositoryProvider);
  return MyListViewModel(
    GetUserListUseCase(repo),
    RemoveFromListUseCase(repo),
    GetListCountsUseCase(repo),
  );
});

// ── ViewModel ────────────────────────────────────────────────────────────────

class MyListViewModel extends StateNotifier<MyListState> {
  final GetUserListUseCase _getUserList;
  final RemoveFromListUseCase _removeFromList;
  final GetListCountsUseCase _getListCounts;

  MyListViewModel(
    this._getUserList,
    this._removeFromList,
    this._getListCounts,
  ) : super(const MyListState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(status: MyListStatus.loading);
    await Future.wait([fetchLists(), fetchCounts()]);
  }

  Future<void> fetchLists() async {
    try {
      // Fetch both lists in parallel
      final results = await Future.wait([
        _getUserList(listType: ListType.favorite),
        _getUserList(listType: ListType.watchlater),
      ]);

      final favorites = results[0];
      final watchLater = results[1];

      state = state.copyWith(
        status: MyListStatus.success,
        allFavorites: favorites,
        allWatchLater: watchLater,
        // Show first page immediately
        displayedFavorites: _getPage(favorites, 1),
        displayedWatchLater: _getPage(watchLater, 1),
        favoritesPage: 1,
        watchLaterPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        status: MyListStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchCounts() async {
    try {
      final counts = await _getListCounts();
      state = state.copyWith(counts: counts);
    } catch (_) {} // non-critical
  }

  // ── Client-side pagination ────────────────────────────────────────────────

  List<UserListEntity> _getPage(List<UserListEntity> all, int page) {
    final end = (page * MyListState.pageSize).clamp(0, all.length);
    return all.sublist(0, end);
  }

  void loadMoreFavorites() {
    if (state.isLoadingMoreFavorites || !state.hasMorFavorites) return;

    state = state.copyWith(isLoadingMoreFavorites: true);

    final nextPage = state.favoritesPage + 1;
    final displayed = _getPage(state.allFavorites, nextPage);

    state = state.copyWith(
      displayedFavorites: displayed,
      favoritesPage: nextPage,
      isLoadingMoreFavorites: false,
    );
  }

  void loadMoreWatchLater() {
    if (state.isLoadingMoreWatchLater || !state.hasMoreWatchLater) return;

    state = state.copyWith(isLoadingMoreWatchLater: true);

    final nextPage = state.watchLaterPage + 1;
    final displayed = _getPage(state.allWatchLater, nextPage);

    state = state.copyWith(
      displayedWatchLater: displayed,
      watchLaterPage: nextPage,
      isLoadingMoreWatchLater: false,
    );
  }

  // ── Remove ────────────────────────────────────────────────────────────────

  Future<void> removeFromList({
    required String listItemId,
    required String movieId,
    required ListType listType,
  }) async {
    // 1. Optimistic: remove from UI immediately
    final newRemoving = {...state.removingIds, listItemId};
    state = state.copyWith(removingIds: newRemoving);

    final newAllFavorites = listType == ListType.favorite
        ? state.allFavorites.where((e) => e.id != listItemId).toList()
        : state.allFavorites;

    final newAllWatchLater = listType == ListType.watchlater
        ? state.allWatchLater.where((e) => e.id != listItemId).toList()
        : state.allWatchLater;

    state = state.copyWith(
      allFavorites: newAllFavorites,
      allWatchLater: newAllWatchLater,
      displayedFavorites: listType == ListType.favorite
          ? _getPage(newAllFavorites, state.favoritesPage)
          : state.displayedFavorites,
      displayedWatchLater: listType == ListType.watchlater
          ? _getPage(newAllWatchLater, state.watchLaterPage)
          : state.displayedWatchLater,
    );

    try {
      // 2. Confirm with backend
      await _removeFromList(movieId: movieId, listType: listType);

      // 3. Refresh counts
      await fetchCounts();
    } catch (e) {
      // 4. Rollback on failure — re-fetch to restore correct state
      await fetchLists();
    } finally {
      final updatedRemoving = {...state.removingIds}..remove(listItemId);
      state = state.copyWith(removingIds: updatedRemoving);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: MyListStatus.loading);
    await Future.wait([fetchLists(), fetchCounts()]);
  }
}