abstract class PrivacyEvent {
  const PrivacyEvent();
}

/// First load - shows a loader.
class LoadPrivacyPolicyEvent extends PrivacyEvent {
  const LoadPrivacyPolicyEvent();
}

/// Pull-to-refresh - keeps the text on screen while reloading.
class RefreshPrivacyPolicyEvent extends PrivacyEvent {
  const RefreshPrivacyPolicyEvent();
}