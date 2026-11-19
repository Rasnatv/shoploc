abstract class RecentViewEvent {
  const RecentViewEvent();
}

/// Loads the top recent views (shows a loader the first time).
class LoadRecentViewsEvent extends RecentViewEvent {
  const LoadRecentViewsEvent();
}

/// Reloads silently (keeps the current list on screen).
class RefreshRecentViewsEvent extends RecentViewEvent {
  const RefreshRecentViewsEvent();
}

/// Saves a product as recently viewed (POST /recent-views).
class SaveRecentViewEvent extends RecentViewEvent {
  final int productId;
  const SaveRecentViewEvent({required this.productId});
}