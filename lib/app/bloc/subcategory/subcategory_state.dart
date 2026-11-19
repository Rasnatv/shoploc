
import '../../data/models/subcategorymodel.dart';

abstract class SubCategoryProductState {
  const SubCategoryProductState();
}

class SubCategoryProductInitialState extends SubCategoryProductState {
  const SubCategoryProductInitialState();
}

class SubCategoryProductLoadingState extends SubCategoryProductState {
  const SubCategoryProductLoadingState();
}

class SubCategoryProductLoadedState extends SubCategoryProductState {
  final List<SubCategoryProductModel> products;
  final int page; // last loaded page
  final bool hasMore;
  final bool isLoadingMore;

  const SubCategoryProductLoadedState({
    required this.products,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  SubCategoryProductLoadedState copyWith({
    List<SubCategoryProductModel>? products,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      SubCategoryProductLoadedState(
        products: products ?? this.products,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class SubCategoryProductErrorState extends SubCategoryProductState {
  final String errorMessage;
  const SubCategoryProductErrorState({required this.errorMessage});
}