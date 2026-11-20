import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/termsprovider.dart';
import '../../data/models/statemodel.dart';
import '../../data/models/termsmodel.dart';
import 'terms_event.dart';
import 'terms_state.dart';

class TermsBloc extends Bloc<TermsEvent, TermsState> {
  final TermsProvider _provider;

  TermsBloc({TermsProvider? provider})
      : _provider = provider ?? TermsProvider(),
        super(const TermsInitialState()) {
    on<LoadTermsEvent>((e, emit) async {
      emit(const TermsLoadingState());
      await _fetch(emit, showError: true);
    });
    on<RefreshTermsEvent>((e, emit) async {
      // On refresh keep the old text if the call fails.
      await _fetch(emit, showError: state is! TermsLoadedState);
    });
  }

  Future<void> _fetch(Emitter<TermsState> emit,
      {required bool showError}) async {
    try {
      final res = await _provider.termsProvider();
      final data = res.payload<TermsResponse>();
      if (data != null) {
        emit(TermsLoadedState(terms: data));
      } else if (showError) {
        emit(TermsErrorState(
            errorMessage:
            res.errorText() ?? 'Failed to load terms and conditions.'));
      }
    } catch (_) {
      if (showError) {
        emit(const TermsErrorState(
            errorMessage: 'Something went wrong. Please try again.'));
      }
    }
  }
}