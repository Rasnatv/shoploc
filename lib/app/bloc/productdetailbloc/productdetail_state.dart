
import '../../data/models/models/productdetailmodel.dart';

abstract class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsInitialState extends ProductDetailsState {
  const ProductDetailsInitialState();
}

class ProductDetailsLoadingState extends ProductDetailsState {
  const ProductDetailsLoadingState();
}

class ProductDetailsLoadedState extends ProductDetailsState {
  final ProductDetailsModel product;
  const ProductDetailsLoadedState({required this.product});
}

class ProductDetailsErrorState extends ProductDetailsState {
  final String errorMessage;
  const ProductDetailsErrorState({required this.errorMessage});
}