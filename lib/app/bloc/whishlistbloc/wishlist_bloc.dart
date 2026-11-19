
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/whishlistprovider.dart';
import '../../core/utils/object_factory.dart';
import '../../data/models/statemodel.dart';
import '../../data/models/whishlistmodel.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  static const int _perPage = 10;

  final WishlistProvider _provider;
  int _page = 1;
  int _msgSeq = 0;

  /// Products with a request in flight (ignores double taps).
  final Set<int> _busy = {};

  WishlistBloc({WishlistProvider? provider})
      : _provider = provider ?? WishlistProvider(),
        super(const WishlistInitialState()) {
    on<LoadWishlistEvent>(_onLoad);
    on<RefreshWishlistEvent>(_onRefresh);
    on<LoadMoreWishlistEvent>(_onLoadMore);
    on<ToggleWishlistEvent>(_onToggle);
    on<RemoveFromWishlistEvent>(_onRemove);
    on<ResetWishlistEvent>((e, emit) {
      _page = 1;
      _busy.clear();
      emit(const WishlistInitialState());
    });
  }

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  /// A 401 clears the session (DioErrorHandler). When a request ends and the
  /// user is no longer logged in, drop the list and show the login prompt.
  bool _sessionEnded(Emitter<WishlistState> emit) {
    if (_loggedIn) return false;
    _page = 1;
    emit(const WishlistErrorState(
        errorMessage: 'Session expired. Please login again.'));
    return true;
  }

  WishlistMessage _msg(String text,
      {bool isError = false, int? productId, bool fromScreen = false}) =>
      WishlistMessage(
        seq: ++_msgSeq,
        text: text,
        isError: isError,
        productId: productId,
        fromWishlistScreen: fromScreen,
      );

  // ---------------- LOAD ----------------
  Future<void> _onLoad(
      LoadWishlistEvent e, Emitter<WishlistState> emit) async {
    if (!_loggedIn) {
      emit(const WishlistErrorState(
          errorMessage: 'Please login to view your wishlist.'));
      return;
    }
    emit(const WishlistLoadingState());
    await _fetchFirstPage(emit, showErrorState: true);
  }

  Future<void> _onRefresh(
      RefreshWishlistEvent e, Emitter<WishlistState> emit) async {
    if (!_loggedIn) {
      emit(const WishlistErrorState(
          errorMessage: 'Please login to view your wishlist.'));
      return;
    }
    await _fetchFirstPage(emit, showErrorState: state is! WishlistLoadedState);
  }

  Future<void> _fetchFirstPage(Emitter<WishlistState> emit,
      {required bool showErrorState}) async {
    try {
      final res = await _provider.wishlistProvider(page: 1, perPage: _perPage);
      final data = res.payload<WishlistResponse>();
      if (data == null) {
        if (_sessionEnded(emit)) return;
        if (showErrorState) {
          emit(WishlistErrorState(
              errorMessage: res.errorText() ?? 'Failed to load wishlist.'));
        }
        return;
      }
      _page = 1;
      emit(WishlistLoadedState(
        items: data.items,
        ids: data.items.map((p) => p.id).toSet(),
        hasMore: data.items.length >= _perPage,
      ));
    } catch (_) {
      if (showErrorState) {
        emit(const WishlistErrorState(
            errorMessage: 'Something went wrong. Please try again.'));
      }
    }
  }

  // ---------------- PAGINATION ----------------
  Future<void> _onLoadMore(
      LoadMoreWishlistEvent e, Emitter<WishlistState> emit) async {
    final s = state;
    if (s is! WishlistLoadedState || !s.hasMore || s.isLoadingMore) return;

    emit(s.copyWith(isLoadingMore: true));
    final res =
    await _provider.wishlistProvider(page: _page + 1, perPage: _perPage);
    final data = res.payload<WishlistResponse>();

    // state may have changed while waiting (e.g. an item was removed)
    final cur = state;
    if (cur is! WishlistLoadedState) return;

    if (data == null) {
      if (_sessionEnded(emit)) return;
      emit(cur.copyWith(isLoadingMore: false));
      return;
    }
    _page++;
    final known = cur.items.map((p) => p.id).toSet();
    final fresh = data.items.where((p) => !known.contains(p.id)).toList();
    emit(cur.copyWith(
      items: [...cur.items, ...fresh],
      ids: {...cur.ids, ...fresh.map((p) => p.id)},
      hasMore: data.items.length >= _perPage,
      isLoadingMore: false,
    ));
  }

  // ---------------- TOGGLE (heart button) ----------------
  Future<void> _onToggle(
      ToggleWishlistEvent e, Emitter<WishlistState> emit) async {
    if (!_loggedIn) {
      _emitMessage(emit, 'Please login to use your wishlist.',
          isError: true, productId: e.productId);
      return;
    }
    if (_busy.contains(e.productId)) return;
    _busy.add(e.productId);

    try {
      // Make sure we know what is already wishlisted (e.g. app just opened).
      if (state is! WishlistLoadedState) {
        await _fetchFirstPage(emit, showErrorState: false);
      }
      final before = state is WishlistLoadedState
          ? state as WishlistLoadedState
          : const WishlistLoadedState(items: [], ids: {});

      final isIn = before.ids.contains(e.productId);
      if (isIn) {
        await _removeInternal(e.productId, emit, before);
      } else {
        await _addInternal(e.productId, e.item, emit, before);
      }
    } finally {
      _busy.remove(e.productId);
    }
  }

  Future<void> _addInternal(int id, WishlistItemModel? item,
      Emitter<WishlistState> emit, WishlistLoadedState before) async {
    // optimistic: heart turns red immediately
    emit(before.copyWith(
      ids: {...before.ids, id},
      items: item != null ? [item, ...before.items] : before.items,
    ));

    final res = await _provider.addToWishlistProvider(productId: id);
    final data = res.payload<WishlistActionResponse>();

    if (data == null) {
      if (_sessionEnded(emit)) return;
      // revert
      emit(before.copyWith(
          message: _msg(res.errorText() ?? 'Could not add to wishlist.',
              isError: true, productId: id)));
      return;
    }

    if (item == null) {
      // we did not have the product details -> pull the real list
      await _fetchFirstPage(emit, showErrorState: false);
    }
    _emitMessage(emit,
        data.message.isNotEmpty ? data.message : 'Added to wishlist.',
        productId: id);
  }

  Future<void> _removeInternal(
      int id, Emitter<WishlistState> emit, WishlistLoadedState before,
      {bool fromScreen = false}) async {
    // optimistic
    emit(before.copyWith(
      ids: {...before.ids}..remove(id),
      items: before.items.where((p) => p.id != id).toList(),
    ));

    final res = await _provider.removeFromWishlistProvider(productId: id);
    final data = res.payload<WishlistActionResponse>();

    if (data == null) {
      if (_sessionEnded(emit)) return;
      // revert
      emit(before.copyWith(
          message: _msg(res.errorText() ?? 'Could not remove from wishlist.',
              isError: true, productId: id, fromScreen: fromScreen)));
      return;
    }
    _emitMessage(emit,
        data.message.isNotEmpty ? data.message : 'Removed from wishlist.',
        productId: id, fromScreen: fromScreen);
  }

  // ---------------- REMOVE (wishlist screen) ----------------
  Future<void> _onRemove(
      RemoveFromWishlistEvent e, Emitter<WishlistState> emit) async {
    final s = state;
    if (s is! WishlistLoadedState || !s.ids.contains(e.productId)) return;
    if (_busy.contains(e.productId)) return;
    _busy.add(e.productId);
    try {
      await _removeInternal(e.productId, emit, s, fromScreen: true);
    } finally {
      _busy.remove(e.productId);
    }
  }

  void _emitMessage(Emitter<WishlistState> emit, String text,
      {bool isError = false, int? productId, bool fromScreen = false}) {
    final s = state;
    final base = s is WishlistLoadedState
        ? s
        : const WishlistLoadedState(items: [], ids: {});
    emit(base.copyWith(
        message: _msg(text,
            isError: isError, productId: productId, fromScreen: fromScreen)));
  }
}