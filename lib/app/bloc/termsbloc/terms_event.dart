abstract class TermsEvent {
  const TermsEvent();
}

/// First load - shows a loader.
class LoadTermsEvent extends TermsEvent {
  const LoadTermsEvent();
}

/// Pull-to-refresh - keeps the text on screen while reloading.
class RefreshTermsEvent extends TermsEvent {
  const RefreshTermsEvent();
}