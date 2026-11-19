abstract class CartEvent {
  const CartEvent();
}

/// First load - shows a loader.
class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

/// Reload silently (pull-to-refresh / tab tap) - keeps the list on screen.
class RefreshCartEvent extends CartEvent {
  const RefreshCartEvent();
}

/// POST /cart/add
class AddToCartEvent extends CartEvent {
  final int productId;
  final int colorId;
  final String size;
  final int quantity;
  const AddToCartEvent({
    required this.productId,
    required this.colorId,
    required this.size,
    this.quantity = 1,
  });
}

/// POST /cart/update  (+ / - buttons)
class UpdateCartQuantityEvent extends CartEvent {
  final int cartItemId;
  final int quantity;
  const UpdateCartQuantityEvent(
      {required this.cartItemId, required this.quantity});
}

/// POST /cart/remove  (delete icon / swipe)
class RemoveCartItemEvent extends CartEvent {
  final int cartItemId;
  const RemoveCartItemEvent({required this.cartItemId});
}

/// Local reset only (call on logout). Does NOT call the API.
class ResetCartEvent extends CartEvent {
  const ResetCartEvent();
}