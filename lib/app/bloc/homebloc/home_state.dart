
import '../../data/models/apibannermodel.dart';
import '../../data/models/homemodel.dart';


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