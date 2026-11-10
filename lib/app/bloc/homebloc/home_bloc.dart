import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/product_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LocalStorageService _storageService;

  HomeBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<HomeState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 350));

      final allProducts = ShoplocDummyData.products;
      final banners = ShoplocDummyData.banners;
      final categories = ShoplocDummyData.categories;

      final newArrivals = allProducts.where((p) => p.isNewArrival).toList();
      final trending = allProducts.where((p) => p.isTrending).toList();
      final bestSellers = allProducts.where((p) => p.isBestSeller).toList();
      final featured = allProducts.where((p) => p.isFeatured).toList();
      final specialOffers = allProducts.where((p) => p.discountPercent >= 30).toList();

      // Recently viewed from storage
      final recentIds = _storageService.getRecentlyViewedIds();
      final List<ProductModel> recentlyViewed = [];
      for (final id in recentIds) {
        final match = allProducts.where((p) => p.id == id).toList();
        if (match.isNotEmpty) {
          recentlyViewed.add(match.first);
        }
      }
      if (recentlyViewed.isEmpty) {
        recentlyViewed.addAll(allProducts.take(3));
      }

      emit(HomeLoadedState(
        banners: banners,
        categories: categories,
        newArrivals: newArrivals.isNotEmpty ? newArrivals : allProducts.take(4).toList(),
        trendingProducts: trending.isNotEmpty ? trending : allProducts.skip(2).take(4).toList(),
        bestSellers: bestSellers.isNotEmpty ? bestSellers : allProducts.take(4).toList(),
        featuredProducts: featured.isNotEmpty ? featured : allProducts.take(4).toList(),
        specialOffers: specialOffers.isNotEmpty ? specialOffers : allProducts.take(4).toList(),
        recentlyViewed: recentlyViewed,
      ));
    } catch (e) {
      emit(HomeErrorState(errorMessage: e.toString()));
    }
  }
}

