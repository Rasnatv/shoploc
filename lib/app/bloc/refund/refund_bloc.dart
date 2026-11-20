import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/refund/refund_event.dart';
import 'package:shoploc/app/bloc/refund/refund_state.dart';
import '../../apiprovider/refundpolicyprovider.dart';
import '../../data/models/refundpolicymodel.dart';
import '../../data/models/statemodel.dart';


class RefundBloc extends Bloc<RefundEvent, RefundState> {
  final RefundPolicyProvider _provider;

  RefundBloc({RefundPolicyProvider? provider})
      : _provider = provider ?? RefundPolicyProvider(),
        super(const RefundInitialState()) {
    on<LoadRefundPolicyEvent>((e, emit) async {
      emit(const RefundLoadingState());
      await _fetch(emit, showError: true);
    });
    on<RefreshRefundPolicyEvent>((e, emit) async {
      // On refresh keep the old text if the call fails.
      await _fetch(emit, showError: state is! RefundLoadedState);
    });
  }

  Future<void> _fetch(Emitter<RefundState> emit,
      {required bool showError}) async {
    try {
      final res = await _provider.refundPolicyProvider();
      final data = res.payload<RefundPolicyResponse>();
      if (data != null) {
        emit(RefundLoadedState(policy: data));
      } else if (showError) {
        emit(RefundErrorState(
            errorMessage: res.errorText() ?? 'Failed to load refund policy.'));
      }
    } catch (_) {
      if (showError) {
        emit(const RefundErrorState(
            errorMessage: 'Something went wrong. Please try again.'));
      }
    }
  }
}