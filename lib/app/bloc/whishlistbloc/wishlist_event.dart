
import '../../data/models/whishlistmodel.dart';

abstract class WishlistEvent {
  const WishlistEvent();
}

/// First load (page 1) - shows a loader.
class LoadWishlistEvent extends WishlistEvent {
  const LoadWishlistEvent();
}

/// Reload page 1 silently (pull-to-refresh) - keeps the list on screen.
class RefreshWishlistEvent extends WishlistEvent {
  const RefreshWishlistEvent();
}

/// Next page (infinite scroll).
class LoadMoreWishlistEvent extends WishlistEvent {
  const LoadMoreWishlistEvent();
}

/// Heart button: adds the product if it is not wishlisted, removes it if it is.
/// Pass [item] (when you have name / image / price) so the Wishlist tab
/// updates instantly without another network call.
class ToggleWishlistEvent extends WishlistEvent {
  final int productId;
  final WishlistItemModel? item;
  const ToggleWishlistEvent({required this.productId, this.item});
}

/// Removes a product (wishlist screen: swipe / delete icon).
class RemoveFromWishlistEvent extends WishlistEvent {
  final int productId;
  const RemoveFromWishlistEvent({required this.productId});
}

/// Local reset only (call on logout). Does NOT call the API.
class ResetWishlistEvent extends WishlistEvent {
  const ResetWishlistEvent();
}