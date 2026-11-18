import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/productdetailbloc/productdetail_event.dart';
import 'package:shoploc/app/bloc/productdetailbloc/productdetail_state.dart';
import '../../apiprovider/productdetailprovider.dart';
import '../../data/models/models/productdetailmodel.dart';
import '../../data/models/statemodel.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final ProductDetailsProvider _provider;

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
    } catch (_) {
      emit(const ProductDetailsErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}