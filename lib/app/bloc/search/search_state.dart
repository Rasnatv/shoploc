import '../../data/models/searchmodel.dart';

abstract class SearchState {
  const SearchState();
}

/// Nothing typed yet (or the text is too short to search).
class SearchInitialState extends SearchState {
  const SearchInitialState();
}

class SearchLoadingState extends SearchState {
  final String query;
  const SearchLoadingState({required this.query});
}

/// [results] may be empty -> show a "No products found" view.
class SearchLoadedState extends SearchState {
  final String query;
  final List<SearchProductModel> results;

  const SearchLoadedState({required this.query, required this.results});

  bool get isEmpty => results.isEmpty;
}

class SearchErrorState extends SearchState {
  final String query;
  final String errorMessage;

  const SearchErrorState({required this.query, required this.errorMessage});
}