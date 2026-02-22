import 'dart:async';

import 'package:cine_stream/features/dashboard/home/data/repositories/home_repository_impl.dart';
import 'package:cine_stream/features/dashboard/home/domain/repositories/home_repository.dart';
import 'package:cine_stream/features/dashboard/home/presentation/view_model/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../state/search_state.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final searchRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.read(homeRemoteDataSourceProvider));
});

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel(ref.read(searchRepositoryProvider));
});

// ── ViewModel ────────────────────────────────────────────────────────────────

class SearchViewModel extends StateNotifier<SearchState> {
  final HomeRepository _repository;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 500);
  static const int _pageSize = 10;

  SearchViewModel(this._repository) : super(const SearchState());

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);

    if (query.trim().isEmpty) {
      _debounce?.cancel();
      state = const SearchState();
      return;
    }

    // Debounce — wait for user to stop typing
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => _search(query));
  }

  Future<void> _search(String query) async {
    state = state.copyWith(
      status: SearchStatus.loading,
      results: [],   // clear previous results
      pagination: null,
    );

    try {
      // ✅ search by title only — pass query directly to 'search' param
      final result = await _repository.getMovies(
        search: query.trim(),
        page: 1,
        limit: _pageSize,
      );

      state = state.copyWith(
        status:
            result.movies.isEmpty ? SearchStatus.empty : SearchStatus.success,
        results: result.movies,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.failure,
        error: e.toString(),
      );
    }
  }

  /// Load next page for current query
  Future<void> loadMore() async {
    if (!state.canLoadMore || state.query.trim().isEmpty) return;

    final nextPage = (state.pagination?.page ?? 1) + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.getMovies(
        search: state.query.trim(),
        page: nextPage,
        limit: _pageSize,
      );

      state = state.copyWith(
        status: SearchStatus.success,
        results: [...state.results, ...result.movies], // ✅ append
        pagination: result.pagination,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}