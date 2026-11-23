import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/odersprovider.dart';
import '../../core/utils/object_factory.dart';
import '../../data/models/ordersmodel.dart';
import '../../data/models/statemodel.dart';
import 'myorders_event.dart';
import 'myorders_state.dart';


class OrderBloc extends Bloc<OrderEvent, OrderState> {
  /// Page size sent as ?per_page=. The API returns no "total" or "last_page",
  /// so a page that comes back with fewer items than this is the last one.
  static const int perPage = 10;

  final OrderProvider _provider;

  OrderBloc({OrderProvider? provider})
      : _provider = provider ?? OrderProvider(),
        super(const OrderInitialState()) {
    on<LoadOrdersEvent>(_onLoad);
    on<LoadMoreOrdersEvent>(_onLoadMore);
    on<RefreshOrdersEvent>(_onRefresh);
  }

  bool get _hasToken => ObjectFactory().prefs.hasAuthToken;

  Future<void> _onLoad(LoadOrdersEvent e, Emitter<OrderState> emit) async {
    // Guest user: orders need a login, calling the API would only give 401
    if (!_hasToken) {
      emit(const OrderInitialState());
      return;
    }
    emit(const OrderLoadingState());
    await _firstPage(emit);
  }

  Future<void> _onRefresh(
      RefreshOrdersEvent e, Emitter<OrderState> emit) async {
    if (!_hasToken) {
      emit(const OrderInitialState());
      return;
    }
    await _firstPage(emit); // no loader: the old list stays visible
  }

  Future<void> _firstPage(Emitter<OrderState> emit) async {
    try {
      final res = await _provider.ordersProvider(page: 1, perPage: perPage);
      final data = res.payload<OrdersResponse>();
      if (data == null) {
        emit(OrderErrorState(
            errorMessage: res.errorText() ?? 'Failed to load orders.'));
        return;
      }
      emit(OrderLoadedState(
        orders: data.orders,
        page: 1,
        hasMore: data.orders.length >= perPage,
      ));
    } catch (_) {
      emit(const OrderErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreOrdersEvent e, Emitter<OrderState> emit) async {
    final current = state;
    if (current is! OrderLoadedState ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final res = await _provider.ordersProvider(page: nextPage, perPage: perPage);
      final data = res.payload<OrdersResponse>();

      if (data == null) {
        // keep what we have; scrolling again retries
        emit(current.copyWith(isLoadingMore: false));
        return;
      }

      // de-duplicate by orderId in case a new order shifted the pages
      final existing = current.orders.map((o) => o.orderId).toSet();
      final fresh = data.orders.where((o) => !existing.contains(o.orderId));

      emit(current.copyWith(
        orders: [...current.orders, ...fresh],
        page: nextPage,
        hasMore: data.orders.length >= perPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}