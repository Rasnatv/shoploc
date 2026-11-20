// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../apiprovider/recentviewprovider.dart';
// import '../../data/models/recentviewmodel.dart';
// import '../../data/models/statemodel.dart';
// import 'recentview_event.dart';
// import 'recentview_state.dart';
//
// class RecentViewBloc extends Bloc<RecentViewEvent, RecentViewState> {
//   final RecentViewProvider _provider;
//
//   RecentViewBloc({RecentViewProvider? provider})
//       : _provider = provider ?? RecentViewProvider(),
//         super(const RecentViewInitialState()) {
//     on<LoadRecentViewsEvent>((e, emit) async {
//       emit(const RecentViewLoadingState());
//       await _fetch(emit);
//     });
//     on<RefreshRecentViewsEvent>((e, emit) => _fetch(emit));
//     on<SaveRecentViewEvent>(_onSave);
//   }
//
//   Future<void> _fetch(Emitter<RecentViewState> emit) async {
//     try {
//       final res = await _provider.topRecentViewsProvider();
//       final data = res.payload<RecentViewsResponse>();
//       if (data == null) {
//         emit(RecentViewErrorState(
//             errorMessage: res.errorText() ?? 'Failed to load recent views.'));
//         return;
//       }
//       emit(RecentViewLoadedState(products: data.products));
//     } catch (_) {
//       emit(const RecentViewErrorState(
//           errorMessage: 'Something went wrong. Please try again.'));
//     }
//   }
//
//   /// Fire-and-forget: a failed save must never disturb the UI.
//   Future<void> _onSave(
//       SaveRecentViewEvent event, Emitter<RecentViewState> emit) async {
//     await _provider.saveRecentViewProvider(productId: event.productId);
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/object_factory.dart';
import '../../apiprovider/recentviewprovider.dart';
import '../../data/models/recentviewmodel.dart';
import '../../data/models/statemodel.dart';
import 'recentview_event.dart';
import 'recentview_state.dart';

class RecentViewBloc extends Bloc<RecentViewEvent, RecentViewState> {
  final RecentViewProvider _provider;

  RecentViewBloc({RecentViewProvider? provider})
      : _provider = provider ?? RecentViewProvider(),
        super(const RecentViewInitialState()) {
    on<LoadRecentViewsEvent>((e, emit) async {
      // Guest user: no token -> do NOT call the API (it would return 401)
      if (!_hasToken) {
        emit(const RecentViewInitialState());
        return;
      }
      emit(const RecentViewLoadingState());
      await _fetch(emit);
    });
    on<RefreshRecentViewsEvent>((e, emit) => _fetch(emit));
    on<SaveRecentViewEvent>(_onSave);
  }

  bool get _hasToken => ObjectFactory().prefs.hasAuthToken;

  Future<void> _fetch(Emitter<RecentViewState> emit) async {
    // Guest user: hide the section, no API call
    if (!_hasToken) {
      emit(const RecentViewInitialState());
      return;
    }
    try {
      final res = await _provider.topRecentViewsProvider();
      final data = res.payload<RecentViewsResponse>();
      if (data == null) {
        emit(RecentViewErrorState(
            errorMessage: res.errorText() ?? 'Failed to load recent views.'));
        return;
      }
      emit(RecentViewLoadedState(products: data.products));
    } catch (_) {
      emit(const RecentViewErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  /// Fire-and-forget: a failed save must never disturb the UI.
  Future<void> _onSave(
      SaveRecentViewEvent event, Emitter<RecentViewState> emit) async {
    if (!_hasToken) return; // guest: nothing to save
    await _provider.saveRecentViewProvider(productId: event.productId);
  }
}