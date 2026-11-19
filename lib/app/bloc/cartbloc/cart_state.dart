import '../../data/models/cartmodel.dart';


abstract class CartState {
  const CartState();
}

class CartInitialState extends CartState {
  const CartInitialState();
}

class CartLoadingState extends CartState {
  const CartLoadingState();
}

enum CartAction { add, update, remove }

/// One-shot message for a snackbar.
class CartMessage {
  final int seq; // changes on every message so listeners always fire
  final String text;
  final bool isError;
  final CartAction action;
  const CartMessage({
    required this.seq,
    required this.text,
    required this.action,
    this.isError = false,
  });
}

class CartLoadedState extends CartState {
  final List<CartItemModel> items;

  /// Number of different lines in the cart (shown on a badge).
  final int totalItems;
  final double cartTotal;

  /// "Add to cart" request running (product details button shows a loader).
  final bool isAdding;

  /// Lines with an update / remove request running (their buttons are disabled).
  final Set<int> busyIds;
  final CartMessage? message;

  const CartLoadedState({
    required this.items,
    required this.totalItems,
    required this.cartTotal,
    this.isAdding = false,
    this.busyIds = const {},
    this.message,
  });

  bool get isEmpty => items.isEmpty;

  /// Total pieces (sum of quantities).
  int get pieces => items.fold(0, (s, i) => s + i.quantity);

  CartLoadedState copyWith({
    List<CartItemModel>? items,
    int? totalItems,
    double? cartTotal,
    bool? isAdding,
    Set<int>? busyIds,
    CartMessage? message,
  }) =>
      CartLoadedState(
        items: items ?? this.items,
        totalItems: totalItems ?? this.totalItems,
        cartTotal: cartTotal ?? this.cartTotal,
        isAdding: isAdding ?? this.isAdding,
        busyIds: busyIds ?? this.busyIds,
        message: message, // null clears the old message
      );
}

class CartErrorState extends CartState {
  final String errorMessage;
  const CartErrorState({required this.errorMessage});
}