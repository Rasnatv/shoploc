// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../../core/storage/local_storage_service.dart';
// // import '../../data/dummy_data/shoploc_dummy_data.dart';
// // import '../../data/models/product_model.dart';
// // import 'home_event.dart';
// // import 'home_state.dart';
// //
// // class HomeBloc extends Bloc<HomeEvent, HomeState> {
// //   final LocalStorageService _storageService;
// //
// //   HomeBloc({required LocalStorageService storageService})
// //       : _storageService = storageService,
// //         super(const HomeInitialState()) {
// //     on<LoadHomeDataEvent>(_onLoadHomeData);
// //     on<RefreshHomeDataEvent>(_onRefreshHomeData);
// //   }
// //
// //   Future<void> _onLoadHomeData(
// //     LoadHomeDataEvent event,
// //     Emitter<HomeState> emit,
// //   ) async {
// //     emit(const HomeLoadingState());
// //     await _fetchAndEmit(emit);
// //   }
// //
// //   Future<void> _onRefreshHomeData(
// //     RefreshHomeDataEvent event,
// //     Emitter<HomeState> emit,
// //   ) async {
// //     await _fetchAndEmit(emit);
// //   }
// //
// //   Future<void> _fetchAndEmit(Emitter<HomeState> emit) async {
// //     try {
// //       await Future.delayed(const Duration(milliseconds: 350));
// //
// //       final allProducts = ShoplocDummyData.products;
// //       final banners = ShoplocDummyData.banners;
// //       final categories = ShoplocDummyData.categories;
// //
// //       final newArrivals = allProducts.where((p) => p.isNewArrival).toList();
// //       final trending = allProducts.where((p) => p.isTrending).toList();
// //       final bestSellers = allProducts.where((p) => p.isBestSeller).toList();
// //       final featured = allProducts.where((p) => p.isFeatured).toList();
// //       final specialOffers = allProducts.where((p) => p.discountPercent >= 30).toList();
// //
// //       // Recently viewed from storage
// //       final recentIds = _storageService.getRecentlyViewedIds();
// //       final List<ProductModel> recentlyViewed = [];
// //       for (final id in recentIds) {
// //         final match = allProducts.where((p) => p.id == id).toList();
// //         if (match.isNotEmpty) {
// //           recentlyViewed.add(match.first);
// //         }
// //       }
// //       if (recentlyViewed.isEmpty) {
// //         recentlyViewed.addAll(allProducts.take(3));
// //       }
// //
// //       emit(HomeLoadedState(
// //         banners: banners,
// //         categories: categories,
// //         newArrivals: newArrivals.isNotEmpty ? newArrivals : allProducts.take(4).toList(),
// //         trendingProducts: trending.isNotEmpty ? trending : allProducts.skip(2).take(4).toList(),
// //         bestSellers: bestSellers.isNotEmpty ? bestSellers : allProducts.take(4).toList(),
// //         featuredProducts: featured.isNotEmpty ? featured : allProducts.take(4).toList(),
// //         specialOffers: specialOffers.isNotEmpty ? specialOffers : allProducts.take(4).toList(),
// //         recentlyViewed: recentlyViewed,
// //       ));
// //     } catch (e) {
// //       emit(HomeErrorState(errorMessage: e.toString()));
// //     }
// //   }
// // }
// //
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../apiprovider/homeprovider.dart';
//
// import '../../data/models/models/homemodel.dart';
// import '../../data/models/models/productlistmodel.dart';
// import '../../data/models/statemodel.dart';
// import 'home_event.dart';
// import 'home_state.dart';
//
// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   final HomeProvider _provider;
//
//   HomeBloc({HomeProvider? provider})
//       : _provider = provider ?? HomeProvider(),
//         super(const HomeInitialState()) {
//     on<LoadHomeDataEvent>(_onLoad);
//     on<RefreshHomeDataEvent>(_onRefresh);
//   }
//
//   Future<void> _onLoad(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
//     emit(const HomeLoadingState());
//     await _fetchAndEmit(emit);
//   }
//
//   Future<void> _onRefresh(RefreshHomeDataEvent event, Emitter<HomeState> emit) async {
//     await _fetchAndEmit(emit);
//   }
//
//   Future<void> _fetchAndEmit(Emitter<HomeState> emit) async {
//     try {
//       // All three calls run in parallel
//       final results = await Future.wait<Object?>([
//         _provider.categoriesProvider(),
//         _provider.homeHighlightsProvider(),
//         _provider.homeBestSellersProvider(),
//       ]);
//
//       final categories = results[0].payload<CategoriesResponse>();
//       final highlights = results[1].payload<HomeHighlightsResponse>();
//       final bestSellers = results[2].payload<BestSellersResponse>();
//
//       // Highlights are essential; categories / best sellers failing alone
//       // shouldn't blank the screen.
//       if (highlights == null) {
//         emit(HomeErrorState(
//           errorMessage: results[1].errorText() ?? 'Failed to load home data.',
//         ));
//         return;
//       }
//
//       emit(HomeLoadedState(
//         categories: categories?.categories ?? const [],
//         newArrivals: highlights.newArrivals,
//         trendingProducts: highlights.trending,
//         bestSellers: bestSellers?.products ?? const [],
//       ));
//     } catch (_) {
//       emit(const HomeErrorState(
//           errorMessage: 'Something went wrong. Please try again.'));
//     }
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/homeprovider.dart';
import '../../data/models/models/apibannermodel.dart';
import '../../data/models/models/homemodel.dart';
import '../../data/models/models/productlistmodel.dart';
import '../../data/models/statemodel.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeProvider _provider;

  HomeBloc({HomeProvider? provider})
      : _provider = provider ?? HomeProvider(),
        super(const HomeInitialState()) {
    on<LoadHomeDataEvent>(_onLoad);
    on<RefreshHomeDataEvent>(_onRefresh);
  }

  Future<void> _onLoad(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoadingState());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(RefreshHomeDataEvent event, Emitter<HomeState> emit) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<HomeState> emit) async {
    try {
      // All four calls run in parallel
      final results = await Future.wait<Object?>([
        _provider.bannersProvider(),
        _provider.categoriesProvider(),
        _provider.homeHighlightsProvider(),
        _provider.homeBestSellersProvider(),
      ]);

      final banners = results[0].payload<BannersResponse>();
      final categories = results[1].payload<CategoriesResponse>();
      final highlights = results[2].payload<HomeHighlightsResponse>();
      final bestSellers = results[3].payload<BestSellersResponse>();

      // Highlights are essential; banners / categories / best sellers
      // failing alone shouldn't blank the screen.
      if (highlights == null) {
        emit(HomeErrorState(
          errorMessage: results[2].errorText() ?? 'Failed to load home data.',
        ));
        return;
      }

      emit(HomeLoadedState(
        banners: banners?.banners ?? const [],
        categories: categories?.categories ?? const [],
        newArrivals: highlights.newArrivals,
        trendingProducts: highlights.trending,
        bestSellers: bestSellers?.products ?? const [],
      ));
    } catch (_) {
      emit(const HomeErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}