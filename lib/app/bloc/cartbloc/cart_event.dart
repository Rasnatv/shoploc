
import '../../data/models/product_model.dart';

abstract class CartEvent {
  const CartEvent();
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

class AddToCartEvent extends CartEvent {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;

  const AddToCartEvent({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });
}

class UpdateCartQuantityEvent extends CartEvent {
  final String cartItemId;
  final int newQuantity;

  const UpdateCartQuantityEvent({
    required this.cartItemId,
    required this.newQuantity,
  });
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;
  const RemoveFromCartEvent({required this.cartItemId});
}

class ApplyCouponEvent extends CartEvent {
  final String couponCode;
  const ApplyCouponEvent({required this.couponCode});
}

class RemoveCouponEvent extends CartEvent {
  const RemoveCouponEvent();
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

