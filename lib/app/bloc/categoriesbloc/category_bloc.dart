import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/homeprovider.dart';
import '../../data/models/models/homemodel.dart';
import '../../data/models/statemodel.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final HomeProvider _provider;

  CategoryBloc({HomeProvider? provider})
      : _provider = provider ?? HomeProvider(),
        super(const CategoryInitialState()) {
    on<LoadCategoriesEvent>(_onLoad);
    on<RefreshCategoriesEvent>(_onRefresh);
    on<SelectCategoryEvent>(_onSelect);
  }

  Future<void> _onLoad(
      LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoadingState());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      RefreshCategoriesEvent event, Emitter<CategoryState> emit) async {
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<CategoryState> emit) async {
    try {
      final previous = state;
      final res = await _provider.categoriesProvider();
      final data = res.payload<CategoriesResponse>();

      if (data == null) {
        emit(CategoryErrorState(
            errorMessage: res.errorText() ?? 'Failed to load categories.'));
        return;
      }

      final categories = data.categories;

      // keep the previous selection if it still exists, else pick the first
      int? selected =
      previous is CategoryLoadedState ? previous.selectedCategoryId : null;
      if (selected == null || !categories.any((c) => c.id == selected)) {
        selected = categories.isNotEmpty ? categories.first.id : null;
      }

      emit(CategoryLoadedState(
          categories: categories, selectedCategoryId: selected));
    } catch (_) {
      emit(const CategoryErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  void _onSelect(SelectCategoryEvent event, Emitter<CategoryState> emit) {
    final current = state;
    if (current is CategoryLoadedState) {
      emit(CategoryLoadedState(
        categories: current.categories,
        selectedCategoryId: event.categoryId,
      ));
    }
  }
}