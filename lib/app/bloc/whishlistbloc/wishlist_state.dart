

import '../../data/models/product_model.dart';

abstract class WishlistState {
  const WishlistState();
}

class WishlistInitialState extends WishlistState {
  const WishlistInitialState();
}

class WishlistLoadingState extends WishlistState {
  const WishlistLoadingState();
}

class WishlistLoadedState extends WishlistState {
  final List<ProductModel> items;

  const WishlistLoadedState({required this.items});

  bool isProductWishlisted(String productId) {
    return items.any((p) => p.id == productId);
  }

  int get count => items.length;
}

class WishlistErrorState extends WishlistState {
  final String errorMessage;
  const WishlistErrorState({required this.errorMessage});
}

