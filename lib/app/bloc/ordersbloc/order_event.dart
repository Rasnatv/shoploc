
import '../../data/models/order_model.dart';

abstract class OrderEvent {
  const OrderEvent();
}

class LoadOrdersEvent extends OrderEvent {
  const LoadOrdersEvent();
}

class PlaceOrderEvent extends OrderEvent {
  final OrderModel order;
  const PlaceOrderEvent({required this.order});
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;
  const CancelOrderEvent({required this.orderId});
}

class ReorderEvent extends OrderEvent {
  final String orderId;
  const ReorderEvent({required this.orderId});
}

