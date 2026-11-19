abstract class SubCategoryProductEvent {
  const SubCategoryProductEvent();
}

/// First page (shows full-screen loader).
class LoadSubCategoryProductsEvent extends SubCategoryProductEvent {
  const LoadSubCategoryProductsEvent();
}

/// Next page (when the user scrolls near the bottom).
class LoadMoreSubCategoryProductsEvent extends SubCategoryProductEvent {
  const LoadMoreSubCategoryProductsEvent();
}

/// Pull-to-refresh: reloads page 1 and keeps content on screen.
class RefreshSubCategoryProductsEvent extends SubCategoryProductEvent {
  const RefreshSubCategoryProductsEvent();
}