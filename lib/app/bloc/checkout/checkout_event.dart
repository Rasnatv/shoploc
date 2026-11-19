abstract class CheckoutEvent {
  const CheckoutEvent();
}

/// First load - shows a loader. Fetches /order/preview and /checkout/summary.
class LoadCheckoutEvent extends CheckoutEvent {
  const LoadCheckoutEvent();
}

/// Reload silently (pull-to-refresh) - keeps the page on screen.
class RefreshCheckoutEvent extends CheckoutEvent {
  const RefreshCheckoutEvent();
}

/// Local reset only (call on logout). Does NOT call the API.
class ResetCheckoutEvent extends CheckoutEvent {
  const ResetCheckoutEvent();
}
