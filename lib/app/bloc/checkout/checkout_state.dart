import '../../data/models/checkoutmodel.dart';

abstract class CheckoutState {
  const CheckoutState();
}

class CheckoutInitialState extends CheckoutState {
  const CheckoutInitialState();
}

class CheckoutLoadingState extends CheckoutState {
  const CheckoutLoadingState();
}

/// One-shot message for a snackbar (a refresh that failed).
class CheckoutMessage {
  final int seq; // changes on every message so listeners always fire
  final String text;
  final bool isError;
  const CheckoutMessage({required this.seq, required this.text, this.isError = true});
}

class CheckoutLoadedState extends CheckoutState {
  final OrderPreviewResponse preview;
  final CheckoutSummaryResponse summary;
  final CheckoutMessage? message;

  const CheckoutLoadedState({
    required this.preview,
    required this.summary,
    this.message,
  });

  bool get isEmpty => preview.isEmpty;
}

class CheckoutErrorState extends CheckoutState {
  final String errorMessage;
  const CheckoutErrorState({required this.errorMessage});
}
