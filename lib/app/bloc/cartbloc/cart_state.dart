
import '../../data/models/cart_item_model.dart';

abstract class CartState {
  const CartState();
}

class CartInitialState extends CartState {
  const CartInitialState();
}

class CartLoadingState extends CartState {
  const CartLoadingState();
}

class CartLoadedState extends CartState {
  final List<CartItemModel> items;
  final double subtotal;
  final double originalSubtotal;
  final double productDiscount;
  final double deliveryFee;
  final double couponDiscount;
  final String? appliedCoupon;
  final String? couponMessage;
  final bool isCouponError;
  final double grandTotal;

  const CartLoadedState({
    required this.items,
    required this.subtotal,
    required this.originalSubtotal,
    required this.productDiscount,
    required this.deliveryFee,
    required this.couponDiscount,
    this.appliedCoupon,
    this.couponMessage,
    this.isCouponError = false,
    required this.grandTotal,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  CartLoadedState copyWith({
    List<CartItemModel>? items,
    double? subtotal,
    double? originalSubtotal,
    double? productDiscount,
    double? deliveryFee,
    double? couponDiscount,
    String? appliedCoupon,
    String? couponMessage,
    bool? isCouponError,
    double? grandTotal,
  }) {
    return CartLoadedState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      originalSubtotal: originalSubtotal ?? this.originalSubtotal,
      productDiscount: productDiscount ?? this.productDiscount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      couponMessage: couponMessage ?? this.couponMessage,
      isCouponError: isCouponError ?? this.isCouponError,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }
}

class CartErrorState extends CartState {
  final String errorMessage;
  const CartErrorState({required this.errorMessage});
}

