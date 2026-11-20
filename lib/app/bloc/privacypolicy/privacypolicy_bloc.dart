import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/bloc/privacypolicy/privacypolicy_event.dart';
import 'package:shoploc/app/bloc/privacypolicy/privacypolicy_state.dart';
import '../../apiprovider/privacypolicyprovider.dart';
import '../../data/models/privacypolicymodel.dart';
import '../../data/models/statemodel.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  final PrivacyPolicyProvider _provider;

  PrivacyBloc({PrivacyPolicyProvider? provider})
      : _provider = provider ?? PrivacyPolicyProvider(),
        super(const PrivacyInitialState()) {
    on<LoadPrivacyPolicyEvent>((e, emit) async {
      emit(const PrivacyLoadingState());
      await _fetch(emit, showError: true);
    });
    on<RefreshPrivacyPolicyEvent>((e, emit) async {
      await _fetch(emit, showError: state is! PrivacyLoadedState);
    });
  }

  Future<void> _fetch(Emitter<PrivacyState> emit,
      {required bool showError}) async {
    try {
      final res = await _provider.privacyPolicyProvider();
      final data = res.payload<PrivacyPolicyResponse>();
      if (data != null) {
        emit(PrivacyLoadedState(policy: data));
      } else if (showError) {
        emit(PrivacyErrorState(
            errorMessage: res.errorText() ?? 'Failed to load privacy policy.'));
      }
    } catch (_) {
      if (showError) {
        emit(const PrivacyErrorState(
            errorMessage: 'Something went wrong. Please try again.'));
      }
    }
  }
}