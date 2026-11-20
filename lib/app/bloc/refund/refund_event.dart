abstract class RefundEvent {
  const RefundEvent();
}

/// First load - shows a loader.
class LoadRefundPolicyEvent extends RefundEvent {
  const LoadRefundPolicyEvent();
}

/// Pull-to-refresh - keeps the text on screen while reloading.
class RefreshRefundPolicyEvent extends RefundEvent {
  const RefreshRefundPolicyEvent();
}