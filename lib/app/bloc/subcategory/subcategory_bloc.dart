import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/subcategory/subcategory_event.dart';
import 'package:shoploc/app/bloc/subcategory/subcategory_state.dart';
import '../../apiprovider/subcategoryprovider.dart';
import '../../data/models/statemodel.dart';
import '../../data/models/subcategorymodel.dart';


class SubCategoryProductBloc
    extends Bloc<SubCategoryProductEvent, SubCategoryProductState> {
  final int subCategoryId;
  final SubCategoryProductProvider _provider;
  static const int perPage = 10;

  SubCategoryProductBloc({
    required this.subCategoryId,
    SubCategoryProductProvider? provider,
  })  : _provider = provider ?? SubCategoryProductProvider(),
        super(const SubCategoryProductInitialState()) {
    on<LoadSubCategoryProductsEvent>(_onLoad);
    on<LoadMoreSubCategoryProductsEvent>(_onLoadMore);
    on<RefreshSubCategoryProductsEvent>(_onRefresh);
  }

  Future<Object?> _call(int page) => _provider.subCategoryProductsProvider(
    subCategoryId: subCategoryId,
    page: page,
    perPage: perPage,
  );

  Future<void> _onLoad(LoadSubCategoryProductsEvent event,
      Emitter<SubCategoryProductState> emit) async {
    emit(const SubCategoryProductLoadingState());
    await _firstPage(emit);
  }

  Future<void> _onRefresh(RefreshSubCategoryProductsEvent event,
      Emitter<SubCategoryProductState> emit) async {
    await _firstPage(emit);
  }

  Future<void> _firstPage(Emitter<SubCategoryProductState> emit) async {
    try {
      final res = await _call(1);
      final data = res.payload<SubCategoryProductsResponse>();
      if (data == null) {
        emit(SubCategoryProductErrorState(
            errorMessage: res.errorText() ?? 'Failed to load products.'));
        return;
      }
      emit(SubCategoryProductLoadedState(
        products: data.products,
        page: 1,
        hasMore: data.products.length >= perPage,
      ));
    } catch (_) {
      emit(const SubCategoryProductErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLoadMore(LoadMoreSubCategoryProductsEvent event,
      Emitter<SubCategoryProductState> emit) async {
    final current = state;
    if (current is! SubCategoryProductLoadedState ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final res = await _call(nextPage);
      final data = res.payload<SubCategoryProductsResponse>();

      if (data == null) {
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