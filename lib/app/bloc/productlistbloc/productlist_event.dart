abstract class ProductListEvent {
  const ProductListEvent();
}

/// First page (shows full-screen loader).
class LoadProductListEvent extends ProductListEvent {
  const LoadProductListEvent();
}

/// Next page (called when the user scrolls near the bottom).
class LoadMoreProductListEvent extends ProductListEvent {
  const LoadMoreProductListEvent();
}

/// Pull-to-refresh: reloads page 1 and keeps content on screen.
class RefreshProductListEvent extends ProductListEvent {
  const RefreshProductListEvent();
}