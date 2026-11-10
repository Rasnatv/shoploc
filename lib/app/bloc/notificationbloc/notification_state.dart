
import '../../data/models/notification_model.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitialState extends NotificationState {
  const NotificationInitialState();
}

class NotificationLoadingState extends NotificationState {
  const NotificationLoadingState();
}

class NotificationLoadedState extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationLoadedState({required this.notifications});

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationErrorState extends NotificationState {
  final String errorMessage;
  const NotificationErrorState({required this.errorMessage});
}

