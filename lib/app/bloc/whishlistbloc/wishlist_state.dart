


import '../../data/models/whishlistmodel.dart';

abstract class WishlistState {
  const WishlistState();

  /// Heart-icon helper that works for every state.
  bool isWishlisted(int productId) =>
      this is WishlistLoadedState &&
          (this as WishlistLoadedState).ids.contains(productId);
}

class WishlistInitialState extends WishlistState {
  const WishlistInitialState();
}

class WishlistLoadingState extends WishlistState {
  const WishlistLoadingState();
}

/// One-shot message for a snackbar (add / remove result or failure).
class WishlistMessage {
  final int seq; // changes on every message so listeners always fire
  final String text;
  final bool isError;

  /// Product this message is about (so only that card shows it).
  final int? productId;

  /// true = came from the Wishlist screen (remove); false = from a heart button.
  final bool fromWishlistScreen;

  const WishlistMessage({
    required this.seq,
    required this.text,
    this.isError = false,
    this.productId,
    this.fromWishlistScreen = false,
  });
}

class WishlistLoadedState extends WishlistState {
  final List<WishlistItemModel> items;

  /// Ids of every wishlisted product (used by the hearts on other screens).
  final Set<int> ids;
  final bool hasMore;
  final bool isLoadingMore;
  final WishlistMessage? message;

  const WishlistLoadedState({
    required this.items,
    required this.ids,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.message,
  });

  int get count => ids.length;

  WishlistLoadedState copyWith({
    List<WishlistItemModel>? items,
    Set<int>? ids,
    bool? hasMore,
    bool? isLoadingMore,
    WishlistMessage? message,
  }) =>
      WishlistLoadedState(
        items: items ?? this.items,
        ids: ids ?? this.ids,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        message: message, // null clears the old message
      );
}

class WishlistErrorState extends WishlistState {
  final String errorMessage;
  const WishlistErrorState({required this.errorMessage});
}