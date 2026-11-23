import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/buynowpricesummary/pricysummary_event.dart';
import 'package:shoploc/app/bloc/buynowpricesummary/pricysummary_state.dart';
import '../../apiprovider/price_summaryprovider.dart';
import '../../data/models/buynowproductsummarymodel.dart';
import '../../data/models/statemodel.dart';


class PriceSummaryBloc extends Bloc<PriceSummaryEvent, PriceSummaryState> {
  /// When the quantity changes, wait this long so quick +/- taps send
  /// only one request (the last one).
  static const Duration debounce = Duration(milliseconds: 350);

  final PriceSummaryProvider _provider;

  /// Number of the newest request. A finished request with an older number
  /// is dropped, so a slow old answer can never overwrite a newer one.
  int _seq = 0;

  PriceSummaryBloc({PriceSummaryProvider? provider})
      : _provider = provider ?? PriceSummaryProvider(),
        super(const PriceSummaryInitialState()) {
    on<LoadPriceSummaryEvent>(_onLoad);
  }

  Future<void> _onLoad(
      LoadPriceSummaryEvent e, Emitter<PriceSummaryState> emit) async {
    final seq = ++_seq;
    final current = state;

    if (current is PriceSummaryLoadedState) {
      // quantity change: keep old numbers visible, mark them as refreshing
      emit(current.copyWith(quantity: e.quantity, isRefreshing: true));
      await Future.delayed(debounce);
      if (seq != _seq || emit.isDone) return;
    } else {
      emit(const PriceSummaryLoadingState());
    }

    try {
      final res = await _provider.priceSummaryProvider(
          productId: e.productId, quantity: e.quantity);
      if (seq != _seq || emit.isDone) return; // stale response

      final data = res.payload<PriceSummaryResponse>();
      if (data == null) {
        emit(PriceSummaryErrorState(
            errorMessage: res.errorText() ?? 'Could not load price details.'));
        return;
      }
      emit(PriceSummaryLoadedState(
          summary: data.summary, quantity: e.quantity));
    } catch (_) {
      if (seq != _seq || emit.isDone) return;
      emit(const PriceSummaryErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}