

import '../../data/models/category_model.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitialState extends CategoryState {
  const CategoryInitialState();
}

class CategoryLoadingState extends CategoryState {
  const CategoryLoadingState();
}

class CategoryLoadedState extends CategoryState {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;

  const CategoryLoadedState({
    required this.categories,
    this.selectedCategoryId,
  });
}

class CategoryErrorState extends CategoryState {
  final String errorMessage;
  const CategoryErrorState({required this.errorMessage});
}

