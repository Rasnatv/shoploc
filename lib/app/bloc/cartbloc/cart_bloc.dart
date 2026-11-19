
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/cartprovider.dart';
import '../../core/utils/object_factory.dart';
import '../../data/models/cartmodel.dart';
import '../../data/models/statemodel.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartProvider _provider;
  int _msgSeq = 0;

  CartBloc({CartProvider? provider})
      : _provider = provider ?? CartProvider(),
        super(const CartInitialState()) {
    on<LoadCartEvent>(_onLoad);
    on<RefreshCartEvent>(_onRefresh);
    on<AddToCartEvent>(_onAdd);
    on<UpdateCartQuantityEvent>(_onUpdate);
    on<RemoveCartItemEvent>(_onRemove);
    on<ResetCartEvent>((e, emit) => emit(const CartInitialState()));
  }

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  /// A 401 clears the session (DioErrorHandler). When a request ends and the
  /// user is no longer logged in, drop the cart and show the login prompt.
  bool _sessionEnded(Emitter<CartState> emit) {
    if (_loggedIn) return false;
    emit(const CartErrorState(
        errorMessage: 'Session expired. Please login again.'));
    return true;
  }

  static const CartLoadedState _empty =
  CartLoadedState(items: [], totalItems: 0, cartTotal: 0);

  CartLoadedState get _loaded =>
      state is CartLoadedState ? state as CartLoadedState : _empty;

  CartMessage _msg(String text, CartAction action, {bool isError = false}) =>
      CartMessage(seq: ++_msgSeq, text: text, action: action, isError: isError);

  double _sum(List<CartItemModel> items) =>
      items.fold(0.0, (a, b) => a + b.itemTotal);

  // ---------------- LOAD ----------------
  Future<void> _onLoad(LoadCartEvent e, Emitter<CartState> emit) async {
    if (!_loggedIn) {
      emit(const CartErrorState(errorMessage: 'Please login to view your cart.'));
      return;
    }
    emit(const CartLoadingState());
    await _fetch(emit, showErrorState: true);
  }

  Future<void> _onRefresh(RefreshCartEvent e, Emitter<CartState> emit) async {
    if (!_loggedIn) {
      emit(const CartErrorState(errorMessage: 'Please login to view your cart.'));
      return;
    }
    await _fetch(emit, showErrorState: state is! CartLoadedState);
  }

  /// Returns true when the cart was loaded.
  Future<bool> _fetch(Emitter<CartState> emit,
      {required bool showErrorState}) async {
    try {
      final res = await _provider.cartProvider();
      final data = res.payload<CartResponse>();
      if (data == null) {
        if (_sessionEnded(emit)) return false;
        if (showErrorState) {
          emit(CartErrorState(
              errorMessage: res.errorText() ?? 'Failed to load cart.'));
        }
        return false;
      }
      emit(CartLoadedState(
        items: data.items,
        totalItems: data.totalItems,
        cartTotal: data.cartTotal,
      ));
      return true;
    } catch (_) {
      if (showErrorState) {
        emit(const CartErrorState(
            errorMessage: 'Something went wrong. Please try again.'));
      }
      return false;
    }
  }

  void _emitMessage(Emitter<CartState> emit, String text, CartAction action,
      {bool isError = false}) {
    emit(_loaded.copyWith(message: _msg(text, action, isError: isError)));
  }

  // ---------------- ADD ----------------
  Future<void> _onAdd(AddToCartEvent e, Emitter<CartState> emit) async {
    if (!_loggedIn) {
      _emitMessage(emit, 'Please login to add items to your cart.',
          CartAction.add,
          isError: true);
      return;
    }
    if (_loaded.isAdding) return;

    emit(_loaded.copyWith(isAdding: true));

    final res = await _provider.addToCartProvider(
      productId: e.productId,
      colorId: e.colorId,
      size: e.size,
      quantity: e.quantity,
    );
    final data = res.payload<CartActionResponse>();

    if (data == null) {
      if (_sessionEnded(emit)) return;
      emit(_loaded.copyWith(
        isAdding: false,
        message: _msg(res.errorText() ?? 'Could not add to cart.', CartAction.add,
            isError: true),
      ));
      return;
    }

    // Pull the real cart (names, prices, merged quantities...) then notify.
    final ok = await _fetch(emit, showErrorState: false);
    if (!ok) emit(_loaded.copyWith(isAdding: false));
    _emitMessage(emit,
        data.message.isNotEmpty ? data.message : 'Added to cart.', CartAction.add);
  }

  // ---------------- UPDATE QUANTITY ----------------
  Future<void> _onUpdate(
      UpdateCartQuantityEvent e, Emitter<CartState> emit) async {
    final s = state;
    if (s is! CartLoadedState || e.quantity < 1) return;
    if (s.busyIds.contains(e.cartItemId)) return;

    final idx = s.items.indexWhere((i) => i.cartItemId == e.cartItemId);
    if (idx < 0 || s.items[idx].quantity == e.quantity) return;
    final old = s.items[idx];

    // optimistic
    final updated = [...s.items]..[idx] = old.withQuantity(e.quantity);
    emit(s.copyWith(
      items: updated,
      cartTotal: _sum(updated),
      busyIds: {...s.busyIds, e.cartItemId},
    ));

    final res = await _provider.updateCartProvider(
        cartItemId: e.cartItemId, quantity: e.quantity);
    final data = res.payload<CartActionResponse>();

    final cur = _loaded;
    final busy = {...cur.busyIds}..remove(e.cartItemId);
    final i2 = cur.items.indexWhere((i) => i.cartItemId == e.cartItemId);

    if (data == null) {
      if (_sessionEnded(emit)) return;
      // revert this line
      final reverted = [...cur.items];
      if (i2 >= 0) reverted[i2] = old;
      emit(cur.copyWith(
        items: reverted,
        cartTotal: _sum(reverted),
        busyIds: busy,
        message: _msg(res.errorText() ?? 'Could not update quantity.',
            CartAction.update,
            isError: true),
      ));
      return;
    }

    // trust the server quantity
    final list = [...cur.items];
    if (i2 >= 0 && data.quantity != null) {
      list[i2] = list[i2].withQuantity(data.quantity!);
    }
    emit(cur.copyWith(items: list, cartTotal: _sum(list), busyIds: busy));
  }

  // ---------------- REMOVE ----------------
  Future<void> _onRemove(
      RemoveCartItemEvent e, Emitter<CartState> emit) async {
    final s = state;
    if (s is! CartLoadedState) return;
    if (s.busyIds.contains(e.cartItemId)) return;

    final idx = s.items.indexWhere((i) => i.cartItemId == e.cartItemId);
    if (idx < 0) return;
    final old = s.items[idx];

    // optimistic
    final left = s.items.where((i) => i.cartItemId != e.cartItemId).toList();
    emit(s.copyWith(
      items: left,
      totalItems: left.length,
      cartTotal: _sum(left),
      busyIds: {...s.busyIds, e.cartItemId},
    ));

    final res = await _provider.removeFromCartProvider(cartItemId: e.cartItemId);
    final data = res.payload<CartActionResponse>();

    final cur = _loaded;
    final busy = {...cur.busyIds}..remove(e.cartItemId);

    if (data == null) {
      if (_sessionEnded(emit)) return;
      // put the line back where it was
      final back = [...cur.items];
      back.insert(idx.clamp(0, back.length), old);
      emit(cur.copyWith(
        items: back,
        totalItems: back.length,
        cartTotal: _sum(back),
        busyIds: busy,
        message: _msg(res.errorText() ?? 'Could not remove item.',
            CartAction.remove,
            isError: true),
      ));
      return;
    }

    emit(cur.copyWith(
      busyIds: busy,
      message: _msg(
          data.message.isNotEmpty ? data.message : 'Removed from cart.',
          CartAction.remove),
    ));
  }
}