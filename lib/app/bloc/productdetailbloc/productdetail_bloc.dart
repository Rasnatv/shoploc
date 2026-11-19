import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/productdetailbloc/productdetail_event.dart';
import 'package:shoploc/app/bloc/productdetailbloc/productdetail_state.dart';
import '../../apiprovider/productdetailprovider.dart';
import '../../apiprovider/recentviewprovider.dart';
import '../../data/models/productdetailmodel.dart';
import '../../data/models/statemodel.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final ProductDetailsProvider _provider;
  final RecentViewProvider _recentProvider = RecentViewProvider();

  ProductDetailsBloc({ProductDetailsProvider? provider})
      : _provider = provider ?? ProductDetailsProvider(),
        super(const ProductDetailsInitialState()) {
    on<LoadProductDetailsEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadProductDetailsEvent event,
      Emitter<ProductDetailsState> emit) async {
    emit(const ProductDetailsLoadingState());
    try {
      final res =
      await _provider.productDetailsProvider(productId: event.productId);
      final data = res.payload<ProductDetailsResponse>();
      final product = data?.product;
      if (product == null) {
        emit(ProductDetailsErrorState(
            errorMessage: res.errorText() ?? 'Failed to load product.'));
        return;
      }
      emit(ProductDetailsLoadedState(product: product));

      // Save to "Recently Viewed" (fire-and-forget; errors are ignored,
      // e.g. when the user is not logged in).
      _recentProvider.saveRecentViewProvider(productId: event.productId);
    } catch (_) {
      emit(const ProductDetailsErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}