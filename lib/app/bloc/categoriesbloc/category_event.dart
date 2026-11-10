abstract class CategoryEvent {
  const CategoryEvent();
}

class LoadCategoriesEvent extends CategoryEvent {
  const LoadCategoriesEvent();
}

class SelectCategoryEvent extends CategoryEvent {
  final String categoryId;
  const SelectCategoryEvent({required this.categoryId});
}

