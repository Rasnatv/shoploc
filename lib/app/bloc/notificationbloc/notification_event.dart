abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;
  const MarkNotificationAsReadEvent({required this.notificationId});
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}

class ClearAllNotificationsEvent extends NotificationEvent {
  const ClearAllNotificationsEvent();
}

