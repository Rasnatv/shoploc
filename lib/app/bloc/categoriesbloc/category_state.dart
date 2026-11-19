import '../../data/models/homemodel.dart';


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
  /// Parent categories; each carries its subcategories in [children].
  final List<CategoryApiModel> categories;
  final int? selectedCategoryId;

  const CategoryLoadedState({
    required this.categories,
    this.selectedCategoryId,
  });
}

class CategoryErrorState extends CategoryState {
  final String errorMessage;
  const CategoryErrorState({required this.errorMessage});
}