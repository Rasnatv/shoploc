
import '../../data/models/ordersmodel.dart';

abstract class OrderState {
  const OrderState();
}

/// Nothing loaded yet (also used for guests who are not logged in).
class OrderInitialState extends OrderState {
  const OrderInitialState();
}

class OrderLoadingState extends OrderState {
  const OrderLoadingState();
}

/// [orders] may be empty -> show the "No Orders Yet" view.
class OrderLoadedState extends OrderState {
  final List<OrderModel> orders;
  final int page; // last page that was loaded
  final bool hasMore; // false when the last page came back short
  final bool isLoadingMore; // true while the next page is being fetched

  const OrderLoadedState({
    required this.orders,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  bool get isEmpty => orders.isEmpty;

  OrderLoadedState copyWith({
    List<OrderModel>? orders,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      OrderLoadedState(
        orders: orders ?? this.orders,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class OrderErrorState extends OrderState {
  final String errorMessage;
  const OrderErrorState({required this.errorMessage});
}