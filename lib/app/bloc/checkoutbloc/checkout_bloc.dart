import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(const CheckoutInitialState()) {
    on<InitCheckoutEvent>(_onInitCheckout);
    on<SelectDeliveryAddressEvent>(_onSelectAddress);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<SubmitOrderEvent>(_onSubmitOrder);
  }

  void _onInitCheckout(
    InitCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(CheckoutReadyState(
      selectedAddress: event.selectedAddress,
      couponCode: event.couponCode,
      selectedPaymentMethod: 'Cash on Delivery',
    ));
  }

  void _onSelectAddress(
    SelectDeliveryAddressEvent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutReadyState) {
      final current = state as CheckoutReadyState;
      emit(current.copyWith(selectedAddress: event.address));
    }
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutReadyState) {
      final current = state as CheckoutReadyState;
      emit(current.copyWith(selectedPaymentMethod: event.paymentMethod));
    }
  }

  Future<void> _onSubmitOrder(
    SubmitOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutReadyState) return;
    final readyState = state as CheckoutReadyState;

    if (readyState.selectedAddress == null) {
      emit(const CheckoutErrorState(errorMessage: 'Please select a shipping address.'));
      emit(readyState);
      return;
    }

    emit(const CheckoutLoadingState(message: 'Securing and placing your order...'));
    await Future.delayed(const Duration(milliseconds: 700));

    final orderId = 'SL-2026-${1000 + Random().nextInt(9000)}';

    final orderItems = event.items.map((cartItem) {
      return OrderItemModel(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productImage: cartItem.product.images.isNotEmpty ? cartItem.product.images.first : '',
        selectedSize: cartItem.selectedSize,
        selectedColor: cartItem.selectedColor,
        unitPrice: cartItem.product.discountedPrice,
        quantity: cartItem.quantity,
        totalPrice: cartItem.totalPrice,
      );
    }).toList();

    final order = OrderModel(
      id: orderId,
      items: orderItems,
      shippingAddress: readyState.selectedAddress!,
      subtotal: event.subtotal,
      discount: event.discount,
      deliveryFee: event.deliveryFee,
      couponDiscount: event.couponDiscount,
      couponCode: event.couponCode,
      totalAmount: event.totalAmount,
      paymentMethod: readyState.selectedPaymentMethod,
      status: 'Confirmed',
      createdAt: DateTime.now(),
      trackingSteps: [
        const OrderTrackingStep(
          title: 'Order Placed',
          subtitle: 'Received at Shoploc fulfillment centre',
          timestamp: 'Just now',
          isCompleted: true,
          isCurrent: true,
        ),
        const OrderTrackingStep(
          title: 'Processing',
          subtitle: 'Quality check and boutique packaging',
          timestamp: 'Scheduled today',
          isCompleted: false,
        ),
        const OrderTrackingStep(
          title: 'Shipped',
          subtitle: 'Handover to regional courier partner',
          timestamp: 'Estimated in 24 hrs',
          isCompleted: false,
        ),
        const OrderTrackingStep(
          title: 'Delivered',
          subtitle: 'Doorstep delivery by Shoploc',
          timestamp: 'Estimated in 3-4 days',
          isCompleted: false,
        ),
      ],
    );

    emit(CheckoutOrderSuccessState(placedOrder: order));
  }
}

