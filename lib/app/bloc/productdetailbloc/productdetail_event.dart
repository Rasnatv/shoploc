abstract class ProductDetailsEvent {
  const ProductDetailsEvent();
}

class LoadProductDetailsEvent extends ProductDetailsEvent {
  final int productId;
  const LoadProductDetailsEvent({required this.productId});
}