
abstract class HomeEvent {
  const HomeEvent();
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

/// Pull-to-refresh: keeps current content on screen while reloading.
class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}