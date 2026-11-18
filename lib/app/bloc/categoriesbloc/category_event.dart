abstract class CategoryEvent {
  const CategoryEvent();
}

class LoadCategoriesEvent extends CategoryEvent {
  const LoadCategoriesEvent();
}

/// Pull-to-refresh: keeps content on screen while reloading.
class RefreshCategoriesEvent extends CategoryEvent {
  const RefreshCategoriesEvent();
}

/// Select a parent category in the left rail.
class SelectCategoryEvent extends CategoryEvent {
  final int categoryId;
  const SelectCategoryEvent({required this.categoryId});
}