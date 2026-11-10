import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/order_model.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final LocalStorageService _storageService;

  OrderBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const OrderInitialState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoadingState());
    final raw = _storageService.getOrders();
    List<OrderModel> orders = [];

    if (raw.isNotEmpty) {
      orders = raw.map((m) => OrderModel.fromMap(m)).toList();
    } else {
      orders = List.from(ShoplocDummyData.initialOrders);
      await _storageService.saveOrders(orders.map((o) => o.toMap()).toList());
    }

    emit(OrderLoadedState(orders: orders));
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoadingState());
    await Future.delayed(const Duration(milliseconds: 600));

    List<OrderModel> orders = [];
    final raw = _storageService.getOrders();
    if (raw.isNotEmpty) {
      orders = raw.map((m) => OrderModel.fromMap(m)).toList();
    } else {
      orders = List.from(ShoplocDummyData.initialOrders);
    }

    orders.insert(0, event.order);
    await _storageService.saveOrders(orders.map((o) => o.toMap()).toList());

    // Also clear cart in storage
    await _storageService.saveCartItems([]);

    emit(OrderPlacedSuccessState(order: event.order));
    emit(OrderLoadedState(orders: orders));
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is! OrderLoadedState) return;
    var orders = List<OrderModel>.from((state as OrderLoadedState).orders);

    final index = orders.indexWhere((o) => o.id == event.orderId);
    if (index >= 0) {
      final updatedSteps = List<OrderTrackingStep>.from(orders[index].trackingSteps);
      updatedSteps.add(const OrderTrackingStep(
        title: 'Cancelled',
        subtitle: 'Order was cancelled by customer',
        timestamp: 'Just now',
        isCompleted: true,
        isCurrent: true,
      ));

      orders[index] = orders[index].copyWith(
        status: 'Cancelled',
        trackingSteps: updatedSteps,
      );

      await _storageService.saveOrders(orders.map((o) => o.toMap()).toList());
      emit(OrderLoadedState(orders: orders));
    }
  }
}

