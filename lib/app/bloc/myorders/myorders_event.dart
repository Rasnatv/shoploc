abstract class OrderEvent {
  const OrderEvent();
}

/// First page (shows the full-screen loader).
class LoadOrdersEvent extends OrderEvent {
  const LoadOrdersEvent();
}

/// Next page (call when the user scrolls near the bottom).
class LoadMoreOrdersEvent extends OrderEvent {
  const LoadMoreOrdersEvent();
}

/// Pull-to-refresh: reloads page 1 and keeps the list on screen meanwhile.
class RefreshOrdersEvent extends OrderEvent {
  const RefreshOrdersEvent();
}