
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/homeprovider.dart';
import '../../data/models/apibannermodel.dart';
import '../../data/models/homemodel.dart';
import '../../data/models/productlistmodel.dart';
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