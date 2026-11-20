import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/cancelationpolicyprovider.dart';
import '../../data/models/cancelationpolicymodel.dart';
import '../../data/models/statemodel.dart';
import 'cancelation_event.dart';
import 'cancelation_state.dart';

class CancellationBloc extends Bloc<CancellationEvent, CancellationState> {
  final CancellationPolicyProvider _provider;

  CancellationBloc({CancellationPolicyProvider? provider})
      : _provider = provider ?? CancellationPolicyProvider(),
        super(const CancellationInitialState()) {
    on<LoadCancellationPolicyEvent>((e, emit) async {
      emit(const CancellationLoadingState());
      await _fetch(emit, showError: true);
    });
    on<RefreshCancellationPolicyEvent>((e, emit) async {
      // On refresh keep the old text if the call fails.
      await _fetch(emit, showError: state is! CancellationLoadedState);
    });
  }

  Future<void> _fetch(Emitter<CancellationState> emit,
      {required bool showError}) async {
    try {
      final res = await _provider.cancellationPolicyProvider();
      final data = res.payload<CancellationPolicyResponse>();
      if (data != null) {
        emit(CancellationLoadedState(policy: data));
      } else if (showError) {
        emit(CancellationErrorState(
            errorMessage:
            res.errorText() ?? 'Failed to load cancellation policy.'));
      }
    } catch (_) {
      if (showError) {
        emit(const CancellationErrorState(
            errorMessage: 'Something went wrong. Please try again.'));
      }
    }
  }
}