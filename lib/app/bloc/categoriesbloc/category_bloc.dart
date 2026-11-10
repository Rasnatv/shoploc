import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(const CategoryInitialState()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SelectCategoryEvent>(_onSelectCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoadingState());
    await Future.delayed(const Duration(milliseconds: 250));
    final categories = ShoplocDummyData.categories;
    emit(CategoryLoadedState(categories: categories));
  }

  void _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<CategoryState> emit,
  ) {
    if (state is CategoryLoadedState) {
      final current = state as CategoryLoadedState;
      emit(CategoryLoadedState(
        categories: current.categories,
        selectedCategoryId: event.categoryId,
      ));
    }
  }
}

