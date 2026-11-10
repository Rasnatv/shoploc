import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final LocalStorageService _storageService;

  CartBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const CartInitialState()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ApplyCouponEvent>(_onApplyCoupon);
    on<RemoveCouponEvent>(_onRemoveCoupon);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoadingState());
    final rawItems = _storageService.getCartItems();
    final items = rawItems.map((m) => CartItemModel.fromMap(m)).toList();
    emit(_calculateState(items: items));
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = state is CartLoadedState
        ? List<CartItemModel>.from((state as CartLoadedState).items)
        : <CartItemModel>[];

    final itemId = CartItemModel.generateId(
      event.product.id,
      event.selectedSize,
      event.selectedColor,
    );

    final existingIndex = currentItems.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      final existing = currentItems[existingIndex];
      currentItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + event.quantity,
      );
    } else {
      currentItems.add(CartItemModel(
        id: itemId,
        product: event.product,
        selectedSize: event.selectedSize,
        selectedColor: event.selectedColor,
        quantity: event.quantity,
        addedAt: DateTime.now(),
      ));
    }

    await _storageService.saveCartItems(currentItems.map((e) => e.toMap()).toList());

    final appliedCoupon = state is CartLoadedState
        ? (state as CartLoadedState).appliedCoupon
        : null;

    emit(_calculateState(items: currentItems, couponCode: appliedCoupon));
  }

  Future<void> _onUpdateQuantity(
    UpdateCartQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoadedState) return;
    final current = state as CartLoadedState;
    final items = List<CartItemModel>.from(current.items);

    final index = items.indexWhere((i) => i.id == event.cartItemId);
    if (index >= 0) {
      if (event.newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: event.newQuantity);
      }
      await _storageService.saveCartItems(items.map((e) => e.toMap()).toList());
      emit(_calculateState(items: items, couponCode: current.appliedCoupon));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoadedState) return;
    final current = state as CartLoadedState;
    final items = List<CartItemModel>.from(current.items);

    items.removeWhere((i) => i.id == event.cartItemId);
    await _storageService.saveCartItems(items.map((e) => e.toMap()).toList());
    emit(_calculateState(items: items, couponCode: current.appliedCoupon));
  }

  void _onApplyCoupon(
    ApplyCouponEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoadedState) return;
    final current = state as CartLoadedState;
    final code = event.couponCode.trim().toUpperCase();

    if (code.isEmpty) {
      emit(current.copyWith(
        couponMessage: 'Please enter a coupon code',
        isCouponError: true,
      ));
      return;
    }

    if (AppConstants.couponPercentages.containsKey(code)) {
      final discountPercent = AppConstants.couponPercentages[code]!;
      emit(_calculateState(
        items: current.items,
        couponCode: code,
        customMessage: 'Coupon $code applied! ($discountPercent% OFF)',
      ));
    } else if (AppConstants.couponFlatDiscounts.containsKey(code)) {
      final flatDiscount = AppConstants.couponFlatDiscounts[code]!;
      emit(_calculateState(
        items: current.items,
        couponCode: code,
        customMessage: 'Coupon $code applied! (₹$flatDiscount OFF)',
      ));
    } else {
      emit(current.copyWith(
        couponMessage: 'Invalid coupon code. Try "SHOPLOC10" or "FIRST50".',
        isCouponError: true,
      ));
    }
  }

  void _onRemoveCoupon(
    RemoveCouponEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoadedState) return;
    final current = state as CartLoadedState;
    emit(_calculateState(
      items: current.items,
      couponCode: null,
      customMessage: 'Coupon removed',
    ));
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    await _storageService.saveCartItems([]);
    emit(_calculateState(items: []));
  }

  CartLoadedState _calculateState({
    required List<CartItemModel> items,
    String? couponCode,
    String? customMessage,
  }) {
    double subtotal = 0.0;
    double originalSubtotal = 0.0;

    for (final item in items) {
      subtotal += item.product.discountedPrice * item.quantity;
      originalSubtotal += item.product.originalPrice * item.quantity;
    }

    final productDiscount = originalSubtotal - subtotal;

    // Delivery fee
    final deliveryFee = (subtotal >= AppConstants.freeShippingThreshold || items.isEmpty)
        ? 0.0
        : AppConstants.standardShippingFee;

    // Coupon discount
    double couponDiscount = 0.0;
    if (couponCode != null && items.isNotEmpty) {
      if (AppConstants.couponPercentages.containsKey(couponCode)) {
        final percent = AppConstants.couponPercentages[couponCode]!;
        couponDiscount = (subtotal * percent) / 100.0;
      } else if (AppConstants.couponFlatDiscounts.containsKey(couponCode)) {
        couponDiscount = AppConstants.couponFlatDiscounts[couponCode]!;
        if (couponDiscount > subtotal) couponDiscount = subtotal;
      }
    }

    final grandTotal = (subtotal - couponDiscount + deliveryFee).clamp(0.0, double.infinity);

    return CartLoadedState(
      items: items,
      subtotal: subtotal,
      originalSubtotal: originalSubtotal,
      productDiscount: productDiscount,
      deliveryFee: deliveryFee,
      couponDiscount: couponDiscount,
      appliedCoupon: couponCode,
      couponMessage: customMessage,
      isCouponError: false,
      grandTotal: grandTotal,
    );
  }
}

