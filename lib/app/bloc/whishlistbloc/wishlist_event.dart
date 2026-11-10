
import '../../data/models/product_model.dart';

abstract class WishlistEvent {
  const WishlistEvent();
}

class LoadWishlistEvent extends WishlistEvent {
  const LoadWishlistEvent();
}

class ToggleWishlistEvent extends WishlistEvent {
  final ProductModel product;
  const ToggleWishlistEvent({required this.product});
}

class RemoveFromWishlistEvent extends WishlistEvent {
  final String productId;
  const RemoveFromWishlistEvent({required this.productId});
}

class ClearWishlistEvent extends WishlistEvent {
  const ClearWishlistEvent();
}

