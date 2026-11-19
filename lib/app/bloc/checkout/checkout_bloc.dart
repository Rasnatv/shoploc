import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/checkoutprovider.dart';
import '../../core/utils/object_factory.dart';
import '../../data/models/checkoutmodel.dart';
import '../../data/models/statemodel.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutProvider _provider;
  int _msgSeq = 0;

  CheckoutBloc({CheckoutProvider? provider})
      : _provider = provider ?? CheckoutProvider(),
        super(const CheckoutInitialState()) {
    on<LoadCheckoutEvent>(_onLoad);
    on<RefreshCheckoutEvent>(_onRefresh);
    on<ResetCheckoutEvent>((e, emit) => emit(const CheckoutInitialState()));
  }

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  /// A 401 clears the session (DioErrorHandler). When a request ends and the
  /// user is no longer logged in, show the login prompt.
  bool _sessionEnded(Emitter<CheckoutState> emit) {
    if (_loggedIn) return false;
    emit(const CheckoutErrorState(
        errorMessage: 'Session expired. Please login again.'));
    return true;
  }

  Future<void> _onLoad(LoadCheckoutEvent e, Emitter<CheckoutState> emit) async {
    if (!_loggedIn) {
      emit(const CheckoutErrorState(errorMessage: 'Please login to checkout.'));
      return;
    }
    emit(const CheckoutLoadingState());
    await _fetch(emit, showErrorState: true);
  }

  Future<void> _onRefresh(
      RefreshCheckoutEvent e, Emitter<CheckoutState> emit) async {
    if (!_loggedIn) {
      emit(const CheckoutErrorState(errorMessage: 'Please login to checkout.'));
      return;
    }
    await _fetch(emit, showErrorState: state is! CheckoutLoadedState);
  }

  /// Always emits something, so no spinner can wait forever.
  Future<void> _fetch(Emitter<CheckoutState> emit,
      {required bool showErrorState}) async {
    try {
      // both requests run at the same time
      final previewF = _provider.orderPreviewProvider();
      final summaryF = _provider.checkoutSummaryProvider();
      final previewRes = await previewF;
      final summaryRes = await summaryF;

      final preview = previewRes.payload<OrderPreviewResponse>();
      final summary = summaryRes.payload<CheckoutSummaryResponse>();

      if (preview == null || summary == null) {
        if (_sessionEnded(emit)) return;
        _fail(
            emit,
            (preview == null ? previewRes.errorText() : summaryRes.errorText()) ??
                'Failed to load checkout.',
            showErrorState);
        return;
      }
      emit(CheckoutLoadedState(preview: preview, summary: summary));
    } catch (_) {
      if (_sessionEnded(emit)) return;
      _fail(emit, 'Something went wrong. Please try again.', showErrorState);
    }
  }

  void _fail(Emitter<CheckoutState> emit, String text, bool showErrorState) {
    final s = state;
    if (showErrorState || s is! CheckoutLoadedState) {
      emit(CheckoutErrorState(errorMessage: text));
    } else {
      // keep what is on screen, just tell the user
      emit(CheckoutLoadedState(
        preview: s.preview,
        summary: s.summary,
        message: CheckoutMessage(seq: ++_msgSeq, text: text),
      ));
    }
  }
}
