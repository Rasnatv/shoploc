
import '../../data/models/address_model.dart';
import '../../data/models/cart_item_model.dart';

abstract class CheckoutEvent {
  const CheckoutEvent();
}

class InitCheckoutEvent extends CheckoutEvent {
  final AddressModel? selectedAddress;
  final String? couponCode;

  const InitCheckoutEvent({
    this.selectedAddress,
    this.couponCode,
  });
}

class SelectDeliveryAddressEvent extends CheckoutEvent {
  final AddressModel address;
  const SelectDeliveryAddressEvent({required this.address});
}

class SelectPaymentMethodEvent extends CheckoutEvent {
  final String paymentMethod;
  const SelectPaymentMethodEvent({required this.paymentMethod});
}

class SubmitOrderEvent extends CheckoutEvent {
  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double couponDiscount;
  final String? couponCode;
  final double totalAmount;

  const SubmitOrderEvent({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.couponDiscount,
    this.couponCode,
    required this.totalAmount,
  });
}

