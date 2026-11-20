abstract class CancellationEvent {
  const CancellationEvent();
}

/// First load - shows a loader.
class LoadCancellationPolicyEvent extends CancellationEvent {
  const LoadCancellationPolicyEvent();
}

/// Pull-to-refresh - keeps the text on screen while reloading.
class RefreshCancellationPolicyEvent extends CancellationEvent {
  const RefreshCancellationPolicyEvent();
}