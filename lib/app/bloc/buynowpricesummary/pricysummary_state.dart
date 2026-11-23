import '../../data/models/buynowproductsummarymodel.dart';

abstract class PriceSummaryState {
  const PriceSummaryState();
}

class PriceSummaryInitialState extends PriceSummaryState {
  const PriceSummaryInitialState();
}

/// First load only (nothing to show yet).
class PriceSummaryLoadingState extends PriceSummaryState {
  const PriceSummaryLoadingState();
}

/// [quantity] is the quantity the numbers belong to.
/// [isRefreshing] is true while a new quantity is being priced: the old
/// numbers stay on screen (dimmed) so the card does not flicker.
class PriceSummaryLoadedState extends PriceSummaryState {
  final PriceSummaryModel summary;
  final int quantity;
  final bool isRefreshing;

  const PriceSummaryLoadedState({
    required this.summary,
    required this.quantity,
    this.isRefreshing = false,
  });

  PriceSummaryLoadedState copyWith({
    PriceSummaryModel? summary,
    int? quantity,
    bool? isRefreshing,
  }) =>
      PriceSummaryLoadedState(
        summary: summary ?? this.summary,
        quantity: quantity ?? this.quantity,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );
}

class PriceSummaryErrorState extends PriceSummaryState {
  final String errorMessage;
  const PriceSummaryErrorState({required this.errorMessage});
}