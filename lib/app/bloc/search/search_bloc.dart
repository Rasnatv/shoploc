import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/search/search_state.dart';
import '../../apiprovider/searchprovider.dart';
import '../../data/models/searchmodel.dart';
import '../../data/models/statemodel.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// Wait this long after the last keystroke before calling the API.
  static const Duration debounce = Duration(milliseconds: 400);

  /// Shorter text than this does not search.
  static const int minChars = 2;

  final SearchProvider _provider;

  /// The newest query. A finished request whose query no longer matches is
  /// dropped, so slow old responses can never overwrite newer results.
  String _latest = '';

  SearchBloc({SearchProvider? provider})
      : _provider = provider ?? SearchProvider(),
        super(const SearchInitialState()) {
    on<SearchQueryChanged>(_onChanged);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onChanged(
      SearchQueryChanged e, Emitter<SearchState> emit) async {
    final q = e.query.trim();
    _latest = q;

    if (q.length < minChars) {
      emit(const SearchInitialState());
      return;
    }

    await Future.delayed(debounce);
    // user typed something newer while we were waiting
    if (_latest != q || emit.isDone) return;

    await _search(q, emit);
  }

  Future<void> _onSubmitted(
      SearchSubmitted e, Emitter<SearchState> emit) async {
    final q = e.query.trim();
    _latest = q;

    if (q.isEmpty) {
      emit(const SearchInitialState());
      return;
    }
    await _search(q, emit);
  }

  void _onCleared(SearchCleared e, Emitter<SearchState> emit) {
    _latest = '';
    emit(const SearchInitialState());
  }

  /// Always emits something, so the spinner can never wait forever.
  Future<void> _search(String q, Emitter<SearchState> emit) async {
    emit(SearchLoadingState(query: q));
    try {
      final res = await _provider.searchProvider(q);
      if (_latest != q || emit.isDone) return; // stale response

      final data = res.payload<SearchResponse>();
      if (data == null) {
        emit(SearchErrorState(
            query: q, errorMessage: res.errorText() ?? 'Search failed.'));
        return;
      }
      emit(SearchLoadedState(query: q, results: data.products));
    } catch (_) {
      if (_latest != q || emit.isDone) return;
      emit(SearchErrorState(
          query: q,
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}