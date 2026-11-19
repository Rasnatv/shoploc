
import '../../data/models/homemodel.dart';

abstract class RecentViewState {
  const RecentViewState();
}

class RecentViewInitialState extends RecentViewState {
  const RecentViewInitialState();
}

class RecentViewLoadingState extends RecentViewState {
  const RecentViewLoadingState();
}

class RecentViewLoadedState extends RecentViewState {
  final List<HomeProductModel> products;
  const RecentViewLoadedState({required this.products});
}

class RecentViewErrorState extends RecentViewState {
  final String errorMessage;
  const RecentViewErrorState({required this.errorMessage});
}