import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/features/dashboard/home/data/datasources/home_remote_datasource.dart';
import 'package:cine_stream/features/dashboard/home/data/repositories/home_repository_impl.dart';
import 'package:cine_stream/features/dashboard/home/domain/repositories/home_repository.dart';
import 'package:cine_stream/features/dashboard/home/domain/usecases/get_movies_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../state/home_state.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource(ref.read(apiClientProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.read(homeRemoteDataSourceProvider));
});

final getMoviesUseCaseProvider = Provider<GetMoviesUseCase>((ref) {
  return GetMoviesUseCase(ref.read(homeRepositoryProvider));
});

final getGenresUseCaseProvider = Provider<GetGenresUseCase>((ref) {
  return GetGenresUseCase(ref.read(homeRepositoryProvider));
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    ref.read(getMoviesUseCaseProvider),
    ref.read(getGenresUseCaseProvider),
  );
});

// ── ViewModel ────────────────────────────────────────────────────────────────

class HomeViewModel extends StateNotifier<HomeState> {
  final GetMoviesUseCase _getMovies;
  final GetGenresUseCase _getGenres;

  static const int _pageSize = 10;

  HomeViewModel(this._getMovies, this._getGenres) : super(const HomeState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(status: HomeStatus.loading);
    await Future.wait([fetchMovies(), fetchGenres()]);
  }

  /// Extracts unique genres from the currently loaded movies.
  /// Used as a reliable fallback when the genres API fails or returns nothing.
  List<String> _genresFromMovies() {
    return state.movies
        .expand((m) => m.genres)
        .toSet()
        .toList()
      ..sort();
  }

  /// Initial fetch or refresh — resets to page 1
  Future<void> fetchMovies({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        status: HomeStatus.loading,
        movies: [],
        pagination: null,
      );
    }

    try {
      final result = await _getMovies(
        page: 1,
        limit: _pageSize,
        genre: state.selectedGenre,
      );

      // ── Derive genres from movies if the genres list is still empty.
      // This makes chips work even if fetchGenres() failed or returned [].
      final derivedGenres = state.genres.isEmpty
          ? (result.movies
                .expand((m) => m.genres)
                .toSet()
                .toList()
              ..sort())
          : state.genres;

      state = state.copyWith(
        status: HomeStatus.success,
        movies: result.movies,
        pagination: result.pagination,
        genres: derivedGenres,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.failure,
        error: e.toString(),
      );
    }
  }

  /// Appends next page to existing list
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final nextPage = (state.pagination?.page ?? 1) + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _getMovies(
        page: nextPage,
        limit: _pageSize,
        genre: state.selectedGenre,
      );

      // Merge any new genres discovered in later pages
      final newGenres = result.movies.expand((m) => m.genres).toSet();
      final mergedGenres = {...state.genres, ...newGenres}.toList()..sort();

      state = state.copyWith(
        status: HomeStatus.success,
        movies: [...state.movies, ...result.movies],
        pagination: result.pagination,
        isLoadingMore: false,
        genres: mergedGenres,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Tries the genres API endpoint. If it returns data, use it.
  /// If it fails or returns empty, genres will be derived from movies instead.
  Future<void> fetchGenres() async {
    try {
      final genres = await _getGenres();
      if (genres.isNotEmpty) {
        state = state.copyWith(genres: genres);
      }
      // If empty, fetchMovies() will derive genres from movie data instead
    } catch (_) {
      // Silently ignored — fetchMovies() handles the fallback
    }
  }

  Future<void> selectGenre(String? genre) async {
    if (state.selectedGenre == genre) {
      state = state.copyWith(clearGenre: true);
    } else {
      state = state.copyWith(selectedGenre: genre);
    }
    await fetchMovies(refresh: true);
  }

  Future<void> refresh() => fetchMovies(refresh: true);
}