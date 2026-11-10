

import '../../data/models/order_model.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitialState extends OrderState {
  const OrderInitialState();
}

class OrderLoadingState extends OrderState {
  const OrderLoadingState();
}

class OrderLoadedState extends OrderState {
  final List<OrderModel> orders;
  const OrderLoadedState({required this.orders});

  int get totalOrderCount => orders.length;
}

class OrderPlacedSuccessState extends OrderState {
  final OrderModel order;
  const OrderPlacedSuccessState({required this.order});
}

class OrderErrorState extends OrderState {
  final String errorMessage;
  const OrderErrorState({required this.errorMessage});
}

