import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/productlistbloc/productlist_event.dart';
import 'package:shoploc/app/bloc/productlistbloc/productlist_state.dart';
import '../../apiprovider/productlistprovider.dart';
import '../../core/utils/productlisttype.dart';
import '../../data/models/models/productlistmodel.dart';
import '../../data/models/statemodel.dart';


class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductListType type;
  final ProductListProvider _provider;
  static const int perPage = 10;

  ProductListBloc({required this.type, ProductListProvider? provider})
      : _provider = provider ?? ProductListProvider(),
        super(const ProductListInitialState()) {
    on<LoadProductListEvent>(_onLoad);
    on<LoadMoreProductListEvent>(_onLoadMore);
    on<RefreshProductListEvent>(_onRefresh);
  }

  Future<Object?> _call(int page) {
    switch (type) {
      case ProductListType.newArrivals:
        return _provider.newArrivalsProvider(page: page, perPage: perPage);
      case ProductListType.trending:
        return _provider.trendingProvider(page: page, perPage: perPage);
      case ProductListType.bestSellers:
        return _provider.bestSellersProvider(page: page, perPage: perPage);
    }
  }

  Future<void> _onLoad(
      LoadProductListEvent event, Emitter<ProductListState> emit) async {
    emit(const ProductListLoadingState());
    await _firstPage(emit);
  }

  Future<void> _onRefresh(
      RefreshProductListEvent event, Emitter<ProductListState> emit) async {
    await _firstPage(emit);
  }

  Future<void> _firstPage(Emitter<ProductListState> emit) async {
    try {
      final res = await _call(1);
      final data = res.payload<ProductListResponse>();
      if (data == null) {
        emit(ProductListErrorState(
            errorMessage: res.errorText() ?? 'Failed to load products.'));
        return;
      }
      emit(ProductListLoadedState(
        products: data.products,
        page: 1,
        hasMore: data.products.length >= perPage,
      ));
    } catch (_) {
      emit(const ProductListErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreProductListEvent event, Emitter<ProductListState> emit) async {
    final current = state;
    if (current is! ProductListLoadedState ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final res = await _call(nextPage);
      final data = res.payload<ProductListResponse>();

      if (data == null) {
        // keep what we have; user can scroll again to retry
        emit(current.copyWith(isLoadingMore: false));
        return;
      }

      // de-duplicate by id in case pages overlap
      final existing = current.products.map((p) => p.id).toSet();
      final fresh = data.products.where((p) => !existing.contains(p.id));

      emit(current.copyWith(
        products: [...current.products, ...fresh],
        page: nextPage,
        hasMore: data.products.length >= perPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}