
import '../../data/models/homemodel.dart';

abstract class ProductListState {
  const ProductListState();
}

class ProductListInitialState extends ProductListState {
  const ProductListInitialState();
}

class ProductListLoadingState extends ProductListState {
  const ProductListLoadingState();
}

class ProductListLoadedState extends ProductListState {
  final List<HomeProductModel> products;
  final int page; // last loaded page
  final bool hasMore;
  final bool isLoadingMore;

  const ProductListLoadedState({
    required this.products,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ProductListLoadedState copyWith({
    List<HomeProductModel>? products,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      ProductListLoadedState(
        products: products ?? this.products,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class ProductListErrorState extends ProductListState {
  final String errorMessage;
  const ProductListErrorState({required this.errorMessage});
}