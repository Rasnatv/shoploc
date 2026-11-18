//
// import '../../data/models/banner_model.dart';
// import '../../data/models/category_model.dart';
// import '../../data/models/product_model.dart';
//
// abstract class HomeState {
//   const HomeState();
// }
//
// class HomeInitialState extends HomeState {
//   const HomeInitialState();
// }
//
// class HomeLoadingState extends HomeState {
//   const HomeLoadingState();
// }
//
// class HomeLoadedState extends HomeState {
//   final List<BannerModel> banners;
//   final List<CategoryModel> categories;
//   final List<ProductModel> newArrivals;
//   final List<ProductModel> trendingProducts;
//   final List<ProductModel> bestSellers;
//   final List<ProductModel> featuredProducts;
//   final List<ProductModel> specialOffers;
//   final List<ProductModel> recentlyViewed;
//
//   const HomeLoadedState({
//     required this.banners,
//     required this.categories,
//     required this.newArrivals,
//     required this.trendingProducts,
//     required this.bestSellers,
//     required this.featuredProducts,
//     required this.specialOffers,
//     required this.recentlyViewed,
//   });
// }
//
// class HomeErrorState extends HomeState {
//   final String errorMessage;
//   const HomeErrorState({required this.errorMessage});
// }
//
import '../../data/models/models/apibannermodel.dart';
import '../../data/models/models/homemodel.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  final List<BannerApiModel> banners;
  final List<CategoryApiModel> categories;
  final List<HomeProductModel> newArrivals;
  final List<HomeProductModel> trendingProducts;
  final List<HomeProductModel> bestSellers;

  const HomeLoadedState({
    required this.banners,
    required this.categories,
    required this.newArrivals,
    required this.trendingProducts,
    required this.bestSellers,
  });
}

class HomeErrorState extends HomeState {
  final String errorMessage;
  const HomeErrorState({required this.errorMessage});
}