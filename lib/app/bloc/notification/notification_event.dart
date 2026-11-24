abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();
}

/// Called when the screen is closed -> clears the red badge.
class MarkNotificationsSeenEvent extends NotificationEvent {
  const MarkNotificationsSeenEvent();
}