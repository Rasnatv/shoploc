import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/product_model.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final LocalStorageService _storageService;

  WishlistBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const WishlistInitialState()) {
    on<LoadWishlistEvent>(_onLoadWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<RemoveFromWishlistEvent>(_onRemoveFromWishlist);
    on<ClearWishlistEvent>(_onClearWishlist);
  }

  Future<void> _onLoadWishlist(
    LoadWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    emit(const WishlistLoadingState());
    final ids = _storageService.getWishlistIds();
    final all = ShoplocDummyData.products;

    final List<ProductModel> items = [];
    for (final id in ids) {
      final matches = all.where((p) => p.id == id).toList();
      if (matches.isNotEmpty) {
        items.add(matches.first);
      }
    }

    emit(WishlistLoadedState(items: items));
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final currentItems = state is WishlistLoadedState
        ? List<ProductModel>.from((state as WishlistLoadedState).items)
        : <ProductModel>[];

    final index = currentItems.indexWhere((p) => p.id == event.product.id);
    if (index >= 0) {
      currentItems.removeAt(index);
    } else {
      currentItems.insert(0, event.product);
    }

    await _storageService.saveWishlistIds(currentItems.map((p) => p.id).toList());
    emit(WishlistLoadedState(items: currentItems));
  }

  Future<void> _onRemoveFromWishlist(
    RemoveFromWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    if (state is WishlistLoadedState) {
      final current = List<ProductModel>.from((state as WishlistLoadedState).items);
      current.removeWhere((p) => p.id == event.productId);
      await _storageService.saveWishlistIds(current.map((p) => p.id).toList());
      emit(WishlistLoadedState(items: current));
    }
  }

  Future<void> _onClearWishlist(
    ClearWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    await _storageService.saveWishlistIds([]);
    emit(const WishlistLoadedState(items: []));
  }
}

