abstract class SearchEvent {
  const SearchEvent();
}

/// Called on every keystroke. The bloc waits a moment (debounce) and ignores
/// older queries, so the API is only hit once the user stops typing.
class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

/// Keyboard "search" button / search icon tap - searches immediately.
class SearchSubmitted extends SearchEvent {
  final String query;
  const SearchSubmitted(this.query);
}

/// Clear (X) button - back to the empty start state. Does NOT call the API.
class SearchCleared extends SearchEvent {
  const SearchCleared();
}