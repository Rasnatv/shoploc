
import '../../data/models/address_model.dart';
import '../../data/models/order_model.dart';

abstract class CheckoutState {
  const CheckoutState();
}

class CheckoutInitialState extends CheckoutState {
  const CheckoutInitialState();
}

class CheckoutLoadingState extends CheckoutState {
  final String? message;
  const CheckoutLoadingState({this.message});
}

class CheckoutReadyState extends CheckoutState {
  final AddressModel? selectedAddress;
  final String selectedPaymentMethod; // 'Cash on Delivery', 'Online Payment'
  final String? couponCode;
  final double deliveryFee;

  const CheckoutReadyState({
    this.selectedAddress,
    this.selectedPaymentMethod = 'Cash on Delivery',
    this.couponCode,
    this.deliveryFee = 0.0,
  });

  CheckoutReadyState copyWith({
    AddressModel? selectedAddress,
    String? selectedPaymentMethod,
    String? couponCode,
    double? deliveryFee,
  }) {
    return CheckoutReadyState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      couponCode: couponCode ?? this.couponCode,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}

class CheckoutOrderSuccessState extends CheckoutState {
  final OrderModel placedOrder;
  const CheckoutOrderSuccessState({required this.placedOrder});
}

class CheckoutErrorState extends CheckoutState {
  final String errorMessage;
  const CheckoutErrorState({required this.errorMessage});
}

