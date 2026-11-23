abstract class PriceSummaryEvent {
  const PriceSummaryEvent();
}

/// Loads the price for [quantity] of [productId].
/// Call it once when the screen opens and again on every quantity change.
class LoadPriceSummaryEvent extends PriceSummaryEvent {
  final int productId;
  final int quantity;
  const LoadPriceSummaryEvent({required this.productId, required this.quantity});
}